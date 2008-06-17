package popcraft.battle.view {

import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import popcraft.*;
import popcraft.battle.*;

public class DiurnalCycleView extends SceneObject
{
    public function DiurnalCycleView ()
    {
        _sprite = new Sprite();

        _sun = SwfResource.instantiateMovieClip("dashboard", "sun");
        _moon = SwfResource.instantiateMovieClip("dashboard", "moon");
        _eclipse = SwfResource.instantiateMovieClip("dashboard", "eclipse");

        _moon.cacheAsBitmap = true;

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

        var timeTillNextPhase :Number = diurnalCycle.timeTillNextPhase;
        var phaseTotalTime :Number = DiurnalCycle.getPhaseLength(newPhase);
        var percentComplete :Number = 1.0 - ((timeTillNextPhase - _updateTimeDelta) / phaseTotalTime);
        var xLoc :Number = BODY_START_X + (percentComplete * BODY_TOTAL_DIST);

        if (null != _curVisibleBody) {
            _curVisibleBody.x = xLoc;
        }
    }

    protected function dayPhaseChanged (newPhase :int, playSound :Boolean) :void
    {
        var soundName :String;
        var newVisibleBody :MovieClip;

        switch (newPhase) {
        case Constants.PHASE_DAY:
            newVisibleBody = _sun;
            soundName = "sfx_day";
            break;

        case Constants.PHASE_NIGHT:
            newVisibleBody = _moon;
            soundName = "sfx_night";
            break;

        case Constants.PHASE_ECLIPSE:
            newVisibleBody = _eclipse;
            soundName = "sfx_night";
            break;
        }

        if (playSound) {
            GameContext.playGameSound(soundName);
        }

        if (null != _curVisibleBody) {
            _sprite.removeChild(_curVisibleBody);
        }

        if (null != newVisibleBody) {
            _sprite.addChild(newVisibleBody);
        }

        _curVisibleBody = newVisibleBody;
        _lastPhase = newPhase;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _sun :MovieClip;
    protected var _moon :MovieClip;
    protected var _eclipse :MovieClip;
    protected var _lastPhase :int;
    protected var _curVisibleBody :MovieClip;
    protected var _playedDawnSound :Boolean;

    protected var _lastUpdateTimestamp :Number = 0;
    protected var _updateTimeDelta :Number = 0;

    protected static const BODY_START_X :Number = -36;
    protected static const BODY_END_X :Number = 736;
    protected static const BODY_TOTAL_DIST :Number = BODY_END_X - BODY_START_X;
}

}
