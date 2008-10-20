package popcraft.battle.view {

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;

import popcraft.*;
import popcraft.battle.*;
import popcraft.net.*;
import popcraft.util.*;

public class BattleBoardView extends SceneObject
{
    public function BattleBoardView (width :int, height :int)
    {
        _width = width;
        _height = height;

        _bg = SwfResource.instantiateMovieClip("bg", GameContext.gameMode.mapSettings.backgroundName, true);
        _bg.x = Constants.SCREEN_SIZE.x * 0.5;
        _bg.y = Constants.SCREEN_SIZE.y * 0.5;
        _bg.mouseEnabled = false;
        _bg.mouseChildren = false;

        _parent = SpriteUtil.createSprite(true, false);
        _parent.addChild(_bg);

        var attach :MovieClip = _bg["attachment"];

        _diurnalMeterParent = SpriteUtil.createSprite();
        _diurnalMeterParent.x = -_bg.x;
        _diurnalMeterParent.y = -_bg.y;
        attach.addChild(_diurnalMeterParent);

        _unitViewParent = SpriteUtil.createSprite();
        _unitViewParent.x = -_bg.x;
        _unitViewParent.y = -_bg.y;
        attach.addChild(_unitViewParent);

        _lastDayPhase = (DiurnalCycle.isDisabled ? Constants.PHASE_NIGHT : GameContext.gameData.initialDayPhase);

        _bg.gotoAndStop(DiurnalCycle.isNight(_lastDayPhase) ? "night" : "day");
        _bg.cacheAsBitmap = true;
    }

    override protected function update (dt :Number) :void
    {
        var newDayPhase :int = GameContext.diurnalCycle.phaseOfDay;
        if (newDayPhase != _lastDayPhase) {
            this.animateDayPhaseChange(newDayPhase);
            _lastDayPhase = newDayPhase;
        }
    }

    protected function animateDayPhaseChange (phase :int) :void
    {
        var animName :String;
        if (DiurnalCycle.isDay(phase)) {
            animName = "nighttoday";
        } else if (DiurnalCycle.isNight(phase) && !DiurnalCycle.isEclipse(_lastDayPhase)) {
            animName = "daytonight";
        }

        if (null != animName) {
            _bg.gotoAndPlay(animName);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _parent;
    }

    public function get clickableObjectParent () :DisplayObjectContainer
    {
        return _parent;
    }

    public function get unitViewParent () :DisplayObjectContainer
    {
        return _unitViewParent;
    }

    public function get diurnalMeterParent () :DisplayObjectContainer
    {
        return _diurnalMeterParent;
    }

    public function sortUnitDisplayChildren () :void
    {
        DisplayUtil.sortDisplayChildren(_unitViewParent, displayObjectYSort);
    }

    protected static function displayObjectYSort (a :DisplayObject, b :DisplayObject) :int
    {
        var ay :Number = a.y;
        var by :Number = b.y;

        if (ay < by) {
            return -1;
        } else if (ay > by) {
            return 1;
        } else {
            return 0;
        }
    }

    protected var _width :int;
    protected var _height :int;
    protected var _parent :Sprite;
    protected var _unitViewParent :Sprite;
    protected var _diurnalMeterParent :Sprite;
    protected var _lastDayPhase :int;
    protected var _bg :MovieClip;
}

}
