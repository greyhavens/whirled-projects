package popcraft.sp.endless {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;

import popcraft.*;
import popcraft.ui.UIBits;

public class ScoreView extends SceneObject
{
    public function ScoreView ()
    {
        _movie = SwfResource.instantiateMovieClip("dashboard", "scoreboard");
        _movie.x = 350;
        _movie.y = 2;
        _scoreText = _movie["score"];
        _multiplierText = _movie["score_multiplier"];

        this.updateText();
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var newScore :int = EndlessGameContext.score;
        var mult :int = EndlessGameContext.scoreMultiplier;
        if (_lastScore != newScore || _lastMultiplier != mult) {
            this.updateText();
        }
    }

    protected function updateText () :void
    {
        var text :String = String(EndlessGameContext.score);
        var numLeadingZeros :int = NUM_DIGITS - text.length;
        for (var ii :int = 0; ii < numLeadingZeros; ++ii) {
            text = "0" + text;
        }

        _scoreText.text = text;
        _multiplierText.text = String(EndlessGameContext.scoreMultiplier);
    }

    protected var _movie :MovieClip;
    protected var _scoreText :TextField;
    protected var _multiplierText :TextField;
    protected var _lastScore :int;
    protected var _lastMultiplier :int;

    protected static const NUM_DIGITS :int = 0;//7;
}

}
