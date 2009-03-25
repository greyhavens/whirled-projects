package vampire.feeding.client {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;

public class TipFactory
{
    public static const POP_RED :int = 0;
    public static const CASCADE :int = 1;
    public static const GRAB_WHITE :int = 2;
    public static const DROP_WHITE :int = 3;
    public static const GET_MULTIPLIER :int = 4;
    public static const GET_SPECIAL :int = 5;

    public static const NUM_TIPS :int = 6;

    public function createTip (type :int, owner :SceneObject) :SimObjectRef
    {
        // Have we already displayed this tip enough?
        if (MAX_TIP_COUNT[type] >= 0 && _tipCounts[type] >= MAX_TIP_COUNT[type]) {
            return SimObjectRef.Null();
        }

        // Is this tip dependent on another one?
        var dependentTip :int = DEPENDENT_TIP[type];
        if (dependentTip >= 0 && _tipCounts[dependentTip] == 0) {
            return SimObjectRef.Null();
        }

        // Are we already displaying a tip? Has it existed for longer than a few seconds?
        var existingTip :Tip = GameCtx.gameMode.getObjectNamed("Tip") as Tip;
        if (existingTip != null) {
            if (existingTip.type == type || existingTip.lifeTime < 5) {
                return SimObjectRef.Null();
            } else {
                existingTip.destroySelf();
            }
        }

        var tip :Tip = new Tip(type, owner);
        tip.offset.x = -tip.width * 0.5;
        tip.offset.y = -tip.height - 10;
        GameCtx.gameMode.addSceneObject(tip, GameCtx.uiLayer);

        _tipCounts[type] += 1;

        return tip.ref;
    }

    protected var _tipCounts :Array = ArrayUtil.create(NUM_TIPS, 0);

    protected static const MAX_TIP_COUNT :Array = [ 1, 1, 2, 2, 2, -1 ];
    protected static const DEPENDENT_TIP :Array = [ -1, 0, 1, 1, 1, -1 ];
}

}

const TIP_TEXT :Array = [
    "Pop red cells to score",
    "Cascades send multipliers\nto your teammates",
    "Grab white cells\nbefore they corrupt",
    "Drag white cells\nto arteries",
    "Catch multipliers\nin cascades",
    "Catch special strains\nin cascades",
];

function createTipText (type :int) :TextField
{
    return TextBits.createText(TIP_TEXT[type], 1.3, 0, 0xffffff, "center", TextBits.FONT_ARNO);
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
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.tasks.AlphaTask;
import com.whirled.contrib.simplegame.tasks.SelfDestructTask;
import com.whirled.contrib.simplegame.tasks.TimedTask;

class Tip extends SceneObject
{
    public var offset :Vector2 = new Vector2();

    public function Tip (type :int, owner :SceneObject)
    {
        _type = type;
        _tf = createTipText(type);
        _ownerRef = owner.ref;

        if (_ownerRef.isNull) {
            throw new Error("Tip owner isn't in an ObjectDB");
        }

        // Start invisible, so if a frame passes before we update our location, we
        // don't appear in the wrong place
        this.alpha = 0;
        addTask(new AlphaTask(1, 0.5));
    }

    public function get type () :int
    {
        return _type;
    }

    public function get lifeTime () :Number
    {
        return _lifeTime;
    }

    override public function get displayObject () :DisplayObject
    {
        return _tf;
    }

    /*override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:     return "Tip";
        case 1:     return "Tip_" + _type;
        default:    return super.getObjectGroup(groupNum - 2);
        }
    }*/

    override public function get objectName () :String
    {
        return "Tip";
    }

    override protected function update (dt :Number) :void
    {
        var owner :SceneObject = _ownerRef.object as SceneObject;
        if (owner == null || owner.displayObject == null || owner.displayObject.parent == null) {
            if (_lifeTime < MIN_TIME) {
                var deadTip :DeadTip = new DeadTip(_type, MIN_TIME - _lifeTime);
                deadTip.x = this.x;
                deadTip.y = this.y;
                GameCtx.gameMode.addSceneObject(deadTip, GameCtx.uiLayer);
            }

            destroySelf();
            return;
        }

        _lifeTime += dt;

        var loc :Point = owner.displayObject.parent.localToGlobal(new Point(owner.x, owner.y));
        loc.x += offset.x;
        loc.y += offset.y;
        loc = this.displayObject.parent.globalToLocal(loc);
        this.x = loc.x;
        this.y = loc.y;
    }

    protected var _type :int;
    protected var _tf :TextField;
    protected var _ownerRef :SimObjectRef;
    protected var _lifeTime :Number = 0;

    protected static const MIN_TIME :Number = 2;
}

class DeadTip extends SceneObject
{
    public function DeadTip (type :int, screenTime :Number = 0)
    {
        _tf = createTipText(type);
        addTask(new SerialTask(
            new TimedTask(screenTime),
            new AlphaTask(0, 0.5),
            new SelfDestructTask()));
    }

    override public function get displayObject () :DisplayObject
    {
        return _tf;
    }

    protected var _tf :TextField;
}
