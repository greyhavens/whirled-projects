package vampire.fightproto.fight {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.fightproto.*;

public class Buddy extends SceneObject
{
    public function Buddy (name :String, skill :PlayerSkill)
    {
        _sprite = new Sprite();

        var bitmap :Bitmap = ClientCtx.instantiateBitmap("buddy");
        bitmap.x = -bitmap.width * 0.5;
        bitmap.y = -bitmap.height;
        _sprite.addChild(bitmap);

        var tfName :TextField = TextBits.createText(name, 1.2, 0, 0x00ffff);
        tfName.x = -tfName.width * 0.5;
        tfName.y = bitmap.y - tfName.height;
        _sprite.addChild(tfName);

        var skillButton :SkillButtonSprite = new SkillButtonSprite(skill, this);
        skillButton.x = -skillButton.width * 0.5;
        skillButton.y = bitmap.y + 60;
        _sprite.addChild(skillButton);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
}

}
