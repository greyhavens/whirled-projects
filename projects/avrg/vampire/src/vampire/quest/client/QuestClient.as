package vampire.quest.client {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimpleGame;
import com.whirled.net.PropertySubControl;

import flash.display.Sprite;
import flash.geom.Rectangle;

import vampire.feeding.FeedingClient;
import vampire.feeding.FeedingClientSettings;
import vampire.feeding.PlayerFeedingData;
import vampire.furni.FurniConstants;
import vampire.quest.*;
import vampire.quest.activity.*;
import vampire.quest.client.npctalk.*;

public class QuestClient
{
    public static function init (gameCtrl :AVRGameControl, simpleGame :SimpleGame,
        appMode :AppMode, panelLayer :Sprite, minigameLayer :Sprite, notificationLayer :Sprite,
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

        ClientCtx.panelLayer = panelLayer;
        ClientCtx.minigameLayer = minigameLayer;
        ClientCtx.notificationLayer = notificationLayer;

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
        handshakeQuestTotems(false);
    }

    public static function checkQuestJuiceRefresh () :void
    {
        // TODO
    }

    public static function goToLocation (loc :LocationDesc) :void
    {
        if (ClientCtx.questData.curLocation != loc) {
            ClientCtx.questData.curLocation = loc;
        }

        showLocationPanel(loc);
    }

    public static function beginActivity (activity :ActivityDesc) :void
    {
        if (activity.params.isLobbied) {
            // TODO
        } else {
            beginSpActivity(activity);
        }
    }

    public static function showLocationPanel (loc :LocationDesc) :void
    {
        showQuestPanel(true);
        _questPanel.showLocationPanel(loc);
    }

    public static function showLastDisplayedLocationPanel () :void
    {
        if (_questPanel != null && _questPanel.lastDisplayedLocation != null) {
            showLocationPanel(_questPanel.lastDisplayedLocation);
        }
    }

    public static function hideDockedPanel (destroy :Boolean) :void
    {
        if (_questPanel != null) {
            _questPanel.hideDockedPanel(destroy);
        }
    }

    public static function showDebugPanel (show :Boolean) :void
    {
        if (_debugPanel == null && show) {
            _debugPanel = new DebugPanel();
            ClientCtx.appMode.addSceneObject(_debugPanel, ClientCtx.panelLayer);
        }

        if (_debugPanel != null) {
            _debugPanel.visible = show;
        }
    }

    public static function showQuestPanel (show :Boolean) :void
    {
        if (_questPanel == null && show) {
            _questPanel = new QuestPanel();

            var bounds :Rectangle = ClientCtx.getPaintableArea(false);
            _questPanel.x = bounds.x + ((bounds.width - _questPanel.width) * 0.5);
            _questPanel.y = bounds.y + 50;

            ClientCtx.appMode.addSceneObject(_questPanel, ClientCtx.panelLayer);
        }

        if (_questPanel != null) {
            _questPanel.visible = show;
        }
    }

    public static function showNpcTalkDialog (programName :String) :void
    {
        var rsrc :NpcTalkResource = ClientCtx.rsrcs.getResource(programName) as NpcTalkResource;
        if (rsrc == null) {
            log.warning("Can't show NpcTalkPanel; no resource named '" + programName + "' exists.");
            return;
        }

        showQuestPanel(true);
        _questPanel.showNpcTalkPanel(rsrc.program);
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
            ClientCtx.gameCtrl.player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM,
                function (...ignored) :void {
                    handshakeQuestTotems(true);
                });

            handshakeQuestTotems(true);
        }

        ClientCtx.questProps.addEventListener(QuestPropEvent.PROP_CHANGED, checkQuestCompletion);
        ClientCtx.questData.addEventListener(PlayerQuestEvent.QUEST_ADDED, onQuestAdded);
        ClientCtx.questData.addEventListener(PlayerQuestEvent.QUEST_COMPLETED, onQuestCompleted);
        ClientCtx.questData.addEventListener(ActivityEvent.ACTIVITY_ADDED, onActivityAdded);

        checkQuestCompletion();
    }

    protected static function onResourceLoadErr (err :String) :void
    {
    }

    protected static function checkQuestCompletion (...ignored) :void
    {
        for each (var quest :QuestDesc in ClientCtx.questData.activeQuests) {
            if (quest.isComplete(ClientCtx.questProps)) {
                ClientCtx.questData.completeQuest(quest.id);
            }
        }
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

        // every time a quest is completed, clear untracked properties to keep
        // our property space clean!
        ClientCtx.questProps.clearUntrackedProps();
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
                    feedingGame.shutdown();
                    feedingGame.parent.removeChild(feedingGame);
                },
                bbParams,
                ClientCtx.questData,
                ClientCtx.questProps);
            feedingGame = FeedingClient.create(feedingSettings);
            showQuestPanel(false);
            ClientCtx.minigameLayer.addChild(feedingGame);
            break;

        case ActivityDesc.TYPE_NPC_TALK:
            showNpcTalkDialog(NpcTalkActivityParams(activity.params).dialogName);
            break;

        default:
            log.warning("Unrecognized activity type", "activity", activity);
            break;
        }
    }

    protected static function handshakeQuestTotems (connect :Boolean) :void
    {
        for each (var furniId :String in ClientCtx.gameCtrl.room.getEntityIds("furni")) {
            var setTotemClickCallback :Function = ClientCtx.gameCtrl.room.getEntityProperty(
                FurniConstants.ENTITY_PROP_SET_CLICK_CALLBACK, furniId) as Function;
            if (setTotemClickCallback != null) {
                log.info("Found Quest Totem", "entityId", furniId);
                setTotemClickCallback(connect ? questTotemClicked : null);
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
            goToLocation(loc);
        }
    }

    protected static var _debugPanel :DebugPanel;
    protected static var _questPanel :QuestPanel;

    protected static var _inited :Boolean;
    protected static var _resourcesLoaded :Boolean;
    protected static var _questDialogsLoaded :Boolean;

    [Embed(source="../../../../rsrc/quest/quest.swf", mimeType="application/octet-stream")]
    protected static const SWF_QUEST :Class;

    protected static var log :Log = Log.getLog(QuestClient);
}

}
