package vampire.fightproto.fight {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;

import vampire.fightproto.*;

public class SkillBelt extends SceneObject
{
    public function SkillBelt ()
    {
        _sprite = new Sprite();

        for each (var ability :Ability in ClientCtx.player.abilities) {
            var abilitySprite :Sprite = ability.createSprite();
            abilitySprite.x = _sprite.width;
            _sprite.addChild(abilitySprite);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
}

}
