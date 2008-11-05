package popcraft.battle {

import com.threerings.flash.Vector2;

import popcraft.*;
import popcraft.game.*;
import popcraft.battle.view.MissileView;

public class MissileFactory
{
    public static function createMissile (targetUnit :Unit, attack :UnitAttack) :Missile
    {
        var srcUnitLoc :Vector2 = attack.sourceUnit.unitLoc;

        var travelDistance :Number = targetUnit.unitLoc.subtract(srcUnitLoc).length;
        var travelTime :Number = (attack.weapon.missileSpeed > 0 ? travelDistance / attack.weapon.missileSpeed : 0);

        // create the logical missile - an attack with a timer on it
        var missile :Missile = new Missile(targetUnit, attack, travelTime);
        GameContext.netObjects.addObject(missile);

        // create the animated missile view
        var missileView :MissileView = new MissileView(srcUnitLoc, targetUnit, travelTime);
        GameContext.gameMode.addObject(missileView, GameContext.battleBoardView.unitViewParent);

        return missile;
    }

}

}
