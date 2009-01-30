package bloodbloom {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.NumRange;
import com.whirled.contrib.simplegame.util.Rand;

import flash.geom.Point;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        _modeSprite.addChild(ClientCtx.instantiateBitmap("bg"));

        _heart = new Heart();
        _heart.x = CTR_LOC.x;
        _heart.y = CTR_LOC.y;
        addObject(_heart, _modeSprite);

        // setup cells
        for (var type :int = 0; type < Constants.CELL__LIMIT; ++type) {
            // create initial cells
            for (var ii :int = 0; ii < Constants.INITIAL_CELL_COUNT[type]; ++ii) {
                spawnCell(type);
            }

            // spawn new cells on a timer
            var spawnRate :NumRange = Constants.CELL_SPAWN_RATE[type];
            var spawner :SimObject = new SimObject();
            spawner.addTask(new RepeatingTask(
                new VariableTimedTask(spawnRate.min, spawnRate.max, Rand.STREAM_GAME),
                new FunctionTask(createCellSpawnCallback(type))));
            addObject(spawner);
        }
    }

    protected function createCellSpawnCallback (type :int) :Function
    {
        return function () :void {
            if (Cell.getCellCount(type) < Constants.MAX_CELL_COUNT[type]) {
                spawnCell(type);
            }
        };
    }

    protected function spawnCell (type :int) :void
    {
        var angle :Number = Rand.nextNumberRange(0, Math.PI * 2, Rand.STREAM_GAME);
        var dist :Number = Constants.CELL_SPAWN_RADIUS.next();
        var loc :Vector2 = Vector2.fromAngle(angle, dist);
        loc.addLocal(CTR_LOC);
        var cell :Cell = new Cell(type);
        cell.x = loc.x;
        cell.y = loc.y;
        addObject(cell, _modeSprite);
    }

    protected var _heart :Heart;

    protected static const CTR_LOC :Vector2 = new Vector2(267, 246);
}

}
