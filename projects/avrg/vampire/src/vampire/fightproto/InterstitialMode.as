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

            // xp award
            var successText :String;
            var levelUp :Boolean;
            if (_lastScenarioSuccess) {
                ClientCtx.player.xp += _lastScenario.xpAward;
                levelUp = ClientCtx.player.canLevelUp;
                if (levelUp) {
                    ClientCtx.player.levelUp();
                }

                successText = "Beautiful biting! You've earned " + _lastScenario.xpAward + " xp" +
                    (levelUp ? ". Level up!" : "!");

            } else {
                successText = "Ouch :(";
            }

            // scenario awards
            if (_lastScenarioSuccess) {
                for each (var newScenarioName :String in _lastScenario.scenarioAwards) {
                    var newScenario :Scenario = Scenarios.getScenario(newScenarioName);
                    if (!ClientCtx.player.hasScenario(newScenario)) {
                        ClientCtx.player.scenarios.push(newScenario);
                    }
                }
            }

            var successColor :uint = (_lastScenarioSuccess ? 0xffffff : 0xff0000);
            var tfSuccess :TextField = TextBits.createText(successText, 2.5, 0, successColor);
            tfSuccess.x = (Constants.SCREEN_SIZE.x - tfSuccess.width) * 0.5;
            tfSuccess.y = tfScenario.y + tfScenario.height + 2;
            _modeSprite.addChild(tfSuccess);

            // New skill rewards
            if (_lastScenarioSuccess) {
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

        // XP meter
        var xpLabel :String = "(Level " + String(ClientCtx.player.level.level + 1) + ") XP: ";
        var xpMeter :StatMeter = new StatMeter(StatMeter.LARGE, 0xffff00, xpLabel);
        var xpReq :int = ClientCtx.player.nextLevelXpRequirement;
        var xp :int = ClientCtx.player.xp;
        xpMeter.minValue = ClientCtx.player.level.xpRequirement;
        xpMeter.maxValue =  (xpReq >= 0 ? xpReq : xp);
        xpMeter.value = ClientCtx.player.xp;
        xpMeter.updateDisplay();
        xpMeter.x = 5;
        xpMeter.y = 5;
        _modeSprite.addChild(xpMeter);

        // Health meter
        var healthMeter :StatMeter = new StatMeter(StatMeter.LARGE, 0xff0000, "Health: ");
        healthMeter.minValue = 0;
        healthMeter.maxValue = ClientCtx.player.maxHealth;
        healthMeter.value = ClientCtx.player.health;
        healthMeter.updateDisplay();
        healthMeter.x = 5;
        healthMeter.y = xpMeter.y + xpMeter.height + 1;
        _modeSprite.addChild(healthMeter);

        // Energy meter
        var energyMeter :StatMeter = new StatMeter(StatMeter.LARGE, 0x0000ff, "Energy: ");
        energyMeter.minValue = 0;
        energyMeter.maxValue = ClientCtx.player.maxEnergy;
        energyMeter.value = ClientCtx.player.energy;
        energyMeter.updateDisplay();
        energyMeter.x = 5;
        energyMeter.y = healthMeter.y + healthMeter.height + 1;
        _modeSprite.addChild(energyMeter);

        // Next scenarios
        var tfChoose :TextField = TextBits.createText("Choose your next battle!", 2, 0, 0xffffff);
        tfChoose.x = (Constants.SCREEN_SIZE.x - tfChoose.width) * 0.5;
        tfChoose.y = (Constants.SCREEN_SIZE.y - tfChoose.height) * 0.5;
        _modeSprite.addChild(tfChoose);

        var buttonSprite :Sprite = new Sprite();
        for each (var scenario :Scenario in ClientCtx.player.scenarios) {
            var button :SimpleButton = createScenarioButton(scenario);
            button.x = -button.width * 0.5;
            button.y = buttonSprite.height;
            buttonSprite.addChild(button);
        }

        buttonSprite.x = Constants.SCREEN_SIZE.x * 0.5;
        buttonSprite.y = tfChoose.y + tfChoose.height + 3;
        _modeSprite.addChild(buttonSprite);
    }

    protected function createScenarioButton (scenario :Scenario) :SimpleButton
    {
        var minLevel :int = scenario.minPlayerLevel;
        var enabled :Boolean = (ClientCtx.player.level.level >= minLevel);
        var buttonText :String = scenario.displayName;
        buttonText += (enabled ? " (+" + scenario.xpAward + " xp)" :
            " (Reach level " + String(minLevel + 1) + "!)");

        var button :SimpleTextButton = new SimpleTextButton(
            buttonText, true,
            (enabled ? 0x003366 : 0x333333),
            (enabled ? 0x6699CC : 0x666666));

        button.enabled = enabled;
        button.scaleX = button.scaleY = 1.5;

        if (enabled) {
            registerListener(button, MouseEvent.CLICK,
                function (...ignored) :void {
                    ClientCtx.mainLoop.changeMode(new FightMode(scenario));
                });
        }

        return button;
    }

    protected var _lastScenario :Scenario;
    protected var _lastScenarioSuccess :Boolean;
}

}
