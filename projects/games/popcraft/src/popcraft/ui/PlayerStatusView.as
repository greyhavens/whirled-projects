package popcraft.ui {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.text.TextField;

import popcraft.*;

public class PlayerStatusView extends SceneObject
{
    public function PlayerStatusView (playerIndex :int)
    {
        _playerInfo = GameContext.playerInfos[playerIndex];

        _movie = SwfResource.instantiateMovieClip("dashboard", "player_slot");
        _movie.cacheAsBitmap = true;

        _healthMeter = _movie["health_meter"];
        _healthMeter.filters = [ ColorMatrix.create().tint(_playerInfo.playerColor).createFilter() ];
        _meterArrow = _movie["meter_arrow"];

        var playerName :TextField = _movie["player_name"];
        playerName.text = _playerInfo.playerName;

        var namePlate :MovieClip = _movie["name_plate"];
        namePlate.filters = [ ColorMatrix.create().colorize(_playerInfo.playerColor).createFilter() ];

        // display the player headshot
        var headshotParent :MovieClip = _movie["player_headshot"];
        var headshot :DisplayObject = _playerInfo.playerHeadshot;
        // scale and align appropriately
        var scale :Number = Math.min(HEADSHOT_SIZE.x / headshot.width, HEADSHOT_SIZE.y / headshot.height, 1);
        var width :Number = headshot.width * scale;
        var height :Number = headshot.height * scale;
        headshot.scaleX = scale;
        headshot.scaleY = scale;
        headshot.x = -(width * 0.5);
        headshot.y = -(height * 0.5) - 2;
        headshotParent.addChild(_playerInfo.playerHeadshot);
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function update (dt :Number) :void
    {
        var healthPercent :Number = _playerInfo.healthPercent;

        if (_oldHealth != healthPercent) {
            var healthRotation :Number = (1.0 - healthPercent) * -180; // DisplayObject rotations are in degrees
            _healthMeter.rotation = healthRotation;
            _meterArrow.rotation = healthRotation;

            _oldHealth = healthPercent;
        }

        if (!_dead && !_playerInfo.isAlive) {
            var deathMovie :MovieClip = _movie["dead"];
            deathMovie.gotoAndPlay(2);
            _dead = true;
        }
    }

    protected var _playerInfo :PlayerInfo;
    protected var _movie :MovieClip;
    protected var _healthMeter :MovieClip;
    protected var _meterArrow :MovieClip;
    protected var _dead :Boolean;
    protected var _oldHealth :Number = -1;

    protected static const HEADSHOT_SIZE :Point = new Point(45, 45);

}

}
