package ghostbusters.fight.lantern {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;

import ghostbusters.fight.common.*;

public class GhostHeart extends SceneObject
{
    public function GhostHeart (radius :Number, maxHealth :Number)
    {
        _radius = radius;
        _maxHealth = maxHealth;
        _health = maxHealth;

        var heart :DisplayObject = SwfResource.getSwfDisplayRoot("lantern.heart");

        var scale :Number = _radius / HEART_RADIUS_BASE;
        heart.scaleX = scale;
        heart.scaleY = scale;

        heart.x = -(heart.width * 0.5);
        heart.y = -(heart.height * 0.5);

        _sprite = new Sprite();
        _sprite.addChild(heart);

        //var heartBounds :Rectangle = heart.getBounds(_sprite);
        //heart.x = -heartBounds.x - heart.width / 2;
        //heart.y = -heartBounds.y - heart.height / 2;
    }

    public function offsetHealth (offset :Number) :void
    {
        _health += offset;
        _health = Math.max(_health, 0);
        _health = Math.min(_health, _maxHealth);

        var cm :ColorMatrix = new ColorMatrix();
        cm.colorize(0x0000FF, 1 - (_health / _maxHealth));

        _sprite.filters = [ cm.createFilter() ];
    }

    public function get health () :Number
    {
        return _health;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _radius :Number;
    protected var _maxHealth :Number;
    protected var _health :Number;

    protected static const BEAT_SCALE :Number = 1.2;
    protected static const BEAT_DELAY :Number = 0.05;

    protected static const HEART_RADIUS_BASE :Number = 41;
}

}
