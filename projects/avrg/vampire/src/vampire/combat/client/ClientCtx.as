package vampire.combat.client
{
import com.whirled.contrib.simplegame.resource.ImageResource;
import com.whirled.contrib.simplegame.resource.ResourceManager;

import flash.display.Bitmap;

public class ClientCtx
{
    public static var rsrcs :ResourceManager;

    public static function instantiateBitmap (rsrcName :String) :Bitmap
    {
        return ImageResource.instantiateBitmap(rsrcs, rsrcName);
    }

}
}