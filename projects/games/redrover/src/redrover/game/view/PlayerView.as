package redrover.game.view {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;

import redrover.*;
import redrover.game.*;
import redrover.ui.UIBits;
import redrover.util.SpriteUtil;

public class PlayerView extends SceneObject
{
    public function PlayerView (player :Player)
    {
        _player = player;
        _sprite = SpriteUtil.createSprite();
        _playerAnims = ArrayUtil.create(Constants.NUM_TEAMS, null);

        if (_player == GameContext.localPlayer) {
            var arrow :Bitmap = ImageResource.instantiateBitmap("player_arrow");
            arrow.x = -arrow.width * 0.5;
            arrow.y = -arrow.height;
            var arrowSprite :Sprite = SpriteUtil.createSprite();
            arrowSprite.addChild(arrow);
            _arrowObj = new SimpleSceneObject(arrowSprite);
            _arrowObj.addTask(new RepeatingTask(
                LocationTask.CreateEaseOut(0, -8, 0.35),
                LocationTask.CreateEaseIn(0, 0, 0.35)));

            _arrowParent = SpriteUtil.createSprite();
            _sprite.addChild(_arrowParent);

            _arrowParent.addChild(_arrowObj.displayObject);

        } else {
            _nameText = UIBits.createText(_player.playerName, 1.1);
            _sprite.addChild(_nameText);
        }

        setTeam(_player.teamId);
        setBoard(_player.curBoardId);

        registerListener(player, GameEvent.GEMS_REDEEMED, onGemsRedeemed);
        if (_player == GameContext.localPlayer) {
            registerListener(player, GameEvent.WAS_EATEN, onWasEaten);
            registerListener(player, GameEvent.ATE_PLAYER, onAtePlayer);
        }
    }

    override protected function addedToDB () :void
    {
        if (_arrowObj != null) {
            this.db.addObject(_arrowObj);
        }
    }

    override protected function removedFromDB () :void
    {
        if (_arrowObj != null) {
            _arrowObj.destroySelf();
        }
    }

    override protected function destroyed () :void
    {
        for each (var movies :Array in _playerAnims) {
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

    protected function onGemsRedeemed (e :GameEvent) :void
    {
        var data :Object = e.data;
        var gems :Array = data.gems;
        var boardCell :BoardCell = data.boardCell;
        GameContext.gameMode.addObject(
            new GemsRedeemedAnim(_player, gems, boardCell),
            GameContext.gameMode.getTeamSprite(_player.teamId));
    }

    protected function onWasEaten (e :GameEvent) :void
    {
        var data :Object = e.data;
        var eatingPlayer :Player = data.eatingPlayer;

        UIBits.createNotification(_player.teamId,
            eatingPlayer.playerName + " captured you!\n" +
            "You now serve the " + Constants.TEAM_LEADER_NAMES[_player.teamId] + ".",
            new Vector2(_player.loc.x, _player.loc.y - 80));
    }

    protected function onAtePlayer (e :GameEvent) :void
    {
        var data :Object = e.data;
        var eatenPlayer :Player = data.eatenPlayer;

        var text :String = "You captured " + eatenPlayer.playerName +
            (eatenPlayer.numGems > 0 ? "\nand took " + eatenPlayer.numGems + " gems!" : "!");

        UIBits.createNotification(_player.teamId, text,
            new Vector2(_player.loc.x, _player.loc.y - 80));
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (!_player.isLiveObject) {
            destroySelf();
            return;
        }

        // Have we switched teams?
        var teamChanged :Boolean;
        if (_lastTeamId != _player.teamId) {
            setTeam(_player.teamId);
            teamChanged = true;
        }

        // Have we switched boards?
        if (_lastBoardId != _player.curBoardId) {
            setBoard(_player.curBoardId);
        }

        // Update animation based on facing direction
        var newDirection :int = _player.moveDirection;
        if (teamChanged || _curAnim == null || (newDirection != _lastFacing && newDirection != -1)) {
            if (_curAnim != null) {
                _sprite.removeChild(_curAnim);
            }

            if (newDirection == -1) {
                newDirection = 0;
            }

            var anims :Array = _playerAnims[_player.teamId];
            _curAnim = anims[newDirection];
            _sprite.addChild(_curAnim);
        }

        // update location
        this.x = _player.loc.x;
        this.y = _player.loc.y;

        // Did we pick up a gem?
        var newGems :int = _player.numGems;
        if (_player.isLocalPlayer && newGems > _lastGems) {
            GameContext.playGameSound("sfx_gem" + Math.min(newGems, NUM_GEM_SOUNDS));
        }

        _lastFacing = newDirection;
        _lastGems = newGems;
    }

    protected function setBoard (boardId :int) :void
    {
        GameContext.gameMode.getTeamSprite(boardId).playerLayer.addChild(_sprite);
        _lastBoardId = boardId;
    }

    protected function setTeam (teamId :int) :void
    {
        var movies :Array = _playerAnims[teamId];
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
                if (facing == Constants.DIR_EAST) {
                    movie.scaleX *= -1;
                }

                movies.push(movie);
                facing++;
            }

            _playerAnims[teamId] = movies;
        }

        if (_nameText != null) {
            _nameText.textColor = NAME_COLORS[teamId];
            _nameText.x = -(_nameText.width * 0.5);
            _nameText.y = -(DisplayObject(movies[0]).height) - _nameText.height;
        }

        if (_arrowParent != null) {
            _arrowParent.x = -1;
            _arrowParent.y = -(DisplayObject(movies[0]).height) - 1;
            _arrowObj.displayObject.filters = [ new ColorMatrix().tint(NAME_COLORS[teamId], 0.7).createFilter() ];
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
    protected var _nameText :TextField;
    protected var _arrowObj :SimpleSceneObject;
    protected var _arrowParent :Sprite;
    protected var _curAnim :MovieClip;
    protected var _playerAnims :Array; // Array<Array<MovieClip>>
    protected var _lastTeamId :int = -1;
    protected var _lastFacing :int = -1;
    protected var _lastLoc :Vector2 = new Vector2();
    protected var _lastGems :int;
    protected var _lastBoardId :int;

    protected var _mask :Shape;

    protected static const MOVIE_SCALES :Array = [ 1.2, 0.8 ];
    protected static const SWF_NAMES :Array = [ "sapper", "grunt" ];
    protected static const MOVIE_NAMES :Array = [
        [ "walk_N", "walk_SW", "walk_S", "walk_SW" ],
        [ "stand_N", "stand_SW", "stand_S", "stand_SW" ]
    ];
    protected static const NAME_COLORS :Array = [ 0xff0000, 0x0000ff  ];

    protected static const NUM_GEM_SOUNDS :int = 7;
}

}
