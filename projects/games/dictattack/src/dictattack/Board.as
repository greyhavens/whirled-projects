//
// $Id$

package dictattack {

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;

import com.threerings.ezgame.PropertyChangedEvent;
import com.whirled.WhirledGameControl;

/**
 * Displays the letters on the board.
 */
public class Board extends Sprite
{
    /** The gap between tiles on the board. */
    public static const GAP :int = 2;

    public function Board (size :int, control :WhirledGameControl, model :Model, content :Content)
    {
        _size = size;
        _control = control;
        _model = model;
        _content = content;

        // listen for property changed events
        _control.addEventListener(PropertyChangedEvent.TYPE, propertyChanged);
    }

    /**
     * Returns the size of the board in tiles (dimension of one side).
     */
    public function getSize () :int
    {
        return _size;
    }

    /**
     * Returns the size of the board in pixels (dimension of one side).
     */
    public function getPixelSize () :int
    {
        return _size * Content.TILE_SIZE + (_size-1) * GAP;
    }

    public function getLetter (pos :int) :Letter
    {
        return (_letters[pos] as Letter);
    }

    public function roundDidStart () :void
    {
        while (numChildren > 0) {
            removeChildAt(0);
        }

        for (var yy :int = 0; yy < _size; yy++) {
            for (var xx : int = 0; xx < _size; xx++) {
                var ll :Letter = new Letter(_content, _model.getType(xx, yy));
                ll.setText("?");
                ll.x = (Content.TILE_SIZE + GAP) * xx;
                ll.y = (Content.TILE_SIZE + GAP) * yy;
                addChild(ll);
                _letters[yy * _size + xx] = ll;
            }
        }
    }

    public function roundDidEnd () :void
    {
        for (var ii :int = 0; ii < _letters.length; ii++) {
            if (_letters[ii] != null) {
                _letters[ii].clearGhost();
            }
        }
    }

    public function resetLetters (used :Array) :void
    {
        Util.invokeLater(LETTER_RESET_DELAY, function () :void {
            for (var ii :int = 0; ii < used.length; ii++) {
                var letter :Letter = getLetter(used[ii]);
                if (letter != null) {
                    letter.setHighlighted(false);
                }
            }
        });
    }

    public function destroyLetter (xx :int, yy :int) :void
    {
        if (clearLetter(yy * _size + xx)) {
            var boom :Explosion = _content.createExplosion();
            boom.x = (Content.TILE_SIZE + GAP) * xx;
            boom.y = (Content.TILE_SIZE + GAP) * yy;
            addChild(boom);
        }
    }

    public function clearLetter (lidx :int) :Boolean
    {
        if (_letters[lidx] == null) {
            return false;
        }
        removeChild(_letters[lidx]);
        _letters[lidx] = null;
        return true;
    }

    /**
     * Called when our distributed game state changes.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == Model.BOARD_DATA) {
            if (event.index == -1) {
                // display the board
                for (var yy :int = 0; yy < _size; yy++) {
                    for (var xx :int = 0; xx < _size; xx++) {
                        var letter :String = _model.getLetter(xx, yy);
                        var pos :int = yy * _size + xx;
                        if (letter == null) {
                            clearLetter(pos);
                        } else {
                            getLetter(pos).setText(letter);
                        }
                    }
                }
            }
        }
    }

    protected var _size :int;
    protected var _control :WhirledGameControl;
    protected var _model :Model;
    protected var _content :Content;
    protected var _letters :Array = new Array();

    protected static const LETTER_RESET_DELAY :int = 1000;
}

}
