package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.media.Sound;
import flash.utils.ByteArray;

import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.HashMap;

public class Resources
{
    public static function init (callback :Function) :void
    {
        _callback = callback;
        _loader = new EmbeddedSwfLoader(true);
        _loader.addEventListener(Event.COMPLETE, successHandler);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, failureHandler);
        _loader.load(new RESOURCE_BUNDLE());
    }

    public static function getClass (name :String) :Class
    {
        if (_loader == null || !_ready) {
            return null;
        }
        var asset :Class = Class(_map.get(name));
        if (asset != null) {
            return asset;
        }
        asset = _loader.getClass(name);
        if (asset != null) {
            _map.put(name, asset);
        }
        return asset;
    }

    public static function getBitmapData (name :String) :BitmapData
    {
        if (_loader == null || !_ready) {
            return null;
        }
        var data :BitmapData = BitmapData(_map.get(name));
        if (data != null) {
            return data;
        }
        data = BitmapData(new (_loader.getClass(name))(0, 0));
        _map.put(name, data);
        return data;
    }

    public static function getBitmap (name :String) :Bitmap
    {
        var data :BitmapData = getBitmapData(name);
        if (data == null) {
            return null;
        }
        return new Bitmap(data);
    }

    public static function getSound (name :String) :Sound
    {
        if (_loader == null || !_ready) {
            return null;
        }
        var sound :Sound = Sound(_map.get(name));
        if (sound != null) {
            return sound;
        }
        sound = Sound(new (_loader.getClass(name))());
        _map.put(name, sound);
        return sound;
    }

    protected static function failureHandler (event :IOErrorEvent) :void
    {
        _callback(false);
        _loader = null;
    }

    protected static function successHandler (event :Event) :void
    {
        _callback(true);
        _loader.removeEventListener(Event.COMPLETE, successHandler);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, failureHandler);
        _ready = true;
    }

    [Embed(source="../rsrc/resources.swf", mimeType="application/octet-stream")]
    protected static const RESOURCE_BUNDLE :Class;

    protected static var _loader :EmbeddedSwfLoader;
    protected static var _callback :Function;
    protected static var _ready :Boolean = false;
    protected static var _map :HashMap = new HashMap();
}
}
