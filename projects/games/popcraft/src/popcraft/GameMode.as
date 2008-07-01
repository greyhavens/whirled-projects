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
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.*;
import com.whirled.game.OccupantChangedEvent;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;

import popcraft.battle.*;
import popcraft.battle.geom.ForceParticleContainer;
import popcraft.battle.view.*;
import popcraft.data.*;
import popcraft.net.*;
import popcraft.puzzle.*;
import popcraft.sp.*;
import popcraft.ui.*;
import popcraft.util.*;

public class GameMode extends TransitionMode
{
    override protected function setup () :void
    {
        Profiler.reset();

        GameContext.gameMode = this;
        GameContext.playerStats = new PlayerStats();

        // init RNGs
        var randSeed :uint = (GameContext.isMultiplayer ? MultiplayerConfig.randSeed : uint(Math.random() * uint.MAX_VALUE));
        Rand.seedStream(AppContext.randStreamPuzzle, randSeed);
        Rand.seedStream(Rand.STREAM_GAME, randSeed);
        log.info("Starting game with seed: " + randSeed);

        if (GameContext.isMultiplayer) {
            this.initMultiplayerSettings();
        }

        // cache some frequently-used values in GameContext
        GameContext.mapScaleXInv = 1 / GameContext.mapSettings.mapScaleX;
        GameContext.mapScaleYInv = 1 / GameContext.mapSettings.mapScaleY;
        GameContext.scaleSprites = GameContext.mapSettings.scaleSprites;

        // create some layers
        GameContext.battleLayer = new Sprite();
        GameContext.dashboardLayer = new Sprite();
        GameContext.overlayLayer = new Sprite();
        _modeLayer.addChild(GameContext.battleLayer);
        _modeLayer.addChild(GameContext.dashboardLayer);
        _modeLayer.addChild(GameContext.overlayLayer);

        this.setupAudio();
        this.setupNetwork();
        this.setupPlayers();
        this.setupBattle();
        this.setupDashboard();

        if (Constants.DEBUG_DRAW_STATS) {
            _debugDataView = new DebugDataView();
            this.addObject(_debugDataView, GameContext.overlayLayer);
            _debugDataView.visible = true;
        }

        // introduce the level
        if (GameContext.isSinglePlayer) {
            AppContext.mainLoop.pushMode(new LevelIntroMode());
        }
    }

