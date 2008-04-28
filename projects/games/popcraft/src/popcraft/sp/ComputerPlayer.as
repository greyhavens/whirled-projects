package popcraft.sp {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

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

        this.queueNextWave();
    }

    protected function queueNextWave () :void
    {
        if (_waveIndex < _data.initialWaves.length) {
            _nextWave = _data.initialWaves[_waveIndex];
        } else if (_data.repeatingWaves.length > 0) {
            var index :int = (_waveIndex - _data.initialWaves.length) % _data.repeatingWaves.length;
            _nextWave = _data.repeatingWaves[index];
        }

        ++_waveIndex;

        if (null != _nextWave) {
            this.addNamedTask(SEND_WAVE_TASK, After(_nextWave.delayBefore, new FunctionTask(sendNextWave)));
        }
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
        if (_pausedForDaytime && dayPhase == Constants.PHASE_NIGHT) {
            _pausedForDaytime = false;
            if (null != _nextWave) {
                this.addNamedTask(SEND_WAVE_TASK, After(_nextWave.delayBefore, new FunctionTask(sendNextWave)));
            }
        } else if (!_pausedForDaytime && dayPhase == Constants.PHASE_DAY) {
            _pausedForDaytime = true;
            this.removeNamedTasks(SEND_WAVE_TASK);
        }
    }

    protected var _data :ComputerPlayerData;
    protected var _playerData :PlayerData;
    protected var _nextWave :UnitWaveData;
    protected var _waveIndex :int;

    protected var _pausedForDaytime :Boolean;

    protected static const SEND_WAVE_TASK :String = "SendWave";
}

}
