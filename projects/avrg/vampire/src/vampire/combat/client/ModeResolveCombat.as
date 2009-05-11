package vampire.combat.client
{
import com.threerings.util.Util;
import com.whirled.contrib.simplegame.util.Rand;

import flash.utils.Dictionary;

import vampire.combat.data.Action;
import vampire.combat.data.Weapon;

public class ModeResolveCombat extends ModeBase
{
    public function ModeResolveCombat(ctx :GameInstance)
    {
        super(ctx);
    }

    override public function pushed():void
    {
        var damageMap :Dictionary = new Dictionary();

        var allUnits :Array = _ctx.enemyUnits.concat(_ctx.friendlyUnits);
        //Handle attacks first
        for each (var u :UnitRecord in allUnits) {
            u.actions.nextRound();
            var actionToResolve :ActionObject = u.actions.previousCurrentAction();
            trace("Combat " + u.name + " " + actionToResolve.action +  " warmup=" + actionToResolve.warmUpRemaining + ", target=" + u.target);

            if (actionToResolve.warmUpRemaining > 0) {
                u.energy -= Action.energyCost(Action.REST);
                actionToResolve.decrementWarmup();
                continue;
            }

            trace("  " + u.name + " energy delta " + Action.energyCost(actionToResolve.action));
            u.energy -= Action.energyCost(actionToResolve.action);
            var target :UnitRecord = u.target;
            if (actionToResolve != null && target != null) {
                switch (actionToResolve.action) {
                    case Action.ATTACK_BASIC:
                        resolveAttack(u, 1, damageMap);
                    break;
//                    case Action.ATTACK_2:
//                        resolveAttack(u, 3, damageMap);
//                    break;

                    case Action.MOVE_FAR:
                        u.range = LocationHandler.RANGED;
                    break;

                    case Action.REST:
                       trace("  " + u.name + " regained energy");
                    break;


                }
            }
            if (actionToResolve == null) {
                u.energy -= Action.energyCost(Action.REST);
            }
        }

        //Then movement
        for each (u in allUnits) {
            actionToResolve = u.actions.previousCurrentAction();
            target = u.target;
            if (actionToResolve != null ) {
                switch (actionToResolve.action) {
                    case Action.MOVE_FAR:
                        u.range = LocationHandler.RANGED;
                    break;

                    case Action.MOVE_CLOSE:
                        if (u.range == LocationHandler.CLOSE && u.target != null) {
                            u.target.range = LocationHandler.CLOSE;
                        }
                        else {
                            u.range = LocationHandler.CLOSE;
                        }

                    break;
                }
            }
        }


        function clearTargetsOfDeadUnit (deadUnit :UnitRecord) :void {
            allUnits.forEach(Util.adapt(function(unit :UnitRecord) :void {
                if (unit.target == deadUnit) {
                    unit.target = null;
                }
            }));
        }


        function filterDead (unit :UnitRecord) :Boolean {
            if (unit.health <= 0) {
                trace(unit.name + "died!!!!!");
                unit.destroySelf();
                clearTargetsOfDeadUnit(unit);
                return false;
            }
            return true;
        }

        _ctx.friendlyUnits = _ctx.friendlyUnits.filter(Util.adapt(filterDead));
        _ctx.enemyUnits = _ctx.enemyUnits.filter(Util.adapt(filterDead));

        _ctx.locationHandler.moveUnits();

        _ctx.selectedEnemyUnit = null;
        _ctx.selectedFriendlyUnit = null;
        _ctx.panel.setUnitForRightInfo(null);

        _ctx.client.popModeOnUpdate = true;

//        units.forEach(Util.adapt(function (unit :UnitRecord) :void {
//            unit.
//        }));
    }

    protected function resolveAttack (attacker :UnitRecord, damageMultiplier :Number, damageMap :Dictionary) :void
    {
        trace("  " + attacker.name + " attacking " + attacker.target.name);
        var TO_HIT :Number = 0.5;
        var target :UnitRecord = attacker.target;
        if (_ctx.locationHandler.isTargetInRange(attacker, target)) {
            if (target.actions.previousCurrentAction().action == Action.DODGE) {
                trace("  " + attacker.name + ": " + target.name + " dodged!");
            }
            else if (Rand.nextNumber(0) <= TO_HIT) {
                //Check dodge
                if (Rand.nextIntRange(0, 100, 0) > target.profile.speed) {
                    var damage :Number = Weapon.damage(attacker.profile.weaponDefault);
                    damage += attacker.profile.strength;
                    damage = Rand.nextIntRange(damage * 0.5, damage * 1.5, 0);
                    damage *= damageMultiplier;
                    trace("  " + attacker.name + " did damage=" + damage);
                    if (target.actions.previousCurrentAction().action == Action.BLOCK) {
                        damage *= target.profile.strength / 100;
                        trace("  " + target.name + " by blocking reduced it to =" + damage);
                    }
                    target.health -= damage;
                    if (damageMap[target] == null) {
                        damageMap[target] = [damage];
                    }
                    else {
                        (damageMap[target] as Array).push(damage);
                    }
                }
            }
        }
        else {
            trace("  " + attacker.name + ": target out of range");
        }
    }
//
//    public function popped():void
//    {
//    }
//
//    public function pushedOnto(mode:GameMode):void
//    {
//    }
//
//    public function poppedFrom(mode:GameMode):void
//    {
//    }

}
}