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
        rm.queueResourceLoad("swf", "grunt", { embeddedClass: SWF_GRUNT });
        rm.queueResourceLoad("swf", "sapper", { embeddedClass: SWF_SAPPER });
        rm.loadQueuedResources(loadCompleteCallback, loadErrorCallback);
    }

    [Embed(source="../../rsrc/UI_bits.swf", mimeType="application/octet-stream")]
    protected static const SWF_UIBITS :Class;
    [Embed(source="../../rsrc/gem.png", mimeType="application/octet-stream")]
    protected static const IMG_GEM :Class;
    [Embed(source="../../rsrc/streetwalker.swf", mimeType="application/octet-stream")]
    protected static const SWF_GRUNT :Class;
    [Embed(source="../../rsrc/runt.swf", mimeType="application/octet-stream")]
    protected static const SWF_SAPPER :Class;
}

}
