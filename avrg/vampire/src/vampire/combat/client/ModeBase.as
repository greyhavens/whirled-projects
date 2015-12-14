package vampire.combat.client
{
import com.threerings.util.Log;
import com.whirled.contrib.GameMode;

public class ModeBase implements GameMode
{
    public function ModeBase(ctx :GameInstance)
    {
        _ctx = ctx;
    }

    public function pushed():void
    {
//        log.debug("pushed " + ClassUtil.tinyClassName(this));
    }

    public function popped():void
    {
//        log.debug("popped " + ClassUtil.tinyClassName(this));
    }

    public function pushedOnto(mode:GameMode):void
    {
    }

    public function poppedFrom(mode:GameMode):void
    {
    }

    protected var _ctx :GameInstance;

    protected static var log :Log = Log.getLog(ModeBase);
}
}
