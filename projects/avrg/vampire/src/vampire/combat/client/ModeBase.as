package vampire.combat.client
{
import com.whirled.contrib.GameMode;

public class ModeBase implements GameMode
{
    public function ModeBase(ctx :CombatGameCtx)
    {
        _ctx = ctx;
    }

    public function pushed():void
    {
    }

    public function popped():void
    {
    }

    public function pushedOnto(mode:GameMode):void
    {
    }

    public function poppedFrom(mode:GameMode):void
    {
    }

    protected var _ctx :CombatGameCtx;

}
}