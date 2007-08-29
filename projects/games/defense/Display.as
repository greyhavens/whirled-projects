package {

import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Mouse;
import flash.utils.getTimer; // function import

import mx.containers.Canvas;
import mx.controls.Image;
import mx.controls.Label;

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;

public class Display extends Canvas
{
    // Public display properties
    public static const pixelBoardLeft :int = 50;
    public static const pixelBoardTop :int = 40;
     
    public function Display ()
    {
    }

    // @Override from Canvas
    override protected function createChildren () :void
    {
        // note - this happens before init
        
        super.createChildren();
        
        // initialize graphics
        var bg :Image = new Image();
        bg.source = AssetFactory.makeBackground();
        addChild(bg);

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

    public function init (board :Board, game :Game, controller :Controller) :void
    {
        trace("*** DISPLAY: INIT");
        
        _board = board;
        _game = game;
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
        g.beginFill(0xffeedd, 0.1);
        g.drawRoundRect(0, 0, _board.pixelWidth, _board.pixelHeight, 5, 5);
        g.endFill();

        // now draw the grid
        g.lineStyle(1, 0x000000, 0.1);
        for (var col :int = 0; col <= _board.width; col++) {
            g.moveTo(col * _board.squareWidth, 0);
            g.lineTo(col * _board.squareWidth, _board.pixelHeight);
        }
        for (var row :int = 0; row <= _board.height; row++) {
            g.moveTo(0, row * _board.squareHeight);
            g.lineTo(_board.pixelWidth, row * _board.squareHeight);
        }
    }


    // Functions called by the game controller
    
    /**
     * Single function for moving and/or changing the cursor. If the cursor was not previously
     * shown, it will be created.
     */
    public function showCursor (defref :TowerDef, valid :Boolean) :void
    {
        Mouse.hide();
        if (_cursor == null) {
            _cursor = new TowerSprite(defref, _board);
            _boardSprite.addChild(_cursor);
        } else {
            _cursor.defref = defref;
        }
        _cursor.updateLocation();
        _cursor.setValid(valid);
    }

    /**
     * Hides the cursor (if one is visible)
     */
    public function hideCursor () :void
    {
        if (_cursor != null) {
            _boardSprite.removeChild(_cursor);
            _cursor = null;
        }
        Mouse.show();
    }

    /**
     * Changes the bitmap displayed under the cursor.
     */
    public function setCursorType (defref :TowerDef) :void
    {
        hideCursor();
        showCursor(defref, true);
    }
        
    /**
     * Adds a tower sprite
     */
    public function handleAddTower (tower :Tower) :void
    {
        var sprite :TowerSprite = new TowerSprite(tower.def, _board);
        _boardSprite.addChild(sprite);
        _towers.put(tower.guid, sprite);
    }

    // Event handlers
    
    protected function handleBoardClick (event :MouseEvent) :void
    {
        trace("*** CLICK: " + event);
        _controller.addTower(_cursor.defref);
    }

    protected function handleBoardMove (event :MouseEvent) :void
    {
        var local :Point = _boardSprite.globalToLocal(new Point(event.stageX, event.stageY));
        var logical :Point = _board.screenToLogicalPosition(local.x, local.y);
        _game.handleMouseMove(logical);
    }

    protected function handleFrame (event :Event) :void
    {
        var now :int = getTimer();
        var delta :Number = (now - _lastFrameTime) / 1000;
        _lastFrameTime = now;
        _fps = Math.round((_fps + 1 / delta) / 2);
        _counter.text = "FPS: " + _fps;
    }

    protected var _board :Board;
    protected var _game :Game;
    protected var _controller :Controller;
    
    protected var _boardSprite :Canvas;
    protected var _backdrop :Image;
    protected var _counter :Label;
    protected var _lastFrameTime :int;
    protected var _fps :Number = 0;

    protected var _cursor :TowerSprite;
    protected var _towers :HashMap = new HashMap(); // from Tower guid to TowerSprite
}
}
