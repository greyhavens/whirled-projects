package popcraft.util {

import flash.display.Sprite;

public class SpriteUtil
{
    public static function createSprite (mouseChildren :Boolean = false, mouseEnabled :Boolean = false) :Sprite
    {
        var sprite :Sprite = new Sprite();
        sprite.mouseChildren = mouseChildren;
        sprite.mouseEnabled = mouseEnabled;
        return sprite;
    }
}

}
