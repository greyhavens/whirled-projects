package redrover.game.view {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import redrover.*;
import redrover.game.*;
import redrover.util.SpriteUtil;

public class PlayerView extends SceneObject
{
    public function PlayerView (player :Player)
    {
        _player = player;
        _sprite = SpriteUtil.createSprite();
        _playerMovies = ArrayUtil.create(Constants.NUM_TEAMS, null);
        setTeam(_player.teamId);
        setBoard(_player.curBoardId);
    }

    override protected function destroyed () :void
    {
        for each (var movies :Array in _playerMovies) {
            if (movies == null) {
                continue;
            }
            for each (var movie :MovieClip in movies) {
                SwfResource.releaseMovieClip(movie);
            }
        }

        super.destroyed();
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        // Have we switched teams?
        if (_lastTeamId != _player.teamId) {
            setTeam(_player.teamId);
        }

        // Have we switched boards?
        if (_lastBoardId != _player.curBoardId) {
            setBoard(_player.curBoardId);
        }

        // Update animation based on facing direction
        var newLoc :Vector2 = _player.loc.clone();
        var newFacing :int;
        if (newLoc.x > _lastLoc.x) {
            newFacing = FACING_E;
        } else if (newLoc.x < _lastLoc.x) {
            newFacing = FACING_W;
        } else if (newLoc.y > _lastLoc.y) {
            newFacing = FACING_S;
        } else if (newLoc.y < _lastLoc.y) {
            newFacing = FACING_N;
        } else {
            newFacing = _lastFacing;
        }

        if (newFacing != _lastFacing || newFacing == -1) {
            if (_sprite.numChildren > 0) {
                _sprite.removeChildAt(0);
            }

            if (newFacing == -1) {
                newFacing = 0;
            }

            var movies :Array = _playerMovies[_player.teamId];
            _sprite.addChildAt(movies[newFacing], 0);
        }

        // update location
        this.x = newLoc.x;
        this.y = newLoc.y;

        // Did we pick up a gem?
        var newGems :int = _player.numGems;
        if (newGems > _lastGems) {
            GameContext.playGameSound("sfx_gem" + Math.min(newGems, NUM_GEM_SOUNDS));
        }

        _lastFacing = newFacing;
        _lastLoc = newLoc;
        _lastGems = newGems;
    }

    protected function setBoard (boardId :int) :void
    {
        GameContext.gameMode.getTeamSprite(boardId).objectLayer.addChild(_sprite);
        _lastBoardId = boardId;
    }

    protected function setTeam (teamId :int) :void
    {
        var movies :Array = _playerMovies[teamId];
        if (movies == null) {
            movies = [];
            var swfName :String = SWF_NAMES[teamId];
            var movieNames :Array = MOVIE_NAMES[teamId];
            var scale :Number = MOVIE_SCALES[teamId];
            var cm :ColorMatrix = new ColorMatrix().colorize(_player.color);

            var facing :int = 0;
            for each (var movieName :String in movieNames) {
                var movie :MovieClip =
                    SwfResource.instantiateMovieClip(swfName, movieName, true, true);

                // colorize
                var ii :int = 1;
                var success :Boolean = true;
                while (success) {
                    success = colorizeAnimation(movie, "recolor" + ii++, cm);
                }
                colorizeAnimation(movie, "recolor", cm);

                movie.scaleX = scale;
                movie.scaleY = scale;

                // for east-facing animations, instantiate the west-facing anim and mirror
                // horizontally
                if (facing == FACING_E) {
                    movie.scaleX *= -1;
                }

                movies.push(movie);
                facing++;
            }

            _playerMovies[teamId] = movies;
        }

        _lastTeamId = teamId;
        _lastFacing = -1;
        _lastLoc = new Vector2();
    }

    protected static function colorizeAnimation (anim :MovieClip, childName :String,
        tintMatrix :ColorMatrix) :Boolean
    {
        var color :MovieClip = anim[childName];
        if (null != color) {
            color = color["recolor"];
            if (null != color) {
                color.filters = [ tintMatrix.createFilter() ];
            }
        }

        return (null != color);
    }

    protected var _player :Player;
    protected var _sprite :Sprite;
    protected var _playerMovies :Array; // Array<Array<MovieClip>>
    protected var _lastTeamId :int = -1;
    protected var _lastFacing :int = -1;
    protected var _lastLoc :Vector2 = new Vector2();
    protected var _lastGems :int;
    protected var _lastBoardId :int;

    protected static const FACING_N :int = 0;
    protected static const FACING_W :int = 1;
    protected static const FACING_S :int = 2;
    protected static const FACING_E :int = 3;

    protected static const MOVIE_SCALES :Array = [ 1.2, 1.5 ];
    protected static const SWF_NAMES :Array = [ "grunt", "sapper" ];
    protected static const MOVIE_NAMES :Array = [
        [ "stand_N", "stand_SW", "stand_S", "stand_SW" ],
        [ "walk_N", "walk_SW", "walk_S", "walk_SW" ]
    ];

    protected static const NUM_GEM_SOUNDS :int = 7;
}

}
