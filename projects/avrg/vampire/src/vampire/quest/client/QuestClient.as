package vampire.quest.client {

import com.whirled.contrib.simplegame.SimpleGame;

import vampire.quest.*;

public class QuestClient
{
    public static function init (simpleGame :SimpleGame, questData :PlayerQuestData,
        stats :PlayerQuestStats) :void
    {
        if (_inited) {
            throw new Error("QuestClient already inited");
        }
        _inited = true;

        Quests.init();
        Locations.init();

        ClientCtx.mainLoop = simpleGame.ctx.mainLoop;
        ClientCtx.questData = questData;
        ClientCtx.stats = stats;
    }

    public static function showDebugPanel (show :Boolean) :void
    {
        if (_debugPanel == null && show) {
            _debugPanel = new StatDebugPanel();
            ClientCtx.mainLoop.topMode.addSceneObject(_debugPanel);
        }

        if (_debugPanel != null) {
            _debugPanel.visible = show;
        }
    }

    public static function showQuestPanel (show :Boolean) :void
    {
        if (_questPanel == null && show) {
            _questPanel = new QuestPanel();
            ClientCtx.mainLoop.topMode.addSceneObject(_questPanel);
        }

        if (_questPanel != null) {
            _questPanel.visible = show;
        }
    }

    protected static var _debugPanel :StatDebugPanel;
    protected static var _questPanel :QuestPanel;

    protected static var _inited :Boolean;
}

}
