package popcraft {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.threerings.util.Log;
import com.threerings.util.RingBuffer;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.contrib.simplegame.util.*;
import com.whirled.game.OccupantChangedEvent;

import flash.display.InteractiveObject;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import popcraft.battle.*;
import popcraft.battle.view.*;
import popcraft.net.*;
import popcraft.puzzle.*;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        GameContext.gameMode = this;

        this.setupPlayers();
        this.setupNetwork();
        this.setupBattle();
        if (GameContext.localUserIsPlaying) {
            this.setupPuzzle();
        }

        // Listen for all keydowns.
        // The suggested way to do this is to attach an event listener to the stage,
        // but that's a security violation. The GameControl re-dispatches global key
        // events for us instead.
        PopCraft.instance.gameControl.local.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

        if (Constants.DEBUG_DRAW_STATS) {
            _debugDataView = new DebugDataView();
            this.addObject(_debugDataView, this.modeSprite);
            _debugDataView.visible = false;
        }
    }

    override protected function destroy () :void
    {
        PopCraft.instance.gameControl.game.removeEventListener(OccupantChangedEvent.OCCUPANT_LEFT,
            handleOccupantLeft);

        PopCraft.instance.gameControl.local.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

        if (null != _messageMgr) {
            _messageMgr.shutdown();
            _messageMgr = null;
        }
    }

    protected function setupPlayers () :void
    {
        // get some information about the players in the game
        var numPlayers :int = PopCraft.instance.gameControl.game.seating.getPlayerIds().length;
        GameContext.localPlayerId = PopCraft.instance.gameControl.game.seating.getMyPosition();

        // create PlayerData structures
        GameContext.playerData = [];
        for (var playerId :uint = 0; playerId < numPlayers; ++playerId) {

            var playerData :PlayerData =
                (playerId == GameContext.localPlayerId ?
                    new LocalPlayerData(playerId) :
                    new PlayerData(playerId));

            // setup initial player targets
            playerData.targetedEnemyId = (playerId + 1 < numPlayers ? playerId + 1 : 0);

            GameContext.playerData.push(playerData);
        }

        // we want to know when a player leaves
        PopCraft.instance.gameControl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT,
            handleOccupantLeft);
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
        // create a special ObjectDB for all objects that are synchronized over the network.
        GameContext.netObjects = new NetObjectDB();

        // set up the message manager
        _messageMgr = new OnlineTickedMessageManager(PopCraft.instance.gameControl,
            GameContext.isFirstPlayer, TICK_INTERVAL_MS);
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
            var spellSet :UnitSpellSet = new UnitSpellSet();
            GameContext.netObjects.addObject(spellSet);
            GameContext.playerUnitSpellSets.push(spellSet);
        }
    }

    protected function setupPuzzle () :void
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

        // create the unit purchase buttons
        this.addObject(new UnitPurchaseButtonManager());
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
        var baseLocs :Array = Constants.getPlayerBaseLocations(numPlayers);
        for (var playerId :int = 0; playerId < numPlayers; ++playerId) {
            var baseLoc :Vector2 = baseLocs[playerId];
            var base :PlayerBaseUnit =
                (UnitFactory.createUnit(Constants.UNIT_TYPE_BASE, playerId) as PlayerBaseUnit);
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

        if (!Constants.DEBUG_DISABLE_DIURNAL_CYCLE) {
            var diurnalMeter :DiurnalMeterView = new DiurnalMeterView();
            diurnalMeter.x = Constants.DIURNAL_METER_LOC.x;
            diurnalMeter.y = Constants.DIURNAL_METER_LOC.y;
            this.addObject(diurnalMeter, this.modeSprite);
        }

    }

    // there has to be a better way to figure out charCodes
    protected static const KEY_4 :uint = "4".charCodeAt(0);
    protected static const KEY_5 :uint = "5".charCodeAt(0);
    protected function onKeyDown (e :KeyboardEvent) :void
    {
        switch (e.charCode) {
        case KEY_4:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                for (var i :uint = 0; i < Constants.RESOURCE__LIMIT; ++i) {
                    GameContext.localPlayerData.offsetResourceAmount(i, 500);
                }
            }
            break;

        case KEY_5:
            if (null != _debugDataView) {
                _debugDataView.visible = !(_debugDataView.visible);
            }
            break;

        // temp
        case "b".charCodeAt(0):
            if (Constants.DEBUG_ALLOW_CHEATS) {
                this.castSpell(GameContext.localPlayerId, Constants.SPELL_TYPE_BLOODLUST);
            }
            break;

        // temp
        case "r".charCodeAt(0):
            if (Constants.DEBUG_ALLOW_CHEATS) {
                this.castSpell(GameContext.localPlayerId, Constants.SPELL_TYPE_RIGORMORTIS);
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

        // The game is over if there's only one man standing
        var livePlayer :PlayerData;
        var livePlayerCount :int;

        for each (var playerData :PlayerData in GameContext.playerData) {
            if (!playerData.leftGame && playerData.isAlive) {
                livePlayer = playerData;
                if (++livePlayerCount > 1) {
                    break;
                }
            }
        }

        if (livePlayerCount <= 1) {
            MainLoop.instance.changeMode(new GameOverMode(livePlayer));
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
            UnitFactory.createUnit(createUnitMsg.unitType, createUnitMsg.playerId);
            break;

        case SelectTargetEnemyMessage.messageName:
            var selectTargetEnemyMsg :SelectTargetEnemyMessage = msg as SelectTargetEnemyMessage;
            this.setTargetEnemy(selectTargetEnemyMsg.playerId, selectTargetEnemyMsg.targetPlayerId);
            break;

        case CastSpellMessage.messageName:
            var castSpellMsg :CastSpellMessage = msg as CastSpellMessage;
            var spellSet :UnitSpellSet = GameContext.playerUnitSpellSets[castSpellMsg.playerId];
            spellSet.addSpell(Constants.UNIT_SPELLS[castSpellMsg.spellType]);
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
            baseView.targetEnemyBadgeVisible = (owningPlayerId == localPlayerData.targetedEnemyId);
            baseView.friendlyBadgeVisible = (owningPlayerId == GameContext.localPlayerId);

            if (GameContext.localPlayerId != owningPlayerId) {
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
        if (GameContext.diurnalCycle.isDay || !GameContext.localPlayerData.canPurchaseUnit(unitType)) {
            return;
        }

        // deduct the cost of the unit from the player's holdings
        var creatureCosts :Array = (Constants.UNIT_DATA[unitType] as UnitData).resourceCosts;
        var n :int = creatureCosts.length;
        for (var resourceType:uint = 0; resourceType < n; ++resourceType) {
            GameContext.localPlayerData.offsetResourceAmount(resourceType, -creatureCosts[resourceType]);
        }

        // send a message!
        _messageMgr.sendMessage(new CreateUnitMessage(playerId, unitType));
    }

    public function castSpell (playerId :uint, spellType :uint) :void
    {
        _messageMgr.sendMessage(new CastSpellMessage(playerId, spellType));
    }

    protected var _gameIsRunning :Boolean;

    protected var _messageMgr :TickedMessageManager;
    protected var _debugDataView :DebugDataView;

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
