//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.text.TextField;
import flash.text.TextFieldType;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;

import flash.net.URLRequest;

import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import flash.ui.Keyboard;

import flash.utils.Timer;

import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

import com.threerings.flash.SimpleTextButton;

import com.whirled.FurniControl;

[SWF(width="500", height="500")]
public class AlbumViewer extends Sprite
{
    public static const WIDTH :int = 500;
    public static const HEIGHT :int = 500;

    public function AlbumViewer ()
    {
        // be prepared to clean up after ourselves...
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload, false, 0, true);

        // configure our conrol
        _furni = new FurniControl(this);

        // Set up the flickr service
        // This is my (Ray Greenwell)'s personal Flickr key!!
        _flickr = new FlickrService("7aa4cc43b7fd51f0f118b0022b7ab13e")
        _flickr.addEventListener(FlickrResultEvent.PEOPLE_GET_PUBLIC_PHOTOS,
            handlePublicPhotoResult);
        _flickr.addEventListener(FlickrResultEvent.PHOTOS_GET_SIZES,
            handlePhotoUrlKnown);

        _loader = new Loader();
        _loader.mouseEnabled = true;
        _loader.mouseChildren = true;
        _loader.addEventListener(MouseEvent.CLICK, handleClick);
        _loader.addEventListener(MouseEvent.ROLL_OVER, handleMouseRoll);
        _loader.addEventListener(MouseEvent.ROLL_OUT, handleMouseRoll);
        addChild(_loader);

        if (_furni.canEditRoom()) {
            _configBtn = new SimpleTextButton("config");
            _configBtn.x = WIDTH - _configBtn.width;
            _configBtn.y = HEIGHT - _configBtn.height;
            addChild(_configBtn);
        }

        _overlay = new Sprite();
        addChild(_overlay);

        _userId = "76219749@N00";

        findPhotos();
    }

    protected function findPhotos () :void
    {
        _flickr.people.getPublicPhotos(_userId);
    }

    /**
     * Handle the results of a tag search.
     */
    protected function handlePublicPhotoResult (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            trace("Failure looking for photos " +
                "[" + evt.data.error.errorMessage + "]");
            return;
        }

        // save the metadata about photos
        _ourPhotos = (evt.data.photos as PagedPhotoList).photos;
        getNextPhotoUrl();
    }

    /**
     * Get the next URL for photos that we ourselves have found via tags.
     */
    protected function getNextPhotoUrl () :void
    {
        if (_ourPhotos == null || _ourPhotos.length == 0) {
            _ourPhotos = null;
            return;
        }

        var photo :Photo = (_ourPhotos.shift() as Photo);
        _nextPhotoLink = "http://www.flickr.com/photos/" + photo.ownerId + "/" + photo.id;
        _flickr.photos.getSizes(photo.id);
    }

    /**
     * Handle data arriving as a result of a getSizes() request.
     */
    protected function handlePhotoUrlKnown (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            trace("Failure getting photo sizes " +
                "[" + evt.data.error.errorMessage + "]");
            return;
        }

        var sizes :Array = (evt.data.photoSizes as Array);
        var p :PhotoSize = getMediumPhotoSource(sizes);
        if (p != null) {
            // yay! We've looked-up our next photo item
            clearLoader();
            _photoLink = _nextPhotoLink;
            _loader.x = (WIDTH - p.width) / 2;
            _loader.y = HEIGHT - p.height;
            _overlay.x = _loader.x;
            _overlay.y = _loader.y;
            _loader.load(new URLRequest(p.source));

            if (_timer == null) {
                _timer = new Timer(7000, 1);
                _timer.addEventListener(TimerEvent.TIMER, handleTimerExpired);
            }
            _timer.reset();
            _timer.start();

        } else {
            getNextPhotoUrl();
        }
    }

    /**
     * Clear any resources from the loader and prepare it to load
     * another photo, or be unloaded.
     */
    protected function clearLoader () :void
    {
        try {
            _loader.close();
        } catch (e :Error) {
            // nada
        }
        _loader.unload();
        _photoLink = null;
        handleMouseRoll(null);
    }

    /**
     * Given an array of PhotoSize objects, return the source url
     * for the medium size photo.
     */
    protected function getMediumPhotoSource (sizes :Array) :PhotoSize
    {
        for each (var p :PhotoSize in sizes) {
            if (p.label == "Medium") {
                return p;
            }
        }

        return null;
    }

    /**
     * Handle a click on the Loader.
     */
    protected function handleClick (event :MouseEvent) :void
    {
        if (_photoLink == null) {
            return;
        }
        try {
            flash.net.navigateToURL(new URLRequest(_photoLink));
        } catch (err :Error) {
            trace("Oh my gosh: " + err);
        }
    }

    protected function handleMouseRoll (event :MouseEvent) :void
    {
        var draw :Boolean = (event == null || event.type == MouseEvent.ROLL_OVER) &&
            (_photoLink != null);

        with (_overlay.graphics) {
            clear();
            if (draw) {
                lineStyle(1, 0xFF4040);
                drawRect(0, 0, _loader.width, _loader.height);
            }
        }
    }

    protected function handleTimerExpired (event :TimerEvent) :void
    {
        getNextPhotoUrl();
    }

    /**
     * Take care of releasing resources when we unload.
     */
    protected function handleUnload (event :Event) :void
    {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        clearLoader();
    }

    /** The interface through which we communicate with metasoy. */
    protected var _furni :FurniControl;

    /** The interface through which we make flickr API requests. */
    protected var _flickr :FlickrService;

    /** The user's photos we're looking for. */
    protected var _userId :String;

    /** Loads up photos for display. */
    protected var _loader :Loader;

    /** Used for drawing UI on top of the photo. */
    protected var _overlay :Sprite;

    /** A button for editing users to configure this damn thing. */
    protected var _configBtn :SimpleTextButton;

    /** The high-level metadata for the result set of photos from our
     * tag search. */
    protected var _ourPhotos :Array;

    /** The url of the photo we're about to show. */
    protected var _nextPhotoLink :String;

    /** The url of the photo we are currently showing, or null. */
    protected var _photoLink :String;

    /** The photo we're currently showing. */
    protected var _showingPhoto :Array;

    /** Timer used to control loading of photos. */
    protected var _timer :Timer;
}
}
