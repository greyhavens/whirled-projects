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

        if (_lastScenario != null) {
            var tfScenario :TextField =
                TextBits.createText(_lastScenario.displayName, 4, 0, 0x00ff00);
            tfScenario.x = (Constants.SCREEN_SIZE.x - tfScenario.width) * 0.5;
            tfScenario.y = 20;
            _modeSprite.addChild(tfScenario);

            var successText :String = (_lastScenarioSuccess ?
                "Beautiful biting! You've earned " + _lastScenario.xpAward + " experience." :
                "Ouch :(");

            var successColor :uint = (_lastScenarioSuccess ? 0xffffff : 0xff0000);
            var tfSuccess :TextField = TextBits.createText(successText, 2.5, 0, successColor);
            tfSuccess.x = (Constants.SCREEN_SIZE.x - tfSuccess.width) * 0.5;
            tfSuccess.y = tfScenario.y + tfScenario.height + 2;
            _modeSprite.addChild(tfSuccess);

            // Give awards
            if (_lastScenarioSuccess) {
                ClientCtx.player.xp += _lastScenario.xpAward;
                var newSkillsSprite :Sprite;
                for each (var awardedSkill :PlayerSkill in _lastScenario.skillAwards) {
                    if (!ClientCtx.player.hasSkill(awardedSkill)) {
                        ClientCtx.player.skills.push(awardedSkill);
                        if (newSkillsSprite == null) {
                            newSkillsSprite = new Sprite();
                        }
                        var skillSprite :Sprite = awardedSkill.createSprite();
                        skillSprite.x = newSkillsSprite.width;
                        newSkillsSprite.addChild(skillSprite);
                    }
                }

                if (newSkillsSprite != null) {
                    var tfNewSkills :TextField =
                        TextBits.createText("You've won these fabulous prizes!", 1.5, 0, 0xffffff);
                    tfNewSkills.x = (Constants.SCREEN_SIZE.x - tfNewSkills.width) * 0.5;
                    tfNewSkills.y = tfSuccess.y + tfSuccess.height + 2;
                    _modeSprite.addChild(tfNewSkills);

                    newSkillsSprite.x = (Constants.SCREEN_SIZE.x - newSkillsSprite.width) * 0.5;
                    newSkillsSprite.y = tfNewSkills.y + newSkillsSprite.height + 2;
                    _modeSprite.addChild(newSkillsSprite);
                }
            }

            // Restore health
            ClientCtx.player.health =
                Math.max(ClientCtx.player.health, ClientCtx.player.maxHealth / 2);
        }

        var tfChoose :TextField = TextBits.createText("Choose your next battle!", 2, 0, 0xffffff);
        tfChoose.x = (Constants.SCREEN_SIZE.x - tfChoose.width) * 0.5;
        tfChoose.y = (Constants.SCREEN_SIZE.y - tfChoose.height) * 0.5;
        _modeSprite.addChild(tfChoose);

        var buttonSprite :Sprite = new Sprite();
        for each (var scenario :Scenario in ClientCtx.player.scenarios) {
            if (scenario.minPlayerLevel <= ClientCtx.player.level.level) {
                var button :SimpleButton = createScenarioButton(scenario);
                button.x = -button.width * 0.5;
                button.y = buttonSprite.height;
                buttonSprite.addChild(button);

            } else {
                var unavailText :String =  scenario.displayName +
                    " (Reach level " + String(scenario.minPlayerLevel + 1) + "!)"
                var tfUnavailable :TextField = TextBits.createText(unavailText, 1.5, 0, 0xffffff);
                tfUnavailable.x = -tfUnavailable.width * 0.5;
                tfUnavailable.y = buttonSprite.height;
                buttonSprite.addChild(tfUnavailable);
            }
        }

        buttonSprite.x = Constants.SCREEN_SIZE.x * 0.5;
        buttonSprite.y = tfChoose.y + tfChoose.height + 3;
        _modeSprite.addChild(buttonSprite);
    }

    protected function createScenarioButton (scenario :Scenario) :SimpleButton
    {
        var buttonText :String = scenario.displayName + " (+" + scenario.xpAward + " xp)"
        var button :SimpleTextButton = new SimpleTextButton(buttonText);
        button.scaleX = button.scaleY = 1.5;

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
