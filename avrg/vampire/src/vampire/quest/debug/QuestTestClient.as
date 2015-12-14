package vampire.quest.debug {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.threerings.util.EventHandlerManager;
import com.whirled.contrib.ManagedTimer;
import com.whirled.contrib.TimerManager;
import com.threerings.flashbang.*;

import flash.display.Sprite;
import flash.events.Event;

import vampire.feeding.*;
import vampire.quest.*;
import vampire.quest.client.*;

public class QuestTestClient extends Sprite
{
    public function QuestTestClient ()
    {
        log.info("Starting QuestTestClient");

        //_events.registerListener(this, Event.UNLOAD, onQuit);
        _events.registerListener(this, Event.REMOVED_FROM_STAGE, onQuit);

        var appMode :AppMode = new AppMode();
        var panelLayer :Sprite = new Sprite();
        var minigameLayer :Sprite = new Sprite();
        var notificationLayer :Sprite = new Sprite();
        appMode.modeSprite.addChild(panelLayer);
        appMode.modeSprite.addChild(minigameLayer);
        appMode.modeSprite.addChild(notificationLayer);

        // Init simplegame
        _sg = new FlashbangApp(new Config());
        _sg.ctx.mainLoop.pushMode(appMode);
        _sg.run(this);

        // Init props
        _gameCtrl = new AVRGameControl(this);

        FeedingClient.init(this, _gameCtrl);
        QuestClient.init(_gameCtrl, _sg, appMode, panelLayer, minigameLayer, notificationLayer);

        var waitLoop :ManagedTimer = _timerMgr.runForever(50,
            function (...ignored) :void {
                if (QuestClient.isReady) {
                    waitLoop.cancel();
                    start();
                }
            });
    }

    protected function start () :void
    {
        QuestClient.showDebugPanel(true);
        ClientCtx.dockSprite.showQuestPanel();
    }

    protected function onQuit (...ignored) :void
    {
        _events.freeAllHandlers();
        _timerMgr.shutdown();
        QuestClient.shutdown();
    }

    protected var _gameCtrl :AVRGameControl;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _timerMgr :TimerManager = new TimerManager();
    protected var _sg :FlashbangApp;

    protected static var log :Log = Log.getLog(QuestTestClient);
}

}
