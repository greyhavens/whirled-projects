package vampire.quest.debug {

import com.whirled.contrib.ManagedTimer;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.net.PropertySubControl;

import flash.display.Sprite;

import vampire.debug.LocalPropertySubControl;
import vampire.quest.*;
import vampire.quest.client.*;

[SWF(width="700", height="500", frameRate="30")]
public class QuestClientStandalone extends Sprite
{
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
        var stats :PlayerQuestStats = new PlayerQuestStats(localProps);

        QuestClient.init(_sg, questData, stats);

        questData.addQuest(Quests.getQuestByName("TestQuest").id);
        questData.addAvailableLocation(Locations.getLocationByName("HomeBase"));
        questData.addAvailableLocation(Locations.getLocationByName("Battleground"));
        questData.curLocation = Locations.getLocationByName("HomeBase");

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
