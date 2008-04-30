package popcraft {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.threerings.util.HashSet;
import com.threerings.util.KeyboardCodes;
import com.threerings.util.Log;
import com.threerings.util.RingBuffer;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.util.*;
import com.whirled.game.OccupantChangedEvent;

import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import popcraft.battle.*;
import popcraft.battle.view.*;
import popcraft.data.*;
import popcraft.net.*;
import popcraft.puzzle.*;
import popcraft.sp.*;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        // make sure we have a valid GameData object in the GameContext
        if (null == GameContext.gameData) {
            GameContext.gameData = AppContext.defaultGameData;
        }

        GameContext.gameMode = this;

        // create a special ObjectDB for all objects that are synchronized over the network.
        GameContext.netObjects = new NetObjectDB();

        if (GameContext.isMultiplayer) {
            this.setupPlayersMP();
        } else {
            this.setupPlayersSP();
        }

        this.setupNetwork();
        this.setupBattle();
        this.setupPuzzleAndUI();
        this.setupInput();

        if (Constants.DEBUG_DRAW_STATS) {
            _debugDataView = new DebugDataView();
            this.addObject(_debugDataView, this.modeSprite);
            _debugDataView.visible = false;
        }

        if (GameContext.isSinglePlayer) {
            AppContext.mainLoop.pushMode(new LevelIntroMode());
        }
    }

    override protected function destroy () :void
    {
        this.shutdownInput();
        this.shutdownNetwork();
        this.shutdownPlayers();
    }

    protected function setupInput () :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            // Listen for all keydowns.
            // The suggested way to do this is to attach an event listener to the stage,
            // but that's a security violation. The GameControl re-dispatches global key
            // events for us instead.
            AppContext.gameCtrl.local.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        } else {
            this.modeSprite.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }
    }

    protected function shutdownInput () :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            // Listen for all keydowns.
            // The suggested way to do this is to attach an event listener to the stage,
            // but that's a security violation. The GameControl re-dispatches global key
            // events for us instead.
            AppContext.gameCtrl.local.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        } else {
            this.modeSprite.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }
    }

    protected function setupPlayersMP () :void
    {
        // get some information about the players in the game
        var numPlayers :int = AppContext.gameCtrl.game.seating.getPlayerIds().length;
        GameContext.localPlayerId = AppContext.gameCtrl.game.seating.getMyPosition();

        // we want to know when a player leaves
        AppContext.gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, handleOccupantLeft);

        // create PlayerData structures
        GameContext.playerData = [];
        for (var playerId :uint = 0; playerId < numPlayers; ++playerId) {

            var playerData :PlayerData;

            var teamId :uint = playerId; // @TODO - add support for team-based MP games?

            if (GameContext.localPlayerId == playerId) {
                var localPlayerData :LocalPlayerData = new LocalPlayerData(playerId, teamId);
                playerData = localPlayerData;
            } else {
                playerData = new PlayerData(playerId, teamId);
            }

            GameContext.playerData.push(playerData);
        }

        // setup target enemies
        for each (playerData in GameContext.playerData) {
            playerData.targetedEnemyId = GameContext.findEnemyForPlayer(playerData.playerId).playerId;
        }
    }

    protected function setupPlayersSP () :void
    {
        GameContext.playerData = [];

        // Create the local player (always on team 0)
        var localPlayerData :LocalPlayerData = new LocalPlayerData(playerId, 0);

        // grant the player some starting resources
        var initialResources :Array = GameContext.spLevel.initialResources;
        for (var resType :uint = 0; resType < initialResources.length; ++resType) {
            localPlayerData.setResourceAmount(resType, int(initialResources[resType]));
        }

        GameContext.playerData.push(localPlayerData);

        // create computer players
        var numComputers :uint = GameContext.spLevel.computers.length;
        for (var playerId :uint = 1; playerId < numComputers + 1; ++playerId) {
            var cpData :ComputerPlayerData = GameContext.spLevel.computers[playerId - 1];
            var playerData :PlayerData = new PlayerData(playerId, cpData.team);
            GameContext.playerData.push(playerData);

            // create the computer player object
            GameContext.netObjects.addObject(new ComputerPlayer(cpData, playerId));
        }

        // setup target enemies
        for each (playerData in GameContext.playerData) {
            playerData.targetedEnemyId = GameContext.findEnemyForPlayer(playerData.playerId).playerId;
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
            var playerData :PlayerData = ArrayUtil.findIf(GameContext.playerData,
                function (data :PlayerData) :Boolean {
                    return data.whirledId == e.occupantId;
                });

            if (null != playerData) {
                playerData.leftGame = true;
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
        _messageMgr.addMessageFactory(CastSpellMessage.messageName, CastSpellMessage.createFactory());

        if (Constants.DEBUG_CHECKSUM_STATE >= 1) {
            _messageMgr.addMessageFactory(ChecksumMessage.messageName, ChecksumMessage.createFactory());
        }

        _messageMgr.setup();

        // create players' unit spell sets (these are synchronized objects)
        GameContext.playerUnitSpellSets = [];
        for (var playerId :uint = 0; playerId < GameContext.numPlayers; ++playerId) {
            var spellSet :SpellSet = new SpellSet();
            GameContext.netObjects.addObject(spellSet);
            GameContext.playerUnitSpellSets.push(spellSet);
        }
    }

    protected function shutdownNetwork () :void
    {
        _messageMgr.shutdown();
    }

    protected function setupPuzzleAndUI () :void
    {
        var resourceDisplay :ResourceDisplay = new ResourceDisplay();
        resourceDisplay.displayObject.x = Constants.RESOURCE_DISPLAY_LOC.x;
        resourceDisplay.displayObject.y = Constants.RESOURCE_DISPLAY_LOC.y;

        this.addObject(resourceDisplay, this.modeSprite);

        var puzzleBoard :PuzzleBoard = new PuzzleBoard(
            Constants.PUZZLE_COLS,
            Constants.PUZZLE_ROWS,
            Constants.PUZZLE_TILE_SIZE);

        puzzleBoard.displayObject.x = Constants.PUZZLE_BOARD_LOC.x;
        puzzleBoard.displayObject.y = Constants.PUZZLE_BOARD_LOC.y;

        this.addObject(puzzleBoard, this.modeSprite);

        _descriptionPopupParent = new Sprite();
        _descriptionPopupParent.x = Constants.UNIT_AND_SPELL_DESCRIPTION_BR_LOC.x;
        _descriptionPopupParent.y = Constants.UNIT_AND_SPELL_DESCRIPTION_BR_LOC.y;
        this.modeSprite.addChild(_descriptionPopupParent);

        this.addObject(new UnitPurchaseButtonManager());
        this.addObject(new SpellCastButtonManager());
    }

    protected function setupBattle () :void
    {
        // Board
        var battleBoard :BattleBoard = new BattleBoard(Constants.BATTLE_WIDTH, Constants.BATTLE_HEIGHT);

        var battleBoardView :BattleBoardView = new BattleBoardView(Constants.BATTLE_WIDTH, Constants.BATTLE_HEIGHT);
        battleBoardView.displayObject.x = Constants.BATTLE_BOARD_LOC.x;
        battleBoardView.displayObject.y = Constants.BATTLE_BOARD_LOC.y;

        this.addObject(battleBoardView, this.modeSprite);

        GameContext.battleBoard = battleBoard;
        GameContext.battleBoardView = battleBoardView;

        // create player bases
        var numPlayers :int = GameContext.numPlayers;
        var baseLocs :Array = GameContext.gameData.getBaseLocsForGameSize(numPlayers);
        for (var playerId :int = 0; playerId < numPlayers; ++playerId) {

            // in single-player levels, bases have custom health
            var overrideMaxHealth :Boolean;
            var maxHealth :int;
            if (GameContext.isSinglePlayer) {
                overrideMaxHealth = true;
                maxHealth = (playerId == 0 ?
                    GameContext.spLevel.playerBaseHealth :
                    ComputerPlayerData(GameContext.spLevel.computers[playerId - 1]).baseHealth);
            }

            var base :PlayerBaseUnit = UnitFactory.createBaseUnit(playerId, overrideMaxHealth, maxHealth);

            var baseLoc :Vector2 = baseLocs[playerId];
            base.unitSpawnLoc = baseLoc;
            base.x = baseLoc.x;
            base.y = baseLoc.y;

            var playerData :PlayerData = GameContext.playerData[playerId];
            playerData.base = base;
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
            this.addObject(diurnalMeter, this.modeSprite);
        }
    }

    protected function setupPostRandSeedReceived () :void
    {
        // any game setup that requires the RNG to be initialized must
        // be run in this function, and not before, to prevent the game from
        // getting out of synch
        this.scheduleNextSpellPickup();
    }

    protected function scheduleNextSpellPickup () :void
    {
        var time :Number = GameContext.gameData.spellObjectTimerLength.next();
        if (time >= 0) {
            this.addObject(new SimpleTimer(time, createNextSpellPickup));
        }
    }

    protected function createNextSpellPickup () :void
    {
        // find a location roughly in the center of the player bases
        var loc :Vector2 = new Vector2();
        var numBases :int;
        for each (var playerData :PlayerData in GameContext.playerData) {
            var playerBase :PlayerBaseUnit = playerData.base;
            if (null != playerBase) {
                loc.addLocal(playerBase.unitLoc);
                ++numBases;
            }
        }

        if (numBases > 0) {
            loc.x /= numBases;
            loc.y /= numBases;

            // randomize the location a bit
            var direction :Number = Rand.nextNumberRange(0, Math.PI * 2, Rand.STREAM_GAME);
            var length :Number = GameContext.gameData.spellObjectDistanceSpread.next();
            loc.addLocal(Vector2.fromAngle(direction, length));

            // pick a spell at random
            var spellType :uint = Rand.nextIntRange(0, Constants.SPELL_NAMES.length, Rand.STREAM_GAME);
            SpellPickupFactory.createSpellPickup(spellType, loc);

            // schedule the next one
            this.scheduleNextSpellPickup();
        }
    }

    protected function onKeyDown (e :KeyboardEvent) :void
    {
       switch (e.keyCode) {
        case KeyboardCodes.NUMBER_4:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                for (var i :uint = 0; i < Constants.RESOURCE__LIMIT; ++i) {
                    GameContext.localPlayerData.offsetResourceAmount(i, 500);
                }
            }
            break;

        case KeyboardCodes.NUMBER_5:
            if (null != _debugDataView) {
                _debugDataView.visible = !(_debugDataView.visible);
            }
            break;

        // temp
        case KeyboardCodes.B:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                this.castSpell(GameContext.localPlayerId, Constants.SPELL_TYPE_BLOODLUST);
            }
            break;

        // temp
        case KeyboardCodes.R:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                this.castSpell(GameContext.localPlayerId, Constants.SPELL_TYPE_RIGORMORTIS);
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
        // don't start doing anything until the messageMgr is ready
        if (!_gameIsRunning && _messageMgr.isReady) {
            log.info("Starting game. randomSeed: " + _messageMgr.randomSeed);
            Rand.seedStream(Rand.STREAM_GAME, _messageMgr.randomSeed);

            this.setupPostRandSeedReceived();

            _gameIsRunning = true;
        }

        if (!_gameIsRunning) {
            return;
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

            ++_tickCount;
        }

        // The game is over if there's only one team standing
        var liveTeams :HashSet = new HashSet();
        var livePlayer :PlayerData;
        var livePlayerCount :int;

        for each (var playerData :PlayerData in GameContext.playerData) {
            if (!playerData.leftGame && playerData.isAlive) {
                livePlayer = playerData;
                livePlayerCount++;

                liveTeams.add(playerData.teamId);
                if (liveTeams.size() > 1) {
                    break;
                }
            }
        }

        if (liveTeams.size() <= 1) {
            // show the appropriate game over screen
            if (GameContext.isMultiplayer) {
                MainLoop.instance.changeMode(new GameOverMode(livePlayer));
            } else {
                var success :Boolean = (null != livePlayer && livePlayer.playerId == GameContext.localPlayerId);
                MainLoop.instance.pushMode(new LevelOutroMode(success));
            }
        }

        // update all non-net objects
        super.update(dt);

        if (sortDisplayChildren) {
            GameContext.battleBoardView.sortUnitDisplayChildren();
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
            log.debug("PLAYER: " + GameContext.localPlayerId + " TICK: " + _tickCount + " MESSAGES: " + messageStatus);
        }

        // calculate a checksum for this frame
        var csumMessage :ChecksumMessage = calculateChecksum();

        // player 1 saves his checksums, player 0 sends his checksums
        if (GameContext.localPlayerId == 1) {
            _myChecksums.unshift(csumMessage);
            _lastCachedChecksumTick = _tickCount;
        } else if ((_tickCount % 2) == 0) {
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
        msg.tick = _tickCount;
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
            break;

        case SelectTargetEnemyMessage.messageName:
            var selectTargetEnemyMsg :SelectTargetEnemyMessage = msg as SelectTargetEnemyMessage;
            this.setTargetEnemy(selectTargetEnemyMsg.playerId, selectTargetEnemyMsg.targetPlayerId);
            break;

        case CastSpellMessage.messageName:
            var castSpellMsg :CastSpellMessage = msg as CastSpellMessage;
            var spellSet :SpellSet = GameContext.playerUnitSpellSets[castSpellMsg.playerId];
            var spell :SpellData = GameContext.gameData.spells[castSpellMsg.spellType];
            spellSet.addSpell(spell.clone());
            break;

        case ChecksumMessage.messageName:
            this.handleChecksumMessage(msg as ChecksumMessage);
            break;
        }

    }

    protected function setTargetEnemy (playerId :uint, targetEnemyId :uint) :void
    {
        var playerData :PlayerData = GameContext.playerData[playerId];
        playerData.targetedEnemyId = targetEnemyId;

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
        var localPlayerData :PlayerData = GameContext.localPlayerData;
        var baseViews :Array = PlayerBaseUnitView.getAll();
        for each (var baseView :PlayerBaseUnitView in baseViews) {
            var owningPlayerId :uint = baseView.baseUnit.owningPlayerId;
            var owningPlayerData :PlayerData = GameContext.playerData[owningPlayerId];
            baseView.targetEnemyBadgeVisible = (owningPlayerId == localPlayerData.targetedEnemyId);
            baseView.friendlyBadgeVisible = (owningPlayerId == GameContext.localPlayerId);

            if (localPlayerData.teamId != owningPlayerData.teamId) {
                (baseView.displayObject as InteractiveObject).addEventListener(
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
        var localPlayerData :PlayerData = GameContext.localPlayerData;
        var newTargetEnemyId :uint = enemyBaseView.baseUnit.owningPlayerId;

        Assert.isTrue(newTargetEnemyId != GameContext.localPlayerId);

        if (newTargetEnemyId != localPlayerData.targetedEnemyId) {
            // update the "target enemy badge" location immediately, even though
            // the change won't be reflected in the game logic until the message round-trips
            this.updateTargetEnemyBadgeLocation(newTargetEnemyId);

            // send a message to everyone
            _messageMgr.sendMessage(new SelectTargetEnemyMessage(GameContext.localPlayerId, newTargetEnemyId));
        }

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
        var localPlayerPurchasing :Boolean = playerId == GameContext.localPlayerId;

        if (GameContext.diurnalCycle.isDay || (localPlayerPurchasing && !GameContext.localPlayerData.canPurchaseUnit(unitType))) {
            return;
        }

        if (localPlayerPurchasing) {
            // deduct the cost of the unit from the player's holdings
            var creatureCosts :Array = (GameContext.gameData.units[unitType] as UnitData).resourceCosts;
            var n :int = creatureCosts.length;
            for (var resourceType:uint = 0; resourceType < n; ++resourceType) {
                GameContext.localPlayerData.offsetResourceAmount(resourceType, -creatureCosts[resourceType]);
            }
        }

        // send a message!
        _messageMgr.sendMessage(new CreateUnitMessage(playerId, unitType));
    }

    public function castSpell (playerId :uint, spellType :uint) :void
    {
        _messageMgr.sendMessage(new CastSpellMessage(playerId, spellType));
    }

    public function get descriptionPopupParent () :Sprite
    {
        return _descriptionPopupParent;
    }

    protected var _gameIsRunning :Boolean;

    protected var _messageMgr :TickedMessageManager;
    protected var _debugDataView :DebugDataView;
    protected var _descriptionPopupParent :Sprite;

    protected var _tickCount :uint;
    protected var _myChecksums :RingBuffer = new RingBuffer(CHECKSUM_BUFFER_LENGTH);
    protected var _lastCachedChecksumTick :int;
    protected var _syncError :Boolean;

    protected static const TICK_INTERVAL_MS :int = 100; // 1/10 of a second
    protected static const TICK_INTERVAL_S :Number = (Number(TICK_INTERVAL_MS) / Number(1000));

    protected static const CHECKSUM_BUFFER_LENGTH :int = 10;

    protected static const log :Log = Log.getLog(GameMode);
}

}
