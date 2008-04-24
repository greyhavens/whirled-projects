//
// $Id$

package editor {

import flash.display.DisplayObject;
import flash.display.Shape;

import flash.events.MouseEvent;

import display.Metrics;
import display.PieceSprite;
import piece.Piece;

/**
 * A piece sprite that contains special handling for use in the editor.
 */
public class EditorPieceSprite extends PieceSprite
{
    public function EditorPieceSprite (ps :PieceSprite, es :EditSprite)
    {
        super(ps.getPiece());

        _sprite = ps;
        _es = es;
        addChild(_sprite);

/*
        var p :Piece  = ps.getPiece();
        if (p.width > 0 && p.height > 0) {
            var box :Shape = new Shape();
            box.graphics.lineStyle(0, 0xFF0000);
            box.graphics.drawRect(0, 0, p.width * Metrics.TILE_SIZE, -p.height * Metrics.TILE_SIZE);
            _sprite.addChild(box);
        }
*/
        addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
    }

    public override function update () :void
    {
        if (_sprite != null) {
            _sprite.update();
        }
    }

    public function mouseMove (newX :int, newY :int) :void
    {
        if (!isNaN(_startX)) {
            _piece.x = Math.max(0, newX - _startX);
            _piece.y = Math.max(0, newY - _startY);
            update();
        }
    }

    public function clearDrag () :void
    {
        _startX = NaN;
    }

    protected function mouseOverHandler (event :MouseEvent) :void
    {
        if (_hoverH == null) {
            _hoverH = createHighlight(0x000066);
        }
        _sprite.addChild(_hoverH);
    }

    protected function mouseOutHandler (event :MouseEvent) :void
    {
        if (_hoverH != null) {
            _sprite.removeChild(_hoverH);
        }
    }

    protected function mouseDownHandler (event :MouseEvent) :void
    {
        _startX = _es.getMouseX() - _piece.x;
        _startY = _es.getMouseY() - _piece.y;
    }

    protected function mouseUpHandler (event :MouseEvent) :void
    {
    }

    protected function mouseMoveHandler (event :MouseEvent) :void
    {
    }

    protected function sign (num :Number) :Number
    {
        return (num == 0) ? 1 : num / Math.abs(num);
    }

    protected function createHighlight (color :uint) :Shape
    {
        var highlight :Shape = new Shape();
        highlight.graphics.beginFill(color, 0.3);
        highlight.graphics.drawRect(0, -_piece.height * Metrics.TILE_SIZE,
                _piece.width * Metrics.TILE_SIZE, _piece.height * Metrics.TILE_SIZE);
        highlight.graphics.endFill();
        return highlight;
    }

    protected var _sprite :PieceSprite;
    protected var _es :EditSprite;
    protected var _hoverH :Shape;
    protected var _selectedH :Shape;

    protected var _dragging :Boolean = false;

    protected var _startX :Number = NaN;
    protected var _startY :Number = NaN;
    protected var _selected :Boolean;
}
}
