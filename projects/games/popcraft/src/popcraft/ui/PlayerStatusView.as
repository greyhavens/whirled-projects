package popcraft.ui {

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.text.TextField;

import popcraft.*;
import popcraft.game.*;

public class PlayerStatusView extends SceneObject
{
    public static const GROUP_NAME :String = "PlayerStatusView";

    public static function getAll () :Array
    {
        return GameCtx.gameMode.getObjectsInGroup(GROUP_NAME);
    }

    public function PlayerStatusView (playerIndex :int)
    {
        _playerInfo = GameCtx.playerInfos[playerIndex];

        _movie = ClientCtx.instantiateMovieClip("dashboard", "player_slot", true);
        _movie.cacheAsBitmap = true;

        _deathMovie = _movie["dead"];
        _deathMovie.visible = false;

        _healthMeter = _movie["health_meter"];
        _healthMeter.filters = [ ColorMatrix.create().tint(_playerInfo.color).createFilter() ];
        _meterArrow = _movie["meter_arrow"];

        var playerName :TextField = _movie["player_name"];
        playerName.text = _playerInfo.displayName;

        var namePlate :MovieClip = _movie["name_plate"];
        namePlate.filters = [ ColorMatrix.create().colorize(_playerInfo.color).createFilter() ];

        var headshotParent :HeadshotSprite = new HeadshotSprite(
            playerIndex, HEADSHOT_SIZE.x, HEADSHOT_SIZE.y, _playerInfo.headshot);

        // display the player headshot
        /*var headshotParent :Sprite = SpriteUtil.createSprite();

        // add the headshot image
        var headshot :DisplayObject = _playerInfo.headshot;
        headshot.scaleX = 1;
        headshot.scaleY = 1;
        var scale :Number = Math.max(HEADSHOT_SIZE.x / headshot.width,
                                     HEADSHOT_SIZE.y / headshot.height);
        headshot.scaleX = scale;
        headshot.scaleY = scale;
        headshot.x = (HEADSHOT_SIZE.x - headshot.width) * 0.5;
        headshot.y = (HEADSHOT_SIZE.y - headshot.height) * 0.5;
        headshotParent.addChild(headshot);

        // mask the headshot
        var headshotMask :Shape = new Shape();
        var g :Graphics = headshotMask.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, HEADSHOT_SIZE.x, HEADSHOT_SIZE.y);
        g.endFill();
        headshotParent.addChild(headshotMask);
        headshotParent.mask = headshotMask;*/

        // add to the PlayerStatusView
        var frame :MovieClip = _movie["player_headshot"];
        DisplayUtil.positionBounds(headshotParent,
            -headshotParent.width * 0.5,
            (-headshotParent.height * 0.5) - 2);
        frame.addChild(headshotParent);
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch(groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    public function get isAlive () :Boolean
    {
        return _playerInfo.isAlive;
    }

    public function get playerInfo () :PlayerInfo
    {
        return _playerInfo;
    }

    override protected function update (dt :Number) :void
    {
        var playerDead :Boolean = !_playerInfo.isAlive;
        if (!_dead && playerDead) {
            _deathMovie.visible = true;
            _deathMovie.gotoAndPlay(2);
            _dead = true;

        } else if (_dead && !playerDead) {
            _deathMovie.visible = false;
            _dead = false;
        }

        if (!_dead) {
            var healthPercent :Number = _playerInfo.healthPercent;
            if (_oldHealth != healthPercent) {
                var healthRotation :Number = (1.0 - healthPercent) * -180; // DisplayObject rotations are in degrees
                _healthMeter.rotation = healthRotation;
                _meterArrow.rotation = healthRotation;

                _oldHealth = healthPercent;
            }
        }
    }

    protected var _playerInfo :PlayerInfo;
    protected var _movie :MovieClip;
    protected var _deathMovie :MovieClip;
    protected var _healthMeter :MovieClip;
    protected var _meterArrow :MovieClip;
    protected var _dead :Boolean;
    protected var _oldHealth :Number = -1;

    protected static const HEADSHOT_SIZE :Point = new Point(45, 45);

}

}