    override protected function destroy () :void
    {
        this.shutdownNetwork();
        this.shutdownPlayers();
        this.shutdownAudio();

        Profiler.displayStats();
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

    protected function initMultiplayerSettings () :void
    {
        // Determine what the game's team arrangement is, and randomly choose an appropriate
        // MultiplayerSettingsData that fits that arrangement.

        var multiplayerArrangement :int = MultiplayerConfig.computeTeamArrangement();
        var potentialSettings :Array = AppContext.multiplayerSettings;
        potentialSettings = potentialSettings.filter(
            function (mpSettings :MultiplayerSettingsData, index :int, array :Array) :Boolean {
                return (mpSettings.arrangeType == multiplayerArrangement);
            });

        GameContext.mpSettings = Rand.nextElement(potentialSettings, Rand.STREAM_GAME);
    }

    protected function setupPlayers () :void
    {
        if (GameContext.isMultiplayer) {
            this.setupPlayersMP();
        } else {
            this.setupPlayersSP();
        }

        // create players' unit spell sets (these are synchronized objects)
        GameContext.playerCreatureSpellSets = [];
        for (var playerIndex :int = 0; playerIndex < GameContext.numPlayers; ++playerIndex) {
            var spellSet :CreatureSpellSet = new CreatureSpellSet();
            GameContext.netObjects.addObject(spellSet);
            GameContext.playerCreatureSpellSets.push(spellSet);
        }
    }

    protected function setupPlayersMP () :void
    {
        var teams :Array = MultiplayerConfig.teams;
        var handicaps :Array = MultiplayerConfig.handicaps;

        // In multiplayer games, base locations are arranged in order of team,
        // with larger teams coming before smaller ones. Populate a set of TeamInfo
        // structures with base locations so that we can put everyone in the correct place.
        var baseLocs :Array = GameContext.mapSettings.baseLocs;
        var teamSizes :Array = MultiplayerConfig.computeTeamSizes();
        var teamInfos :Array = [];
        var teamInfo :TeamInfo;
        for (var teamId :int = 0; teamId < teamSizes.length; ++teamId) {
            teamInfo = new TeamInfo();
            teamInfo.teamId = teamId;
            teamInfo.teamSize = teamSizes[teamId];
            teamInfos.push(teamInfo);
        }

        teamInfos.sort(TeamInfo.teamSizeCompare);
        var baseLocIndex :int = 0;
        for each (teamInfo in teamInfos) {
            for (var i :int = 0; i < teamInfo.teamSize; ++i) {
                teamInfo.baseLocs.push(baseLocs[baseLocIndex++]);
            }
        }

        var largestTeamSize :int = TeamInfo(teamInfos[0]).teamSize;

        teamInfos.sort(TeamInfo.teamIdCompare);

        // get some information about the players in the game
        var numPlayers :int = AppContext.gameCtrl.game.seating.getPlayerIds().length;
        GameContext.localPlayerIndex = AppContext.gameCtrl.game.seating.getMyPosition();

        // we want to know when a player leaves
        AppContext.gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, handleOccupantLeft);

        // create PlayerInfo structures
        GameContext.playerInfos = [];
        for (var playerIndex :int = 0; playerIndex < numPlayers; ++playerIndex) {

            var playerInfo :PlayerInfo;
            teamId = teams[playerIndex];
            teamInfo = teamInfos[teamId];
            var baseLoc :Vector2 = teamInfo.baseLocs.shift();

            // calculate the player's handicap
            var handicap :Number = 1;
            if (teamInfo.teamSize < largestTeamSize) {
                handicap = GameContext.mpSettings.smallerTeamHandicap;
            }
            if (handicaps[playerIndex]) {
                handicap *= Constants.HANDICAPPED_MULTIPLIER;
            }

            if (GameContext.localPlayerIndex == playerIndex) {
                var localPlayerInfo :LocalPlayerInfo = new LocalPlayerInfo(playerIndex, teamId, baseLoc, handicap);
                playerInfo = localPlayerInfo;
            } else {
                playerInfo = new PlayerInfo(playerIndex, teamId, baseLoc, handicap);
            }

            GameContext.playerInfos.push(playerInfo);
        }

        // setup target enemies
        for each (playerInfo in GameContext.playerInfos) {
            playerInfo.targetedEnemyId = GameContext.findEnemyForPlayer(playerInfo.playerIndex).playerIndex;
        }
    }

