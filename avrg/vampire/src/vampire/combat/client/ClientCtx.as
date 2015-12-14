package vampire.combat.client
{
import com.threerings.flashbang.resource.ImageResource;
import com.threerings.flashbang.resource.ResourceManager;

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
