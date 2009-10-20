package vampire.combat.client
{
import com.whirled.contrib.GameMode;

public class ModeShowCombatAnimations extends ModeBase
{
    public function ModeShowCombatAnimations(ctx :GameInstance)
    {
        super(ctx);
    }

    override public function pushed():void
    {
        super.pushed();
        _ctx.locationHandler.moveUnits();
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
