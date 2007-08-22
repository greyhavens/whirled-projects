package {

import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.getTimer; // function import

import mx.containers.Canvas;
import mx.controls.Image;
import mx.controls.Label;

import com.threerings.util.ArrayUtil;

public class Display extends Canvas
{
    public var def :BoardDefinition;

    // Public display properties
    public static const pixelBoardLeft :int = 50;
    public static const pixelBoardTop :int = 50;
    
    public function Display ()
    {
    }

    public function init (controller :Controller, def :BoardDefinition) :void
    {
        this.def = def;
        _controller = controller;
    }

    public function handleUnload (event : Event) : void
    {
        removeEventListener(MouseEvent.CLICK, handleBoardClick);
        removeEventListener(MouseEvent.MOUSE_MOVE, handleBoardMove);
        removeEventListener(Event.ENTER_FRAME, handleFrame);
        trace("DISPLAY UNLOAD");
    }

    // Functions available to the game logic

    /** Initializes the empty board. */
    public function resetBoard () :void
    {
        var g :Graphics = _backdrop.graphics;
        g.clear();
        g.beginFill(0x4444ff, 0.1);
        g.drawRoundRect(0, 0, def.pixelWidth, def.pixelHeight, 5, 5);
        g.endFill();

        // now draw the grid
        g.lineStyle(1, 0x000000, 0.1);
        for (var col :int = 0; col <= def.width; col++) {
            g.moveTo(col * def.squareWidth, 0);
            g.lineTo(col * def.squareWidth, def.pixelHeight);
        }
        for (var row :int = 0; row <= def.height; row++) {
            g.moveTo(0, row * def.squareHeight);
            g.lineTo(def.pixelWidth, row * def.squareHeight);
        }
    }

    /** Creates a new cursor, initialized by the game object. */
    public function setCursor (cursor :Cursor) :void
    {
        _cursor = cursor;
        // test test test
        _cursor.setCursorType(Tower.TYPE_SIMPLE);
    }
    
    /** Adds a new tower that will be displayed on the board. */
    public function addTowerSprite (tower :TowerSprite) :void
    {
        _boardSprite.addChild(tower);
        _towers.push(tower);
    }

    /** Removes a tower from the board. */
    public function removeTowerSprite (tower :TowerSprite) :void
    {
        _boardSprite.removeChild(tower);
        ArrayUtil.removeFirst(_towers, tower);
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        
        // initialize graphics
        _boardSprite = new Canvas();
        _boardSprite.x = pixelBoardLeft;
        _boardSprite.y = pixelBoardTop;
        addChild(_boardSprite);

        _backdrop = new Image();
        _boardSprite.addChild(_backdrop);

        _counter = new Label();
        _counter.x = _counter.y = 20;
        addChild(_counter);
        
        // initialize event handlers
        addEventListener(MouseEvent.CLICK, handleBoardClick);
        addEventListener(MouseEvent.MOUSE_MOVE, handleBoardMove);
        addEventListener(Event.ENTER_FRAME, handleFrame);
    }

    protected function handleBoardClick (event :MouseEvent) :void
    {
        trace("*** CLICK: " + event);
        _controller.addTower(_cursor.getTower());
    }

    protected function handleBoardMove (event :MouseEvent) :void
    {
        if (_cursor != null) {
            var local :Point = _boardSprite.globalToLocal(new Point(event.stageX, event.stageY));
            var logical :Point = def.screenToLogicalPosition(local.x, local.y);
            //trace("MOVE: " + local + "->" + logical);
            _cursor.setBoardLocation(logical.x, logical.y);
        } 
    }

    protected function handleFrame (event :Event) :void
    {
        var now :int = getTimer();
        var delta :Number = (now - _lastFrameTime) / 1000;
        _lastFrameTime = now;
        _counter.text = "FPS: " + (1 / delta);
    }

    protected var _defense :Defense;
    protected var _controller :Controller;
    
    protected var _boardSprite :Canvas;
    protected var _backdrop :Image;
    protected var _cursor :Cursor;
    protected var _counter :Label;
    protected var _lastFrameTime :int;
    
    protected var _towers :Array = new Array(); /* of TowerSprite */
}
}
