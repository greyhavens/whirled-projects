package flashmob.client {

import com.whirled.contrib.simplegame.resource.*;

public class Resources
{
    public static function loadResources (loadCompleteCallback :Function = null,
        loadErrorCallback :Function = null) :void
    {
        var rm :ResourceManager = ResourceManager.instance;

        rm.queueResourceLoad("swf", "uiBits",  { embeddedClass: SWF_UIBITS });
        rm.queueResourceLoad("swf", "Spectacle_UI",  { embeddedClass: SWF_SPECTACLE_UI });

        rm.loadQueuedResources(loadCompleteCallback, loadErrorCallback);
    }

    [Embed(source="../../../rsrc/UI_bits.swf", mimeType="application/octet-stream")]
    protected static const SWF_UIBITS :Class;
    [Embed(source="../../../rsrc/Spectacle_UI.swf", mimeType="application/octet-stream")]
    protected static const SWF_SPECTACLE_UI :Class;
}

}
