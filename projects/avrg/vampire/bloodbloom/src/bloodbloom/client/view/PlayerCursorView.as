package bloodbloom.client.view {

import bloodbloom.*;
import bloodbloom.client.*;

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class PlayerCursorView extends SceneObject
{
    public function PlayerCursorView (cursor :PlayerCursor, playerType :int)
    {
        _cursor = cursor;

        var bm :Bitmap = ClientCtx.instantiateBitmap(
            playerType == Constants.PLAYER_PREY ? "prey_cursor" : "predator_cursor");
        bm.x = -bm.width * 0.5;
        bm.y = -bm.height * 0.5;
        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(bm);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        if (!_cursor.isLiveObject) {
            destroySelf();
            return;
        }

        // estimate the object's current location
        var newLoc :Vector2 = _cursor.getNextLoc(_cursor.loc, GameCtx.clientFutureDelta);
        this.x = newLoc.x;
        this.y = newLoc.y;

        if (!newLoc.similar(_cursor.moveTarget, 0.5)) {
            // rotate towards our move target. 0 degrees == straight up
            var targetRotation :Number =
                90 + ((_cursor.moveTarget.subtract(newLoc).angle) * (180 / Math.PI));

            var curRotation :Number = this.rotation;
            if (targetRotation - curRotation > 180) {
                targetRotation -= 360;
            } else if (targetRotation - curRotation < -180) {
                targetRotation += 360;
            }

            addNamedTask(
                "Rotate",
                RotationTask.CreateEaseOut(
                    targetRotation,
                    Math.abs((targetRotation % 360) - curRotation) / ROTATE_SPEED),
                true);

        }
    }

    protected var _cursor :PlayerCursor;
    protected var _sprite :Sprite;

    protected static const ROTATE_SPEED :Number = 180; // 360 d/s
}

}
