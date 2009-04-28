package vampire.quest.debug {

import com.whirled.contrib.ManagedTimer;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.net.PropertySubControl;

import flash.display.Sprite;

import vampire.avatar.VampireBody;
import vampire.debug.LocalPropertySubControl;
import vampire.feeding.FeedingClient;
import vampire.furni.QuestTotem;
import vampire.quest.*;
import vampire.quest.client.*;

[SWF(width="1000", height="700", frameRate="30")]
public class QuestClientStandalone extends Sprite
{
    QuestTestClient;
    QuestTotem;
    VampireBody;

    public function QuestClientStandalone ()
    {
        // Init simplegame
        var config :Config = new Config();
        config.hostSprite = this;
        _sg = new SimpleGame(config);
        _sg.ctx.mainLoop.pushMode(new AppMode());
        _sg.run();

        // Init local props
        var localProps :LocalPropertySubControl = new LocalPropertySubControl();
        var questData :PlayerQuestData = new PlayerQuestData(localProps);
        var questProps :PlayerQuestProps = new PlayerQuestProps(localProps);
        var gameCtrl :DisconnectedControl = new DisconnectedControl(this);

        FeedingClient.init(this, gameCtrl);
        QuestClient.init(gameCtrl, _sg, questData, questProps);

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
        QuestClient.showQuestPanel(true);
    }

    protected var _sg :SimpleGame;
    protected var _localProps :PropertySubControl;
    protected var _timerMgr :TimerManager = new TimerManager();
}

}

import com.whirled.avrg.AVRGameControl;
import flash.display.DisplayObject;

class DisconnectedControl extends AVRGameControl
{
    public function DisconnectedControl (disp :DisplayObject)
    {
        super(disp);
    }

    override public function isConnected () :Boolean
    {
        return false;
    }
}
