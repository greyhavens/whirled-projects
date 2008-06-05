package {

import flash.display.Sprite;
import flash.events.MouseEvent;
import com.whirled.game.GameControl;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.MessageReceivedEvent;

public class Board extends Sprite
{
    public static const BOXSIZE :int = 60;
    public static const BOXMARGIN :int = 10;
    public static const THICKNESS :int = 4;

    public function Board (parent :TicTacToe)
    {
        _parent = parent;

        addEventListener(MouseEvent.CLICK, click);
    }

    public function get enabled () :Boolean
    {
        return _enable;
    }

    public function set enabled (value :Boolean) :void
    {
        _enable = value;
    }

    public function updateAll (board :Array) :void
    {
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

        if (board != null) {
            for (var ii :int = 0; ii < 9; ++ii) {
                update(ii, board[ii]);
            }
        }
    }

    public function update (idx :int, symbol :int) :void
    {
        var x :Number = int(idx % 3) * BOXSIZE;
        var y :Number = int(idx / 3) * BOXSIZE;

        graphics.lineStyle(NaN);
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(
            x + BOXMARGIN, y + BOXMARGIN, 
            BOXSIZE - BOXMARGIN * 2, BOXSIZE - BOXMARGIN * 2);
        graphics.endFill();

        if (symbol == 1) {
            graphics.lineStyle(THICKNESS);
            graphics.moveTo(x + BOXMARGIN, y + BOXMARGIN);
            graphics.lineTo(x + BOXSIZE - BOXMARGIN * 2, y + BOXSIZE - BOXMARGIN * 2);
            graphics.moveTo(x + BOXSIZE - BOXMARGIN * 2, y + BOXMARGIN);
            graphics.lineTo(x + BOXMARGIN, y + BOXSIZE - BOXMARGIN * 2);
            graphics.moveTo(0, 0);
        }
        else if (symbol == 2) {
            graphics.lineStyle(THICKNESS);
            graphics.drawCircle(x + BOXSIZE / 2, y + BOXSIZE / 2, BOXSIZE / 2 - BOXMARGIN);
        }
    }

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

    protected function click (event :MouseEvent) :void
    {
        if (!_enable) {
            trace("Disabled");
            return;
        }

        var x :Number = int(event.localX / BOXSIZE);
        var y :Number = int(event.localY / BOXSIZE);
        trace("Got click in box " + x + ", " + y);

        if (_parent.makeMove(x, y)) {
            graphics.lineStyle(NaN);
            graphics.beginFill(0xff0000);
            graphics.drawCircle(
                x * BOXSIZE + BOXSIZE / 2, 
                y * BOXSIZE + BOXSIZE / 2, BOXSIZE / 10);
            graphics.endFill();
            _enable = false;
        }
    }

    protected var _enable :Boolean;
    protected var _parent :TicTacToe;
}


}