    protected function setupPlayersSP () :void
    {
        GameContext.localPlayerIndex = 0;
        GameContext.playerInfos = [];

        var level :LevelData = GameContext.spLevel;

        // in single player levels, base location are arranged in order of player id
        var baseLocs :Array = GameContext.mapSettings.baseLocs;

        // Create the local player (always playerIndex=0, team=0)
        var localPlayerInfo :LocalPlayerInfo = new LocalPlayerInfo(
            0, 0, baseLocs[0], 1, level.playerName, level.playerHeadshot);

        // grant the player some starting resources
        var initialResources :Array = level.initialResources;
        for (var resType :int = 0; resType < initialResources.length; ++resType) {
            localPlayerInfo.setResourceAmount(resType, int(initialResources[resType]));
        }

        // ...and some starting spells
        var initialSpells :Array = level.initialSpells;
        for (var spellType :int = 0; spellType < initialSpells.length; ++spellType) {
            localPlayerInfo.addSpell(spellType, int(initialSpells[spellType]));
        }

        GameContext.playerInfos.push(localPlayerInfo);

        // create computer players
        var numComputers :int = level.computers.length;
        for (var playerIndex :int = 1; playerIndex < numComputers + 1; ++playerIndex) {
            var cpData :ComputerPlayerData = level.computers[playerIndex - 1];
            var computerPlayerInfo :ComputerPlayerInfo = new ComputerPlayerInfo(
                playerIndex, cpData.team, baseLocs[playerIndex], cpData.playerName, cpData.playerHeadshot);
            GameContext.playerInfos.push(computerPlayerInfo);

            // create the computer player object
            GameContext.netObjects.addObject(new ComputerPlayer(cpData, playerIndex));
        }

        // setup target enemies
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            playerInfo.targetedEnemyId = GameContext.findEnemyForPlayer(playerInfo.playerIndex).playerIndex;
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
        // create a special ObjectDB for all objects that are synchronized over the network.
        GameContext.netObjects = new NetObjectDB();

        // set up the message manager
        if (GameContext.gameType == GameContext.GAME_TYPE_MULTIPLAYER) {
            _messageMgr = new OnlineTickedMessageManager(AppContext.gameCtrl, SeatingManager.isLocalPlayerInControl, TICK_INTERVAL_MS);
        } else {
            _messageMgr = new OfflineTickedMessageManager(AppContext.gameCtrl, TICK_INTERVAL_MS);
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

    protected function setupDashboard () :void
    {
        var dashboard :DashboardView = new DashboardView();
        dashboard.x = Constants.DASHBOARD_LOC.x;
        dashboard.y = Constants.DASHBOARD_LOC.y;
        this.addObject(dashboard, GameContext.dashboardLayer);

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
        GameContext.unitFactory = new UnitFactory();

        GameContext.forceParticleContainer = new ForceParticleContainer(
            GameContext.battlefieldWidth,
            GameContext.battlefieldHeight);

        // Board
        var battleBoardView :BattleBoardView = new BattleBoardView(Constants.BATTLE_WIDTH, Constants.BATTLE_HEIGHT);
        this.addObject(battleBoardView, GameContext.battleLayer);

        GameContext.battleBoardView = battleBoardView;

        // create player bases
        var numPlayers :int = GameContext.numPlayers;
        for (var playerIndex :int = 0; playerIndex < numPlayers; ++playerIndex) {

            // in single-player levels, bases have custom health
            var maxHealthOverride :int = 0;
            var startingHealthOverride :int = 0;
            var invincible :Boolean;
            if (GameContext.isSinglePlayer) {
                if (playerIndex == 0) {
                    maxHealthOverride = GameContext.spLevel.playerBaseHealth;
                    startingHealthOverride = GameContext.spLevel.playerBaseStartHealth;
                } else {
                    var cpData :ComputerPlayerData = GameContext.spLevel.computers[playerIndex - 1];
                    maxHealthOverride = cpData.baseHealth;
                    startingHealthOverride = cpData.baseStartHealth;
                    invincible = cpData.invincible;
                }
            }

            var playerInfo :PlayerInfo = GameContext.playerInfos[playerIndex];
            var baseLoc :Vector2 = playerInfo.baseLoc;

            var base :PlayerBaseUnit = GameContext.unitFactory.createBaseUnit(playerIndex, maxHealthOverride, startingHealthOverride);
            base.isInvincible = invincible;
            base.x = baseLoc.x;
            base.y = baseLoc.y;

            playerInfo.base = base;
        }

        this.setupPlayerBaseViewMouseHandlers();

        // Day/night cycle
        GameContext.diurnalCycle = new DiurnalCycle();
        GameContext.netObjects.addObject(GameContext.diurnalCycle);

        if (!DiurnalCycle.isDisabled) {
            var diurnalMeter :DiurnalCycleView = new DiurnalCycleView();
            diurnalMeter.x = Constants.DIURNAL_METER_LOC.x;
            diurnalMeter.y = Constants.DIURNAL_METER_LOC.y;
            this.addObject(diurnalMeter, GameContext.battleBoardView.diurnalMeterParent);
        }

        GameContext.netObjects.addObject(new SpellDropTimer());

        _trophyWatcher = new TrophyWatcher();
    }

    override public function onKeyDown (keyCode :uint) :void
    {
        if (_gameOver) {
            return;
        }

        switch (keyCode) {
        case KeyboardCodes.NUMBER_4:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                for (var i :int = 0; i < Constants.RESOURCE__LIMIT; ++i) {
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
                GameContext.diurnalCycle.incrementDayCount();
                GameContext.diurnalCycle.resetPhase(
                    GameContext.gameData.enableEclipse ? Constants.PHASE_ECLIPSE : Constants.PHASE_DAY);
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

        case KeyboardCodes.W:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                // destroy all enemy bases
                for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
                    if (playerInfo.teamId != GameContext.localPlayerInfo.teamId) {
                        enemyBase = playerInfo.base;
                        if (null != enemyBase) {
                            enemyBase.health = 0;
                        }
                    }
                }
            }
            break;

        case KeyboardCodes.SLASH:
            if (Constants.DEBUG_ALLOW_CHEATS && GameContext.isSinglePlayer) {
                // restart the level
                // playLevel(true) forces the current level to reload
                AppContext.levelMgr.playLevel(null, true);
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
                _gameIsRunning = true;
            } else if (!SeatingManager.allPlayersPresent) {
                // If a player leaves before the game starts, the messageMgr will never
                // be ready.
                AppContext.mainLoop.unwindToMode(new MultiplayerFailureMode());
                return;
            } else {
                return;
            }
        } else if (_gameOver) {
            // stop processing game logic when the game is over
            super.update(dt);
            return;
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
            _gameTime += TICK_INTERVAL_S;
        }

        this.checkForGameOver();

        // update all non-net objects
        super.update(dt);

        if (sortDisplayChildren) {
            GameContext.battleBoardView.sortUnitDisplayChildren();
        }

        // update the game music, unless we're in "eclipse mode", where we loop
        // the night music forever
        var dayPhase :int = GameContext.diurnalCycle.phaseOfDay;
        if (!_startedMusic || (dayPhase != _lastDayPhase && !GameContext.gameData.enableEclipse)) {
            if (null != _musicChannel) {
                _musicChannel.audioControls.fadeOut(0.5).stopAfter(0.5);
            }

            _musicChannel = GameContext.playGameMusic(DiurnalCycle.isDay(dayPhase) ? "mus_day" : "mus_night");

            _lastDayPhase = dayPhase;
            _startedMusic = true;
        }

        ++_updateCount;
    }

    protected function checkForGameOver () :void
    {
        // The game is over if there's only one team standing
        var liveTeamId :int = -1;
        _gameOver = true;
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            // for the purposes of game-over detection, discount invincible players from the
            // live player count. this is kind of ugly - the last level is the only level
            // in which there's an invincible player (Professor Weardd).
            if (!playerInfo.leftGame && playerInfo.isAlive && !playerInfo.isInvincible) {
                var playerTeam :int = playerInfo.teamId;
                if (playerTeam != liveTeamId) {
                    if (liveTeamId == -1) {
                        liveTeamId = playerTeam;
                    } else {
                        // there's more than one live team
                        _gameOver = false;
                        break;
                    }
                }
            }
        }

        if (_gameOver) {
            GameContext.playerStats.totalGameTime = _gameTime;
            GameContext.winningTeamId = liveTeamId;

            // show the appropriate outro screen
            var nextMode :AppMode;
            if (GameContext.isMultiplayer) {
                nextMode = new MultiplayerGameOverMode();
            } else if (AppContext.levelMgr.isLastLevel && liveTeamId == GameContext.localPlayerInfo.teamId) {
                nextMode = new EpilogueMode(EpilogueMode.TRANSITION_LEVELOUTRO);
            } else {
                nextMode = new LevelOutroMode();
            }

            this.fadeOutToMode(nextMode, FADE_OUT_TIME);
            GameContext.musicControls.fadeOut(FADE_OUT_TIME - 0.25);
            GameContext.sfxControls.fadeOut(FADE_OUT_TIME - 0.25);
        }
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
            log.debug("PLAYER: " + GameContext.localPlayerIndex + " TICK: " + _gameTickCount + " MESSAGES: " + messageStatus);
        }

