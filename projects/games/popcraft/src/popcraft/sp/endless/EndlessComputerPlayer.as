package popcraft.sp.endless {

import popcraft.data.EndlessComputerPlayerData;
import popcraft.data.UnitWaveData;
import popcraft.sp.ComputerPlayer;

public class EndlessComputerPlayer extends ComputerPlayer
{
    public function EndlessComputerPlayer (data :EndlessComputerPlayerData, playerIndex :int)
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
        var cycle :int = Math.ceil(daysOver / numRepeatingDays);

        var scale :Number = 1;
        for (var ii :int = 0; ii < cycle; ++ii) {
            scale *= _endlessData.waveDelayScale;
        }

        return scale;
    }

    protected var _endlessData :EndlessComputerPlayerData;
}

}
