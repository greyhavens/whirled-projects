package vampire.feeding.client {

import com.threerings.flashbang.GameObjectRef;
import com.threerings.flashbang.tasks.*;

import vampire.data.VConstants;
import vampire.feeding.*;
import vampire.server.Trophies;

public class RedBurst extends CellBurst
{
    public static function getRedBurstCollision (obj :CollidableObj) :RedBurst
    {
        // returns the first burst that collides with the given object
        var bursts :Array = GameCtx.gameMode.getObjectRefsInGroup(GROUP_NAME);
        for each (var ref :GameObjectRef in bursts) {
            var burst :RedBurst = ref.object as RedBurst;
            if (burst != null && burst.collidesWith(obj)) {
                return burst;
            }
        }

        return null;
    }

    public function RedBurst (fromCell :Cell, cascade :BurstCascade)
    {
        super(fromCell.type, Constants.RED_BURST_RADIUS_MIN, Constants.RED_BURST_RADIUS_MAX,
              fromCell.multiplier, cascade);
    }

    override protected function beginBurst () :void
    {
        super.beginBurst();

        addTask(ScaleTask.CreateEaseOut(
            this.targetScale,
            this.targetScale,
            Constants.BURST_EXPAND_TIME));

        addTask(new SerialTask(
            new TimedTask(Constants.BURST_COMPLETE_TIME),
            new FunctionTask(function () :void {
                _burstCompleted = true;
            }),
            new SelfDestructTask()));

        ClientCtx.audio.playSoundNamed("sfx_red_burst");
    }

    override protected function removedFromDB () :void
    {
        if (!_burstCompleted && _cascade != null) {
            _cascade.removeCellBurst(this);
        }
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var cell :Cell = Cell.getCellCollision(this);
        if (cell != null && !cell.isWhiteCell && cell.state == Cell.STATE_NORMAL) {
            if (cell.type == Constants.CELL_SPECIAL) {
                // harvest the special blood
                GameObjects.createSpecialBloodAnim(cell);
                ClientCtx.playerData.collectStrainFromPlayer(cell.specialStrain, ClientCtx.preyId);

                // award the HUNTER trophy
                if (ClientCtx.playerData.getStrainCount(cell.specialStrain) >=
                    Trophies.HUNTER_COLLECTION_REQUIREMENT) {
                    ClientCtx.awardTrophy(Trophies.getHunterTrophyName(cell.specialStrain));
                }

                // award the HUNTER_ALL trophy (for getting the rest of the HUNTER trophies)
                var hasAllHunterTrophies :Boolean = true;
                for (var strain :int = 0; strain < VConstants.UNIQUE_BLOOD_STRAINS; ++strain) {
                    if (ClientCtx.playerData.getStrainCount(strain) <
                        Trophies.HUNTER_COLLECTION_REQUIREMENT) {
                        hasAllHunterTrophies = false;
                        break;
                    }
                }

                if (hasAllHunterTrophies) {
                    ClientCtx.awardTrophy(Trophies.TROPHY_HUNTER_ALL);
                }

            } else {
                GameObjects.createRedBurst(cell, _cascade);
            }
        }
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:     return GROUP_NAME;
        default:    return super.getObjectGroup(groupNum - 1);
        }
    }

    protected var _burstCompleted :Boolean;

    protected static const GROUP_NAME :String = "RedBurst";
}

}
