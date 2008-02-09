package ghostbusters.fight.common {
    
import com.whirled.contrib.core.resource.*;
    
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
        
        _rsrcMgr.pendResourceLoad("swf", "intro.screen", { embeddedClass: SWF_INTROOUTROSCREEN });
        
        _rsrcMgr.pendResourceLoad("swf", "lantern.ghost", { embeddedClass: SWF_LANTERNGHOST });
        _rsrcMgr.pendResourceLoad("swf", "lantern.heart", { embeddedClass: SWF_HEART });
        
        _rsrcMgr.pendResourceLoad("image", "ouija.planchette", { embeddedClass: IMAGE_PLANCHETTE });
        _rsrcMgr.pendResourceLoad("swf", "ouija.board", { embeddedClass: SWF_BOARD });
        _rsrcMgr.pendResourceLoad("swf", "ouija.timer", { embeddedClass: SWF_TIMER });
        _rsrcMgr.pendResourceLoad("image", "ouija.pictoboard", { embeddedClass: IMAGE_PICTOBOARD });
        
        _rsrcMgr.pendResourceLoad("image", "plasma.ghost", { embeddedClass: IMAGE_PLASMAGHOST });
        _rsrcMgr.pendResourceLoad("image", "plasma.ectoplasm", { embeddedClass: IMAGE_ECTOPLASM });
        _rsrcMgr.pendResourceLoad("image", "plasma.plasma", { embeddedClass: IMAGE_PLASMA });
        
        _rsrcMgr.pendResourceLoad("swf", "potions.board", { embeddedClass: SWF_HUEANDCRYBOARD });
        
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
    
    /* intro */
    [Embed(source="../../../../rsrc/UI/gameDirections.swf", mimeType="application/octet-stream")]
    protected static const SWF_INTROOUTROSCREEN :Class;
    
    /* Lantern */
    [Embed(source="../../../../rsrc/Ghosts/Ghost_Duchess.swf", mimeType="application/octet-stream")]
    protected static const SWF_LANTERNGHOST :Class;
    
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
    [Embed(source="../../../../rsrc/Microgames/plasmaGhost.png", mimeType="application/octet-stream")]
    protected static const IMAGE_PLASMAGHOST :Class;
    
    [Embed(source="../../../../rsrc/Microgames/ectoplasm.png", mimeType="application/octet-stream")]
    protected static const IMAGE_ECTOPLASM :Class;
    
    [Embed(source="../../../../rsrc/Microgames/plasma.png", mimeType="application/octet-stream")]
    protected static const IMAGE_PLASMA :Class;
    
    /* Potions */
    [Embed(source="../../../../rsrc/Microgames/ectopotions_code_no_opening.swf", mimeType="application/octet-stream")]
    protected static const SWF_HUEANDCRYBOARD :Class;

}

}