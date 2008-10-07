package popcraft.sp.endless {

import popcraft.data.EndlessComputerPlayerData;
import popcraft.sp.ComputerPlayerAI;
import popcraft.sp.ComputerPlayerInfo;

public class EndlessComputerPlayerInfo extends ComputerPlayerInfo
{
    public function EndlessComputerPlayerInfo (playerIndex :int, data :EndlessComputerPlayerData,
        healthScale :Number)
    {
        super(playerIndex, data.baseLoc, data);
        _ecpData = data;

        _maxHealth *= healthScale;
        _startHealth *= healthScale;
    }

    override protected function createAi () :ComputerPlayerAI
    {
        return new EndlessComputerPlayerAI(_ecpData, _playerIndex);
    }

    protected var _ecpData :EndlessComputerPlayerData
}

}
