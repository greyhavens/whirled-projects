package popcraft {

import com.threerings.util.ArrayUtil;
import com.whirled.game.OccupantChangedEvent;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

public class SeatingManager
{
    public static function init () :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            _numExpectedPlayers = AppContext.gameCtrl.game.seating.getPlayerIds().length;
            _headshots = ArrayUtil.create(_numExpectedPlayers, null);
            _playersPresent = ArrayUtil.create(_numExpectedPlayers, false);
            _localPlayerSeat = AppContext.gameCtrl.game.seating.getMyPosition();
            updatePlayers();

            // Use a high priority for these event handlers. We want to process them before
            // anyone else does.
            AppContext.gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, updatePlayers, false, int.MAX_VALUE);
            AppContext.gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, updatePlayers, false, int.MAX_VALUE);

        } else {
            _numExpectedPlayers = 1;
            _headshots = [ null ];
            _numPlayers = 1;
            _localPlayerSeat = 0;
            _lowestOccupiedSeat = 0;
        }
    }

    public static function get numExpectedPlayers () :int
    {
        return _numExpectedPlayers;
    }

    public static function get numPlayers () :int
    {
        return _numPlayers;
    }

    public static function get allPlayersPresent () :Boolean
    {
        return _numExpectedPlayers == _numPlayers;
    }

    public static function get localPlayerSeat () :int
    {
        return _localPlayerSeat;
    }

    public static function get localPlayerOccupantId () :int
    {
        return getPlayerOccupantId(_localPlayerSeat);
    }

    public static function isPlayerPresent (playerSeat :int) :Boolean
    {
        return _playersPresent[playerSeat];
    }

    public static function getPlayerName (playerSeat :int) :String
    {
        var playerName :String;
        if (AppContext.gameCtrl.isConnected() && playerSeat < _numExpectedPlayers) {
            playerName = AppContext.gameCtrl.game.seating.getPlayerNames()[playerSeat];
        }

        return (null != playerName ? playerName : "[Unknown Player: " + playerSeat + "]");
    }

    public static function getPlayerOccupantId (playerSeat :int) :int
    {
        if (AppContext.gameCtrl.isConnected() && playerSeat < _numExpectedPlayers) {
            return AppContext.gameCtrl.game.seating.getPlayerIds()[playerSeat];
        } else {
            return 0;
        }
    }

    public static function getPlayerHeadshot (playerSeat :int) :DisplayObject
    {
        var headshot :DisplayObject;

        if (playerSeat < _numExpectedPlayers) {
            headshot = _headshots[playerSeat];
        }

        if (null == headshot) {
            // construct a default headshot (box with an X through it)
            var shape :Shape = new Shape();
            var g :Graphics = shape.graphics;
            g.lineStyle(2, 0);
            g.beginFill(0);
            g.drawRect(0, 0, 80, 60);
            g.endFill();
            g.lineStyle(2, 0xFF0000);
            g.moveTo(2, 2);
            g.lineTo(78, 58);
            g.moveTo(78, 2);
            g.lineTo(2, 58);

            headshot = shape;
        }

        return headshot;
    }

    public static function get isLocalPlayerInControl () :Boolean
    {
        return _localPlayerSeat == _lowestOccupiedSeat;
    }

    protected static function updatePlayers (...ignored) :void
    {
        var playerIds :Array = AppContext.gameCtrl.game.seating.getPlayerIds();
        _numPlayers = 0;
        _lowestOccupiedSeat = -1;
        for (var seatIndex :int = 0; seatIndex < playerIds.length; ++seatIndex) {
            var playerId :int = playerIds[seatIndex];
            var playerPresent :Boolean = (playerId != 0);

            if (playerPresent) {
                ++_numPlayers;
                if (_lowestOccupiedSeat < 0) {
                    _lowestOccupiedSeat = seatIndex;
                }

                if (null == _headshots[seatIndex]) {
                    _headshots[seatIndex] = AppContext.gameCtrl.local.getHeadShot(playerId);
                }
            }

            _playersPresent[seatIndex] = playerPresent;
        }
    }

    protected static var _playersPresent :Array;
    protected static var _numExpectedPlayers :int;  // the number of players who initially joined the game
    protected static var _numPlayers :int;          // the number of players in the game right now
    protected static var _lowestOccupiedSeat :int;
    protected static var _localPlayerSeat :int;
    protected static var _headshots :Array;
}

}
