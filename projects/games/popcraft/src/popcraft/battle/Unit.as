package popcraft.battle {

import popcraft.*;

import core.AppObject;
import core.ResourceManager;
import core.tasks.RepeatingTask;
import core.tasks.LocationTask;
import core.tasks.SerialTask;
import core.util.Rand;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;
import core.tasks.FunctionTask;
import flash.geom.Point;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.display.BitmapData;

public class Unit extends AppObject
{
    public function Unit (owningPlayerId :uint)
    {
        _owningPlayerId = owningPlayerId;

        // create the visual representation
        _sprite = new Sprite();

        // add the image
        var image :Bitmap = new Constants.IMAGE_MELEE();
        _sprite.addChild(image);

        // add a glow around the image
        _sprite.addChild(Util.createGlowBitmap(image, Constants.PLAYER_COLORS[_owningPlayerId] as uint));

        // start at our owning player's base's spawn loc
        var spawnLoc :Point = GameMode.instance.getPlayerBase(_owningPlayerId).unitSpawnLoc;
        _sprite.x = spawnLoc.x;
        _sprite.y = spawnLoc.y;

        // @TEMP
        var enemyPlayerId :uint = (_owningPlayerId == 0 ? 1 : 0);
        var moveLoc :Point = GameMode.instance.getPlayerBase(enemyPlayerId).unitSpawnLoc;
        moveTo(moveLoc.x, moveLoc.y);
    }

    protected function roam () :void
    {
        this.removeNamedTasks("roam");

        var x: int = Rand.nextIntRange(50, 450, Rand.STREAM_GAME);
        var y: int = Rand.nextIntRange(50, 450, Rand.STREAM_GAME);

        //trace("roam to " + x + ", " + y);

        this.addNamedTask("roam", new SerialTask(
            LocationTask.CreateSmooth(x, y, 5.5),
            new FunctionTask(roam)));
    }

    protected function moveTo (x :int, y :int) :void
    {
        // units wander drunkenly from point to point.

        var start :Vector2 = new Vector2(_sprite.x, _sprite.y);
        var end :Vector2 = new Vector2(x, y);
        var direction :Vector2 = Vector2.subtract(end, start);
        var distanceBetween :Number = direction.length;

        // direction is a unit vector
        direction.normalize();

        // two unit vectors, both perpendicular to our direction vector
        var perp1 :Vector2 = direction.getPerp(true);
        var perp2 :Vector2 = direction.getPerp(false);

        // how many times will we wander from our path?
        var numWanders :int = distanceBetween / WANDER_EVERY;

        var moveTask :SerialTask = new SerialTask();

        var curLoc :Vector2 = start;

        for (var i :int = 0; i < numWanders; ++i) {
            // where are we actually trying to get to?
            var newLoc :Vector2 = Vector2.scale(direction, WANDER_EVERY * i);
            newLoc.add(start);

            // wander off our path a bit
            var perp :Vector2 = (Rand.nextBoolean(Rand.STREAM_GAME) ? perp1.clone() : perp2.clone());
            perp.scale(Rand.nextNumberRange(WANDER_RANGE_MIN, WANDER_RANGE_MAX, Rand.STREAM_GAME));
            newLoc.add(perp);

            // move!
            var wanderDist :Number = Math.abs(Vector2.subtract(newLoc, curLoc).length);
            moveTask.addTask(new LocationTask(newLoc.x, newLoc.y, wanderDist / WALK_SPEED));

            curLoc = newLoc;
        }

        // @TODO: smooth these points?

        // move to the destination
        var moveDist :Number = Math.abs(Vector2.subtract(end, curLoc).length);
        moveTask.addTask(new LocationTask(end.x, end.y, moveDist / WALK_SPEED));

        this.removeNamedTasks("move");
        this.addNamedTask("move", moveTask);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _owningPlayerId :uint;

    protected static const WANDER_EVERY :Number = 30;  // for each WANDER_EVERY pixels the unit moves, he will wander
    protected static const WANDER_RANGE_MIN :Number = 5; // how far will he wander?
    protected static const WANDER_RANGE_MAX :Number = 25;
    protected static const WALK_SPEED :Number = 64; // pixels/second
}

}
