package {

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

public class Display extends Sprite
{
    // Public display properties
    public static const pixelBoardLeft :int = 50;
    public static const pixelBoardTop :int = 50;
    
    public function Display (controller :Controller)
    {
        _controller = controller;

        // initialize graphics
        _boardSprite = new Sprite();
        _boardSprite.x = pixelBoardLeft;
        _boardSprite.y = pixelBoardTop;
        addChild(_boardSprite);

        _backdrop = new Shape();
        _boardSprite.addChild(_backdrop);

        // initialize event handlers
        _boardSprite.addEventListener(MouseEvent.CLICK, handleClick);
        _boardSprite.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
    }

    public function handleUnload (event : Event) : void
    {
        _boardSprite.removeEventListener(MouseEvent.CLICK, handleClick);
        _boardSprite.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
        trace("DISPLAY UNLOAD");
    }

    // Functions available to the game logic

    /** Initializes the empty board. */
    public function resetBoard (def :BoardDefinition) :void
    {
        var pixelWidth :int = def.width * def.squareWidth;
        var pixelHeight :int = def.height * def.squareHeight;
        
        var g :Graphics = _backdrop.graphics;
        g.clear();
        g.beginFill(0x4444ff, 0.1);
        g.drawRoundRect(0, 0, pixelWidth, pixelHeight, 5, 5);
        g.endFill();

        // now draw the grid
        g.lineStyle(1, 0x000000, 0.1);
        for (var col :int = 0; col <= def.width; col++) {
            g.moveTo(col * def.squareWidth, 0);
            g.lineTo(col * def.squareWidth, pixelHeight);
        }
        for (var row :int = 0; row <= def.height; row++) {
            g.moveTo(0, row * def.squareHeight);
            g.lineTo(pixelWidth, row * def.squareHeight);
        }
    }

    protected function handleClick (event :MouseEvent) :void
    {
        trace("*** CLICK: " + event);
        _controller.addTower();
    }

    protected function handleMouseMove (event :MouseEvent) :void
    {
    }
    
    protected var _controller :Controller;

    protected var _boardSprite :Sprite;
    protected var _backdrop :Shape;
}
}
