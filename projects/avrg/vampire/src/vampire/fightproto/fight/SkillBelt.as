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

        var x :Number = 0;
        for each (var skill :PlayerSkill in ClientCtx.player.skills) {
            var button :SkillButtonSprite = new SkillButtonSprite(skill, GameCtx.playerView);
            button.x = x;
            x += button.width;
            _sprite.addChild(button);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
}

}
