//
// $Id$

package display {

import flash.display.DisplayObject;

/**
 * Geneartes background images.
 */
public class BackgroundFactory
{
    public static function getBackground (type :String) :DisplayObject
    {
        if (type == "skybox") {
            var skybox :DisplayObject = new SKYBOX_BG() as DisplayObject;
            skybox.cacheAsBitmap = true;
            return skybox;
        } if (type == "skybox_b") {
            return new SKYBOX_BITMAP() as DisplayObject;
        }
        return null;
    }

    [Embed(source="../../rsrc/skybox_test.swf")]
    protected static const SKYBOX_BG :Class;

    [Embed(source="../../rsrc/skybox_sunset_desert_bitmap.swf")]
    protected static const SKYBOX_BITMAP :Class;
}
}
