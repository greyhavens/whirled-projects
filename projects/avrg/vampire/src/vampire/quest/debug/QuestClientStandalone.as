package vampire.quest.debug {

import com.whirled.contrib.simplegame.*;

import flash.display.Sprite;

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

        QuestClient.init(_sg);
    }

    protected var _sg :SimpleGame;
}

}
