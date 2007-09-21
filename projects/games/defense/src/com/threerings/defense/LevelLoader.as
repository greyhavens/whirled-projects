package com.threerings.defense {

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.utils.ByteArray;

import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.HashMap;

/**
 * Loads Level objects, and the swf files that include their assets.
 */
public class LevelLoader
{
    public static const LEVEL_1 :int = 1;
    
    public function LevelLoader ()
    {
        _swfLoader = new EmbeddedSwfLoader();
        _swfLoader.addEventListener(Event.COMPLETE, successHandler);
        _swfLoader.addEventListener(IOErrorEvent.IO_ERROR, failureHandler);
    }

    public function handleUnload (event :Event) :void
    {
        _swfLoader.removeEventListener(Event.COMPLETE, successHandler);
        _swfLoader.removeEventListener(IOErrorEvent.IO_ERROR, failureHandler);
        _swfLoader = null;
    }

    /**
     * Call this function to begin loading level information. /level/ should be one of the
     * LEVEL_* constants, and /cont/ should be a function of the form:
     *   function (level :Level) :void { }
     * - it will be called after the load was performed, with the new level object, or null
     * if loading was unsuccessful.
     *
     * Level loads are not queued - while a load operation is pending, any calls to this function
     * will be quietly ignored.
     */
    public function load (level :int, cont :Function) :void
    {
        if (_callback == null) {
            _callback = cont;
            _level = level;
            _swfLoader.load(getSwf(level));
        }
    }

    /**
     * Function used by the Level wrapper, to retrieve data from storage.
     */
    public function getClass (className :String) :Class
    {
        var c :Class = _classes.get(className);
        if (c == null && _swfLoader != null) {
            c = _swfLoader.getClass(className);
            _classes.put(className, c);
        }

        return c; // possibly null, if the loader isn't initialized yet.
    }
    
    protected function failureHandler (event :IOErrorEvent) :void
    {
        _callback(null);
        _callback = null;
    }

    protected function successHandler (event :Event) :void
    {
        _callback(new Level(this, _level));
        _callback = null;
    }

    protected function getSwf (level :int) :ByteArray
    {
        var name :String = "LEVEL_" + level + "_SWF";
        var cl :Class = LevelLoader[name];
        return (cl != null) ? new cl() : null;
    }

    [Embed(source="../../../../rsrc/levels/Level01.swf", mimeType="application/octet-stream")]
    protected static const LEVEL_1_SWF :Class;
    
    protected var _swfLoader :EmbeddedSwfLoader;
    protected var _callback :Function;
    protected var _level :int;
    
    /** Map from class names to instances. */
    protected var _classes :HashMap = new HashMap();
}
}
