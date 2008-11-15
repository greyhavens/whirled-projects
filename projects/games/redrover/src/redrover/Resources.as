package redrover {

import com.whirled.contrib.simplegame.resource.*;

public class Resources
{
    public static function loadResources (loadCompleteCallback :Function = null,
        loadErrorCallback :Function = null) :void
    {
        var rm :ResourceManager = ResourceManager.instance;

        rm.queueResourceLoad("swf", "uiBits",  { embeddedClass: SWF_UIBITS });
        rm.queueResourceLoad("image", "gem", { embeddedClass: IMG_GEM });
        rm.loadQueuedResources(loadCompleteCallback, loadErrorCallback);
    }

    [Embed(source="../../rsrc/UI_bits.swf", mimeType="application/octet-stream")]
    protected static const SWF_UIBITS :Class;
    [Embed(source="../../rsrc/gem.png", mimeType="application/octet-stream")]
    protected static const IMG_GEM :Class;
}

}
