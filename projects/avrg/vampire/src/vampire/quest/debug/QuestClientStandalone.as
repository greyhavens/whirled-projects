package vampire.quest.debug {

import com.threerings.util.MethodQueue;
import com.whirled.contrib.simplegame.*;
import com.whirled.net.PropertySubControl;

import flash.display.Sprite;

import vampire.debug.LocalPropertySubControl;
import vampire.quest.PlayerQuestData;
import vampire.quest.PlayerQuestStats;
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

        MethodQueue.callLater(function () :void {
            QuestClient.showDebugPanel(true);
            QuestClient.showQuestPanel(true);
        });
    }

    protected var _sg :SimpleGame;
    protected var _localProps :PropertySubControl;
}

}
