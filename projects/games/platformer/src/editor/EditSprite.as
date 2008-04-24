//
// $Id$

package editor {

import flash.display.Shape;
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.geom.Point;

import com.threerings.util.ArrayIterator;

import board.Board;

import display.Layer;
import display.Metrics;
import display.PieceSpriteFactory;

import piece.Piece;

public class EditSprite extends Sprite
{
    public function EditSprite ()
    {
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
    }

    public function positionView (nX :Number, nY :Number) :void
    {
        _bX = nX;
        _bY = nY;
        updateDisplay();
    }

    public function moveView (dX :Number, dY :Number) :void
    {
        _bX += dX;
        _bY += dY;
        updateDisplay();
    }

    public function moveViewTile (dX :int, dY :int) :void
    {
        //trace("moveViewTile (" + dX + ", " + dY + ")");
        moveView(dX * Metrics.TILE_SIZE, dY * Metrics.TILE_SIZE);
    }

    public function getMouseX () :int
    {
        return Math.floor((_bX + mouseX) / Metrics.TILE_SIZE);
    }

    public function getMouseY () :int
    {
        return Math.floor(((Metrics.DISPLAY_HEIGHT - mouseY) - _bY) / Metrics.TILE_SIZE);
    }

    protected function clearDisplay () :void
    {

    }

    protected function initDisplay () :void
    {
        positionView(0, 0);
    }

    protected function updateDisplay () :void
    {
    }

    protected function mouseDownHandler (event :MouseEvent) :void
    {
    }

    protected function mouseUpHandler (event :MouseEvent) :void
    {
        clearDrag();
    }

    protected function mouseOverHandler (event :MouseEvent) :void
    {
        if (!event.buttonDown) {
            clearDrag();
        }
    }

    protected function mouseOutHandler (event: MouseEvent) :void
    {
    }

    protected function mouseMoveHandler (event :MouseEvent) :void
    {
        var newX :int = getMouseX();
        var newY :int = getMouseY();
        if (newX != _mX || newY != _mY) {
            tileChanged(newX, newY);
            _mX = newX;
            _mY = newY;
        }
    }

    protected function tileChanged (newX :int, newY :int) :void
    {
    }

    protected function clearDrag () :void
    {
    }

    protected var _bX :int;
    protected var _bY :int;

    protected var _mX :int;
    protected var _mY :int;
}
}
