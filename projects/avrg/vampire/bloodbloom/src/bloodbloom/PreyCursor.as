package bloodbloom {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class PreyCursor extends SceneObject
{
    public function PreyCursor ()
    {
        _sprite = new Sprite();
        var bitmap :Bitmap = ClientCtx.instantiateBitmap("prey_cursor");
        bitmap.x = -bitmap.width * 0.5;
        bitmap.y = -bitmap.height * 0.5;
        _sprite.addChild(bitmap);
    }

    override protected function update (dt :Number) :void
    {
        var targetLoc :Vector2 = new Vector2(
            ClientCtx.gameMode.modeSprite.mouseX,
            ClientCtx.gameMode.modeSprite.mouseY);

        var curLoc :Vector2 = new Vector2(this.x, this.y);

        if (curLoc.similar(targetLoc, 0.5)) {
            return;
        }

        var newLoc :Vector2 = targetLoc.subtract(curLoc);
        var dist :Number = newLoc.normalizeLocalAndGetLength();
        newLoc.scale(Math.min(dist, this.speed * dt));
        newLoc.addLocal(curLoc);
        newLoc = ClientCtx.clampLoc(newLoc);

        this.x = newLoc.x;
        this.y = newLoc.y;

        // rotate the bitmap. 0 degrees == straight up
        var angle :Number = newLoc.subtract(curLoc).angle * (180 / Math.PI);
        this.rotation = angle + 90;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function get speed () :Number
    {
        return Constants.PREY_SPEED_BASE;
    }

    protected var _sprite :Sprite;
}

}
