package simon.client {

import com.whirled.contrib.simplegame.resource.ResourceManager;

public class Resources
{
    public static function load (loadCompleteCallback :Function = null, loadErrorCallback :Function = null) :void
    {
        ClientCtx.rsrcs.queueResourceLoad("swf", "ui", { embeddedClass: Resources.SWF_RAINBOW });
        ClientCtx.rsrcs.loadQueuedResources(loadCompleteCallback, loadErrorCallback);
    }

    // gfx

    [Embed(source="../../../rsrc/pookah_rainbow.swf", mimeType="application/octet-stream")]
    public static const SWF_RAINBOW :Class;

    // sfx

    /* old sfx
    [Embed(source="../../../rsrc/1c.1.mp3")]
    public static const SFX_RED :Class;

    [Embed(source="../../../rsrc/1d.1.mp3")]
    public static const SFX_ORANGE :Class;

    [Embed(source="../../../rsrc/1e.1.mp3")]
    public static const SFX_YELLOW :Class;

    [Embed(source="../../../rsrc/1f.1.mp3")]
    public static const SFX_GREEN :Class;

    [Embed(source="../../../rsrc/1g.1.mp3")]
    public static const SFX_BLUE :Class;

    [Embed(source="../../../rsrc/2a.1.mp3")]
    public static const SFX_INDIGO :Class;

    [Embed(source="../../../rsrc/2b.1.mp3")]
    public static const SFX_VIOLET :Class;
    */

    [Embed(source="../../../rsrc/steelstring.c3.mp3")]
    public static const SFX_RED :Class;

    [Embed(source="../../../rsrc/steelstring.d3.mp3")]
    public static const SFX_ORANGE :Class;

    [Embed(source="../../../rsrc/steelstring.e3.mp3")]
    public static const SFX_YELLOW :Class;

    [Embed(source="../../../rsrc/steelstring.f3.mp3")]
    public static const SFX_GREEN :Class;

    [Embed(source="../../../rsrc/steelstring.g3.mp3")]
    public static const SFX_BLUE :Class;

    [Embed(source="../../../rsrc/steelstring.a3.mp3")]
    public static const SFX_INDIGO :Class;

    [Embed(source="../../../rsrc/steelstring.b3.mp3")]
    public static const SFX_VIOLET :Class;

    [Embed(source="../../../rsrc/fail.mp3")]
    public static const SFX_FAIL :Class;
}

}
