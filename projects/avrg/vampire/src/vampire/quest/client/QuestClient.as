package vampire.quest.client {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.contrib.simplegame.SimpleGame;

import vampire.feeding.FeedingClient;
import vampire.feeding.FeedingClientSettings;
import vampire.feeding.PlayerFeedingData;
import vampire.feeding.variant.Variant;
import vampire.furni.FurniConstants;
import vampire.quest.*;
import vampire.quest.activity.*;

public class QuestClient
{
    public static function init (gameCtrl :AVRGameControl, simpleGame :SimpleGame,
        questData :PlayerQuestData, stats :PlayerQuestStats) :void
    {
        if (_inited) {
            throw new Error("QuestClient already inited");
        }
        _inited = true;

        Quests.init();
        Locations.init();

        ClientCtx.gameCtrl = gameCtrl;
        ClientCtx.mainLoop = simpleGame.ctx.mainLoop;
        ClientCtx.rsrcs = simpleGame.ctx.rsrcs;
        ClientCtx.questData = questData;
        ClientCtx.stats = stats;

        if (ClientCtx.gameCtrl.isConnected()) {
            ClientCtx.gameCtrl.player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM,
                function (...ignored) :void {
                    handshakeQuestTotems();
                });

            handshakeQuestTotems();
        }

        ClientCtx.stats.addEventListener(PlayerStatEvent.STAT_CHANGED, checkQuestCompletion);
        ClientCtx.questData.addEventListener(PlayerQuestEvent.QUEST_COMPLETED, onQuestCompleted);

        checkQuestCompletion();

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

    public static function beginActivity (activity :ActivityDesc) :void
    {
        if (activity.params.isLobbied) {
            // TODO
        } else {
            beginSpActivity(activity);
        }
    }

    public static function showActivityPanel (loc :LocationDesc) :void
    {
        hideActivityPanel();
        _activityPanel = new ActivityPanel(loc);
        ClientCtx.mainLoop.topMode.addSceneObject(_activityPanel);
    }

    public static function hideActivityPanel () :void
    {
        if (_activityPanel != null) {
            _activityPanel.destroySelf();
            _activityPanel = null;
        }
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

    protected static function checkQuestCompletion (...ignored) :void
    {
        for each (var quest :QuestDesc in ClientCtx.questData.activeQuests) {
            if (quest.isComplete(ClientCtx.stats)) {
                ClientCtx.questData.completeQuest(quest.id);
            }
        }
    }

    protected static function onQuestCompleted (e :PlayerQuestEvent) :void
    {
        var note :QuestCompletedNotification = new QuestCompletedNotification(e.quest);
        note.x = (ClientCtx.mainLoop.topMode.modeSprite.width - note.width) * 0.5;
        note.y = 15;
        ClientCtx.mainLoop.topMode.addSceneObject(note);
    }

    protected static function beginSpActivity (activity :ActivityDesc) :void
    {
        switch (activity.type) {
        case ActivityDesc.TYPE_CORRUPTION:
            var feedingGame :FeedingClient = FeedingClient.create(FeedingClientSettings.spSettings(
                "", 0,
                Variant.CORRUPTION,
                new PlayerFeedingData(),
                function () :void {
                    feedingGame.shutdown();
                    feedingGame.parent.removeChild(feedingGame);
                },
                ClientCtx.questData,
                ClientCtx.stats,
                activity.params as BloodBloomActivityParams));
            ClientCtx.mainLoop.topMode.modeSprite.addChild(feedingGame);
            break;

        default:
            log.warning("Unrecognized activity type", "activity", activity);
            break;
        }
    }

    protected static function handshakeQuestTotems () :void
    {
        for each (var furniId :String in ClientCtx.gameCtrl.room.getEntityIds("furni")) {
            var setTotemClickCallback :Function = ClientCtx.gameCtrl.room.getEntityProperty(
                FurniConstants.ENTITY_PROP_SET_CLICK_CALLBACK, furniId) as Function;
            if (setTotemClickCallback != null) {
                log.info("Found Quest Totem", "entityId", furniId);
                setTotemClickCallback(questTotemClicked);
            }
        }
    }

    protected static function questTotemClicked (totemType :String, totemEntityId :String) :void
    {
        log.info("questTotemClicked", "totemType", totemType, "entityId", totemEntityId);
        var loc :LocationDesc = Locations.getLocationByName(totemType);
        if (loc == null) {
            log.warning("No location for Quest Totem", "totemType", totemType);
        } else {
            showActivityPanel(loc);
        }
    }

    protected static var _activityPanel :ActivityPanel;
    protected static var _debugPanel :StatDebugPanel;
    protected static var _questPanel :QuestPanel;

    protected static var _inited :Boolean;
    protected static var _resourcesLoaded :Boolean;

    [Embed(source="../../../../rsrc/quest/map_mockup.swf", mimeType="application/octet-stream")]
    protected static const SWF_MAP :Class;

    protected static var log :Log = Log.getLog(QuestClient);
}

}