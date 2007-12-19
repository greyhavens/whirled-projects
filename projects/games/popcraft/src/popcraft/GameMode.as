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
import com.threerings.parlor.game.data.GameObject;

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

    }

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

            // calculate a checksum for this frame
            var csum :uint = calculateChecksum();

            trace(
                "(playerId: " + _playerData.playerId + ") " +
                "(tick: " + _tickCount + ") " +
                "(checksum: " + csum + ") "
                );

            ++_tickCount;
        }


        // update all non-net objects
        super.update(dt);
    }

    public function getPlayerBase (player :uint) :PlayerBaseUnit
    {
        return (_netObjects.getObject(_playerBaseIds[player]) as PlayerBaseUnit);
    }

    protected function calculateChecksum () :uint
    {
        // iterate over all the shared state and calculate
        // a simple checksum for it
        var csum :Checksum = new Checksum();

        // waypoints
        csum.add(_playerWaypoints.length);
        for each (var waypoint :Point in _playerWaypoints) {
            csum.add(waypoint.x);
            csum.add(waypoint.y);
        }

        // units
        var units :Array = _netObjects.getObjectsInGroup(Unit.GROUP_NAME).toArray();
        csum.add(units.length);
        for each (var unit :Unit in units) {
            csum.add(unit.owningPlayerId);
            csum.add(unit.unitType);
            csum.add(unit.displayObject.x);
            csum.add(unit.displayObject.y);
            csum.add(unit.health);
        }

        return csum.value;
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

    // from core.AppMode
    override public function destroy () :void
    {
        if (null != _messageMgr) {
            _messageMgr.shutdown();
            _messageMgr = null;
        }
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

    protected static const TICK_INTERVAL_MS :int = 100; // 1/10 of a second
    protected static const TICK_INTERVAL_S :Number = (Number(TICK_INTERVAL_MS) / Number(1000));
}

}
