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

public class BattleBoardView extends SceneObject
{
    public function BattleBoardView (width :int, height :int)
    {
        _width = width;
        _height = height;

        _view = new Sprite();

        // @TODO - randomize multiplayer backgrounds
        var bgName :String = (GameContext.isSinglePlayer ? GameContext.spLevel.backgroundName : "Level2");
        _bg = SwfResource.instantiateMovieClip("bg", bgName);
        _bg.x = _bg.width * 0.5;
        _bg.y = _bg.height * 0.5;

        _view.addChild(_bg);
        _view.addChild(_spellDropViewParent);
        _view.addChild(_unitViewParent);

        _lastDayPhase = (DiurnalCycle.isDisabled ? Constants.PHASE_NIGHT : GameContext.gameData.initialDayPhase);

        _bg.gotoAndStop(_lastDayPhase == Constants.PHASE_NIGHT ? "night" : "day");
    }

    override protected function update (dt :Number) :void
    {
        var newDayPhase :uint = GameContext.diurnalCycle.phaseOfDay;
        if (newDayPhase != _lastDayPhase) {
            this.animateDayPhaseChange(newDayPhase);
            _lastDayPhase = newDayPhase;
        }
    }

    protected function animateDayPhaseChange (phase :uint) :void
    {
        _bg.gotoAndPlay(phase == Constants.PHASE_NIGHT ? "daytonight" : "nighttoday");
    }

    override public function get displayObject () :DisplayObject
    {
        return _view;
    }

    public function get spellDropViewParent () :DisplayObjectContainer
    {
        return _spellDropViewParent;
    }

    public function get unitViewParent () :DisplayObjectContainer
    {
        return _unitViewParent;
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
    protected var _view :Sprite;
    protected var _spellDropViewParent :Sprite = new Sprite();
    protected var _unitViewParent :Sprite = new Sprite();
    protected var _lastDayPhase :uint;
    protected var _bg :MovieClip;
}

}
