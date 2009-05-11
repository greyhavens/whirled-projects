package vampire.combat.client
{
import com.threerings.util.Command;
import com.whirled.contrib.DisplayUtil;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

import vampire.combat.data.Action;


public class ActionObject extends SceneObject
{
    public function ActionObject(action :int, type :int, unit :UnitRecord = null)
    {
        super();
        _action = action;
        _warmUp = Action.warmUp(action);
        var selfref :ActionObject = this;
        switch (type) {
            case MENU:
            registerListener(_displaySprite, MouseEvent.CLICK, function (...ignored) :void {
                Command.dispatch(_displaySprite, CombatController.MENU_ACTION_CLICK, [unit, selfref]);
            });
            break;
            case UNIT:
            registerListener(_displaySprite, MouseEvent.CLICK, function (...ignored) :void {
                Command.dispatch(_displaySprite, CombatController.UNIT_ACTION_CLICK, [unit, selfref]);
            });
            break;
        }

        redraw();
    }
    public function get action () :int
    {
        return _action;
    }

    public function redraw () :void
    {
        var buttonheight :int = 40;

        DisplayUtil.removeAllChildren(_displaySprite);
        var g :Graphics = _displaySprite.graphics;
        g.clear();
        g.beginFill(0x00CCFF);
        g.drawRoundRect(-WIDTH / 2, -buttonheight / 2, WIDTH, buttonheight, 20);
        DisplayUtil.drawText(_displaySprite, Action.name(action), -WIDTH / 2, -buttonheight / 2);
        for (var ii :int = 1; ii <= _warmUp; ++ii) {
            g.drawRoundRect(-WIDTH / 2 + (ii * WIDTH), -buttonheight / 2, WIDTH, buttonheight, 20);
        }
        g.endFill();
    }

    public function nextRound () :void
    {
        _events.freeAllHandlers();
        redraw();
    }

    public function decrementWarmup () :void
    {
        _warmUp--;
        _warmUp = Math.max(_warmUp, 0);
        redraw();
    }

    public function get warmUpRemaining () :int
    {
        return _warmUp;
    }

    public function get isWarmUpRemaining () :Boolean
    {
        return _warmUp > 0;
    }

    public function get dispatcher () :EventDispatcher
    {
        return _displaySprite;
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    protected var _warmUp :int;
    protected var _action :int;
    protected var _displaySprite :Sprite = new Sprite();


    public static const NULL :int = 0;
    public static const MENU :int = 1;
    public static const UNIT :int = 2;

    public static const WIDTH :int = 40;
}
}