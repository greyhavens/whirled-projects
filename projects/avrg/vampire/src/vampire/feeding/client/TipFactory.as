package vampire.feeding.client {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.objects.SceneObject;

public class TipFactory
{
    public static const GRAB_WHITE :int = 0;
    public static const DROP_WHITE :int = 1;
    public static const GET_MULTIPLIER :int = 2;
    public static const GET_SPECIAL :int = 3;

    public static function createTip (type :int, owner :SceneObject) :SimObject
    {
        var tip :Tip = new Tip(TIP_TEXT[type], owner);
        tip.offset.x = -tip.width * 0.5;
        tip.offset.y = -tip.height - 5;
        GameCtx.gameMode.addSceneObject(tip, GameCtx.uiLayer);

        return tip;
    }

    protected static const TIP_TEXT :Array = [
        "Grab me before I explode!",
        "Drag me to an artery!",
        "Catch me in a cascade to increase its value!",
        "Catch me in a cascade to harvest my special strain!",
    ];
}

}

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.components.SceneComponent;
import flash.text.TextField;

import vampire.feeding.client.*;
import com.threerings.flash.Vector2;
import com.threerings.whirled.data.SceneCodes;
import flash.geom.Point;
import flash.display.DisplayObject;

class Tip extends SceneObject
{
    public var offset :Vector2 = new Vector2();

    public function Tip (text :String, owner :SceneObject)
    {
        _tf = TextBits.createText(text, 1.5, 0, 0xffffff);
        _ownerRef = owner.ref;

        // Start invisible, so if a frame passes before we update our location, we
        // don't appear in the wrong place
        this.visible = false;
    }

    override public function get displayObject () :DisplayObject
    {
        return _tf;
    }

    override protected function update (dt :Number) :void
    {
        var owner :SceneObject = _ownerRef.object as SceneObject;
        if (owner == null || owner.displayObject == null || owner.displayObject.parent == null) {
            destroySelf();
            return;
        }

        var loc :Point = owner.displayObject.parent.localToGlobal(new Point(owner.x, owner.y));
        loc.x += offset.x;
        loc.y += offset.y;
        loc = this.displayObject.parent.globalToLocal(loc);
        this.x = loc.x;
        this.y = loc.y;

        this.visible = true;
    }

    protected var _tf :TextField;
    protected var _ownerRef :SimObjectRef;
}
