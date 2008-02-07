package popcraft.battle {
    
import popcraft.GameMode;
    
public class MissileFactory
{
    public static function createMissile (targetUnit :Unit, srcUnit :Unit, weapon :UnitWeapon) :Missile
    {
        var travelDistance :Number = targetUnit.unitLoc.getSubtract(srcUnit.unitLoc).length;
        var travelTime :Number = (weapon.missileSpeed > 0 ? travelDistance / weapon.missileSpeed : 0);
        
        var missile :Missile = new Missile(new UnitAttack(targetUnit.id, srcUnit.id, weapon), travelTime);
        
        GameMode.instance.netObjects.addObject(missile);
        
        return missile;
    }

}

}