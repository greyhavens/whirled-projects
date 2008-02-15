package popcraft.battle {
    
import popcraft.GameMode;
    
public class MissileFactory
{
    public static function createMissile (targetUnit :Unit, srcUnit :Unit, weapon :UnitWeapon) :Missile
    {
        var travelDistance :Number = targetUnit.unitLoc.subtract(srcUnit.unitLoc).length;
        var travelTime :Number = (weapon.missileSpeed > 0 ? travelDistance / weapon.missileSpeed : 0);
        
        var missile :Missile = new Missile(new UnitAttack(targetUnit.id, srcUnit.id, weapon), travelTime);
        
        GameMode.instance.netObjects.addObject(missile);
        
        var missileView :MissileView = new MissileView(srcUnit.unitLoc, targetUnit.id, travelTime);
        
        GameMode.instance.netObjects.addObject(missileView, GameMode.instance.battleUnitDisplayParent);
        
        return missile;
    }

}

}