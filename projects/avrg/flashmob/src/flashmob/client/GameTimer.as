package flashmob.client {

import com.whirled.contrib.simplegame.SimObject;

public class GameTimer extends SimObject
{
    public function GameTimer (time :Number, countUp :Boolean, onTimeUpdated :Function = null)
    {
        _countUp = countUp;
        _onTimeUpdated = onTimeUpdated;

        this.time = time;
    }

    public function get timerText () :String
    {
        return _timerText;
    }

    public function set time (val :Number) :void
    {
        _clockTime = val;
        _lastTime = ClientContext.timeNow;
        updateText();
    }

    public function get time () :Number
    {
        return _clockTime;
    }

    public function set paused (val :Boolean) :void
    {
        _paused = val;
    }

    public function get paused () :Boolean
    {
        return _paused;
    }

    override protected function update (dt :Number) :void
    {
        // GameTimer is running even when its mode is not topmost
        if (!_paused) {
            var now :Number = ClientContext.timeNow;
            dt = now - _lastTime;
            _lastTime = now;

            if (_countUp) {
                _clockTime += dt;
            } else {
                _clockTime = Math.max(_clockTime - dt, 0);
            }
        }

        updateText();
    }

    protected function updateText () :void
    {
        var time :int = Math.floor(_clockTime);
        if (time == _lastUpdate) {
            return;
        }
        _lastUpdate = time;

        var mins :int = time / 60;
        var secs :int = time % 60;
        var minStr :String = String(mins);
        var secStr :String = String(secs);
        /*if (minStr.length < 2) {
            minStr = "0" + minStr;
        }*/
        if (secStr.length < 2) {
            secStr = "0" + secStr;
        }

        _timerText = minStr + ":" + secStr;

        if (_onTimeUpdated != null) {
            _onTimeUpdated(_timerText);
        }
    }

    protected var _clockTime :Number;
    protected var _lastTime :Number;
    protected var _countUp :Boolean;
    protected var _paused :Boolean;
    protected var _onTimeUpdated :Function;

    protected var _timerText :String = "";

    protected var _lastUpdate :Number = Number.MIN_VALUE;
}

}
