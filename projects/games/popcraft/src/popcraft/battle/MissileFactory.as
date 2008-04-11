package popcraft.battle {

import com.threerings.flash.Vector2;

import popcraft.GameMode;
import popcraft.battle.view.MissileView;

public class MissileFactory
{
    public static function createMissile (targetUnit :Unit, attack :UnitAttack) :Missile
    {
        var srcUnitLoc :Vector2 = attack.sourceUnit.unitLoc;

        var travelDistance :Number = targetUnit.unitLoc.subtract(srcUnitLoc).length;
        var travelTime :Number = (attack.weapon.missileSpeed > 0 ? travelDistance / attack.weapon.missileSpeed : 0);

        var missile :Missile = new Missile(targetUnit, attack, travelTime);

        GameMode.instance.netObjects.addObject(missile);

        var missileView :MissileView = new MissileView(srcUnitLoc, targetUnit.ref, travelTime);

        GameMode.instance.netObjects.addObject(missileView, GameMode.instance.battleUnitDisplayParent);

        return missile;
    }

}

}
