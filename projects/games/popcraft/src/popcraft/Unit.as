package popcraft {

import core.AppObject;
import core.ResourceManager;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

public class Unit extends AppObject
{
    public function Unit (owningPlayerId :uint)
    {
        _owningPlayerId = owningPlayerId;

        // create the visual representation
        _sprite = new Sprite();
        _sprite.addChild(new Content.MELEE());

    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _owningPlayerId :uint;
}

}
