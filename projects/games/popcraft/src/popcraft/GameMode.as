package popcraft {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.threerings.util.KeyboardCodes;
import com.threerings.util.Log;
import com.threerings.util.RingBuffer;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.contrib.simplegame.resource.SoundResource;
import com.whirled.contrib.simplegame.util.*;
import com.whirled.game.OccupantChangedEvent;

import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.MouseEvent;

import popcraft.battle.*;
import popcraft.battle.view.*;
import popcraft.data.*;
import popcraft.net.*;
import popcraft.puzzle.*;
import popcraft.sp.*;
import popcraft.ui.*;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        // make sure we have a valid GameData object in the GameContext
        if (GameContext.isSinglePlayer && null != GameContext.spLevel.gameDataOverride) {
            GameContext.gameData = GameContext.spLevel.gameDataOverride;
        } else {
            // @TODO - remove this testing code
            var variants :Array = AppContext.gameVariants;
            var variant :GameVariantData = variants[0];
            GameContext.gameData = variant.gameDataOverride;
        }

        GameContext.gameMode = this;

        // create some layers
        _battleParent = new Sprite();
        this.modeSprite.addChild(_battleParent);

        _hudParent = new Sprite();
        this.modeSprite.addChild(_hudParent);

        _overlayParent = new Sprite();
        this.modeSprite.addChild(_overlayParent);

        this.setupAudio();

        // create a special ObjectDB for all objects that are synchronized over the network.
        GameContext.netObjects = new NetObjectDB();

        this.setupNetwork();

        if (Constants.DEBUG_DRAW_STATS) {
            _debugDataView = new DebugDataView();
            this.addObject(_debugDataView, _overlayParent);
            _debugDataView.visible = false;
        }

        if (GameContext.isSinglePlayer) {
            // introduce the level
            AppContext.mainLoop.pushMode(new LevelIntroMode());

            // introduce the spell that's new to this level, if one exists
            if (GameContext.spLevel.newSpellType >= 0) {
                AppContext.mainLoop.pushMode(new SpellIntroMode());
            }

            // introduce the creature that's new to this level, if one exists
            if (GameContext.spLevel.newCreatureType >= 0) {
                AppContext.mainLoop.pushMode(new CreatureIntroMode());
            }
        }
    }

    override protected function destroy () :void
    {
        this.shutdownNetwork();
        this.shutdownPlayers();
        this.shutdownAudio();
    }

    override protected function enter () :void
    {
        // game audio isn't started until _updateCount hits 1,
        // to allow intro screens to be shown
        if (_updateCount > 0) {
            GameContext.sfxControls.pause(false);
            GameContext.musicControls.pause(false);
            GameContext.musicControls.volumeTo(1, 0.3);
        }
    }

    override protected function exit () :void
    {
        GameContext.sfxControls.pause(true);
        GameContext.musicControls.volumeTo(0.2, 0.3);
    }

    protected function setupAudio () :void
    {
        GameContext.sfxControls = new AudioControls(
            AudioManager.instance.getControlsForSoundType(SoundResource.TYPE_SFX));
        GameContext.musicControls = new AudioControls(
            AudioManager.instance.getControlsForSoundType(SoundResource.TYPE_MUSIC));

        GameContext.sfxControls.retain();
        GameContext.musicControls.retain();

        GameContext.sfxControls.pause(true);
        GameContext.musicControls.pause(true);
    }

    protected function shutdownAudio () :void
    {
        GameContext.sfxControls.stop(true);
        GameContext.musicControls.stop(true);

        GameContext.sfxControls.release();
        GameContext.musicControls.release();

        GameContext.sfxControls = null;
        GameContext.musicControls = null;
    }

    protected function setupPlayersMP () :void
    {
        // get some information about the players in the game
        var numPlayers :int = AppContext.gameCtrl.game.seating.getPlayerIds().length;
        GameContext.localPlayerId = AppContext.gameCtrl.game.seating.getMyPosition();

        // we want to know when a player leaves
        AppContext.gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, handleOccupantLeft);

        // create PlayerInfo structures
        GameContext.playerInfos = [];
        for (var playerId :uint = 0; playerId < numPlayers; ++playerId) {

            var playerInfo :PlayerInfo;

            var teamId :uint = playerId; // @TODO - add support for team-based MP games?

            if (GameContext.localPlayerId == playerId) {
                var localPlayerInfo :LocalPlayerInfo = new LocalPlayerInfo(playerId, teamId);
                playerInfo = localPlayerInfo;
            } else {
                playerInfo = new PlayerInfo(playerId, teamId);
            }

            GameContext.playerInfos.push(playerInfo);
        }

        // setup target enemies
        for each (playerInfo in GameContext.playerInfos) {
            playerInfo.targetedEnemyId = GameContext.findEnemyForPlayer(playerInfo.playerId).playerId;
        }
    }

    protected function setupPlayersSP () :void
    {
        GameContext.playerInfos = [];

        // Create the local player (always on team 0)
        var localPlayerInfo :LocalPlayerInfo = new LocalPlayerInfo(playerId, 0, GameContext.spLevel.playerName);

        // grant the player some starting resources
        var initialResources :Array = GameContext.spLevel.initialResources;
        for (var resType :uint = 0; resType < initialResources.length; ++resType) {
            localPlayerInfo.setResourceAmount(resType, int(initialResources[resType]));
        }

        GameContext.playerInfos.push(localPlayerInfo);

        // create computer players
        var numComputers :uint = GameContext.spLevel.computers.length;
        for (var playerId :uint = 1; playerId < numComputers + 1; ++playerId) {
            var cpData :ComputerPlayerData = GameContext.spLevel.computers[playerId - 1];
            var computerPlayerInfo :ComputerPlayerInfo = new ComputerPlayerInfo(playerId, cpData.team, cpData.playerName);
            GameContext.playerInfos.push(computerPlayerInfo);

            // create the computer player object
            GameContext.netObjects.addObject(new ComputerPlayer(cpData, playerId));
        }

        // setup target enemies
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            playerInfo.targetedEnemyId = GameContext.findEnemyForPlayer(playerInfo.playerId).playerId;
        }
    }

    protected function shutdownPlayers () :void
    {
        if (GameContext.gameType == GameContext.GAME_TYPE_MULTIPLAYER) {
            AppContext.gameCtrl.game.removeEventListener(OccupantChangedEvent.OCCUPANT_LEFT, handleOccupantLeft);
        }
    }

    protected function handleOccupantLeft (e :OccupantChangedEvent) :void
    {
        if (e.player) {
            // did a player leave?
            var playerInfo :PlayerInfo = ArrayUtil.findIf(GameContext.playerInfos,
                function (data :PlayerInfo) :Boolean {
                    return data.whirledId == e.occupantId;
                });

            if (null != playerInfo) {
                playerInfo.leftGame = true;
            }
        }
    }

    protected function setupNetwork () :void
    {
        // set up the message manager
        if (GameContext.gameType == GameContext.GAME_TYPE_MULTIPLAYER) {
            _messageMgr = new OnlineTickedMessageManager(AppContext.gameCtrl, GameContext.isFirstPlayer, TICK_INTERVAL_MS);
        } else {
            _messageMgr = new OfflineTickedMessageManager(TICK_INTERVAL_MS);
        }

        _messageMgr.addMessageFactory(CreateUnitMessage.messageName, CreateUnitMessage.createFactory());
        _messageMgr.addMessageFactory(SelectTargetEnemyMessage.messageName, SelectTargetEnemyMessage.createFactory());
        _messageMgr.addMessageFactory(CastCreatureSpellMessage.messageName, CastCreatureSpellMessage.createFactory());

        if (Constants.DEBUG_CHECKSUM_STATE >= 1) {
            _messageMgr.addMessageFactory(ChecksumMessage.messageName, ChecksumMessage.createFactory());
        }

        _messageMgr.setup();
    }

    protected function shutdownNetwork () :void
    {
        _messageMgr.shutdown();
    }

    protected function setupPuzzleAndUI () :void
    {
        var dashboard :DashboardView = new DashboardView();
        dashboard.x = Constants.DASHBOARD_LOC.x;
        dashboard.y = Constants.DASHBOARD_LOC.y;
        this.addObject(dashboard, _hudParent);

        GameContext.dashboard = dashboard;

        var puzzleBoard :PuzzleBoard = new PuzzleBoard(
            Constants.PUZZLE_COLS,
            Constants.PUZZLE_ROWS,
            Constants.PUZZLE_TILE_SIZE);

        puzzleBoard.displayObject.x = Constants.PUZZLE_BOARD_LOC.x;
        puzzleBoard.displayObject.y = Constants.PUZZLE_BOARD_LOC.y;

        DisplayObjectContainer(dashboard.displayObject).addChildAt(puzzleBoard.displayObject, 0);
        this.addObject(puzzleBoard);

        GameContext.puzzleBoard = puzzleBoard;
    }

    protected function setupBattle () :void
    {
        // Board
        var battleBoardView :BattleBoardView = new BattleBoardView(Constants.BATTLE_WIDTH, Constants.BATTLE_HEIGHT);
        battleBoardView.displayObject.x = Constants.BATTLE_BOARD_LOC.x;
        battleBoardView.displayObject.y = Constants.BATTLE_BOARD_LOC.y;

        this.addObject(battleBoardView, _battleParent);

        GameContext.battleBoardView = battleBoardView;

        // create player bases
        var numPlayers :int = GameContext.numPlayers;
        var baseLocs :Array = GameContext.gameData.getBaseLocsForGameSize(numPlayers);
        for (var playerId :int = 0; playerId < numPlayers; ++playerId) {

            // in single-player levels, bases have custom health
            var maxHealthOverride :int = 0;
            var startingHealthOverride :int = 0;
            if (GameContext.isSinglePlayer) {
                maxHealthOverride = (playerId == 0 ?
                    GameContext.spLevel.playerBaseHealth :
                    ComputerPlayerData(GameContext.spLevel.computers[playerId - 1]).baseHealth);
                startingHealthOverride = (playerId == 0 ?
                    GameContext.spLevel.playerBaseStartHealth :
                    ComputerPlayerData(GameContext.spLevel.computers[playerId - 1]).baseStartHealth);
            }

            var base :PlayerBaseUnit = UnitFactory.createBaseUnit(playerId, maxHealthOverride, startingHealthOverride);

            var baseLoc :Vector2 = baseLocs[playerId];
            base.unitSpawnLoc = baseLoc;
            base.x = baseLoc.x;
            base.y = baseLoc.y;

            var playerInfo :PlayerInfo = GameContext.playerInfos[playerId];
            playerInfo.base = base;
        }

        // inelegantly scale the health meters on all the player base unit views. This relies on
        // all views being added to the db.
        var bases :Array = PlayerBaseUnitView.getAll();
        for each (var baseView :PlayerBaseUnitView in bases) {
            baseView.scaleHealthMeter();
        }

        if (GameContext.localUserIsPlaying) {
            this.setupPlayerBaseViewMouseHandlers();
        }

        // Day/night cycle
        GameContext.diurnalCycle = new DiurnalCycle();
        GameContext.netObjects.addObject(GameContext.diurnalCycle);

        if (!DiurnalCycle.isDisabled) {
            var diurnalMeter :DiurnalMeterView = new DiurnalMeterView();
            diurnalMeter.x = Constants.DIURNAL_METER_LOC.x;
            diurnalMeter.y = Constants.DIURNAL_METER_LOC.y;
            this.addObject(diurnalMeter, GameContext.battleBoardView.diurnalMeterParent);
        }

        GameContext.netObjects.addObject(new SpellDropTimer());
    }

    override public function onKeyDown (keyCode :uint) :void
    {
       switch (keyCode) {
        case KeyboardCodes.NUMBER_4:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                for (var i :uint = 0; i < Constants.RESOURCE__LIMIT; ++i) {
                    GameContext.localPlayerInfo.offsetResourceAmount(i, 500);
                }
            }
            break;

        case KeyboardCodes.NUMBER_5:
            if (null != _debugDataView) {
                _debugDataView.visible = !(_debugDataView.visible);
            }
            break;

        case KeyboardCodes.B:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                GameContext.localPlayerInfo.addSpell(Constants.SPELL_TYPE_BLOODLUST);
            }
            break;

        case KeyboardCodes.R:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                GameContext.localPlayerInfo.addSpell(Constants.SPELL_TYPE_RIGORMORTIS);
            }
            break;

        case KeyboardCodes.P:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                GameContext.localPlayerInfo.addSpell(Constants.SPELL_TYPE_PUZZLERESET);
            }
            break;

        case KeyboardCodes.N:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                GameContext.diurnalCycle.resetPhase(Constants.PHASE_NIGHT);
            }
            break;

        case KeyboardCodes.D:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                GameContext.diurnalCycle.resetPhase(Constants.PHASE_DAY);
            }
            break;

        case KeyboardCodes.K:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                // destroy the targeted enemy's base
                var enemyPlayerInfo :PlayerInfo = GameContext.playerInfos[GameContext.localPlayerInfo.targetedEnemyId];
                var enemyBase :PlayerBaseUnit = enemyPlayerInfo.base;
                if (null != enemyBase) {
                    enemyBase.health = 0;
                }
            }
            break;

        case KeyboardCodes.SLASH:
            if (Constants.DEBUG_ALLOW_CHEATS && GameContext.isSinglePlayer) {
                // restart the level
                // playLevel(true) forces the current level to reload
                AppContext.levelMgr.playLevel(true);
            }
            break;

        case KeyboardCodes.ESCAPE:
            if (GameContext.isSinglePlayer) {
                AppContext.mainLoop.pushMode(new PauseMode());
            }
            break;
        }
    }

    // from AppMode
    override public function update (dt :Number) :void
    {
        if (!_gameIsRunning) {
            // don't start doing anything until the messageMgr is ready
            if (_messageMgr.isReady) {
                log.info("Starting game. randomSeed: " + _messageMgr.randomSeed);
                Rand.seedStream(AppContext.randStreamPuzzle, _messageMgr.randomSeed);
                Rand.seedStream(Rand.STREAM_GAME, _messageMgr.randomSeed);

                if (GameContext.isMultiplayer) {
                    this.setupPlayersMP();
                } else {
                    this.setupPlayersSP();
                }

                // create players' unit spell sets (these are synchronized objects)
                GameContext.playerCreatureSpellSets = [];
                for (var playerId :uint = 0; playerId < GameContext.numPlayers; ++playerId) {
                    var spellSet :CreatureSpellSet = new CreatureSpellSet();
                    GameContext.netObjects.addObject(spellSet);
                    GameContext.playerCreatureSpellSets.push(spellSet);
                }

                this.setupBattle();
                this.setupPuzzleAndUI();

                _gameIsRunning = true;
            } else {
                return;
            }
        }

        // start the game audio when _updateCount hits 1, allowing a full update to pass without
        // audio so that intro screens can be shown
        if (_updateCount == 1) {
            GameContext.musicControls.pause(false);
            GameContext.sfxControls.pause(false);
        }

        // update the network
        _messageMgr.update(dt);

        // if the network simulation is updated, we'll need to depth-sort
        // the battlefield display objects
        var sortDisplayChildren :Boolean = (_messageMgr.unprocessedTickCount > 0);

        while (_messageMgr.unprocessedTickCount > 0) {

            // process all messages from this tick
            var messageArray: Array = _messageMgr.getNextTick();
            for each (var msg :Message in messageArray) {
                handleMessage(msg);
            }

            // run the simulation the appropriate amount
            // (our network update time is unrelated to the application's update time.
            // network timeslices are always the same distance apart)
            GameContext.netObjects.update(TICK_INTERVAL_S);

            if (Constants.DEBUG_CHECKSUM_STATE >= 1) {
                debugNetwork(messageArray);
            }

            ++_gameTickCount;
        }

        // The game is over if there's only one team standing
        var liveTeamId :int = -1;
        var gameOver :Boolean = true;
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            if (!playerInfo.leftGame && playerInfo.isAlive) {
                var playerTeam :int = playerInfo.teamId;
                if (playerTeam != liveTeamId) {
                    if (liveTeamId == -1) {
                        liveTeamId = playerTeam;
                    } else {
                        // there's more than one live team
                        gameOver = false;
                        break;
                    }
                }
            }
        }

        if (gameOver) {
            // show the appropriate game over screen
            if (GameContext.isMultiplayer) {
                MainLoop.instance.changeMode(new GameOverMode(liveTeamId));
            } else {
                var success :Boolean = (liveTeamId == GameContext.localPlayerInfo.teamId);

                // save our progress if we were successful
                if (success) {
                    // calculate the score for this level
                    var fastCompletionScore :int =
                        Math.max(GameContext.spLevel.parDays - GameContext.diurnalCycle.dayCount, 0) *
                        GameContext.gameData.pointsPerDayUnderPar;

                    var resourcesScore :int =
                        Math.max(GameContext.localPlayerInfo.totalResourcesEarned, 0) *
                        GameContext.gameData.pointsPerResource;

                    var levelScore :int =
                        fastCompletionScore +
                        resourcesScore +
                        GameContext.spLevel.levelCompletionBonus;

                    var dataChanged :Boolean;

                    var thisLevel :LevelRecord = AppContext.levelMgr.getLevelRecord(AppContext.levelMgr.curLevelNum);
                    if (null != thisLevel && thisLevel.score < levelScore) {
                        thisLevel.score = levelScore;
                        dataChanged = true;
                    }

                    var nextLevel :LevelRecord = AppContext.levelMgr.getLevelRecord(AppContext.levelMgr.curLevelNum + 1);
                    if (null != nextLevel && !nextLevel.unlocked) {
                        nextLevel.unlocked = true;
                        dataChanged = true;
                    }

                    if (dataChanged) {
                        AppContext.cookieMgr.setNeedsUpdate();
                    }
                }

                MainLoop.instance.pushMode(new LevelOutroMode(success));
            }
        }

        // update the game music
        var dayPhase :int = GameContext.diurnalCycle.phaseOfDay;
        if (dayPhase != _lastDayPhase) {
            if (null != _musicChannel) {
                _musicChannel.audioControls.fadeOut(0.5).stopAfter(0.5);
            }

            _musicChannel = GameContext.playGameMusic(dayPhase == Constants.PHASE_DAY ? "mus_day" : "mus_night");

            _lastDayPhase = dayPhase;
        }

        // update all non-net objects
        super.update(dt);

        if (sortDisplayChildren) {
            GameContext.battleBoardView.sortUnitDisplayChildren();
        }

        ++_updateCount;
    }

    protected function debugNetwork (messageArray :Array) :void
    {
        // process all messages from this tick
        var messageStatus :String = new String();
        var needsBreak :Boolean = false;
        for each (var msg :Message in messageArray) {
            if (msg.name != ChecksumMessage.messageName) {
                if (needsBreak) {
                    messageStatus += " ** ";
                }
                messageStatus += msg.toString();
                needsBreak = true;
            }
        }

        if (messageStatus.length > 0) {
            log.debug("PLAYER: " + GameContext.localPlayerId + " TICK: " + _gameTickCount + " MESSAGES: " + messageStatus);
        }

        // calculate a checksum for this frame
        var csumMessage :ChecksumMessage = calculateChecksum();

        // player 1 saves his checksums, player 0 sends his checksums
        if (GameContext.localPlayerId == 1) {
            _myChecksums.unshift(csumMessage);
            _lastCachedChecksumTick = _gameTickCount;
        } else if ((_gameTickCount % 2) == 0) {
            _messageMgr.sendMessage(csumMessage);
        }
    }

    protected function calculateChecksum () :ChecksumMessage
    {
        var msg :ChecksumMessage = new ChecksumMessage(0, 0, 0, "");

        // iterate over all the shared state and calculate
        // a simple checksum for it
        var csum :Checksum = new Checksum();

        var i :int = 0;

        // random state
        add(Rand.nextInt(Rand.STREAM_GAME), "Rand state");

        // units
        /*var unitIds :Array = _netObjects.getObjectIdsInGroup(Unit.GROUP_NAME);
        add(unitIds.length, "units.length");
        for (i = 0; i < unitIds.length; ++i) {
            var unit :Unit = _netObjects.get(units[i] as Unit);
            add(unit.owningPlayerId, "unit.owningPlayerId - " + i);
            add(unit.unitType, "unit.unitType - " + i);
            add(unit.displayObject.x, "unit.displayObject.x - " + i);
            add(unit.displayObject.y, "unit.displayObject.y - " + i);
            add(unit.health, "unit.health - " + i);
        }*/

        msg.playerId = GameContext.localPlayerId;
        msg.tick = _gameTickCount;
        msg.checksum = csum.value;

        return msg;

        var needsLinebreak :Boolean = false;

        function add (val :*, desc :String) :void
        {
            csum.add(val);

            if (Constants.DEBUG_CHECKSUM_STATE >= 2) {
                if (needsLinebreak) {
                    msg.details += "\n";
                }

                msg.details += String("csum : " + csum.value + "\t(desc: " + desc + ")\t(val: " + val + ")");
                needsLinebreak = true;
            }
        }
    }

    protected function handleMessage (msg :Message) :void
    {
        switch (msg.name) {
        case CreateUnitMessage.messageName:
            var createUnitMsg :CreateUnitMessage = (msg as CreateUnitMessage);
            UnitFactory.createCreature(createUnitMsg.unitType, createUnitMsg.playerId);
            var baseView :PlayerBaseUnitView = PlayerBaseUnitView.getForPlayer(createUnitMsg.playerId);
            if (null != baseView) {
                baseView.unitCreated();
            }
            break;

        case SelectTargetEnemyMessage.messageName:
            var selectTargetEnemyMsg :SelectTargetEnemyMessage = msg as SelectTargetEnemyMessage;
            this.setTargetEnemy(selectTargetEnemyMsg.playerId, selectTargetEnemyMsg.targetPlayerId);
            break;

        case CastCreatureSpellMessage.messageName:
            var castSpellMsg :CastCreatureSpellMessage = msg as CastCreatureSpellMessage;
            var playerId :uint = castSpellMsg.playerId;
            if (PlayerInfo(GameContext.playerInfos[playerId]).isAlive) {
                var spellSet :CreatureSpellSet = GameContext.playerCreatureSpellSets[playerId];
                var spell :CreatureSpellData = GameContext.gameData.spells[castSpellMsg.spellType];
                spellSet.addSpell(spell.clone() as CreatureSpellData);
                GameContext.playGameSound("sfx_" + spell.name);
            }
            break;

        case ChecksumMessage.messageName:
            this.handleChecksumMessage(msg as ChecksumMessage);
            break;
        }

    }

    protected function setTargetEnemy (playerId :uint, targetEnemyId :uint) :void
    {
        var playerInfo :PlayerInfo = GameContext.playerInfos[playerId];
        playerInfo.targetedEnemyId = targetEnemyId;

        if (playerId == GameContext.localPlayerId) {
            this.updateTargetEnemyBadgeLocation(targetEnemyId);
        }
    }

    protected function updateTargetEnemyBadgeLocation (targetEnemyId :uint) :void
    {
        // move the "target enemy" badge to the correct base
        var baseViews :Array = PlayerBaseUnitView.getAll();
        for each (var baseView :PlayerBaseUnitView in baseViews) {
            baseView.targetEnemyBadgeVisible = (baseView.baseUnit.owningPlayerId == targetEnemyId);
        }
    }

    protected function setupPlayerBaseViewMouseHandlers () :void
    {
        // add click listeners to all the enemy bases.
        // when an enemy base is clicked, that player becomes the new "target enemy" for the local player.
        var localPlayerInfo :PlayerInfo = GameContext.localPlayerInfo;
        var baseViews :Array = PlayerBaseUnitView.getAll();
        for each (var baseView :PlayerBaseUnitView in baseViews) {
            var owningPlayerId :uint = baseView.baseUnit.owningPlayerId;
            var owningPlayerInfo :PlayerInfo = GameContext.playerInfos[owningPlayerId];
            baseView.targetEnemyBadgeVisible = (owningPlayerId == localPlayerInfo.targetedEnemyId);

            if (localPlayerInfo.teamId != owningPlayerInfo.teamId) {
                InteractiveObject(baseView.displayObject).addEventListener(
                    MouseEvent.MOUSE_DOWN, this.createBaseViewClickListener(baseView));
            }
        }
    }

    protected function createBaseViewClickListener (baseView :PlayerBaseUnitView) :Function
    {
        return function (...ignored) :void { enemyBaseViewClicked(baseView); }
    }

    protected function enemyBaseViewClicked (enemyBaseView :PlayerBaseUnitView) :void
    {
        // when the player clicks on an enemy base, that enemy becomes the player's target
        var localPlayerInfo :PlayerInfo = GameContext.localPlayerInfo;
        var newTargetEnemyId :uint = enemyBaseView.baseUnit.owningPlayerId;

        Assert.isTrue(newTargetEnemyId != GameContext.localPlayerId);

        if (newTargetEnemyId != localPlayerInfo.targetedEnemyId) {
            // update the "target enemy badge" location immediately, even though
            // the change won't be reflected in the game logic until the message round-trips
            this.updateTargetEnemyBadgeLocation(newTargetEnemyId);

            // send a message to everyone
            this.selectTargetEnemy(GameContext.localPlayerId, newTargetEnemyId);
        }

    }

    public function selectTargetEnemy (playerId :uint, enemyId :uint) :void
    {
        _messageMgr.sendMessage(new SelectTargetEnemyMessage(playerId, enemyId));
    }

    protected function handleChecksumMessage (msg :ChecksumMessage) :void
    {
        if (msg.playerId != GameContext.localPlayerId) {
            // check this checksum against our checksum buffer
            if (msg.tick > _lastCachedChecksumTick || msg.tick <= (_lastCachedChecksumTick - _myChecksums.length)) {
                log.debug("discarding checksum message (too old or too new)");
            } else {
                var index :uint = (_lastCachedChecksumTick - msg.tick);
                var myChecksum :ChecksumMessage = (_myChecksums.at(index) as ChecksumMessage);
                if (myChecksum.checksum != msg.checksum) {
                    log.warning("** WARNING ** Mismatched checksums at tick " + msg.tick + "!");

                    // only dump the details once
                    if (!_syncError) {
                        log.debug("-- PLAYER " + myChecksum.playerId + " --");
                        log.debug(myChecksum.details);
                        log.debug("-- PLAYER " + msg.playerId + " --");
                        log.debug(msg.details);
                        _syncError = true;
                    }
                }
            }
        }
    }

    public function buildUnit (playerId :uint, unitType :uint) :void
    {
        var playerInfo :PlayerInfo = GameContext.playerInfos[playerId];

        if (!playerInfo.isAlive || GameContext.diurnalCycle.isDay || !playerInfo.canPurchaseCreature(unitType)) {
            return;
        }

        playerInfo.creaturePurchased(unitType);
        _messageMgr.sendMessage(new CreateUnitMessage(playerId, unitType));
    }

    public function castSpell (playerId :uint, spellType :uint) :void
    {
        var playerInfo :PlayerInfo = GameContext.playerInfos[playerId];
        var isCreatureSpell :Boolean = (spellType < Constants.CREATURE_SPELL_TYPE__LIMIT);

        if (!playerInfo.isAlive || (isCreatureSpell && GameContext.diurnalCycle.isDay) || !playerInfo.canCastSpell(spellType)) {
            return;
        }

        playerInfo.spellCast(spellType);

        if (isCreatureSpell) {
            _messageMgr.sendMessage(new CastCreatureSpellMessage(playerId, spellType));
        } else if (spellType == Constants.SPELL_TYPE_PUZZLERESET) {
            // there's only one non-creature spell
            GameContext.dashboard.puzzleShuffle();
        }
    }

    public function get overlayParent () :DisplayObjectContainer
    {
        return _overlayParent;
    }

    protected var _gameIsRunning :Boolean;

    protected var _messageMgr :TickedMessageManager;
    protected var _debugDataView :DebugDataView;
    protected var _battleParent :Sprite;
    protected var _hudParent :Sprite;
    protected var _overlayParent :Sprite;
    protected var _musicChannel :AudioChannel;
    protected var _lastDayPhase :int = -1;

    protected var _gameTickCount :uint;
    protected var _updateCount :uint;
    protected var _myChecksums :RingBuffer = new RingBuffer(CHECKSUM_BUFFER_LENGTH);
    protected var _lastCachedChecksumTick :int;
    protected var _syncError :Boolean;

    protected static const TICK_INTERVAL_MS :int = 100; // 1/10 of a second
    protected static const TICK_INTERVAL_S :Number = (Number(TICK_INTERVAL_MS) / Number(1000));

    protected static const CHECKSUM_BUFFER_LENGTH :int = 10;

    protected static const log :Log = Log.getLog(GameMode);
}

}
