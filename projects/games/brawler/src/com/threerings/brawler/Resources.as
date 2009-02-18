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
    public static function load (completeCallback :Function = null) :void
    {
        if (_appDom != null) {
            if (completeCallback != null) {
                completeCallback();
            }

        } else {
            var alreadyLoading :Boolean = (_callbacks != null);
            if (!alreadyLoading) {
                _callbacks = [];
            }
            if (completeCallback != null) {
                _callbacks.push(completeCallback);
            }
            if (!alreadyLoading) {
                // Load the embedded SWFs that contain the game's resources.
                MultiLoader.loadClasses(INIT_SWFS, new ApplicationDomain(), onLoaded);
            }
        }
    }

    protected static function onLoaded (appDom :ApplicationDomain) :void
    {
        _appDom = appDom;
        for each (var callback :Function in _callbacks) {
            callback();
        }
        _callbacks = null;
    }

    protected static var _callbacks :Array; // non-null if we're currently loading
    protected static var _appDom :ApplicationDomain; // non-null after everything's loaded

    /** The raw SWF data. */
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
