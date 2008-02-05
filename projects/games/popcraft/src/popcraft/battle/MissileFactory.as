package popcraft.battle {
    
import popcraft.GameMode;
    
public class MissileFactory
{
    public static function createMissile (srcUnit :Unit, targetUnit :Unit, payload :UnitWeapon) :Missile
    {
        var travelDistance :Number = targetUnit.unitLoc.getSubtract(srcUnit.unitLoc).length;
        var travelTime :Number = travelDistance / payload.missileSpeed;
        
        var missile :Missile = new Missile(srcUnit.id, targetUnit.id, payload, travelTime);
        
        GameMode.instance.netObjects.addObject(missile);
        
        return missile;
    }

}

}