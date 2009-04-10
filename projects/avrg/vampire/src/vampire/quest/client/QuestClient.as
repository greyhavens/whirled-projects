package vampire.quest.client {

import com.whirled.contrib.simplegame.SimpleGame;

import vampire.quest.PlayerQuestStats;

public class QuestClient
{
    public static function init (simpleGame :SimpleGame, stats :PlayerQuestStats) :void
    {
        if (_inited) {
            throw new Error("QuestClient already inited");
        }
        _inited = true;

        ClientCtx.mainLoop = simpleGame.ctx.mainLoop;
        ClientCtx.stats = stats;
    }

    public static function showDebugPanel () :void
    {
        if (_debugPanel == null) {
            _debugPanel = new StatDebugPanel(ClientCtx.stats);
            ClientCtx.mainLoop.topMode.addSceneObject(_debugPanel);
        }
    }

    protected static var _debugPanel :StatDebugPanel;

    protected static var _inited :Boolean;
}

}
