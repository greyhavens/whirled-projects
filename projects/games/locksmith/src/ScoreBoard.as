// $Id$

package {

import flash.display.Sprite;

import flash.geom.Point;

public class ScoreBoard extends Sprite 
{
    public static const MOON_PLAYER :int = 1;
    public static const SUN_PLAYER :int = 2;

    public function ScoreBoard (moonPlayer :String, sunPlayer :String, gameEndedCallback :Function) 
    {
        _gameEndedCallback = gameEndedCallback;
    }

    public function get moonScore () :int
    {
        return _moonScore;
    }

    public function get sunScore () :int
    {
        return _sunScore;
    }

    public function scorePoint (player :int) :void
    {
        if (player == MOON_PLAYER) {
            var marble :MarbleMovie = new MarbleMovie(Marble.MOON);
            marble.rotation = 90;
            scorePointAnimation(marble, MOON_RAMP_BEGIN, MOON_RAMP_END);
            if (++_moonScore == Locksmith.WIN_SCORE) {
                gameOver();
            }
        } else if (player == SUN_PLAYER) {
            marble = new MarbleMovie(Marble.SUN);
            marble.rotation = -90;
            scorePointAnimation(marble, SUN_RAMP_BEGIN, SUN_RAMP_END);
            if (++_sunScore == Locksmith.WIN_SCORE) {
                gameOver();
            }
        } else {
            Log.getLog(this).debug("Asked to score point for unknown player [" + player + "]");
        }
    }

    protected function gameOver () :void
    {
        if (_gameEndedCallback == null) {
            return;
        }

        _gameEndedCallback();
        _gameEndedCallback = null;
    }

    protected function scorePointAnimation (marble :MarbleMovie, rampBegin :Point, 
        rampEnd :Point) :void
    {
        marble.x = rampBegin.x;
        marble.y = rampBegin.y;
        addChild(marble);
    }

    protected static const SUN_RAMP_BEGIN :Point = new Point(256, 38);
    protected static const SUN_RAMP_END :Point = new Point(312, 99);
    protected static const MOON_RAMP_BEGIN :Point = new Point(-257, 38);
    protected static const MOON_RAMP_END :Point = new Point(-313, 99);

    protected var _moonScore :int = 0;
    protected var _sunScore :int = 0;
    protected var _gameEndedCallback :Function;
}
}
