package bloodbloom {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.AlphaTask;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class Cell extends SceneObject
{
    public static function getCellCount (type :int) :int
    {
        return ClientCtx.mainLoop.topMode.getObjectRefsInGroup("Cell_" + type).length;
    }

    public function Cell (type :int, fadeIn :Boolean)
    {
        _type = type;

        _sprite = new Sprite();
        var bitmap :Bitmap =
            ClientCtx.instantiateBitmap(_type == Constants.CELL_WHITE ? "white_cell" : "red_cell");
        bitmap.x = -bitmap.width * 0.5;
        bitmap.y = -bitmap.height * 0.5;
        _sprite.addChild(bitmap);

        // fade in
        if (fadeIn) {
            this.alpha = 0;
            addTask(new AlphaTask(1, 0.4));
        }
    }

    override protected function update (dt :Number) :void
    {
        var loc :Vector2 = new Vector2(this.x, this.y);
        var ctrImpulse :Vector2 = loc.subtract(Constants.GAME_CTR);
        ctrImpulse.length = SPEED * dt;

        loc.x += ctrImpulse.x;
        loc.y += ctrImpulse.y;
        loc = ClientCtx.clampToGame(loc);

        this.x = loc.x;
        this.y = loc.y;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        if (groupNum == 0) {
            return "Cell_" + _type;
        } else {
            return super.getObjectGroup(groupNum - 1);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _type :int;
    protected var _sprite :Sprite;

    protected static const SPEED :Number = 5;
}

}
