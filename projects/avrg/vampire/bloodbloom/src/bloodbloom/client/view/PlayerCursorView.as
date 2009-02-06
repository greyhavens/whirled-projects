package bloodbloom.client.view {

import bloodbloom.*;
import bloodbloom.client.*;

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;

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
        var newLoc :Vector2 = _cursor.getNextLocation(_cursor.loc, GameCtx.clientFutureDelta);
        this.x = newLoc.x;
        this.y = newLoc.y;

        if (_lastLoc != null) {
            // rotate towards our movement direction. 0 degrees == straight up
            var angle :Number = (newLoc.subtract(_lastLoc).angle) * (180 / Math.PI);
            this.rotation = angle + 90;
        }

        _lastLoc = newLoc;
    }

    protected var _cursor :PlayerCursor;
    protected var _lastLoc :Vector2;

    protected var _sprite :Sprite;
}

}
