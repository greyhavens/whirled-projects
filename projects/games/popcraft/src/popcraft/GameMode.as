package popcraft {

import core.*;
import core.util.*;

import popcraft.net.*;
import popcraft.puzzle.*;
import popcraft.battle.*;

import com.threerings.util.Assert;
import com.threerings.flash.DisablingButton;

import flash.display.SimpleButton;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.TextField;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

public class GameMode extends AppMode
{
    public static function get instance () :GameMode
    {
        var instance :GameMode = (MainLoop.instance.topMode as GameMode);

        Assert.isNotNull(instance);

        return instance;
    }

    public function GameMode ()
    {
    }

    // from core.AppMode
    override public function setup () :void
    {
        var myPosition :int = PopCraft.instance.gameControl.seating.getMyPosition();
        var isAPlayer :Boolean = (myPosition >= 0);
        var numPlayers :int = PopCraft.instance.gameControl.seating.getPlayerIds().length;

        // only players get puzzles
        if (isAPlayer) {
            _playerData = new PlayerData(uint(myPosition));

            var resourceDisplay :ResourceDisplay = new ResourceDisplay();
            resourceDisplay.displayObject.x = Constants.RESOURCE_DISPLAY_LOC.x;
            resourceDisplay.displayObject.y = Constants.RESOURCE_DISPLAY_LOC.y;

            this.addObject(resourceDisplay, this);

            _puzzleBoard = new PuzzleBoard(
                Constants.PUZZLE_COLS,
                Constants.PUZZLE_ROWS,
                Constants.PUZZLE_TILE_SIZE);

            _puzzleBoard.displayObject.x = Constants.PUZZLE_BOARD_LOC.x;
            _puzzleBoard.displayObject.y = Constants.PUZZLE_BOARD_LOC.y;

            this.addObject(_puzzleBoard, this);

            // create the unit purchase buttons
            this.addObject(new UnitPurchaseButtonManager());
       }

        // everyone gets to see the BattleBoard
        _battleBoard = new BattleBoard(
            Constants.BATTLE_COLS,
            Constants.BATTLE_ROWS,
            Constants.BATTLE_TILE_SIZE);

        _battleBoard.displayObject.x = Constants.BATTLE_BOARD_LOC.x;
        _battleBoard.displayObject.y = Constants.BATTLE_BOARD_LOC.y;

        this.addObject(_battleBoard, this);

        // set up some network stuff
        _messageMgr = new TickedMessageManager(PopCraft.instance.gameControl);
        _messageMgr.addMessageFactory(CreateUnitMessage.messageName, CreateUnitMessage.createFactory());
        _messageMgr.addMessageFactory(PlaceWaypointMessage.messageName, PlaceWaypointMessage.createFactory());

        if (Constants.DEBUG_LEVEL >= 1) {
            _messageMgr.addMessageFactory(ChecksumMessage.messageName, ChecksumMessage.createFactory());
        }

        _messageMgr.setup((0 == _playerData.playerId), TICK_INTERVAL_MS);

        // create a special AppMode for all objects that are synchronized over the network.
        // we will manage this mode ourselves.
        _netObjects = new AppMode();

        // create the player bases & waypoints
        var baseLocs :Array = Constants.getPlayerBaseLocations(numPlayers);
        var playerId :uint = 0;
        for each (var loc :Vector2 in baseLocs) {
            var base :PlayerBaseUnit = new PlayerBaseUnit(playerId, loc);
            var baseId :uint = _netObjects.addObject(base, _battleBoard.displayObjectContainer);

            _playerBaseIds.push(baseId);

            // waypoint
            _playerWaypoints.push(loc.toPoint());

            // create a visual representation of the waypoint
            // if it belongs to us
            if (playerId == _playerData.playerId) {
                _waypointMarker = new WaypointMarker(playerId);
                _waypointMarker.displayObject.x = loc.x;
                _waypointMarker.displayObject.y = loc.y;

                this.addObject(_waypointMarker, _battleBoard.displayObjectContainer);
            }

            ++playerId;
        }

        // Listen for all keydowns.
        // The suggested way to do this is to attach an event listener to the stage,
        // but that's a security violation. The GameControl re-dispatches global key events for us instead.
        PopCraft.instance.gameControl.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
    }

    // from core.AppMode
    override public function destroy () :void
    {
        PopCraft.instance.gameControl.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);

        if (null != _messageMgr) {
            _messageMgr.shutdown();
            _messageMgr = null;
        }
    }

    // there has to be a better way to figure out charCodes
    protected static const KEY_4 :uint = "4".charCodeAt(0);
    protected function onKeyDown (e :KeyboardEvent) :void
    {
        if (Constants.CHEATS_ENABLED) {
            switch (e.charCode) {
            case KEY_4:
                for (var i :uint = 0; i < Constants.RESOURCE__LIMIT; ++i) {
                    _playerData.offsetResourceAmount(i, 100);
                }
                break;
            }
        }
    }

    // from AppMode
    override public function update(dt :Number) :void
    {
        // don't start doing anything until the messageMgr is ready
        if (!_gameIsRunning && _messageMgr.isReady) {
            trace("Starting game. randomSeed: " + _messageMgr.randomSeed);
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

            if (Constants.DEBUG_LEVEL >= 1) {
                debugNetwork(messageArray);
            }

            ++_tickCount;
        }

        // update all non-net objects
        super.update(dt);
    }

    public function getPlayerBase (player :uint) :PlayerBaseUnit
    {
        return (_netObjects.getObject(_playerBaseIds[player]) as PlayerBaseUnit);
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
            trace("PLAYER: " + _playerData.playerId + " TICK: " + _tickCount + " MESSAGES: " + messageStatus);
        }

        // calculate a checksum for this frame
        var csumMessage :ChecksumMessage = calculateChecksum();

        // player 1 saves his checksums, player 0 sends his checksums
        if (_playerData.playerId == 1) {
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

        // waypoints
        add(_playerWaypoints.length, "_playerWaypoints.length");
        for (i = 0; i < _playerWaypoints.length; ++i) {
            var waypoint :Point = (_playerWaypoints[i] as Point);
            add(waypoint.x, "waypoint.x - " + i);
            add(waypoint.y, "waypoint.x - " + i);
        }

        // units
        var units :Array = _netObjects.getObjectsInGroup(Unit.GROUP_NAME);
        add(units.length, "units.length");
        for (i = 0; i < units.length; ++i) {
            var unit :Unit = (units[i] as Unit);
            add(unit.owningPlayerId, "unit.owningPlayerId - " + i);
            add(unit.unitType, "unit.unitType - " + i);
            add(unit.displayObject.x, "unit.displayObject.x - " + i);
            add(unit.displayObject.y, "unit.displayObject.y - " + i);
            add(unit.health, "unit.health - " + i);
        }

        msg.playerId = _playerData.playerId;
        msg.tick = _tickCount;
        msg.checksum = csum.value;

        return msg;

        var needsLinebreak :Boolean = false;

        function add (val :*, desc :String) :void
        {
            csum.add(val);

            if (Constants.DEBUG_LEVEL >= 2) {
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
            _netObjects.addObject(
                UnitFactory.createUnit(createUnitMsg.unitType, createUnitMsg.owningPlayer),
                _battleBoard.displayObjectContainer);
            break;

        case PlaceWaypointMessage.messageName:
            var placeWaypointMsg :PlaceWaypointMessage = (msg as PlaceWaypointMessage);
            var loc :Point = (_playerWaypoints[placeWaypointMsg.owningPlayerId] as Point);
            loc.x = placeWaypointMsg.xLoc;
            loc.y = placeWaypointMsg.yLoc;
            break;

        case ChecksumMessage.messageName:
            this.handleChecksumMessage(msg as ChecksumMessage);
            break;
        }

    }

    protected function handleChecksumMessage (msg :ChecksumMessage) :void
    {
        if (msg.playerId != _playerData.playerId) {
            // check this checksum against our checksum buffer
            if (msg.tick > _lastCachedChecksumTick || msg.tick <= (_lastCachedChecksumTick - _myChecksums.length)) {
                trace("discarding checksum message (too old or too new)");
            } else {
                var index :uint = (_lastCachedChecksumTick - msg.tick);
                var myChecksum :ChecksumMessage = (_myChecksums.at(index) as ChecksumMessage);
                if (myChecksum.checksum != msg.checksum) {
                    trace("** WARNING ** Mismatched checksums at tick " + msg.tick + "!");

                    // only dump the details once
                    if (!_syncError) {
                        trace("-- PLAYER " + myChecksum.playerId + " --");
                        trace(myChecksum.details);
                        trace("-- PLAYER " + msg.playerId + " --");
                        trace(msg.details);
                        _syncError = true;
                    }
                }
            }
        }
    }

    public function canPurchaseUnit (unitType :uint) :Boolean
    {
        var creatureCosts :Array = (Constants.UNIT_DATA[unitType] as UnitData).resourceCosts;
        for (var resourceType:uint = 0; resourceType < creatureCosts.length; ++resourceType) {
            if (_playerData.getResourceAmount(resourceType) < creatureCosts[resourceType]) {
                return false;
            }
        }

        return true;
    }

    public function purchaseUnit (unitType :uint) :void
    {
        if (!canPurchaseUnit(unitType)) {
            return;
        }

        // deduct the cost of the unit from the player's holdings
        var creatureCosts :Array = (Constants.UNIT_DATA[unitType] as UnitData).resourceCosts;
        for (var resourceType:uint = 0; resourceType < creatureCosts.length; ++resourceType) {
            _playerData.offsetResourceAmount(resourceType, -creatureCosts[resourceType]);
        }

        // send a message!
        _messageMgr.sendMessage(new CreateUnitMessage(unitType, _playerData.playerId));
    }

    public function placeWaypoint (x :uint, y :uint) :void
    {
        // drop redundant clicks
        if (_waypointMarker.displayObject.x == x && _waypointMarker.displayObject.y == y) {
            trace("dropping redundant waypoint placement message");
            return;
        }

        // move our waypoint marker immediately.
        // This causes our visual state to be slightly out of sync with the network state,
        // but hopefully not for too long. By the time the player buys a new unit, everything should
        // be caught up. (the visual state is not used for
        _waypointMarker.displayObject.x = x;
        _waypointMarker.displayObject.y = y;

        // send a message!
        _messageMgr.sendMessage(new PlaceWaypointMessage(_playerData.playerId, x, y));
    }

    public function getWaypointLoc (playerId :uint) :Point
    {
        return (_playerWaypoints[playerId] as Point);
    }

    public function get playerData () :PlayerData
    {
        return _playerData;
    }

    public function get netObjects () :AppMode
    {
        return _netObjects;
    }

    public function get messageManager () :TickedMessageManager
    {
        return _messageMgr;
    }

    protected var _gameIsRunning :Boolean;

    protected var _messageMgr :TickedMessageManager;
    protected var _puzzleBoard :PuzzleBoard;
    protected var _battleBoard :BattleBoard;
    protected var _playerData :PlayerData;

    protected var _netObjects :AppMode;

    protected var _playerBaseIds :Array = new Array();
    protected var _playerWaypoints :Array = new Array();
    protected var _waypointMarker :WaypointMarker;

    protected var _tickCount :uint;
    protected var _myChecksums :RingBuffer = new RingBuffer(CHECKSUM_BUFFER_LENGTH);
    protected var _lastCachedChecksumTick :int;
    protected var _syncError :Boolean;

    protected static const TICK_INTERVAL_MS :int = 100; // 1/10 of a second
    protected static const TICK_INTERVAL_S :Number = (Number(TICK_INTERVAL_MS) / Number(1000));

    protected static const CHECKSUM_BUFFER_LENGTH :int = 10;
}

}
