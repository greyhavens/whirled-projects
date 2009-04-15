package vampire.quest.client {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.SimpleGame;

import flash.display.Sprite;

import vampire.quest.*;

public class QuestClient extends Sprite
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
        ClientCtx.rsrcs = simpleGame.ctx.rsrcs;
        ClientCtx.questData = questData;
        ClientCtx.stats = stats;

        // load resources
        ClientCtx.rsrcs.queueResourceLoad("swf", "map", { embeddedClass: SWF_MAP });
        ClientCtx.rsrcs.loadQueuedResources(
            function () :void {
                _resourcesLoaded = true;
            },
            function (err :String) :void {
                log.error("Error loading resources: " + err);
            });
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

    public static function get isReady () :Boolean
    {
        return _resourcesLoaded;
    }

    protected static var _debugPanel :StatDebugPanel;
    protected static var _questPanel :QuestPanel;

    protected static var _inited :Boolean;
    protected static var _resourcesLoaded :Boolean;

    [Embed(source="../../../../rsrc/quest/map_mockup.swf", mimeType="application/octet-stream")]
    protected static const SWF_MAP :Class;

    protected static var log :Log = Log.getLog(QuestClient);
}

}
