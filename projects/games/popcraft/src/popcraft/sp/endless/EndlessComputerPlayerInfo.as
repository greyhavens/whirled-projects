package popcraft.sp.endless {

import popcraft.data.EndlessComputerPlayerData;
import popcraft.sp.ComputerPlayerAI;
import popcraft.sp.ComputerPlayerInfo;

public class EndlessComputerPlayerInfo extends ComputerPlayerInfo
{
    public function EndlessComputerPlayerInfo (playerIndex :int, data :EndlessComputerPlayerData,
        mapCycleNumber :int)
    {
        super(playerIndex, data.baseLoc, data);
        _ecpData = data;

        var healthIncrement :int = mapCycleNumber * data.baseHealthIncrement;
        _maxHealth += healthIncrement;
        _startHealth += healthIncrement;
    }

    override protected function createAi () :ComputerPlayerAI
    {
        return new EndlessComputerPlayerAI(_ecpData, _playerIndex);
    }

    protected var _ecpData :EndlessComputerPlayerData
}

}
