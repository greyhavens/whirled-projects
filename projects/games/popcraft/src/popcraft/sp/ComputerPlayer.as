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
        if (_playerData.isAlive && GameContext.diurnalCycle.isNight) {
            for each (var unitType :uint in _nextWave.units) {
                this.buildUnit(unitType);
            }

            this.queueNextWave();
        }
    }

    protected function buildUnit (unitType :uint) :void
    {
        GameContext.gameMode.buildUnit(_playerData.playerId, unitType);
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
            this.removeNamedTasks(SPELL_DROP_SPOTTED_TASK); // stop looking for spells during the day
        }

        // look for spell drops
        if (_data.lookForSpellDrops && dayPhase == Constants.PHASE_NIGHT && !this.spellDropSpotted && this.spellDropOnBoard) {
            this.addNamedTask(
                SPELL_DROP_SPOTTED_TASK,
                After(_data.noticeSpellDropAfter.next(),
                    new FunctionTask(sendCouriersForSpellDrop)));
        }
    }

    protected function sendCouriersForSpellDrop () :void
    {
        if (_playerData.isAlive && GameContext.diurnalCycle.isNight) {
            var numCouriers :int = _data.spellDropCourierGroupSize.next() - this.numCouriersOnBoard;
            for (var i :int = 0; i < numCouriers; ++i) {
                this.buildUnit(Constants.UNIT_TYPE_COURIER);
            }
        }
    }

    protected function get spellDropSpotted () :Boolean
    {
        return this.hasTasksNamed(SPELL_DROP_SPOTTED_TASK);
    }

    protected function get spellDropOnBoard () :Boolean
    {
        return GameContext.netObjects.getObjectRefsInGroup(SpellDropObject.GROUP_NAME).length > 0;
    }

    protected function get numCouriersOnBoard () :int
    {
        return CourierCreatureUnit.getNumPlayerCouriersOnBoard(_playerData.playerId);
    }

    protected var _data :ComputerPlayerData;
    protected var _playerData :PlayerData;
    protected var _nextWave :UnitWaveData;
    protected var _waveIndex :int;
    protected var _dayIndex :int;

    protected var _queuedFirstWave :Boolean;
    protected var _wavesPaused :Boolean;

    protected static const SEND_WAVE_TASK :String = "SendWave";
    protected static const SPELL_DROP_SPOTTED_TASK :String = "SpellDropSpotted";
}

}
