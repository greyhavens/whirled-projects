package ghostbusters.fight.core {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;
import flash.display.BitmapData;
import mx.controls.Image;

public class ResourceManager
    implements Updatable
{
    public static function get instance () :ResourceManager
    {
        if (null == g_instance) {
            new ResourceManager();
        }

        return g_instance;
    }

    public function ResourceManager ()
    {
        Assert.isNull(g_instance);
        g_instance = this;
    }

    public function loadImage (name :String, filename :String) :void
    {
        var resource :ImageResource = new ImageResource(name, filename);

        if (resource.isLoaded) {
            _resources.put(resource.name, resource);
        } else {
            _pendingResources.put(resource.name, resource);
        }
    }

    public function getImage (name :String) :BitmapData
    {
        var resource :ImageResource = (_resources.get(name) as ImageResource);

        if (null == resource) {
            return null;
        }

        if (!resource.bitmapData) {
            return null;
        }

        return resource.bitmapData;
    }

    public function unload (name :String) :void
    {
        _resources.remove(name);
        _pendingResources.remove(name);
    }

    public function isLoaded (name :String) :Boolean
    {
        return (null != getImage(name));
    }

    public function get hasPendingResources () :Boolean
    {
        return !(_pendingResources.isEmpty());
    }

    // from Updatable
    public function update (dt :Number) :void
    {
        if (!hasPendingResources) {
            return;
        }

        var pending :Array = _pendingResources.values();
        for each (var resource :ImageResource in pending) {
            if (resource.hasError) {
                // resource loaders report their own errors, so we don't need to do so here.
                _pendingResources.remove(resource.name);
            } else if (resource.isLoaded) {
                _pendingResources.remove(resource.name);
                _resources.put(resource.name, resource);
            }
        }
    }

    protected var _resources :HashMap = new HashMap();
    protected var _pendingResources :HashMap = new HashMap();

    protected static var g_instance :ResourceManager;
}

}

import com.threerings.util.Assert;
import flash.display.Loader;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.net.URLRequest;
import flash.events.IOErrorEvent;

class ImageResource
{
    public function ImageResource (name :String, filename :String)
    {
        _name = name;
        _filename = filename;
        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.INIT, onInit);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
        _loader.load(new URLRequest(filename));
    }

    public function get name () :String
    {
        return _name;
    }

    public function get isLoaded () :Boolean
    {
        return (!_hasError && _isLoaded);
    }

    public function get hasError () :Boolean
    {
        return _hasError;
    }

    public function get bitmapData () :BitmapData
    {
        Assert.isTrue(isLoaded);
        return Bitmap(_loader.content).bitmapData;
    }

    protected function onInit (e :Event) :void
    {
        _isLoaded = true;
    }

    protected function onError (e :IOErrorEvent) :void
    {
        trace("Failed to load image '" + _filename + "': " + e.text);
        _hasError = true;
    }

    protected var _name :String;
    protected var _filename :String;
    protected var _hasError :Boolean;
    protected var _isLoaded :Boolean;
    protected var _loader :Loader;

}
