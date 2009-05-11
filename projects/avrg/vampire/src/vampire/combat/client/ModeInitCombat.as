package vampire.combat.client
{
    import com.threerings.util.Command;

    import flash.events.MouseEvent;



/**
 * This is called once at the beginning.
 * Setup units, create sprites, register listeners etc
 *
 */
public class ModeInitCombat extends ModeBase
{
    public function ModeInitCombat(ctx :GameInstance)
    {
        super(ctx);
    }

    override public function pushed():void
    {
        super.pushed();
        var u :UnitRecord;
        for each (u in _ctx.enemyUnits) {
            _ctx.panel.addSimObject(u);
            _ctx.panel.arena.addSceneObject(u.arenaIcon);
            bindMouseOver(u, u.arenaIcon);
        }
        for each (u in _ctx.friendlyUnits) {
            _ctx.panel.addSimObject(u);
            _ctx.panel.arena.addSceneObject(u.arenaIcon);
            bindMouseOver(u, u.arenaIcon);
        }
        _ctx.locationHandler.moveUnits();

        _ctx.modeStack.pop();
    }

    protected function bindMouseOver (unit :UnitRecord, icon :UnitArenaIcon) :void
    {
        Command.bind(icon.displayObject, MouseEvent.MOUSE_OVER, CombatController.MOUSE_OVER_UNIT, unit);
        Command.bind(icon.displayObject, MouseEvent.ROLL_OUT, CombatController.MOUSE_OUT_UNIT, unit);
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