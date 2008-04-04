package popcraft {

import com.threerings.flash.Vector2;
import com.threerings.util.Assert;
import com.threerings.util.Log;
import com.threerings.util.RingBuffer;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.DisplayObjectContainer;
import flash.events.KeyboardEvent;

import popcraft.battle.*;
import popcraft.battle.geom.AttractRepulseGrid;
import popcraft.net.*;
import popcraft.puzzle.*;

public class GameMode extends AppMode
{
    public static function get instance () :GameMode
    {
        var instance :GameMode = (MainLoop.instance.topMode as GameMode);

        Assert.isNotNull(instance);

        return instance;
    }

    public static function getNetObjectNamed (objectName :String) :SimObject
    {
        return GameMode.instance.netObjects.getObjectNamed(objectName);
    }

    public static function getNetObjectRefsInGroup (groupName :String) :Array
    {
        return GameMode.instance.netObjects.getObjectRefsInGroup(groupName);
    }

    override protected function setup () :void
    {
        // get some information about the players in the game
        var numPlayers :int = PopCraft.instance.gameControl.game.seating.getPlayerIds().length;
        _localPlayerId = PopCraft.instance.gameControl.game.seating.getMyPosition();
        var isAPlayer :Boolean = (_localPlayerId >= 0);
        var isFirstPlayer :Boolean = (_localPlayerId == 0);

        // create PlayerData structures
        for (var playerId :uint = 0; playerId < numPlayers; ++playerId) {

            var playerData :PlayerData =
                (playerId == _localPlayerId ?
                    new LocalPlayerData(playerId) :
                    new PlayerData(playerId));

            // setup initial player targets
            playerData.targetedEnemyId = (playerId + 1 < numPlayers ? playerId + 1 : 0);

            _playerData.push(playerData);
        }

        this.setupNetwork(isFirstPlayer);

        this.setupBattleUI();

        // create player bases
        var baseLocs :Array = Constants.getPlayerBaseLocations(numPlayers);
        for (playerId = 0; playerId < numPlayers; ++playerId) {
            var baseLoc :Vector2 = baseLocs[playerId];
            var base :PlayerBaseUnit = (UnitFactory.createUnit(Constants.UNIT_TYPE_BASE, playerId) as PlayerBaseUnit);
            base.unitSpawnLoc = baseLoc;
            base.x = baseLoc.x;
            base.y = baseLoc.y;

            playerData = _playerData[playerId];
            playerData.base = base;
        }

        if (isAPlayer) {
            this.setupPuzzleUI();
        }

        // Listen for all keydowns.
        // The suggested way to do this is to attach an event listener to the stage,
        // but that's a security violation. The GameControl re-dispatches global key events for us instead.
        PopCraft.instance.gameControl.local.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, false);

        if (Constants.DEBUG_DRAW_STATS) {
            _debugDataView = new DebugDataView();
            this.addObject(_debugDataView, this.modeSprite);
        }
    }

    override protected function destroy () :void
    {
        PopCraft.instance.gameControl.local.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);

        if (null != _messageMgr) {
            _messageMgr.shutdown();
            _messageMgr = null;
        }
    }

    protected function setupNetwork (isFirstPlayer :Boolean) :void
    {
        _messageMgr = new TickedMessageManager(PopCraft.instance.gameControl);
        _messageMgr.addMessageFactory(CreateUnitMessage.messageName, CreateUnitMessage.createFactory());

        if (Constants.DEBUG_CHECKSUM_STATE >= 1) {
            _messageMgr.addMessageFactory(ChecksumMessage.messageName, ChecksumMessage.createFactory());
        }

        _messageMgr.setup(isFirstPlayer, TICK_INTERVAL_MS);

        // create a special ObjectDB for all objects that are synchronized over the network.
        _netObjects = new NetObjectDB();
    }

    protected function setupPuzzleUI () :void
    {
        var resourceDisplay :ResourceDisplay = new ResourceDisplay();
        resourceDisplay.displayObject.x = Constants.RESOURCE_DISPLAY_LOC.x;
        resourceDisplay.displayObject.y = Constants.RESOURCE_DISPLAY_LOC.y;

        this.addObject(resourceDisplay, this.modeSprite);

        _puzzleBoard = new PuzzleBoard(
            Constants.PUZZLE_COLS,
            Constants.PUZZLE_ROWS,
            Constants.PUZZLE_TILE_SIZE);

        _puzzleBoard.displayObject.x = Constants.PUZZLE_BOARD_LOC.x;
        _puzzleBoard.displayObject.y = Constants.PUZZLE_BOARD_LOC.y;

        this.addObject(_puzzleBoard, this.modeSprite);

        // create the unit purchase buttons
        this.addObject(new UnitPurchaseButtonManager());
    }

    protected function setupBattleUI () :void
    {
        _battleBoard = new BattleBoard(Constants.BATTLE_WIDTH, Constants.BATTLE_HEIGHT);

        _battleBoard.displayObject.x = Constants.BATTLE_BOARD_LOC.x;
        _battleBoard.displayObject.y = Constants.BATTLE_BOARD_LOC.y;

        this.addObject(_battleBoard, this.modeSprite);
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
                    this.localPlayerData.offsetResourceAmount(i, 100);
                }
            }
            break;

        case KEY_5:
            if (null != _debugDataView) {
                _debugDataView.visible = !(_debugDataView.visible);
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

        while (_messageMgr.hasUnprocessedTicks) {

            // process all messages from this tick
            var messageArray: Array = _messageMgr.getNextTick();
            for each (var msg :Message in messageArray) {
                handleMessage(msg);
            }

            // run the simulation the appropriate amount
            // (our network update time is unrelated to the application's update time.
            // network timeslices are always the same distance apart)
            _netObjects.update(TICK_INTERVAL_S);

            if (Constants.DEBUG_CHECKSUM_STATE >= 1) {
                debugNetwork(messageArray);
            }

            ++_tickCount;

            // The game is over if there's only one man standing
            var livePlayerId :int = -1;
            var livePlayerCount :int;

            for each (var playerData :PlayerData in _playerData) {
                if (playerData.isAlive) {
                    livePlayerId = playerData.playerId;

                    if (++livePlayerCount > 1) {
                        break;
                    }
                }
            }

            if (livePlayerCount <= 1) {
                MainLoop.instance.changeMode(new GameOverMode(livePlayerId));
            }
        }

        // update all non-net objects
        super.update(dt);
    }

    public function getPlayerData (playerId :uint) :PlayerData
    {
        return _playerData[playerId];
    }

    public function get numPlayers () :int
    {
        return _playerData.length;
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
            log.debug("PLAYER: " + _localPlayerId + " TICK: " + _tickCount + " MESSAGES: " + messageStatus);
        }

        // calculate a checksum for this frame
        var csumMessage :ChecksumMessage = calculateChecksum();

        // player 1 saves his checksums, player 0 sends his checksums
        if (_localPlayerId == 1) {
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

        msg.playerId = _localPlayerId;
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
            UnitFactory.createUnit(createUnitMsg.unitType, createUnitMsg.owningPlayer);
            break;

        case ChecksumMessage.messageName:
            this.handleChecksumMessage(msg as ChecksumMessage);
            break;
        }

    }

    protected function handleChecksumMessage (msg :ChecksumMessage) :void
    {
        if (msg.playerId != _localPlayerId) {
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

    public function purchaseUnit (unitType :uint) :void
    {
        if (!this.localPlayerData.canPurchaseUnit(unitType)) {
            return;
        }

        // deduct the cost of the unit from the player's holdings
        var creatureCosts :Array = (Constants.UNIT_DATA[unitType] as UnitData).resourceCosts;
        var n :int = creatureCosts.length;
        for (var resourceType:uint = 0; resourceType < n; ++resourceType) {
            this.localPlayerData.offsetResourceAmount(resourceType, -creatureCosts[resourceType]);
        }

        // send a message!
        _messageMgr.sendMessage(new CreateUnitMessage(unitType, _localPlayerId));
    }

    public function get localPlayerData () :LocalPlayerData
    {
        return _playerData[_localPlayerId];
    }

    public function get netObjects () :ObjectDB
    {
        return _netObjects;
    }

    public function get messageManager () :TickedMessageManager
    {
        return _messageMgr;
    }

    public function get battleUnitDisplayParent () :DisplayObjectContainer
    {
        return _battleBoard.unitDisplayParent;
    }

    public function get battleCollisionGrid () :AttractRepulseGrid
    {
        return _battleBoard.collisionGrid;
    }

    protected var _gameIsRunning :Boolean;

    protected var _playerData :Array = [];
    protected var _localPlayerId :uint;

    protected var _messageMgr :TickedMessageManager;
    protected var _puzzleBoard :PuzzleBoard;
    protected var _battleBoard :BattleBoard;
    protected var _debugDataView :DebugDataView;

    protected var _netObjects :ObjectDB;

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
