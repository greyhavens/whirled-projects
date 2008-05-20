package simon {

import com.whirled.contrib.simplegame.resource.*;

import flash.display.MovieClip;

public class Resources
{
    public static function load (loadCompleteCallback :Function = null, loadErrorCallback :Function = null) :void
    {
        ResourceManager.instance.pendResourceLoad("swf", "ui", { embeddedClass: Resources.SWF_RAINBOW });
        ResourceManager.instance.load(loadCompleteCallback, loadErrorCallback);
    }

    public static function instantiateMovieClip (resourceName :String, symbolName :String) :MovieClip
    {
        var movie :MovieClip;

        var swf :SwfResourceLoader = ResourceManager.instance.getResource(resourceName) as SwfResourceLoader;
        if (null != swf) {
            var theClass :Class = swf.getClass(symbolName);

            if (null != theClass) {
                movie = new theClass();
            }
        }

        return movie;
    }

    // gfx

    [Embed(source="../../rsrc/pookah_rainbow.swf", mimeType="application/octet-stream")]
    public static const SWF_RAINBOW :Class;

    // sfx

    /* old sfx
    [Embed(source="../../rsrc/1c.1.mp3")]
    public static const SFX_RED :Class;

    [Embed(source="../../rsrc/1d.1.mp3")]
    public static const SFX_ORANGE :Class;

    [Embed(source="../../rsrc/1e.1.mp3")]
    public static const SFX_YELLOW :Class;

    [Embed(source="../../rsrc/1f.1.mp3")]
    public static const SFX_GREEN :Class;

    [Embed(source="../../rsrc/1g.1.mp3")]
    public static const SFX_BLUE :Class;

    [Embed(source="../../rsrc/2a.1.mp3")]
    public static const SFX_INDIGO :Class;

    [Embed(source="../../rsrc/2b.1.mp3")]
    public static const SFX_VIOLET :Class;
    */

    [Embed(source="../../rsrc/steelstring.c3.mp3")]
    public static const SFX_RED :Class;

    [Embed(source="../../rsrc/steelstring.d3.mp3")]
    public static const SFX_ORANGE :Class;

    [Embed(source="../../rsrc/steelstring.e3.mp3")]
    public static const SFX_YELLOW :Class;

    [Embed(source="../../rsrc/steelstring.f3.mp3")]
    public static const SFX_GREEN :Class;

    [Embed(source="../../rsrc/steelstring.g3.mp3")]
    public static const SFX_BLUE :Class;

    [Embed(source="../../rsrc/steelstring.a3.mp3")]
    public static const SFX_INDIGO :Class;

    [Embed(source="../../rsrc/steelstring.b3.mp3")]
    public static const SFX_VIOLET :Class;

    [Embed(source="../../rsrc/fail.mp3")]
    public static const SFX_FAIL :Class;
}

}
