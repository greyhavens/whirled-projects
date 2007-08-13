package {

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;

public class TowerSprite extends Sprite
{
    public function TowerSprite (type :int)
    {
        var bitmap :DisplayObject = AssetFactory.makeTower(type);
        addChild(bitmap);
    }
}
}
