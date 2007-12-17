package popcraft {

import core.AppMode;
import core.MainLoop;
import core.util.Rand;

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

        _messageMgr = new TickedMessageManager(PopCraft.instance.gameControl);
        _messageMgr.addMessageFactory(CreateUnitMessage.messageName, CreateUnitMessage.createFactory());
        _messageMgr.setup((0 == _playerData.playerId), TICK_INTERVAL_MS);

        // create a special AppMode for all objects that are synchronized over the network.
        // we will manage this mode ourselves.
        _netObjects = new AppMode();

        // create the player bases
        var baseLocs :Array = Constants.getPlayerBaseLocations(numPlayers);
        var player :uint = 0;
        for each (var loc :Vector2 in baseLocs) {
            var base :PlayerBaseUnit = new PlayerBaseUnit(player, loc);
            var baseId :uint = _netObjects.addObject(base, _battleBoard.displayObjectContainer);

            _playerBaseIds.push(baseId);

            trace("adding base " + baseId);

            ++player;
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
        }


        // update all non-net objects
        super.update(dt);
    }

    public function getPlayerBase (player :uint) :PlayerBaseUnit
    {
        return (_netObjects.getObject(_playerBaseIds[player]) as PlayerBaseUnit);
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

    protected var _gameIsRunning :Boolean;

    protected var _messageMgr :TickedMessageManager;
    protected var _puzzleBoard :PuzzleBoard;
    protected var _battleBoard :BattleBoard;
    protected var _playerData :PlayerData;

    protected var _netObjects :AppMode;

    protected var _playerBaseIds :Array = new Array();

    protected static const TICK_INTERVAL_MS :int = 100; // 1/10 of a second
    protected static const TICK_INTERVAL_S :Number = (Number(TICK_INTERVAL_MS) / Number(1000));
}

}
