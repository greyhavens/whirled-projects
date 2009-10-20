package vampire.feeding.client {

import com.threerings.util.ArrayUtil;
import com.threerings.flashbang.*;
import com.threerings.flashbang.objects.*;

public class TipFactory
{
    // Normal
    public static const POP_RED :int = 0;
    public static const CASCADE :int = 1;
    public static const GRAB_WHITE :int = 2;
    public static const DROP_WHITE :int = 3;
    public static const GET_MULTIPLIER :int = 4;
    public static const GET_SPECIAL :int = 5;

    // Corruption
    public static const CORRUPTION_AVOID_RED :int = 6;
    public static const CORRUPTION_DROP_WHITE :int = 7;
    public static const CORRUPTION_CASCADE :int = 8;
    public static const CORRUPTION_CASCADE_2 :int = 9;
    public static const CORRUPTION_MULTIPLIER :int = 10;
    public static const CORRUPTION_ARTERIES :int = 11;

    public static const NUM_TIPS :int = 12;

    public function createTip (type :int, owner :SceneObject, followsOwner :Boolean = true)
        :GameObjectRef
    {
        // Have we already displayed this tip enough?
        if (MAX_TIP_COUNT[type] >= 0 && _tipCounts[type] >= MAX_TIP_COUNT[type]) {
            return GameObjectRef.Null();
        }

        // Is this tip dependent on another one?
        var dependentTip :int = DEPENDENT_TIP[type];
        if (dependentTip >= 0 && _tipCounts[dependentTip] == 0) {
            return GameObjectRef.Null();
        }

        // Are we already displaying a tip? Has it existed for longer than a few seconds?
        var existingTip :Tip = GameCtx.gameMode.getObjectNamed("Tip") as Tip;
        if (existingTip != null) {
            if (existingTip.type == type || existingTip.lifeTime < 5) {
                return GameObjectRef.Null();
            } else {
                existingTip.destroySelf();
            }
        }

        var tip :Tip = new Tip(type, owner, followsOwner);
        tip.offset.x = -tip.width * 0.5;
        tip.offset.y = -tip.height - 10;
        GameCtx.gameMode.addSceneObject(tip, GameCtx.effectLayer);

        _tipCounts[type] += 1;

        return tip.ref;
    }

    public function createTipFromList (types :Array, owner :SceneObject,
        followsOwner :Boolean = true) :GameObjectRef
    {
        // try to create each tip type in the list, and return when the first one is
        // successfully created
        for each (var type :int in types) {
            var tipRef :GameObjectRef = createTip(type, owner, followsOwner);
            if (!tipRef.isNull) {
                return tipRef;
            }
        }

        return GameObjectRef.Null();
    }

    protected var _tipCounts :Array = ArrayUtil.create(NUM_TIPS, 0);

    protected static const MAX_TIP_COUNT :Array = [
        1, 1, 2, 2, 2, -1,

        1, 1, 1, 1, 1, 1
    ];

    protected static const DEPENDENT_TIP :Array = [
        -1, POP_RED, CASCADE, CASCADE, CASCADE, -1,

        CORRUPTION_DROP_WHITE, -1, CORRUPTION_AVOID_RED, CORRUPTION_CASCADE, CORRUPTION_CASCADE,
        CORRUPTION_CASCADE_2
    ];
}

}

const TIP_TEXT :Array = [
    "Pop red cells to score",
    "Cascades send multipliers\nto your teammates",
    "Grab white cells\nbefore they corrupt",
    "Drag white cells\nto arteries",
    "Catch multipliers\nin cascades",
    "Catch special strains\nin cascades",

    "Avoid popping\nred cells directly",
    "Click the mouse to\ndrop a white cell",
    "White cells explode,\ncorrupting reds!",
    "Corruption saps your\nprey's health",
    "Multipliers increase\ncorruption potency",
    "Cross an artery with a\nwhite cell to pump more reds",
];

function createTipText (type :int) :TextField
{
    return TextBits.createText(TIP_TEXT[type], 1.3, 0, 0xffffff, "center", TextBits.FONT_ARNO);
}

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.GameObjectRef;
import com.threerings.flashbang.objects.SceneObject;
import com.threerings.flashbang.components.SceneComponent;
import flash.text.TextField;

import vampire.feeding.client.*;
import com.threerings.flash.Vector2;
import flash.geom.Point;
import flash.display.DisplayObject;
import com.threerings.flashbang.tasks.SerialTask;
import com.threerings.flashbang.tasks.AlphaTask;
import com.threerings.flashbang.tasks.SelfDestructTask;
import com.threerings.flashbang.tasks.TimedTask;

class Tip extends SceneObject
{
    public var offset :Vector2 = new Vector2();

    public function Tip (type :int, owner :SceneObject, followsOwner :Boolean)
    {
        _type = type;
        _tf = createTipText(type);
        _ownerRef = owner.ref;
        _followsOwner = followsOwner;

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
                GameCtx.gameMode.addSceneObject(deadTip, GameCtx.effectLayer);
            }

            destroySelf();
            return;
        }

        // Reposition the tip to be near its owner if the tip was just created, or if
        // _followsOwner is true
        if (_followsOwner || _lifeTime == 0) {
            var loc :Point = owner.displayObject.parent.localToGlobal(new Point(owner.x, owner.y));
            loc.x += offset.x;
            loc.y += offset.y;
            loc = this.displayObject.parent.globalToLocal(loc);
            this.x = loc.x;
            this.y = loc.y;
        }

        _lifeTime += dt;
    }

    protected var _type :int;
    protected var _tf :TextField;
    protected var _ownerRef :GameObjectRef;
    protected var _followsOwner :Boolean;
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
