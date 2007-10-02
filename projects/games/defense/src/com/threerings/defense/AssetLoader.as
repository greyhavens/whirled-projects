package com.threerings.defense {

import flash.events.Event;

/**
 * Creates level objects and loads assets for the level.
 */
public class AssetLoader
{
    /**
     * Takes a listener function of the form: function (:Level) :void { },
     * and will call that function with a new Level instance once the level assets are loaded.
     */
    public function AssetLoader (level :int, cont :Function)
    {
        _units = new SWFWrapper(UNITS, checkDone);
        _boards = new SWFWrapper(BOARDS, checkDone);
        _level = level;
        _callback = cont;
    }

    public function handleUnload (event :Event) :void
    {
        _units = null;
        _boards = null;
    }
    
    public function getBoardClass (className :String) :Class
    {
        return _boards.getClass(className);
    }
    
    public function getUnitClass (className :String) :Class
    {
        return _units.getClass(className);
    }

    protected function checkDone (doneWrapper :SWFWrapper) :void
    {
        if (_callback != null) {
            if (_units.state == SWFWrapper.STATE_READY &&
                _boards.state == SWFWrapper.STATE_READY)
            {
                _callback(new Level(this, _level));
                _callback = null;
            }
        }
    }

    protected var _units :SWFWrapper;
    protected var _boards :SWFWrapper;

    protected var _callback :Function;
    protected var _level :int;
    
    [Embed(source="../../../../rsrc/levels/THD_units.swf", mimeType="application/octet-stream")]
    protected static const UNITS :Class;
    [Embed(source="../../../../rsrc/levels/THD_BGs.swf", mimeType="application/octet-stream")]
    protected static const BOARDS :Class;
}
}

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.utils.ByteArray;

import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.HashMap;

internal class SWFWrapper
{
    public static const STATE_PENDING :int = 0;
    public static const STATE_READY :int = 1;
    public static const STATE_ERROR :int = 2;

    /**
     * Takes a SWF class reference, and a callback of form: function (:SWFWrapper) :void { }.
     * Once the SWF loading completes, the callback function will be called, passing itself as
     * the argument. The state() getter can also be queried to see if loadeding was successful.
     */
    public function SWFWrapper (swfClass :Class, callback :Function)
    {
        _callback = callback;
        _loader = new EmbeddedSwfLoader();
        _loader.addEventListener(Event.COMPLETE, successHandler);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, failureHandler);
        _loader.load(new swfClass());
    }

    public function get state () :int
    {
        return _state;
    }

    /** Retrieves class from the swf. */
    public function getClass (className :String) :Class
    {
        var c :Class = _classes.get(className);
        if (c == null && state == STATE_READY) {
            c = _loader.getClass(className);
            _classes.put(className, c);
        }

        return c; // possibly null, if the swf isn't loaded yet
    }

    protected function failureHandler (event :IOErrorEvent) :void
    {
        _state = STATE_ERROR;
        finish();
    }

    protected function successHandler (event :Event) :void
    {
        _state = STATE_READY;
        finish();
    }

    protected function finish () :void
    {
        _callback(this);
        _loader.removeEventListener(Event.COMPLETE, successHandler);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, failureHandler);
    }

    protected var _callback :Function;
    protected var _state :int = STATE_PENDING;
    protected var _loader :EmbeddedSwfLoader;
    protected var _classes :HashMap = new HashMap();
}