        // calculate a checksum for this frame
        var csumMessage :ChecksumMessage = calculateChecksum();

        // player 1 saves his checksums, player 0 sends his checksums
        if (GameContext.localPlayerIndex == 1) {
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
            add(unit.owningPlayerIndex, "unit.owningPlayerIndex - " + i);
            add(unit.unitType, "unit.unitType - " + i);
            add(unit.displayObject.x, "unit.displayObject.x - " + i);
            add(unit.displayObject.y, "unit.displayObject.y - " + i);
            add(unit.health, "unit.health - " + i);
        }*/

        msg.playerIndex = GameContext.localPlayerIndex;
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
            GameContext.unitFactory.createCreature(createUnitMsg.unitType, createUnitMsg.playerIndex);
            var baseView :PlayerBaseUnitView = PlayerBaseUnitView.getForPlayer(createUnitMsg.playerIndex);
            if (null != baseView) {
                baseView.unitCreated();
            }
            break;

        case SelectTargetEnemyMessage.messageName:
            var selectTargetEnemyMsg :SelectTargetEnemyMessage = msg as SelectTargetEnemyMessage;
            this.setTargetEnemy(selectTargetEnemyMsg.playerIndex, selectTargetEnemyMsg.targetPlayerIndex);
            break;

        case CastCreatureSpellMessage.messageName:
            var castSpellMsg :CastCreatureSpellMessage = msg as CastCreatureSpellMessage;
            var playerIndex :int = castSpellMsg.playerIndex;
            if (PlayerInfo(GameContext.playerInfos[playerIndex]).isAlive) {
                var spellSet :CreatureSpellSet = GameContext.playerCreatureSpellSets[playerIndex];
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

    protected function setTargetEnemy (playerIndex :int, targetEnemyId :int) :void
    {
        var playerInfo :PlayerInfo = GameContext.playerInfos[playerIndex];
        playerInfo.targetedEnemyId = targetEnemyId;

        if (playerIndex == GameContext.localPlayerIndex) {
            this.updateTargetEnemyBadgeLocation(targetEnemyId);
        }
    }

    protected function updateTargetEnemyBadgeLocation (targetEnemyId :int) :void
    {
        // move the "target enemy" badge to the correct base
        var baseViews :Array = PlayerBaseUnitView.getAll();
        for each (var baseView :PlayerBaseUnitView in baseViews) {
            baseView.targetEnemyBadgeVisible = (baseView.baseUnit.owningPlayerIndex == targetEnemyId);
        }
    }

    protected function setupPlayerBaseViewMouseHandlers () :void
    {
        // add click listeners to all the enemy bases.
        // when an enemy base is clicked, that player becomes the new "target enemy" for the local player.
        var localPlayerInfo :PlayerInfo = GameContext.localPlayerInfo;
        var baseViews :Array = PlayerBaseUnitView.getAll();
        for each (var baseView :PlayerBaseUnitView in baseViews) {
            var owningPlayerIndex :int = baseView.baseUnit.owningPlayerIndex;
            var owningPlayerInfo :PlayerInfo = GameContext.playerInfos[owningPlayerIndex];
            baseView.targetEnemyBadgeVisible = (owningPlayerIndex == localPlayerInfo.targetedEnemyId);

            if (localPlayerInfo.teamId != owningPlayerInfo.teamId && !owningPlayerInfo.isInvincible) {
                baseView.clickableObject.addEventListener(
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
        var newTargetEnemyId :int = enemyBaseView.baseUnit.owningPlayerIndex;

        Assert.isTrue(newTargetEnemyId != GameContext.localPlayerIndex);

        if (newTargetEnemyId != localPlayerInfo.targetedEnemyId) {
            // update the "target enemy badge" location immediately, even though
            // the change won't be reflected in the game logic until the message round-trips
            this.updateTargetEnemyBadgeLocation(newTargetEnemyId);

            // send a message to everyone
            this.selectTargetEnemy(GameContext.localPlayerIndex, newTargetEnemyId);
        }

    }

    public function selectTargetEnemy (playerIndex :int, enemyId :int) :void
    {
        _messageMgr.sendMessage(new SelectTargetEnemyMessage(playerIndex, enemyId));
    }

    protected function handleChecksumMessage (msg :ChecksumMessage) :void
    {
        if (msg.playerIndex != GameContext.localPlayerIndex) {
            // check this checksum against our checksum buffer
            if (msg.tick > _lastCachedChecksumTick || msg.tick <= (_lastCachedChecksumTick - _myChecksums.length)) {
                log.debug("discarding checksum message (too old or too new)");
            } else {
                var index :int = (_lastCachedChecksumTick - msg.tick);
                var myChecksum :ChecksumMessage = (_myChecksums.at(index) as ChecksumMessage);
                if (myChecksum.checksum != msg.checksum) {
                    log.warning("** WARNING ** Mismatched checksums at tick " + msg.tick + "!");

                    // only dump the details once
                    if (!_syncError) {
                        log.debug("-- PLAYER " + myChecksum.playerIndex + " --");
                        log.debug(myChecksum.details);
                        log.debug("-- PLAYER " + msg.playerIndex + " --");
                        log.debug(msg.details);
                        _syncError = true;
                    }
                }
            }
        }
    }

    public function buildCreature (playerIndex :int, unitType :int, noCost :Boolean = false) :void
    {
        var playerInfo :PlayerInfo = GameContext.playerInfos[playerIndex];

        if (!playerInfo.isAlive || GameContext.diurnalCycle.isDay || (!noCost && !playerInfo.canPurchaseCreature(unitType))) {
            return;
        }

        if (!noCost) {
            playerInfo.deductCreatureCost(unitType);
        }

        _messageMgr.sendMessage(new CreateUnitMessage(playerIndex, unitType));

        GameContext.playerStats.creaturesCreated[unitType] += 1;
    }

    public function castSpell (playerIndex :int, spellType :int) :void
    {
        var playerInfo :PlayerInfo = GameContext.playerInfos[playerIndex];
        var isCreatureSpell :Boolean = (spellType < Constants.CREATURE_SPELL_TYPE__LIMIT);

        if (!playerInfo.isAlive || (isCreatureSpell && GameContext.diurnalCycle.isDay) || !playerInfo.canCastSpell(spellType)) {
            return;
        }

        playerInfo.spellCast(spellType);

        if (isCreatureSpell) {
            _messageMgr.sendMessage(new CastCreatureSpellMessage(playerIndex, spellType));
        } else if (spellType == Constants.SPELL_TYPE_PUZZLERESET) {
            // there's only one non-creature spell
            GameContext.dashboard.puzzleShuffle();
        }

        GameContext.playerStats.spellsCast[spellType] += 1;
    }

    protected var _gameIsRunning :Boolean;

    protected var _messageMgr :TickedMessageManager;
    protected var _debugDataView :DebugDataView;
    protected var _musicChannel :AudioChannel;
    protected var _lastDayPhase :int = -1;
    protected var _startedMusic :Boolean;
    protected var _gameOver :Boolean;

    protected var _gameTickCount :int;
    protected var _gameTime :Number;
    protected var _updateCount :int;
    protected var _myChecksums :RingBuffer = new RingBuffer(CHECKSUM_BUFFER_LENGTH);
    protected var _lastCachedChecksumTick :int;
    protected var _syncError :Boolean;

    protected var _trophyWatcher :TrophyWatcher;

    protected static const TICK_INTERVAL_MS :int = 100; // 1/10 of a second
    protected static const TICK_INTERVAL_S :Number = (Number(TICK_INTERVAL_MS) / Number(1000));

    protected static const CHECKSUM_BUFFER_LENGTH :int = 10;

    protected static const FADE_OUT_TIME :Number = 3;

    protected static const log :Log = Log.getLog(GameMode);
}

}

/** Used by GameMode.setupPlayersMP() */
class TeamInfo
{
    public var teamId :int;
    public var teamSize :int;
    public var baseLocs :Array = [];

    // Used to sort TeamInfos from largest to smallest team size
    public static function teamSizeCompare (a :TeamInfo, b :TeamInfo) :int
    {
        if (a.teamSize > b.teamSize) {
            return -1;
        } else if (a.teamSize < b.teamSize) {
            return 1;
        } else {
            return 0;
        }
    }

    // Used to sort TeamInfos from smallest to largest teamId
    public static function teamIdCompare (a :TeamInfo, b :TeamInfo) :int
    {
        if (a.teamId < b.teamId) {
            return -1;
        } else if (a.teamId > b.teamId) {
            return 1;
        } else {
            return 0;
        }
    }
}
