package vampire.quest.client {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.threerings.flashbang.AppMode;
import com.threerings.flashbang.FlashbangApp;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertySubControl;

import flash.display.Sprite;

import vampire.feeding.FeedingClient;
import vampire.feeding.FeedingClientSettings;
import vampire.feeding.PlayerFeedingData;
import vampire.furni.FurniConstants;
import vampire.quest.*;
import vampire.quest.activity.*;
import vampire.quest.client.npctalk.*;

public class QuestClient
{
    public static function init (gameCtrl :AVRGameControl, simpleGame :FlashbangApp,
        appMode :AppMode, hudSprite :Sprite, minigameLayer :Sprite, notificationLayer :Sprite,
        playerProps :PropertySubControl = null) :void
    {
        if (_inited) {
            throw new Error("QuestClient already inited");
        }
        _inited = true;

        Quests.init();
        Locations.init();
        Activities.init();

        if (playerProps == null) {
            playerProps = gameCtrl.player.props;
        }

        ClientCtx.gameCtrl = gameCtrl;
        ClientCtx.mainLoop = simpleGame.ctx.mainLoop;
        ClientCtx.appMode = appMode;
        ClientCtx.rsrcs = simpleGame.ctx.rsrcs;
        ClientCtx.questData = new PlayerQuestData(playerProps);
        ClientCtx.questProps = new PlayerQuestProps(playerProps);
        ClientCtx.notificationMgr = new NotificationMgr();

        ClientCtx.hudSprite = hudSprite;
        ClientCtx.minigameLayer = minigameLayer;
        ClientCtx.notificationLayer = notificationLayer;

        ClientCtx.dockSprite = new DockSprite(700, 55);
        ClientCtx.hudSprite.addChild(ClientCtx.dockSprite);

        ClientCtx.rsrcs.registerResourceType("npcTalk", NpcTalkResource);

        // load resources
        ClientCtx.rsrcs.queueResourceLoad("swf", "quest", { embeddedClass: SWF_QUEST });
        ClientCtx.rsrcs.loadQueuedResources(
            function () :void {
                _resourcesLoaded = true;
                maybeFinishInit();
            },
            onResourceLoadErr);

        // load NPC dialogs
        QuestDialogLoader.loadQuestDialogs(
            function () :void {
                _questDialogsLoaded = true;
                maybeFinishInit();
            },
            onResourceLoadErr);
    }

    public static function shutdown () :void
    {
    }

    public static function showQuestPanel () :void
    {
        ClientCtx.dockSprite.showQuestPanel();
    }

    public static function playerCompletedFeeding () :void
    {
        ClientCtx.questProps.offsetIntProp(QuestProps.NORMAL_FEEDINGS, 1);
    }

    public static function beginActivity (activity :ActivityDesc) :void
    {
        if (activity.params.isLobbied) {
            // TODO
        } else {
            beginSpActivity(activity);
        }
    }

    public static function showDebugPanel (show :Boolean) :void
    {
        if (_debugPanel == null && show) {
            _debugPanel = new DebugPanel();
            ClientCtx.appMode.addSceneObject(_debugPanel, ClientCtx.hudSprite);
        } else if (_debugPanel != null && !show) {
            _debugPanel.destroySelf();
            _debugPanel = null;
        }
    }

    public static function get isReady () :Boolean
    {
        return _resourcesLoaded && _questDialogsLoaded;
    }

    protected static function maybeFinishInit () :void
    {
        if (!isReady) {
            return;
        }

        if (ClientCtx.gameCtrl.isConnected()) {
            ClientCtx.gameCtrl.player.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
                onPlayerMsgReceived);

            ClientCtx.gameCtrl.agent.sendMessage(QuestMessages.TIMESTAMP);
        }

        _statusPanel = new StatusPanel();
        ClientCtx.appMode.addSceneObject(_statusPanel, ClientCtx.hudSprite);

        ClientCtx.questProps.addEventListener(QuestPropEvent.PROP_CHANGED, checkQuestCompletion);
        ClientCtx.questData.addEventListener(PlayerQuestEvent.QUEST_ADDED, onQuestAdded);
        ClientCtx.questData.addEventListener(PlayerQuestEvent.QUEST_COMPLETED, onQuestCompleted);
        ClientCtx.questData.addEventListener(ActivityEvent.ACTIVITY_ADDED, onActivityAdded);

        // Give the player the first quest
        var introQuest :QuestDesc = Quests.getQuestByName("intro_quest");
        if (!ClientCtx.questData.hasSeenQuest(introQuest)) {
            ClientCtx.questData.addQuest(introQuest);
        }

        checkQuestCompletion();
    }

    protected static function onPlayerMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == QuestMessages.TIMESTAMP && e.isFromServer()) {
            gotTimestamp(e.value as Number);
        }
    }

    protected static function onResourceLoadErr (err :String) :void
    {
    }

    protected static function checkQuestCompletion (...ignored) :void
    {
        for each (var quest :QuestDesc in ClientCtx.questData.activeQuests) {
            if (quest.isComplete(ClientCtx.questProps)) {
                ClientCtx.questData.completeQuest(quest);
            }
        }
    }

    protected static function gotTimestamp (newTimestamp :Number) :void
    {
        if (!Constants.DEBUG_ENABLE_QUESTS) {
            return;
        }

        var timeSinceRefresh :Number = newTimestamp - ClientCtx.questData.lastJuiceRefresh;
        if (timeSinceRefresh >= Constants.JUICE_REFRESH_MS) {
            var amount :int = Math.min(Constants.JUICE_REFRESH_AMOUNT,
                Constants.JUICE_REFRESH_MAX - ClientCtx.questData.questJuice);
            if (amount < 0) {
                log.info("Not refreshing quest juice; player already at max",
                    "max", Constants.JUICE_REFRESH_MAX, "timeSinceRefresh", timeSinceRefresh);
            } else {
                log.info("Refreshing quest juice!", "amount", amount,
                    "timeSinceRefresh", timeSinceRefresh);
            }

            ClientCtx.gameCtrl.doBatch(function () :void {
                if (amount > 0) {
                    ClientCtx.questData.questJuice += amount;
                }
                ClientCtx.questData.lastJuiceRefresh = newTimestamp;
            });

        } else {
            log.info("Not refreshing quest juice; not enough time has passed",
                "timeSinceRefresh", timeSinceRefresh);
        }
    }

    protected static function checkQuestJuiceRefresh () :void
    {
        // TODO
        ClientCtx.questData.questJuice = Math.max(ClientCtx.questData.questJuice, 30);
    }

    protected static function onQuestAdded (e :PlayerQuestEvent) :void
    {
        ClientCtx.notificationMgr.addNotification(
            new QuestNotification(e.quest, PlayerQuestData.STATUS_ACTIVE));
    }

    protected static function onQuestCompleted (e :PlayerQuestEvent) :void
    {
        ClientCtx.notificationMgr.addNotification(
            new QuestNotification(e.quest, PlayerQuestData.STATUS_COMPLETE));
    }

    protected static function onActivityAdded (e :ActivityEvent) :void
    {
        ClientCtx.notificationMgr.addNotification(new ActivityAddedNotification(e.activity));
    }

    protected static function beginSpActivity (activity :ActivityDesc) :void
    {
        var feedingGame :FeedingClient;

        switch (activity.type) {
        case ActivityDesc.TYPE_FEEDING:
            var bbParams :BloodBloomActivityParams = BloodBloomActivityParams(activity.params);
            var feedingSettings :FeedingClientSettings = FeedingClientSettings.spSettings(
                new PlayerFeedingData(),
                function () :void {
                    // roundComplete
                },
                function () :void {
                    feedingGame.shutdown();
                },
                bbParams,
                ClientCtx.questData,
                ClientCtx.questProps);
            feedingGame = FeedingClient.create(feedingSettings);
            break;

        case ActivityDesc.TYPE_NPC_TALK:
            var talkParams :NpcTalkActivityParams = NpcTalkActivityParams(activity.params);
            ClientCtx.dockSprite.showNpcTalkDialog(talkParams);
            break;

        default:
            log.warning("Unrecognized activity type", "activity", activity);
            break;
        }
    }

    protected static var _debugPanel :DebugPanel;
    protected static var _statusPanel :StatusPanel;

    protected static var _inited :Boolean;
    protected static var _resourcesLoaded :Boolean;
    protected static var _questDialogsLoaded :Boolean;

    [Embed(source="../../../../rsrc/quest/quest.swf", mimeType="application/octet-stream")]
    protected static const SWF_QUEST :Class;

    protected static var log :Log = Log.getLog(QuestClient);
}

}
