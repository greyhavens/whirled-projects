package bloodbloom {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.AlphaTask;
import com.whirled.contrib.simplegame.util.Collision;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class Cell extends SceneObject
{
    public static function getCellCount (type :int) :int
    {
        return ClientCtx.mainLoop.topMode.getObjectRefsInGroup("Cell_" + type).length;
    }

    public static function getCellCollision (loc :Vector2, radius :Number, cellType :int = -1) :Cell
    {
        // returns the first cell that collides with the given circle
        var groupName :String = (cellType == -1 ? "Cell" : "Cell_" + cellType);
        var cells :Array = ClientCtx.mainLoop.topMode.getObjectRefsInGroup(groupName);

        for each (var cellRef :SimObjectRef in cells) {
            var cell :Cell = cellRef.object as Cell;
            if (cell != null &&
                Collision.circlesIntersect(cell._loc, Constants.CELL_RADIUS, loc, radius)) {
                return cell;
            }
        }

        return null;
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

        _moveCCW = Rand.nextBoolean(Rand.STREAM_GAME);

        // fade in
        if (fadeIn) {
            this.alpha = 0;
            addTask(new AlphaTask(1, 0.4));
        }
    }

    override protected function update (dt :Number) :void
    {
        _loc.x = this.x;
        _loc.y = this.y;

        var ctrImpulse :Vector2 = _loc.subtract(Constants.GAME_CTR);
        ctrImpulse.length = 1;

        var perpImpulse :Vector2 = ctrImpulse.getPerp(_moveCCW);
        perpImpulse.length = 3.5;

        var impulse :Vector2 = ctrImpulse.add(perpImpulse);
        impulse.length = SPEED * dt;

        _loc.x += impulse.x;
        _loc.y += impulse.y;
        _loc = ClientCtx.clampLoc(_loc);

        this.x = _loc.x;
        this.y = _loc.y;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:     return "Cell_" + _type;
        case 1:     return "Cell";
        default:    return super.getObjectGroup(groupNum - 2);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function get type () :int
    {
        return _type;
    }

    public function get isRedCell () :Boolean
    {
        return _type == Constants.CELL_RED;
    }

    public function get isWhiteCell () :Boolean
    {
        return _type == Constants.CELL_WHITE;
    }

    protected var _type :int;
    protected var _sprite :Sprite;
    protected var _moveCCW :Boolean;
    protected var _loc :Vector2 = new Vector2();

    protected static const SPEED :Number = 5;
}

}
