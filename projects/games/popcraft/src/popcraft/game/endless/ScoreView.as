package popcraft.game.endless {

import com.threerings.util.StringUtil;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.text.TextField;

import popcraft.*;

public class ScoreView extends SceneObject
{
    public function ScoreView ()
    {
        _movie = ClientCtx.instantiateMovieClip("dashboard", "scoreboard", true);
        _movie.x = 350;
        _movie.y = 2;
        _scoreText = _movie["score"];
        _multiplierText = _movie["score_multiplier"];

        updateText();
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_lastScore != EndlessGameContext.totalScoreThisLevel ||
            _lastMultiplier != EndlessGameContext.scoreMultiplier) {
            updateText();
        }
    }

    protected function updateText () :void
    {
        var score :int = EndlessGameContext.totalScoreThisLevel;
        var multiplier :int = EndlessGameContext.scoreMultiplier;

        _scoreText.text = StringUtil.formatNumber(score);
        _multiplierText.text = String(multiplier);

        _lastScore = score;
        _lastMultiplier = multiplier;
    }

    protected var _movie :MovieClip;
    protected var _scoreText :TextField;
    protected var _multiplierText :TextField;
    protected var _lastScore :int;
    protected var _lastMultiplier :int;
}

}
