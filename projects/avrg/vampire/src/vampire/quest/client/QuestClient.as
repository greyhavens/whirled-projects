package vampire.quest.client {

import com.whirled.contrib.simplegame.SimpleGame;

public class QuestClient
{
    public static function init (simpleGame :SimpleGame) :void
    {
        if (_inited) {
            throw new Error("QuestClient already inited");
        }
        _inited = true;

        ClientCtx.mainLoop = simpleGame.ctx.mainLoop;
    }

    protected static var _inited :Boolean;
}

}
