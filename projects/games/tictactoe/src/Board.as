package {

import flash.display.Sprite;
import flash.events.MouseEvent;

import com.whirled.game.GameControl;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.MessageReceivedEvent;

/**
 * Sprite class that is just the 3x3 tic tac toe board.
 */
public class Board extends Sprite
{
    /** Pixel size of a single box. */
    public static const BOXSIZE :int = 60;

    /** Number of pixels between the edge of a marker and the box edge. */
    public static const BOXMARGIN :int = 10;

    /** Line thickness of the box borders. */
    public static const THICKNESS :int = 4;

    /** Creates a new board. */
    public function Board (parent :TicTacToe)
    {
        _parent = parent;

        addEventListener(MouseEvent.CLICK, click);
    }

    /** Accesses whether or not this board is accepting mouse clicks. */
    public function get enabled () :Boolean
    {
        return _enable;
    }

    /** Accesses whether or not this board is accepting mouse clicks. */
    public function set enabled (value :Boolean) :void
    {
        _enable = value;
    }

    /** Redraw our graphics using the given board array. */
    public function updateAll (board :Array) :void
    {
        // redraw the 3x3 frame
        graphics.lineStyle(NaN);

        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(0, 0, BOXSIZE*3, BOXSIZE*3);
        graphics.endFill();

        graphics.lineStyle(THICKNESS);

        graphics.moveTo(BOXSIZE, 0);
        graphics.lineTo(BOXSIZE, BOXSIZE * 3);

        graphics.moveTo(BOXSIZE * 2, 0);
        graphics.lineTo(BOXSIZE * 2, BOXSIZE * 3);

        graphics.moveTo(0, BOXSIZE);
        graphics.lineTo(BOXSIZE * 3, BOXSIZE);

        graphics.moveTo(0, BOXSIZE * 2);
        graphics.lineTo(BOXSIZE * 3, BOXSIZE * 2);

        // put in the symbols
        if (board != null) {
            for (var ii :int = 0; ii < 9; ++ii) {
                update(ii, board[ii]);
            }
        }
    }

    /** 
     * Puts a symbol on the graphics in the box corresponding to a BOARD array index.
     */
    public function update (idx :int, symbol :int) :void
    {
        // translate to x,y coordinates
        var x :Number = int(idx % 3) * BOXSIZE;
        var y :Number = int(idx / 3) * BOXSIZE;

        // erase the box
        graphics.lineStyle(NaN);
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(
            x + BOXMARGIN, y + BOXMARGIN, 
            BOXSIZE - BOXMARGIN * 2, BOXSIZE - BOXMARGIN * 2);
        graphics.endFill();

        if (symbol == 1) {
            // X
            graphics.lineStyle(THICKNESS);
            graphics.moveTo(x + BOXMARGIN, y + BOXMARGIN);
            graphics.lineTo(x + BOXSIZE - BOXMARGIN * 2, y + BOXSIZE - BOXMARGIN * 2);
            graphics.moveTo(x + BOXSIZE - BOXMARGIN * 2, y + BOXMARGIN);
            graphics.lineTo(x + BOXMARGIN, y + BOXSIZE - BOXMARGIN * 2);
            graphics.moveTo(0, 0);
        
        } else if (symbol == 2) {
            // O
            graphics.lineStyle(THICKNESS);
            graphics.drawCircle(x + BOXSIZE / 2, y + BOXSIZE / 2, BOXSIZE / 2 - BOXMARGIN);
        }
    }

    /**
     * Draws a line through three boxed to indicate a win.
     */
    public function drawWin (positions :Array) :void
    {
        graphics.lineStyle(THICKNESS, 0xFF0000);
        graphics.moveTo(
            int(positions[0] % 3) * BOXSIZE + BOXSIZE/2,
            int(positions[0] / 3) * BOXSIZE + BOXSIZE/2);
        graphics.lineTo(
            int(positions[2] % 3) * BOXSIZE + BOXSIZE/2,
            int(positions[2] / 3) * BOXSIZE + BOXSIZE/2);
        graphics.moveTo(0, 0);
    }

    /**
     * Notifies us that a user has clicked somewhere on the board.
     */
    protected function click (event :MouseEvent) :void
    {
        // ignore if clicks are disabled
        if (!_enable) {
            return;
        }

        // calculate the x,y coordinate
        var x :Number = int(event.localX / BOXSIZE);
        var y :Number = int(event.localY / BOXSIZE);

        // request the move
        if (_parent.makeMove(x, y)) {

            // draw a little dot to confirm the click. the symbol will appear later when 
            // update is called
            graphics.lineStyle(NaN);
            graphics.beginFill(0xff0000);
            graphics.drawCircle(
                x * BOXSIZE + BOXSIZE / 2, 
                y * BOXSIZE + BOXSIZE / 2, BOXSIZE / 10);
            graphics.endFill();

            // disallow clicks until they are enabled again (when it becomes our turn)
            _enable = false;
        }
    }

    /** Indicates if the board can be clicked. */
    protected var _enable :Boolean;

    /** The main sprite for dispatching move requests. */
    protected var _parent :TicTacToe;
}
}
