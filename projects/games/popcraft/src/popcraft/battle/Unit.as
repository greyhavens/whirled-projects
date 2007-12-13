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

public class Unit extends AppObject
{
    public function Unit (owningPlayerId :uint)
    {
        _owningPlayerId = owningPlayerId;

        // create the visual representation
        _sprite = new Sprite();
        _sprite.addChild(new Constants.IMAGE_MELEE());

        roam();
    }

    protected function roam () :void
    {
        this.removeNamedTasks("roam");

        var x: int = Rand.nextIntRange(50, 450, Rand.STREAM_GAME);
        var y: int = Rand.nextIntRange(50, 450, Rand.STREAM_GAME);

        //trace("roam to " + x + ", " + y);

        this.addNamedTask("roam", new SerialTask(
            LocationTask.CreateSmooth(x, y, 1.5),
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
