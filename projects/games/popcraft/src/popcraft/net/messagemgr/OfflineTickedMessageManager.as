//
// $Id$

package popcraft.net.messagemgr {

import com.whirled.contrib.messagemgr.BasicMessageManager;
import com.whirled.contrib.messagemgr.Message;
import com.whirled.game.GameControl;

public class OfflineTickedMessageManager extends BasicMessageManager
    implements TickedMessageManager
{
    public function OfflineTickedMessageManager (gameCtrl :GameControl, tickIntervalMS :int)
    {
        _gameCtrl = gameCtrl;

        _randSeed = uint(Math.random() * uint.MAX_VALUE);
        _tickIntervalMS = tickIntervalMS;
        _msTillNextTick = tickIntervalMS;

        // create the first tick
        _ticks.push(new Array());
    }

    public function run () :void
    {
        // no-op
    }

    public function stop () :void
    {
        // no-op
    }

    public function update (dt :Number) :void
    {
        // convert seconds to milliseconds
        var dtMS :int = (dt * 1000);

        // create new tick timeslices as necessary
        while (dtMS > 0) {
            if (dtMS < _msTillNextTick) {
                _msTillNextTick -= dtMS;
                dtMS = 0;
            } else {
                dtMS -= _msTillNextTick;
                _msTillNextTick = _tickIntervalMS;
                _ticks.push(new Array());
            }
        }
    }

    public function get isReady () :Boolean
    {
        return true;
    }

    public function get randomSeed () :uint
    {
        return _randSeed;
    }

    public function get unprocessedTickCount () :uint
    {
        return (0 == _ticks.length ? 0 : _ticks.length - 1);
    }

    public function getNextTick () :Array
    {
        if(_ticks.length <= 1) {
            return null;
        } else {
            return (_ticks.shift() as Array);
        }
    }

    public function sendMessage (msg :Message, playerId :int = 0 /* == NetSubControl.TO_ALL */)
        :void
    {
        // add any actions received during this tick
        var array :Array = (_ticks[_ticks.length - 1] as Array);
        array.push(msg);
    }

    public function canSendMessage () :Boolean
    {
        return true;
    }

    protected var _gameCtrl :GameControl;
    protected var _tickIntervalMS :int;
    protected var _randSeed :uint;
    protected var _ticks :Array = [];
    protected var _msTillNextTick :int;

}
}
