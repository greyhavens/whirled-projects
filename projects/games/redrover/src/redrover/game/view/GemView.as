package redrover.game.view {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.Bitmap;
import flash.display.DisplayObject;

public class GemView extends SceneObject
{
    public function GemView ()
    {
        _bitmap = ImageResource.instantiateBitmap("gem");
    }

    override public function get displayObject () :DisplayObject
    {
        return _bitmap;
    }

    protected var _bitmap :Bitmap;

}

}
