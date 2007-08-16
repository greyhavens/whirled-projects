package {

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

public class Display extends Sprite
{
    public var def :BoardDefinition;

    // Public display properties
    public static const pixelBoardLeft :int = 50;
    public static const pixelBoardTop :int = 50;
    
    public function Display (controller :Controller, def :BoardDefinition)
    {
        _controller = controller;
        this.def = def;

        // initialize graphics
        _boardSprite = new Sprite();
        _boardSprite.x = pixelBoardLeft;
        _boardSprite.y = pixelBoardTop;
        addChild(_boardSprite);

        _backdrop = new Shape();
        _boardSprite.addChild(_backdrop);

        // initialize event handlers
        _boardSprite.addEventListener(MouseEvent.CLICK, handleBoardClick);
        _boardSprite.addEventListener(MouseEvent.MOUSE_MOVE, handleBoardMove);
        _boardSprite.addEventListener(MouseEvent.ROLL_OVER, handleBoardOver);
        _boardSprite.addEventListener(MouseEvent.ROLL_OUT, handleBoardOut);

        testInit();
    }

    // ONLY FOR TESTING
    public function testInit () :void
    {
        setCursor(new TowerSprite(Tower.TYPE_SIMPLE, this));
    }

    public function handleUnload (event : Event) : void
    {
        _boardSprite.removeEventListener(MouseEvent.CLICK, handleBoardClick);
        _boardSprite.removeEventListener(MouseEvent.MOUSE_MOVE, handleBoardMove);
        _boardSprite.removeEventListener(MouseEvent.ROLL_OVER, handleBoardOver);
        _boardSprite.removeEventListener(MouseEvent.ROLL_OUT, handleBoardOut);
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

    /** Adds a new tower that will be displayed on the board. */
    public function addTowerSprite (tower :TowerSprite) :void
    {
        _boardSprite.addChild(tower);
        _towers.add(tower);
    }

    /** Removes a tower from the board. */
    public function removeTowerSprite (tower :TowerSprite) :void
    {
        _boardSprite.removeChild(tower);
        _towers.remove(tower);
    }

    /** Set or clear the cursor. The new cursor will not be displayed by default. */
    public function setCursor (tower :TowerSprite) :void
    {
        if (_cursor == tower) {
            return; // we're so done
        }
        if (_cursor != null) {
            showCursor(false);
            _cursor = null;
        }
        if (tower != null) {
            _cursor = tower;
        }             
    }

    /** Show or hide the currently selected cursor. */
    public function showCursor (show :Boolean) :void
    {
        if (_cursor != null) {
            var visible :Boolean = _boardSprite.contains(_cursor);
            if (! visible && show) {
                _boardSprite.addChild(_cursor);
                _cursor.enabled = true;
            }
            if (visible && ! show) {
                _boardSprite.removeChild(_cursor);
            }
        } 
    }
    
    protected function handleBoardClick (event :MouseEvent) :void
    {
        trace("*** CLICK: " + event);
        _controller.addTower();
        showCursor(true);
    }

    protected function handleBoardMove (event :MouseEvent) :void
    {
        if (_cursor != null) {
            var local :Point = _boardSprite.globalToLocal(new Point(event.stageX, event.stageY));
            var p :Point = def.screenToLogical(local.x, local.y);
            if (p.x < 0 || p.y < 0 || p.x >= def.width || p.y >= def.height) {
                showCursor(false);
            } else {
                _cursor.move(p.x, p.y);
            }
        } 
    }

    protected function handleBoardOver (event :MouseEvent) :void
    {
        trace("*** OVER: " + event);
        showCursor(true);
    }

    protected function handleBoardOut (event :MouseEvent) :void
    {
        trace("*** OUT: " + event);
        showCursor(false);
    }

    protected var _controller :Controller;
    
    protected var _boardSprite :Sprite;
    protected var _backdrop :Shape;
    protected var _cursor :TowerSprite;

    protected var _towers :Array = new Array(); /* of TowerSprite */
}
}
