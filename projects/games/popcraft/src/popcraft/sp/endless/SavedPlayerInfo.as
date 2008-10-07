package popcraft.sp.endless {

import popcraft.PlayerInfo;
import popcraft.battle.WorkshopUnit;

public class SavedPlayerInfo
{
    public var health :Number;
    public var damageShields :Array;

    public function SavedPlayerInfo (playerInfo :PlayerInfo)
    {
        var workshop :WorkshopUnit = playerInfo.workshop;
        if (workshop != null) {
            health = workshop.health;
            damageShields = workshop.damageShieldsClone;

        } else {
            health = 0;
            damageShields = [];
        }
    }

}

}
