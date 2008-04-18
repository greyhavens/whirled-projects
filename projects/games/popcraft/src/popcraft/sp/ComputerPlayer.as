package popcraft.sp {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

import popcraft.*;
import popcraft.battle.*;

public class ComputerPlayer extends SimObject
{
    public function ComputerPlayer (data :ComputerPlayerData, playerId :uint)
    {
        _data = data;
        _playerData = GameContext.playerData[playerId];

        this.queueNextWave();
    }

    protected function queueNextWave () :void
    {
        if (_waveIndex < _data.initialWaves.length) {
            _nextWave = _data.initialWaves[_waveIndex];
        } else {
            var index :int = (_waveIndex - _data.initialWaves.length) % _data.repeatingWaves.length;
            _nextWave = _data.repeatingWaves[index];
        }

        ++_waveIndex;

        this.addNamedTask(SEND_WAVE_TASK, After(_nextWave.delayBefore, new FunctionTask(sendNextWave)));
    }

    protected function sendNextWave () :void
    {
        for each (var unitType :uint in _nextWave.units) {
            GameContext.gameMode.buildUnit(_playerData.playerId, unitType);
        }

        this.queueNextWave();
    }

    override protected function update (dt :Number) :void
    {
        // stop sending out waves during the day, and resume at night
        var dayPhase :int = GameContext.diurnalCycle.phaseOfDay;
        if (_pausedForDaytime && dayPhase == DiurnalCycle.NIGHT) {
            _pausedForDaytime = false;
            this.addNamedTask(SEND_WAVE_TASK, After(_nextWave.delayBefore, new FunctionTask(sendNextWave)));
        } else if (!_pausedForDaytime && dayPhase == DiurnalCycle.DAY) {
            _pausedForDaytime = true;
            this.removeNamedTasks(SEND_WAVE_TASK);
        }
    }

    protected var _data :ComputerPlayerData;
    protected var _playerData :PlayerData;
    protected var _nextWave :UnitWave;
    protected var _waveIndex :int;

    protected var _pausedForDaytime :Boolean;

    protected static const SEND_WAVE_TASK :String = "SendWave";
}

}
