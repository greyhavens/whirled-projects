package vampire.combat.client
{
import com.threerings.flashbang.util.Rand;

import vampire.combat.data.Action;
/**
 * AI units choose their actions.
 */
public class ModeAIChooseActions extends ModeBase
{
    public function ModeAIChooseActions(ctx :GameInstance)
    {
        super(ctx);
    }

    override public function pushed():void
    {
        super.pushed();

        if (_ctx.friendlyUnits.length == 0) {
            return;
        }

        for each (var unit :UnitRecord in _ctx.enemyUnits) {
            var enemy :UnitRecord = _ctx.locationHandler.getClosestEnemy(unit);
            unit.setTarget(enemy);

            if (enemy == null) {
                unit.setTarget(_ctx.friendlyUnits[0]);
                unit.actions.addAction(Action.MOVE_CLOSE);
            }
            else if(!_ctx.locationHandler.isTargetInRange(unit, enemy)) {
                unit.actions.addAction(Action.MOVE_CLOSE);
            }
            else {

                if (unit.energy < 20) {
                    unit.actions.addAction(Action.REST);
                }
                else {
                    var action :int = Action.ATTACK_AND__DEFENCE[Rand.nextIntRange(0, Action.ATTACK_AND__DEFENCE.length, 0)];
                    unit.actions.addAction(action);
                }
            }
        }

        for each (unit in _ctx.friendlyUnits) {
            if (unit.target == null) {
            unit.setTarget(_ctx.locationHandler.getClosestEnemy(unit));

            }
        }
        _ctx.client.popModeOnUpdate = true;
//        _ctx.panel.detachActionChooser();
//        _ctx.modeStack.pop();
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
