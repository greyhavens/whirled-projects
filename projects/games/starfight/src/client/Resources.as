package client {

import com.threerings.util.HashMap;
import com.threerings.util.MultiLoader;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.media.Sound;
import flash.system.ApplicationDomain;

public class Resources
{
    public static function init (callback :Function) :void
    {
        _callback = callback;
        _resourceDomain = new ApplicationDomain();

        MultiLoader.getLoaders(RESOURCE_BUNDLE, loadComplete, false, _resourceDomain);
    }

    public static function getClass (name :String) :Class
    {
        if (!_ready) {
            return null;
        }
        var asset :Class = Class(_map.get(name));
        if (asset != null) {
            return asset;
        }
        asset = getLoadedClass(name);
        if (asset != null) {
            _map.put(name, asset);
        }
        return asset;
    }

    public static function getBitmapData (name :String) :BitmapData
    {
        if (!_ready) {
            return null;
        }
        var data :BitmapData = BitmapData(_map.get(name));
        if (data != null) {
            return data;
        }
        data = BitmapData(new (getLoadedClass(name))(0, 0));
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
        if (!_ready) {
            return null;
        }
        var sound :Sound = Sound(_map.get(name));
        if (sound != null) {
            return sound;
        }
        sound = Sound(new (getLoadedClass(name))());
        _map.put(name, sound);
        return sound;
    }

    protected static function loadComplete (result :Object) :void
    {
        if (result is Error) {
            _callback(false);
        } else {
            _ready = true;
            _callback(true);
        }
    }

    protected static function getLoadedClass (name :String) :Class
    {
        return (_resourceDomain != null ? _resourceDomain.getDefinition(name) as Class : null);
    }

    [Embed(source="../../rsrc/resources.swf", mimeType="application/octet-stream")]
    protected static const RESOURCE_BUNDLE :Class;

    protected static var _resourceDomain :ApplicationDomain;
    protected static var _callback :Function;
    protected static var _ready :Boolean = false;
    protected static var _map :HashMap = new HashMap();
}
}
