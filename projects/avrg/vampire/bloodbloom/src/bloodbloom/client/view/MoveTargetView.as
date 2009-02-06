package bloodbloom.client.view {

import bloodbloom.*;
import bloodbloom.client.PlayerCursor;

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;

public class MoveTargetView extends SceneObject
{
    public function MoveTargetView (cursor :PlayerCursor, playerType :int)
    {
        _cursor = cursor;

        _shape = new Shape();
        var g :Graphics = _shape.graphics;
        g.beginFill(playerType == Constants.PLAYER_PREDATOR ? 0xffffff : 0x00ff00);
        g.drawCircle(0, 0, 5);
        g.endFill();

        addTask(new RepeatingTask(
            ScaleTask.CreateSmooth(1.5, 1.5, 0.5),
            ScaleTask.CreateSmooth(1, 1, 0.5)));
    }

    override public function get displayObject () :DisplayObject
    {
        return _shape;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (!_cursor.isLiveObject) {
            destroySelf();
            return;
        }

        this.x = _cursor.moveTarget.x;
        this.y = _cursor.moveTarget.y;
    }

    protected var _shape :Shape;
    protected var _cursor :PlayerCursor;
}

}
