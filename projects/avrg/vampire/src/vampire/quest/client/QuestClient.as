package vampire.quest.client {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.SimpleGame;

import vampire.feeding.FeedingClient;
import vampire.feeding.FeedingClientSettings;
import vampire.feeding.PlayerFeedingData;
import vampire.feeding.variant.Variant;
import vampire.furni.FurniConstants;
import vampire.quest.*;
import vampire.quest.activity.*;
import vampire.quest.client.npctalk.*;

public class QuestClient
{
    public static function init (gameCtrl :AVRGameControl, simpleGame :SimpleGame,
        questData :PlayerQuestData, questProps :PlayerQuestProps) :void
    {
        if (_inited) {
            throw new Error("QuestClient already inited");
        }
        _inited = true;

        Quests.init();
        Locations.init();
        Activities.init();

        ClientCtx.gameCtrl = gameCtrl;
        ClientCtx.mainLoop = simpleGame.ctx.mainLoop;
        ClientCtx.rsrcs = simpleGame.ctx.rsrcs;
        ClientCtx.questData = questData;
        ClientCtx.questProps = questProps;

        ClientCtx.rsrcs.registerResourceType("npcTalk", NpcTalkResource);

        // load resources
        ClientCtx.rsrcs.queueResourceLoad("swf", "quest", { embeddedClass: SWF_QUEST });
        ClientCtx.rsrcs.queueResourceLoad("npcTalk", "dialogTest", { embeddedClass: DIALOG_TEST });
        ClientCtx.rsrcs.loadQueuedResources(
            onResourcesLoaded,
            function (err :String) :void {
                log.error("Error loading resources: " + err);
            });
    }

    public static function shutdown () :void
    {
        handshakeQuestTotems(false);
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

    public static function hideLocationPanel () :void
    {
        if (_questPanel != null) {
            _questPanel.hideLocationPanel();
        }
    }

    public static function showDebugPanel (show :Boolean) :void
    {
        if (_debugPanel == null && show) {
            _debugPanel = new DebugPanel();
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

    public static function showNpcTalkDialog (programName :String) :void
    {
        closeNpcTalkDialog();

        var dialogTest :NpcTalkResource =
            ClientCtx.rsrcs.getResource(programName) as NpcTalkResource;
        var view :TalkView = new TalkView(dialogTest.program);
        ClientCtx.mainLoop.topMode.addSceneObject(view);
        _npcTalkViewRef = view.ref;
    }

    public static function closeNpcTalkDialog () :void
    {
        if (!_npcTalkViewRef.isNull) {
            _npcTalkViewRef.object.destroySelf();
        }
    }

    public static function get isReady () :Boolean
    {
        return _resourcesLoaded;
    }

    protected static function onResourcesLoaded () :void
    {
        _resourcesLoaded = true;

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

        checkQuestCompletion();
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
        var note :QuestAddedNotification = new QuestAddedNotification(e.quest);
        note.x = (ClientCtx.mainLoop.topMode.modeSprite.width - note.width) * 0.5;
        note.y = 15;
        ClientCtx.mainLoop.topMode.addSceneObject(note);
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
                ClientCtx.questProps,
                activity.params as BloodBloomActivityParams));
            ClientCtx.mainLoop.topMode.modeSprite.addChild(feedingGame);
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
    protected static var _npcTalkViewRef :SimObjectRef = SimObjectRef.Null();

    protected static var _inited :Boolean;
    protected static var _resourcesLoaded :Boolean;

    [Embed(source="../../../../rsrc/quest/quest.swf", mimeType="application/octet-stream")]
    protected static const SWF_QUEST :Class;

    [Embed(source="../../../../rsrc/quest/DialogTest.xml", mimeType="application/octet-stream")]
    protected static const DIALOG_TEST :Class;

    protected static var log :Log = Log.getLog(QuestClient);
}

}
