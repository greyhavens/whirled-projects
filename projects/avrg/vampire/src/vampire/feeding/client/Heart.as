package vampire.feeding.client {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.util.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;

import vampire.feeding.*;

public class Heart extends SceneObject
{
    public function Heart ()
    {
        _totalBeatTime = ClientCtx.variantSettings.heartbeatTime;
        _lastBeat = FIRST_BEAT_DELAY - _totalBeatTime;

        if (ClientCtx.isCorruption) {
            _circulatory = ClientCtx.instantiateMovieClip("blood", "circulatory_corruption");
            _heartDying = _circulatory["heart_dying"];
            _heartDying.parent.removeChild(_heartDying);
            _heartDeath = _circulatory["heart_death"];
            _heartDeath.parent.removeChild(_heartDeath);
            var arteryTopDying :MovieClip = _circulatory["artery_top_dying"];
            arteryTopDying.parent.removeChild(arteryTopDying);
            var arteryBottomDying :MovieClip = _circulatory["artery_bottom_dying"];
            arteryBottomDying.parent.removeChild(arteryBottomDying);

            _arteriesDying = ArrayUtil.create(2);
            _arteriesDying[Constants.ARTERY_TOP] = arteryTopDying;
            _arteriesDying[Constants.ARTERY_BOTTOM] = arteryBottomDying;

        } else {
            _circulatory = ClientCtx.instantiateMovieClip("blood", "circulatory");
        }

        _arteries = ArrayUtil.create(2);
        _arteries[Constants.ARTERY_TOP] = _circulatory["artery_top"];
        _arteries[Constants.ARTERY_BOTTOM] = _circulatory["artery_bottom"];

        _sparkles = _circulatory["sparkles"];

        _countdown = _circulatory["countdown"];
        _countdown.visible = false;
        _countdown.gotoAndStop(0);

        _heart = _circulatory["heart"];
    }

    public function deliverWhiteCell (arteryType :int) :void
    {
        beat(1);

        // show the delivery animation
        var artery :MovieClip = _arteries[arteryType];
        artery.gotoAndPlay(2);

        _sparkles.gotoAndPlay(2);
    }

    public function get totalBeatTime () :Number
    {
        return _totalBeatTime;
    }

    override public function get displayObject () :DisplayObject
    {
        return _circulatory;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        _liveTime += dt;

        if (_liveTime >= _lastBeat + _totalBeatTime) {
            beat(Math.floor((_liveTime - _lastBeat) / _totalBeatTime));
            _lastBeat = _liveTime + ((_liveTime - _lastBeat) % _totalBeatTime);
        }

        /*if (GameCtx.timeLeft <= 10 && !_countdown.visible) {
            _countdown.visible = true;
            // tick the countdown one frame per second
            addTask(new ShowFramesTask(_countdown, 0, -1, GameCtx.timeLeft));
        }*/

        if (ClientCtx.isCorruption) {
            if (GameCtx.score.bloodCount >= ClientCtx.requiredBlood) {
                if (!_showingDyingMovies) {
                    swapInDisplayObject(_heart, _heartDying);
                    _heart = _heartDying;
                    _heartDying = null;

                    var arteryTop :MovieClip = _arteries[Constants.ARTERY_TOP];
                    var arteryTopDying :MovieClip = _arteriesDying[Constants.ARTERY_TOP];
                    swapInDisplayObject(arteryTop, arteryTopDying);

                    var arteryBottom :MovieClip = _arteries[Constants.ARTERY_BOTTOM];
                    var arteryBottomDying :MovieClip = _arteriesDying[Constants.ARTERY_BOTTOM];
                    swapInDisplayObject(arteryBottom, arteryBottomDying);

                    _arteries = _arteriesDying;
                    _arteriesDying = null;

                    _showingDyingMovies = true;
                }

                if (!_showingDeathMovies && GameCtx.gameOver) {
                    swapInDisplayObject(_heart, _heartDeath);

                    // show a splatter movie
                    var splatter :MovieClip =
                        ClientCtx.instantiateMovieClip("blood", "death_splatter");
                    splatter.x = Constants.GAME_CTR.x;
                    splatter.y = Constants.GAME_CTR.y;
                    GameCtx.bgLayer.addChild(splatter);

                    _showingDeathMovies = true;
                }
            }
        }
    }

    protected function beat (numBeats :int) :void
    {
        if (GameCtx.gameOver) {
            return;
        }

        for (var ii :int = 0; ii < numBeats; ++ii) {
            GameCtx.gameMode.onHeartbeat();
        }

        // only show the animation once
        _heart.gotoAndPlay(2);
        ClientCtx.audio.playSoundNamed("sfx_heartbeat");
    }

    protected static function swapInDisplayObject (disp :DisplayObject, swapIn :DisplayObject) :void
    {
        var parent :DisplayObjectContainer = disp.parent;
        var idx :int = parent.getChildIndex(disp);
        parent.removeChildAt(idx);
        parent.addChildAt(swapIn, idx);
    }

    protected var _totalBeatTime :Number;
    protected var _lastBeat :Number = 0;
    protected var _liveTime :Number = 0;

    protected var _circulatory :MovieClip;
    protected var _heart :MovieClip;

    protected var _arteries :Array;
    protected var _sparkles :MovieClip;
    protected var _countdown :MovieClip;

    protected var _heartDying :MovieClip;
    protected var _arteriesDying :Array;
    protected var _heartDeath :MovieClip;

    protected var _showingDyingMovies :Boolean;
    protected var _showingDeathMovies :Boolean;

    protected static const FIRST_BEAT_DELAY :Number = 1;
}

}
