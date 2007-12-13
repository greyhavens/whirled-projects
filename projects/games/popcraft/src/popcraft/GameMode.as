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

            _puzzleBoard.displayObject.x = Constants.PUZZLE_LOC.x;
            _puzzleBoard.displayObject.y = Constants.PUZZLE_LOC.y;

            this.addObject(_puzzleBoard, this);

            // create the unit purchase buttons
            this.addObject(new UnitPurchaseButtonManager());
       }

        // everyone gets to see the BattleBoard
        _battleBoard = new BattleBoard(
            Constants.BATTLE_COLS,
            Constants.BATTLE_ROWS,
            Constants.BATTLE_TILE_SIZE);

        _battleBoard.displayObject.x = Constants.BATTLE_LOC.x;
        _battleBoard.displayObject.y = Constants.BATTLE_LOC.y;

        this.addObject(_battleBoard, this);

        _messageMgr = new TickedMessageManager(PopCraft.instance.gameControl);
        _messageMgr.addMessageFactory(CreateUnitMessage.messageName, CreateUnitMessage.createFactory());
        _messageMgr.setup((0 == _playerData.playerId), TICK_INTERVAL_MS);

        // create a special AppMode for all objects that are synchronized over the network.
        // we will manage this mode ourselves.
        _netObjects = new AppMode();

        // create the player bases
        var base1 :PlayerBase = new PlayerBase(100);
        base1.displayObject.y = 200;
        _netObjects.addObject(base1, _battleBoard.displayObjectContainer);
    }

    override public function update(dt :Number) :void
    {
        // don't start doing anything until the messageMgr is ready
        if (!_gameIsRunning && _messageMgr.isReady) {
            trace("Starting game. randomSeed=" + _messageMgr.randomSeed);
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
    override public function destroy() :void
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

    protected static function createUnitPurchaseButton (iconClass :Class, creatureType :uint) :DisablingButton
    {
        var data :UnitData = Constants.UNIT_DATA[creatureType];

        // how much does it cost?
        var costString :String = new String();
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            var resData :ResourceType = Constants.getResource(resType);
            var resCost :int = data.getResourceCost(resType);

            if (resCost == 0) {
                continue;
            }

            if (costString.length > 0) {
                costString += " ";
            }

            costString += (resData.name + " (" + data.getResourceCost(resType) + ")");
        }

        var button :DisablingButton = new DisablingButton();
        var outline :int = uint(0x000000);
        var background :int = uint(0xFFD800);
        var rolloverBackground :int = uint(0xCFAF00);
        var disabledBackground :int = uint(0x525252);

        button.upState = makeButtonFace(iconClass, costString, outline, background);
        button.overState = makeButtonFace(iconClass, costString, outline, rolloverBackground);
        button.downState = makeButtonFace(iconClass, costString, outline, rolloverBackground);
        button.downState.x = -1;
        button.downState.y = -1;
        button.disabledState = makeButtonFace(iconClass, costString, outline, disabledBackground, 0.5);
        button.hitTestState = button.upState;

        return button;
    }

    protected static function makeButtonFace (iconClass :Class, costString :String, foreground :uint, background :uint, iconAlpha :Number = 1.0) :Sprite
    {
        var face :Sprite = new Sprite();

        var icon :DisplayObject = new iconClass();
        icon.alpha = iconAlpha;

        face.addChild(icon);

        var costText :TextField = new TextField();
        costText.text = costString;
        costText.textColor = 0;
        costText.height = costText.textHeight + 2;
        costText.width = costText.textWidth + 3;
        costText.y = icon.height + 5;

        face.addChild(costText);

        var padding :int = 5;
        var w :Number = icon.width + 2 * padding;
        var h :Number = icon.height + 2 * padding;

        // draw our button background (and outline)
        face.graphics.beginFill(background);
        face.graphics.lineStyle(1, foreground);
        face.graphics.drawRect(0, 0, w, h);
        face.graphics.endFill();

        icon.x = padding;
        icon.y = padding;

        return face;
    }

    protected var _gameIsRunning :Boolean;

    protected var _messageMgr :TickedMessageManager;
    protected var _puzzleBoard :PuzzleBoard;
    protected var _battleBoard :BattleBoard;
    protected var _playerData :PlayerData;

    protected var _netObjects :AppMode;

    protected static const TICK_INTERVAL_MS :int = 100; // 1/10 of a second
    protected static const TICK_INTERVAL_S :Number = (Number(TICK_INTERVAL_MS) / Number(1000));
}

}
