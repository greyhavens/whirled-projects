package core {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;
import flash.display.BitmapData;

public class ResourceManager
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
        _resources.put(name, new ImageResource(filename));
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
    }

    public function isLoaded (name :String) :Boolean
    {
        return (null != getImage(name));
    }

    protected var _resources :HashMap = new HashMap();

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
    public function ImageResource (filename :String)
    {
        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.INIT, onInit);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
        _loader.load(new URLRequest(filename));
    }

    public function get isLoaded () :Boolean
    {
        return (!_isError && _isLoaded);
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
        _isError = true;
    }

    protected var _isError :Boolean;
    protected var _isLoaded :Boolean;
    protected var _loader :Loader;

}
