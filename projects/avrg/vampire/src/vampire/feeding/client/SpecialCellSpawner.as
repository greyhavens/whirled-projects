package vampire.feeding.client {

import com.whirled.contrib.simplegame.SimObject;

import vampire.feeding.*;

public class SpecialCellSpawner extends SimObject
{
    override protected function update (dt :Number) :void
    {
        if (!this.canCollectPreyStrain) {
            destroySelf();
            return;
        }

        _elapsedTime += dt;

        if (Cell.getCellCount(Constants.CELL_SPECIAL) == 0) {
            if (_nextSpawnTime < 0) {
                _nextSpawnTime = _elapsedTime + Constants.SPECIAL_CELL_CREATION_TIME.next();
            } else if (_elapsedTime >= _nextSpawnTime) {
                var cell :Cell =
                    GameObjects.createCell(Constants.CELL_SPECIAL, true, ClientCtx.preyBloodType);
                _nextSpawnTime = -1;
            }
        }
    }

    protected function get canCollectPreyStrain () :Boolean
    {
        // Is there a special blood strain to collect from the prey? Can we collect it?
        return (!ClientCtx.isPrey &&
                ClientCtx.preyBloodType >= 0 &&
                ClientCtx.playerData.canCollectStrainFromPlayer(ClientCtx.preyBloodType,
                                                                ClientCtx.preyId));
    }

    protected var _elapsedTime :Number = 0;
    protected var _nextSpawnTime :Number = -1;
}

}
