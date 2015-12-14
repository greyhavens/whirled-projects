//
// $Id$

package dictattack {

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import com.whirled.net.PropertyChangedEvent;

/**
 * Displays the letters on the board.
 */
public class Board extends Sprite
{
    /** The gap between tiles on the board. */
    public static const GAP :int = 2;

    public function Board (ctx :Context)
    {
        _ctx = ctx;
        _size = _ctx.model.getBoardSize();

        // if we're not connected, stop here
        if (!_ctx.control.isConnected()) {
            return;
        }

        // scale our tiles to fit the board
        var size :Point = _ctx.control.local.getSize();
        var havail :int = size.y - Content.BOARD_BORDER*2 - GameView.INPUT_HEIGHT;
        Content.TILE_SIZE = (havail / _size) - 2;

        // listen for property changed events
        _ctx.control.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);

        // if we're already in play, start displaying the board immediately
        if (_ctx.control.game.isInPlay()) {
            _gotBoard = true;
            _roundStarted = true;
            maybeStartRound();
        }
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

    public function getLetterAt (xx :int, yy :int) :Letter
    {
        return getLetter(yy * _size + xx);
    }

    public function roundDidStart () :void
    {
        _roundStarted = true;
        maybeStartRound();
    }

    public function roundDidEnd () :void
    {
        for (var yy :int = 0; yy < _size; yy++) {
            for (var xx : int = 0; xx < _size; xx++) {
                var ll :Letter = _letters[yy * _size + xx];
                if (ll == null) {
                    continue;
                }
                ll.clearGhost();
                var sx :int = (Content.TILE_SIZE + GAP) * xx;
                var sy :int = (Content.TILE_SIZE + GAP) * yy;
                var dx :int = (Content.TILE_SIZE + GAP) * (xx-_size-5);
                var delay :int = (_size-yy-1) * (_size*20) + xx * 20;
                DelayedPath.delay(LinePath.move(ll, sx, sy, dx, sy, 1000), delay).start();
            }
        }

        // clear out our state tracking flags
        _roundStarted = false;
        _gotBoard = false;
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
            var boom :Explosion = _ctx.content.createExplosion();
            boom.x = (Content.TILE_SIZE + GAP) * xx;
            boom.y = (Content.TILE_SIZE + GAP) * yy;
            addChild(boom);
        }
        _ctx.model.updateColumnPlayable(this, xx);
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
            _gotBoard = true;
            maybeStartRound();
        }
    }

    protected function maybeStartRound () :void
    {
        // if one of our two conditions is not yet met, then wait; we'll be called again
        if (!_gotBoard || !_roundStarted) {
            return;
        }

        while (numChildren > 0) {
            removeChildAt(0);
        }

        var longestDelay :int = 0;
        for (var yy :int = 0; yy < _size; yy++) {
            for (var xx : int = 0; xx < _size; xx++) {
                var letter :String = _ctx.model.getLetter(xx, yy);
                var pos :int = yy * _size + xx;
                if (letter == Model.BLANK) {
                    continue;
                }

                var ll :Letter = new Letter(_ctx.content, _ctx.model.getType(xx, yy));
                ll.setText(letter);
                var sx :int = (Content.TILE_SIZE + GAP) * xx;
                var sy :int = (Content.TILE_SIZE + GAP) * (yy-_size-5);
                var dy :int = (Content.TILE_SIZE + GAP) * yy;
                ll.x = sx;
                ll.y = sy;
                addChild(ll);
                var delay :int = (_size-yy-1) * (_size*20) + ((yy%2 == 0) ? xx : (_size-xx-1)) * 20;
                DelayedPath.delay(LinePath.move(ll, sx, sy, sx, dy, 1000), delay).start();
                if (delay > longestDelay) {
                    longestDelay = delay;
                }
                _letters[yy * _size + xx] = ll;
            }
        }

        // once the last alien moves into position, drop our aliens into place
        var timer :Timer = new Timer(longestDelay + 1500, 1);
        timer.addEventListener(TimerEvent.TIMER, boardAnimationComplete);
        timer.start();
    }

    // have to do this in a separate function because we can't use this in an anonymous function
    // and ActionScript has no Board.this
    protected function boardAnimationComplete (event :TimerEvent) :void
    {
        _ctx.model.updatePlayable(this);
    }

    protected var _size :int;
    protected var _ctx :Context;
    protected var _letters :Array = new Array();

    protected var _roundStarted :Boolean = false;
    protected var _gotBoard :Boolean = false;

    protected static const LETTER_RESET_DELAY :int = 1000;
}
}
