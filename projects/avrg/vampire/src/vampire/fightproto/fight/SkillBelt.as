package vampire.fightproto.fight {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.fightproto.*;

public class SkillBelt extends SceneObject
{
    public function SkillBelt ()
    {
        _sprite = new Sprite();

        for each (var skill :Skill in ClientCtx.player.skills) {
            var button :SkillButton = createSkillButton(skill);
            button.x = _sprite.width;
            _sprite.addChild(button);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function createSkillButton (skill :Skill) :SkillButton
    {
        var button :SkillButton = new SkillButton(skill);
        registerListener(button, MouseEvent.CLICK,
            function (...ignored) :void {
                GameCtx.mode.skillSelected(skill);
            });

        return button;
    }

    protected var _sprite :Sprite;
}

}

import flash.display.SimpleButton;

import vampire.fightproto.*;
import flash.display.Sprite;
import flash.filters.GlowFilter;

class SkillButton extends SimpleButton
{
    public function SkillButton (skill :Skill)
    {
        var upSprite :Sprite = skill.createSprite();
        var overSprite :Sprite = skill.createSprite();
        overSprite.filters = [ new GlowFilter() ];
        var downSprite :Sprite = skill.createSprite();
        downSprite.filters = [ new GlowFilter() ];
        downSprite.x += 1;
        downSprite.y += 1;

        this.upState = upSprite;
        this.overState = overSprite;
        this.downState = downSprite;
        this.hitTestState = upSprite;
    }
}
