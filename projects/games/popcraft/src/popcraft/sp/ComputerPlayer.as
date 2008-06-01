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
        _playerInfo = GameContext.playerInfos[playerId] as ComputerPlayerInfo;

        // add starting spells to our playerInfo
        _playerInfo.setSpellCounts(data.startingCreatureSpells);

        // Computer players always target the local player
        _playerInfo.targetedEnemyId = GameContext.localPlayerId;

        _wavesPaused = true;

        _curDay = this.getDayData(0);
    }

    protected function getDayData (dayIndex :int) :DaySequenceData
    {
        if (dayIndex < _data.initialDays.length) {
            return _data.initialDays[_dayIndex];
        } else if (_data.repeatingDays.length > 0) {
            var index :int = (dayIndex - _data.initialDays.length) % _data.repeatingDays.length;
            return _data.repeatingDays[index];
        } else {
            return null;
        }
    }

    protected function queueNextWave () :void
    {
        if (null == _curDay) {
            return;
        }

        _queuedFirstWave = true;

        if (_waveIndex < _curDay.unitWaves.length || _curDay.repeatWaves) {
            _nextWave = _curDay.unitWaves[_waveIndex % _curDay.unitWaves.length];
        } else {
            return;
        }

        ++_waveIndex;

        this.addNamedTask(SEND_WAVE_TASK, After(_nextWave.delayBefore, new FunctionTask(sendNextWave)));
    }

    protected function sendNextWave () :void
    {
        if (_playerInfo.isAlive && GameContext.diurnalCycle.isNight) {

            // before each wave goes out, there's a chance that the computer
            // player will cast a spell (if it has one available)
            if (Rand.nextNumberRange(0, 1, Rand.STREAM_GAME) < _nextWave.spellCastChance) {
                var availableSpells :Array = [];
                for (var spellType :uint = 0; spellType < Constants.SPELL_NAMES.length; ++spellType) {
                    if (_playerInfo.canCastSpell(spellType)) {
                        availableSpells.push(spellType);
                    }
                }

                if (availableSpells.length > 0) {
                    spellType = availableSpells[Rand.nextIntRange(0, availableSpells.length, Rand.STREAM_GAME)];
                    GameContext.gameMode.castSpell(_playerInfo.playerId, spellType);
                }
            }

            for each (var unitType :uint in _nextWave.units) {
                this.buildUnit(unitType);
            }

            this.queueNextWave();
        }
    }

    protected function buildUnit (unitType :uint) :void
    {
        GameContext.gameMode.buildUnit(_playerInfo.playerId, unitType);
    }

    override protected function update (dt :Number) :void
    {
        if (!_playerInfo.isAlive) {
            this.destroySelf();
            return;
        }

        if (null == _curDay) {
            return;
        }

        // stop sending out waves during the day, and resume at night
        var dayPhase :int = GameContext.diurnalCycle.phaseOfDay;
        if (_wavesPaused && dayPhase == Constants.PHASE_NIGHT) {
            _wavesPaused = false;
            _waveIndex = 0;
            if (_queuedFirstWave) {
                // don't increase the day index if nothing has been sent yet
                _curDay = this.getDayData(++_dayIndex);
            }
            this.queueNextWave();
        } else if (!_wavesPaused && dayPhase == Constants.PHASE_DAY) {
            _wavesPaused = true;
            _nextWave = null;
            this.removeNamedTasks(SEND_WAVE_TASK);
            this.removeNamedTasks(SPELL_DROP_SPOTTED_TASK); // stop looking for spells during the day
        }

        // look for spell drops
        if (_curDay.lookForSpellDrops && dayPhase == Constants.PHASE_NIGHT && !this.spellDropSpotted && this.spellDropOnBoard) {
            this.addNamedTask(
                SPELL_DROP_SPOTTED_TASK,
                After(_curDay.noticeSpellDropAfter.next(),
                    new FunctionTask(sendCouriersForSpellDrop)));
        }
    }

    protected function sendCouriersForSpellDrop () :void
    {
        if (_playerInfo.isAlive && GameContext.diurnalCycle.isNight) {
            var numCouriers :int = _curDay.spellDropCourierGroupSize.next() - this.numCouriersOnBoard;
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
        return CourierCreatureUnit.getNumPlayerCouriersOnBoard(_playerInfo.playerId);
    }

    protected var _data :ComputerPlayerData;
    protected var _playerInfo :ComputerPlayerInfo;
    protected var _curDay :DaySequenceData;
    protected var _nextWave :UnitWaveData;
    protected var _waveIndex :int;
    protected var _dayIndex :int;

    protected var _queuedFirstWave :Boolean;
    protected var _wavesPaused :Boolean;

    protected static const SEND_WAVE_TASK :String = "SendWave";
    protected static const SPELL_DROP_SPOTTED_TASK :String = "SpellDropSpotted";
}

}
