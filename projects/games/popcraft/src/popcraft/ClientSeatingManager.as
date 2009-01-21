package popcraft {

import com.threerings.util.ArrayUtil;
import com.whirled.game.GameControl;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;

public class ClientSeatingManager extends SeatingManager
{
    override public function init (gameCtrl :GameControl) :void
    {
        super.init(gameCtrl);

        if (_gameCtrl.isConnected()) {
            _headshots = ArrayUtil.create(_numExpectedPlayers, null);
        } else {
            _headshots = [ null ];
        }

        _inited = true;
        updatePlayers();

    }
    public function getPlayerHeadshot (playerSeat :int) :DisplayObject
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

    override protected function updatePlayers (...ignored) :void
    {
        if (!_inited) {
            return;
        }

        super.updatePlayers();
        var playerIds :Array = _gameCtrl.game.seating.getPlayerIds();
        for (var seatIndex :int = 0; seatIndex < playerIds.length; ++seatIndex) {
            var playerId :int = playerIds[seatIndex];
            var playerPresent :Boolean = (playerId != 0);
            if (playerPresent && null == _headshots[seatIndex]) {
                _headshots[seatIndex] = ClientContext.gameCtrl.local.getHeadShot(playerId);
            }
        }
    }

    protected var _headshots :Array;
    protected var _inited :Boolean;
}

}
