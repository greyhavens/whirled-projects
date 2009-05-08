package vampire.fightproto.fight {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.fightproto.*;

public class SkillButtonSprite extends Sprite
{
    public function SkillButtonSprite (skill :PlayerSkill, caster :SceneObject)
    {
        var button :SkillButton = new SkillButton(skill);
        addChild(button);

        var cooldownAnim :SkillCooldownAnim = new SkillCooldownAnim(skill);
        GameCtx.mode.addSceneObject(cooldownAnim, this);

        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                GameCtx.playerView.playerSkillSelected(skill, caster);
            });
    }
}

}

import com.whirled.contrib.simplegame.objects.SceneObject;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.fightproto.*;
import vampire.fightproto.fight.*;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.filters.GlowFilter;

const BUTTON_SIZE :Point = new Point(50, 50);

class SkillButton extends SimpleButton
{
    public function SkillButton (skill :PlayerSkill)
    {
        var upSprite :Sprite = skill.createSprite(BUTTON_SIZE);
        var overSprite :Sprite = skill.createSprite(BUTTON_SIZE);
        overSprite.filters = [ new GlowFilter() ];
        var downSprite :Sprite = skill.createSprite(BUTTON_SIZE);
        downSprite.filters = [ new GlowFilter() ];
        downSprite.x += 1;
        downSprite.y += 1;

        this.upState = upSprite;
        this.overState = overSprite;
        this.downState = downSprite;
        this.hitTestState = upSprite;
    }
}

class SkillCooldownAnim extends SceneObject
{
    public function SkillCooldownAnim (skill :PlayerSkill)
    {
        _skill = skill;

        _sprite = new Sprite();
        var g :Graphics = _sprite.graphics;
        g.beginFill(0xffffff, 0.5);
        g.drawRect(0, 0, BUTTON_SIZE.x, BUTTON_SIZE.y);
        g.endFill();

        _tf = TextBits.createText("");
        _sprite.addChild(_tf);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var cooldownTimeLeft :Number = GameCtx.playerView.getSkillCooldownTimeLeft(_skill);
        var hasEnergy :Boolean = ClientCtx.player.energy >= _skill.energyCost;
        if (hasEnergy && cooldownTimeLeft <= 0) {
            this.visible = false;

        } else {
            this.visible = true;
            var text :String = (cooldownTimeLeft > 0 ? cooldownTimeLeft.toFixed(1) : "");
            if (text != _lastText) {
                TextBits.initTextField(_tf, text, 1.2, 0, 0xff0000);
                _tf.x = (_sprite.width - _tf.width) * 0.5;
                _tf.y = (_sprite.height - _tf.height) * 0.5;
                _lastText = text;
            }
        }
    }

    protected var _skill :PlayerSkill;
    protected var _sprite :Sprite;
    protected var _tf :TextField;

    protected var _lastText :String;
}
