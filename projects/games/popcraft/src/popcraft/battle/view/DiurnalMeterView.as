package popcraft.battle.view {

import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.objects.RectMeter;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

import popcraft.*;
import popcraft.battle.*;

public class DiurnalMeterView extends SceneObject
{
    public function DiurnalMeterView ()
    {
        _sprite = new Sprite();

        _sun = AppContext.instantiateBitmap("sun");
        _moon = AppContext.instantiateBitmap("moon");

        _meter = new RectMeter();
        _meter.width = METER_WIDTH;
        _meter.height = METER_HEIGHT;
        _meter.backgroundColor = 0xFFFFFF;
        _meter.minValue = 0;
        _meter.x = _sun.width + 2;
        _meter.y = (_sun.height * 0.5) - (_meter.height * 0.5);

        _sprite.addChild(_sun);
        _sprite.addChild(_moon);

        this.dayPhaseChanged(GameContext.gameData.initialDayPhase, true);
    }

    override protected function addedToDB () :void
    {
        this.db.addObject(_meter, _sprite);
    }

    override protected function removedFromDB () :void
    {
        _meter.destroySelf();
    }

    override protected function update (dt :Number) :void
    {
        var newPhase :int = GameContext.diurnalCycle.phaseOfDay;
        if (newPhase != _lastPhase) {
            this.dayPhaseChanged(newPhase, true);
        }

        if (!_playedDawnSound && GameContext.diurnalCycle.isNight && GameContext.diurnalCycle.timeTillNextPhase <= GameContext.gameData.dawnWarning) {
            AudioManager.instance.playSoundNamed("sfx_dawn");
            _playedDawnSound = true;
        }

        _meter.value = GameContext.diurnalCycle.timeTillNextPhase;
    }

    protected function dayPhaseChanged (newPhase :uint, playSound :Boolean) :void
    {
        var soundName :String;

        if (newPhase == Constants.PHASE_DAY) {
            _meter.foregroundColor = METER_DAY_FG;
            _meter.maxValue = GameContext.gameData.dayLength;
            _sun.visible = true;
            _moon.visible = false;
            soundName = "sfx_day";
        } else {
            _meter.foregroundColor = METER_NIGHT_FG;
            _meter.maxValue = GameContext.gameData.nightLength;
            _sun.visible = false;
            _moon.visible = true;
            _playedDawnSound = false;
            soundName = "sfx_night";
        }

        if (playSound) {
            AudioManager.instance.playSoundNamed(soundName);
        }

        _lastPhase = newPhase;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _sun :Bitmap;
    protected var _moon :Bitmap;
    protected var _meter :RectMeter;
    protected var _lastPhase :int;
    protected var _playedDawnSound :Boolean;

    protected static const METER_WIDTH :int = 120;
    protected static const METER_HEIGHT :int = 20;
    protected static const METER_DAY_FG :uint = 0xFFCC00;
    protected static const METER_NIGHT_FG :uint = 0x3B5187;

}

}
