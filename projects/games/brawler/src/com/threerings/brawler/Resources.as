package com.threerings.brawler {

import com.threerings.util.MultiLoader;

import flash.system.ApplicationDomain;

public class Resources
{
    /**
     * Creates an instance of the asset with the supplied class name.
     */
    public static function create (name :String) :*
    {
        var clazz :Class = _appDom.getDefinition(name) as Class;
        return new clazz();
    }

    /**
     * Loads the game's resources, and calls a function when loading is complete.
     * It's not an error to call this function multiple times.
     */
    public static function load (loadCompleteCallback :Function = null) :void
    {
        if (_loaded) {
            if (loadCompleteCallback != null) {
                loadCompleteCallback();
            }

        } else {
            if (loadCompleteCallback != null) {
                _loadCompleteCallbacks.push(loadCompleteCallback);
            }

            if (!_loading) {
                // Load the embedded SWFs that contain the game's resources.
                MultiLoader.getLoaders(INIT_SWFS, onLoaded, false, _appDom);
                _loading = true;
            }
        }
    }

    protected static function onLoaded (...ignored) :void
    {
        _loaded = true;
        _loading = false;
        for each (var loadCompleteCallback :Function in _loadCompleteCallbacks) {
            loadCompleteCallback();
        }
    }

    protected static var _loaded :Boolean;
    protected static var _loading :Boolean;
    protected static var _loadCompleteCallbacks :Array = [];
    protected static var _appDom :ApplicationDomain = new ApplicationDomain();

    /** The raw SWF data. */
    //[Embed(source="../../../../rsrc/raw.swf", mimeType="application/octet-stream")]
    //protected static const RAW_SWF :Class;
    [Embed(source="../../../../rsrc/hud_effects.swf", mimeType="application/octet-stream")]
    protected static const RAW_SWF :Class;
    [Embed(source="../../../../rsrc/bgs.swf", mimeType="application/octet-stream")]
    protected static const BGS_SWF :Class;
    [Embed(source="../../../../rsrc/pc.swf", mimeType="application/octet-stream")]
    protected static const PC_SWF :Class;
    [Embed(source="../../../../rsrc/mobs.swf", mimeType="application/octet-stream")]
    protected static const MOBS_SWF :Class;

    /** The SWFs to load on initialization. */
    protected static const INIT_SWFS :Array = [ RAW_SWF, BGS_SWF, PC_SWF, MOBS_SWF ];
}

}
