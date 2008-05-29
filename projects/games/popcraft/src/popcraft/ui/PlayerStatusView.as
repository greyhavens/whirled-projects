package popcraft.ui {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.text.TextField;

import popcraft.*;

public class PlayerStatusView extends SceneObject
{
    public function PlayerStatusView (playerId :uint)
    {
        _playerInfo = GameContext.playerInfos[playerId];

        _movie = SwfResource.instantiateMovieClip("dashboard", "player_slot");

        _healthMeter = _movie["health_meter"];
        _healthMeter.filters = [ ColorMatrix.create().tint(_playerInfo.playerColor).createFilter() ];
        _meterArrow = _movie["meter_arrow"];

        var playerName :TextField = _movie["player_name"];
        playerName.text = _playerInfo.playerName;

        var namePlate :MovieClip = _movie["name_plate"];
        namePlate.filters = [ ColorMatrix.create().colorize(_playerInfo.playerColor).createFilter() ];
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function update (dt :Number) :void
    {
        var healthPercent :Number = _playerInfo.healthPercent;
        var healthRotation :Number = (1.0 - healthPercent) * -180; // DisplayObject rotations are in degrees
        _healthMeter.rotation = healthRotation;
        _meterArrow.rotation = healthRotation;

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

}

}
