//
// $Id$

package popcraft.game.endless {

import popcraft.data.EndlessComputerPlayerData;
import popcraft.data.UnitWaveData;
import popcraft.game.ComputerPlayerAI;

public class EndlessComputerPlayerAI extends ComputerPlayerAI
{
    public function EndlessComputerPlayerAI (data :EndlessComputerPlayerData, playerIndex :int)
    {
        super(data, playerIndex);
        _endlessData = data;
    }

    override protected function getWaveDelay (wave :UnitWaveData) :Number
    {
        return wave.delayBefore * getWaveDelayScale(_lastDayIndex);
    }

    protected function getWaveDelayScale (dayIndex :int) :Number
    {
        var numInitialDays :int = _endlessData.initialDays.length;
        var numRepeatingDays :int = _endlessData.repeatingDays.length;
        var daysOver :int = Math.max(0, dayIndex + 1 - numInitialDays - numRepeatingDays);

        // increase the speed of waves every time the computer cycles through its days,
        // and every time the player cycles all the way through the levels.
        var cycle :int = Math.ceil(daysOver / numRepeatingDays) + EndlessGameContext.mapCycleNumber;

        return 1 * Math.pow(_endlessData.waveDelayScale, cycle);
    }

    protected var _endlessData :EndlessComputerPlayerData;
}

}
