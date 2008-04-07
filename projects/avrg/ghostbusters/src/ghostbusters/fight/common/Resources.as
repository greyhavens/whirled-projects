package ghostbusters.fight.common {

import com.whirled.contrib.simplegame.resource.*;

import flash.display.MovieClip;

public class Resources
{
    public static function get instance () :Resources
    {
        if (null == g_instance) {
            new Resources();
        }

        return g_instance;
    }

    public function Resources ()
    {
        if (null != g_instance) {
            throw new Error("Resources is a singleton class and cannot be instantiated more than once");
        }

        g_instance = this;
    }

    public function loadAll () :void
    {
        if (_loaded) {
            return;
        }

        _loaded = true;

        // for now, just naively load all resources we might need.
        // change this if it becomes too much of a burden.

        _rsrcMgr.pendResourceLoad("swf", "intro.screen", { embeddedClass: SWF_INTROSCREEN });
        _rsrcMgr.pendResourceLoad("swf", "outro.screen", { embeddedClass: SWF_OUTROSCREEN });

        _rsrcMgr.pendResourceLoad("swf", "lantern.heart", { embeddedClass: SWF_HEART });

        _rsrcMgr.pendResourceLoad("image", "ouija.planchette", { embeddedClass: IMAGE_PLANCHETTE });
        _rsrcMgr.pendResourceLoad("swf", "ouija.board", { embeddedClass: SWF_BOARD });
        _rsrcMgr.pendResourceLoad("swf", "ouija.timer", { embeddedClass: SWF_TIMER });
        _rsrcMgr.pendResourceLoad("image", "ouija.pictoboard", { embeddedClass: IMAGE_PICTOBOARD });

        _rsrcMgr.pendResourceLoad("swf", "potions.board", { embeddedClass: SWF_HUEANDCRYBOARD });

        _rsrcMgr.pendResourceLoad("swf", "spiritshell.board", { embeddedClass: SWF_SPIRITSHELL });

        _rsrcMgr.load();
    }

    public function getSwfLoader (name :String) :SwfResourceLoader
    {
        return _rsrcMgr.getResource(name) as SwfResourceLoader;
    }

    public function getImageLoader (name :String) :ImageResourceLoader
    {
        return _rsrcMgr.getResource(name) as ImageResourceLoader;
    }

    public function instantiateMovieClip (resourceName :String, className :String) :MovieClip
    {
        var swf :SwfResourceLoader = this.getSwfLoader(resourceName);
        if (null != swf) {
            var movieClass :Class = swf.getClass(className);
            if (null != movieClass) {
                return new movieClass();
            }
        }

        return null;
    }

    public function get isLoading () :Boolean
    {
        return _rsrcMgr.isLoading;
    }

    public function get resourceManager () :ResourceManager
    {
        return _rsrcMgr;
    }

    protected var _rsrcMgr :ResourceManager = new ResourceManager();
    protected var _loaded :Boolean;

    protected static var g_instance :Resources;

    /* intro/outro */
    [Embed(source="../../../../rsrc/Microgames/gameDirections.swf", mimeType="application/octet-stream")]
    protected static const SWF_INTROSCREEN :Class;

    [Embed(source="../../../../rsrc/Microgames/minigame_outro.swf", mimeType="application/octet-stream")]
    protected static const SWF_OUTROSCREEN :Class;

    [Embed(source="../../../../rsrc/Microgames/heart.swf", mimeType="application/octet-stream")]
    protected static const SWF_HEART :Class;

    /* Ouija */
    [Embed(source="../../../../rsrc/Fonts/DelitschAntiqua.ttf", fontName="DelitschAntiqua")]
    public static const FONT_GAME :Class;

    public static const OUIJA_FONT_NAME :String = "DelitschAntiqua";

    [Embed(source="../../../../rsrc/Microgames/ouijaplanchette.png", mimeType="application/octet-stream")]
    protected static const IMAGE_PLANCHETTE :Class;

    [Embed(source="../../../../rsrc/Microgames/Ouija_animated_01.swf", mimeType="application/octet-stream")]
    protected static const SWF_BOARD :Class;

    [Embed(source="../../../../rsrc/Microgames/Ouija_timer_10fnew.swf", mimeType="application/octet-stream")]
    protected static const SWF_TIMER :Class;

    [Embed(source="../../../../rsrc/Microgames/pictogeistboard.png", mimeType="application/octet-stream")]
    protected static const IMAGE_PICTOBOARD :Class;

    /* Plasma */
    [Embed(source="../../../../rsrc/Microgames/blaster_ghost.swf", mimeType="application/octet-stream")]
    protected static const SWF_SPIRITSHELL :Class;

    /* Potions */
    [Embed(source="../../../../rsrc/Microgames/ectopotions_code_no_opening.swf", mimeType="application/octet-stream")]
    protected static const SWF_HUEANDCRYBOARD :Class;

}

}
