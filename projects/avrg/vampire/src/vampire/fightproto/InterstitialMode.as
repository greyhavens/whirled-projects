package vampire.fightproto {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.fightproto.fight.FightMode;

public class InterstitialMode extends AppMode
{
    public function InterstitialMode (lastScenario :Scenario = null,
        lastScenarioSuccess :Boolean = false)
    {
        _lastScenario = lastScenario;
        _lastScenarioSuccess = lastScenarioSuccess;
    }

    override protected function setup () :void
    {
        var g :Graphics = _modeSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        var tf :TextField = TextBits.createText("Choose your next battle!", 3, 0, 0xffffff);
        tf.x = (Constants.SCREEN_SIZE.x - tf.width) * 0.5;
        tf.y = (Constants.SCREEN_SIZE.y - tf.height) * 0.5;
        _modeSprite.addChild(tf);

        var buttonSprite :Sprite = new Sprite();
        for each (var scenario :Scenario in Scenario.ALL) {
            var button :SimpleButton = createScenarioButton(scenario);
            button.x = buttonSprite.width;
            buttonSprite.addChild(button);
        }

        buttonSprite.x = (Constants.SCREEN_SIZE.x - buttonSprite.width) * 0.5;
        buttonSprite.y = tf.y + tf.height + 3;
        _modeSprite.addChild(buttonSprite);
    }

    protected function createScenarioButton (scenario :Scenario) :SimpleButton
    {
        var button :SimpleTextButton = new SimpleTextButton(scenario.displayName);
        button.scaleX = button.scaleY = 2;

        registerListener(button, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.mainLoop.changeMode(new FightMode(scenario));
            });

        return button;
    }

    protected var _lastScenario :Scenario;
    protected var _lastScenarioSuccess :Boolean;
}

}
