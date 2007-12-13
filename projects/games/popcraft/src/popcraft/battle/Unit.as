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
        roam();
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

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _owningPlayerId :uint;
}

}
