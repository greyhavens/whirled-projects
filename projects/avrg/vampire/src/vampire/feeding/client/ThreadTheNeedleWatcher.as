package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.TimeBuffer;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.util.Collision;

import vampire.feeding.*;
import vampire.server.Trophies;

public class ThreadTheNeedleWatcher extends SimObject
{
    public function ThreadTheNeedleWatcher ()
    {
        _countedCells = new TimeBuffer(Trophies.THREAD_TIME * 1000, 10,
            function () :int {
                return _totalTime * 0.001;
            });

        registerListener(GameCtx.cursor, GameEvent.HIT_RED_CELL, reset);

        reset();
    }

    protected function reset (...ignored) :void
    {
        if (_countedCells.length > 0) {
            _countedCells.clear();
        }

        _timeSinceReset = 0;
    }

    override protected function update (dt :Number) :void
    {
        _totalTime += dt;
        _timeSinceReset += dt;

        // count the number of cells the player is nearby right now
        var loc :Vector2 = GameCtx.cursor.loc;
        var radius :Number = Constants.CURSOR_RADIUS + Trophies.THREAD_DIST;

        for each (var cellRef :SimObjectRef in Cell.getCellRefs(Constants.CELL_RED)) {
            var cell :Cell = cellRef.object as Cell;
            if (cell == null ||
                !cell.canCollide ||
                _countedCells.indexOf(cellRef) >= 0) {
                continue;
            }

            if (Collision.circlesIntersect(cell.loc, cell.radius, loc, radius)) {
                _countedCells.push(cellRef);
                //trace("THREAD THE NEEDLE! " + _countedCells.length);
                if (_countedCells.length >= Trophies.THREAD_CELLS) {
                    ClientCtx.awardTrophy(Trophies.THREAD_THE_NEEDLE);
                    destroySelf();
                    return;
                }

                // I think it's ok to just count 1 cell per frame. We can get any others on the
                // next frame.
                break;
            }
        }
    }

    protected var _countedCells :TimeBuffer;
    protected var _timeSinceReset :Number;
    protected var _totalTime :Number = 0;
}

}
