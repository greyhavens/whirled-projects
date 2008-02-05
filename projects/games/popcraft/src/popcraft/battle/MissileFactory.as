package popcraft.battle {
    
import popcraft.GameMode;
    
public class MissileFactory
{
    public static function createMissile (targetUnit :Unit, srcUnit :Unit, weapon :UnitWeapon) :Missile
    {
        var travelDistance :Number = targetUnit.unitLoc.getSubtract(srcUnit.unitLoc).length;
        var travelTime :Number = travelDistance / weapon.missileSpeed;
        
        var missile :Missile = new Missile(new UnitAttack(targetUnit.id, srcUnit.id, weapon), travelTime);
        
        GameMode.instance.netObjects.addObject(missile);
        
        return missile;
    }

}

}