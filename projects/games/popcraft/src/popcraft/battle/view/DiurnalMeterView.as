package popcraft.battle.view {

import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import popcraft.*;
import popcraft.battle.*;

public class DiurnalMeterView extends SceneObject
{
    public function DiurnalMeterView ()
    {
        _sprite = new Sprite();

        _sun = SwfResource.instantiateMovieClip("dashboard", "sun");
        _moon = SwfResource.instantiateMovieClip("dashboard", "moon");

        _moon.cacheAsBitmap = true;

        _sprite.addChild(_sun);
        _sprite.addChild(_moon);

        this.dayPhaseChanged(GameContext.gameData.initialDayPhase, true);
    }

    override protected function update (dt :Number) :void
    {
        var diurnalCycle :DiurnalCycle = GameContext.diurnalCycle;
        var newPhase :int = diurnalCycle.phaseOfDay;
        if (newPhase != _lastPhase) {
            this.dayPhaseChanged(newPhase, true);
        }

        if (!_playedDawnSound && diurnalCycle.isNight && diurnalCycle.timeTillNextPhase <= GameContext.gameData.dawnWarning) {
            GameContext.playGameSound("sfx_dawn");
            _playedDawnSound = true;
        }

        // estimate the amount of time that's elapsed since the DiurnalCycle's last
        // update, to get smoother sun/moon motion
        var updateTimestamp :Number = diurnalCycle.lastUpdateTimestamp;
        if (updateTimestamp == _lastUpdateTimestamp) {
            _updateTimeDelta += dt;
        } else {
            _lastUpdateTimestamp = updateTimestamp;
            _updateTimeDelta = 0;
        }

        var activeBody :MovieClip = (diurnalCycle.isDay ? _sun : _moon);
        var percentComplete :Number =
            1.0 - ((diurnalCycle.timeTillNextPhase - _updateTimeDelta) / diurnalCycle.curPhaseTotalTime);
        activeBody.x = BODY_START_X + (percentComplete * BODY_TOTAL_DIST);
    }

    protected function dayPhaseChanged (newPhase :uint, playSound :Boolean) :void
    {
        var soundName :String;
        var musicName :String;

        if (newPhase == Constants.PHASE_DAY) {
            _sun.visible = true;
            _moon.visible = false;
            soundName = "sfx_day";
        } else {
            _sun.visible = false;
            _moon.visible = true;
            _playedDawnSound = false;
            soundName = "sfx_night";
            musicName = "mus_night";
        }

        if (playSound) {
            GameContext.playGameSound(soundName);
        }

        if (null != musicName) {
            GameContext.playGameMusic(musicName);
        }

        _lastPhase = newPhase;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _sun :MovieClip;
    protected var _moon :MovieClip;
    protected var _lastPhase :int;
    protected var _playedDawnSound :Boolean;

    protected var _lastUpdateTimestamp :Number = 0;
    protected var _updateTimeDelta :Number = 0;

    protected static const BODY_START_X :Number = -36;
    protected static const BODY_END_X :Number = 736;
    protected static const BODY_TOTAL_DIST :Number = BODY_END_X - BODY_START_X;
}

}
