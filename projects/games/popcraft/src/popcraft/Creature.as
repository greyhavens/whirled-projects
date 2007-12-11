package popcraft {

import core.AppObject;
import core.ResourceManager;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

public class Creature extends AppObject
{
    public function Creature ()
    {
        // create the visual representation
        var bitmap :Bitmap = new Bitmap(ResourceManager.instance.getImage("melee"));
        bitmap.x = -(bitmap.width / 2);
        bitmap.y = -bitmap.height;
        _sprite = new Sprite();
        _sprite.addChild(bitmap);

    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
}

}
