package popcraft.sp {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.tasks.*;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;

public class ComputerPlayer extends SimObject
{
    public function ComputerPlayer (data :ComputerPlayerData, playerId :uint)
    {
        _data = data;
        _playerData = GameContext.playerData[playerId];

        // Computer players always target the local player
        _playerData.targetedEnemyId = GameContext.localPlayerId;

        _wavesPaused = true;
    }

    protected function queueNextWave () :void
    {
        _queuedFirstWave = true;

        var curDay :DaySequenceData;
        if (_dayIndex < _data.initialDays.length) {
            curDay = _data.initialDays[_dayIndex];
        } else if (_data.repeatingDays.length > 0) {
            var index :int = (_dayIndex - _data.initialDays.length) % _data.repeatingDays.length;
            curDay = _data.repeatingDays[index];
        } else {
            return;
        }

        if (_waveIndex < curDay.unitWaves.length || curDay.repeatWaves) {
            _nextWave = curDay.unitWaves[_waveIndex % curDay.unitWaves.length];
        } else {
            return;
        }

        ++_waveIndex;

        this.addNamedTask(SEND_WAVE_TASK, After(_nextWave.delayBefore, new FunctionTask(sendNextWave)));
    }

    protected function sendNextWave () :void
    {
        if (_playerData.isAlive) {
            for each (var unitType :uint in _nextWave.units) {
                GameContext.gameMode.buildUnit(_playerData.playerId, unitType);
            }

            this.queueNextWave();
        }
    }

    override protected function update (dt :Number) :void
    {
        if (!_playerData.isAlive) {
            this.destroySelf();
            return;
        }

        // stop sending out waves during the day, and resume at night
        var dayPhase :int = GameContext.diurnalCycle.phaseOfDay;
        if (_wavesPaused && dayPhase == Constants.PHASE_NIGHT) {
            _wavesPaused = false;
            _waveIndex = 0;
            if (_queuedFirstWave) {
                // don't increase the day index if nothing has been sent yet
                ++_dayIndex;
            }
            this.queueNextWave();
        } else if (!_wavesPaused && dayPhase == Constants.PHASE_DAY) {
            _wavesPaused = true;
            _nextWave = null;
            this.removeNamedTasks(SEND_WAVE_TASK);
        }
    }

    protected var _data :ComputerPlayerData;
    protected var _playerData :PlayerData;
    protected var _nextWave :UnitWaveData;
    protected var _waveIndex :int;
    protected var _dayIndex :int;

    protected var _queuedFirstWave :Boolean;
    protected var _wavesPaused :Boolean;

    protected static const SEND_WAVE_TASK :String = "SendWave";
}

}
