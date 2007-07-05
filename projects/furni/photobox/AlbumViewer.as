//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Graphics;
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
        _flickr.addEventListener(FlickrResultEvent.PEOPLE_FIND_BY_USERNAME,
            handleFindUsername);
        _flickr.addEventListener(FlickrResultEvent.PEOPLE_GET_PUBLIC_PHOTOS,
            handleGotPhotos);
        _flickr.addEventListener(FlickrResultEvent.PHOTOSETS_GET_PHOTOS,
            handleGotPhotos);
        _flickr.addEventListener(FlickrResultEvent.PHOTOS_GET_SIZES,
            handlePhotoUrlKnown);

        for (var ii :int = 0; ii < 2; ii++) {
            var loader :Loader = new Loader();
            loader = new Loader();
            loader.mouseEnabled = true;
            loader.mouseChildren = true;
            loader.addEventListener(MouseEvent.CLICK, handleClick);
            loader.addEventListener(MouseEvent.ROLL_OVER, handleMouseRoll);
            loader.addEventListener(MouseEvent.ROLL_OUT, handleMouseRoll);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleImageLoaded);
            addChild(loader);
            if (ii == 0) {
                _curLoader = loader;
            } else {
                loader.visible = false;
                _nextLoader = loader;
            }
        }

        var showConfig :Boolean;
        if (_furni.isConnected()) {
            showConfig = _furni.canEditRoom();

        } else {
            setLabel("This flickr AlbumViewer is normally used inside whirled. You may configure " +
                "it here just for testing.");
            showConfig = true;
        }

        if (showConfig) {
            _configBtn = new SimpleTextButton("config");
            _configBtn.x = WIDTH - _configBtn.width;
            _configBtn.y = HEIGHT - _configBtn.height;
            _configBtn.addEventListener(MouseEvent.CLICK, handleConfig);
            addChild(_configBtn);
        }

        _overlay = new Sprite();
        addChild(_overlay);

        //_userId = "76219749@N00";

        findPhotos();
    }

    /**
     * Set the text to be displayed in a label.
     */
    protected function setLabel (text :String) :void
    {
        if (_label == null) {
            _label = new TextField();
            _label.background = true;
            _label.backgroundColor = 0xFFFFFF;
            _label.autoSize = TextFieldAutoSize.LEFT;
            _label.wordWrap = true;
            _label.defaultTextFormat = new TextFormat(null, 16);
            _label.width = WIDTH;
            addChild(_label);
        }

        _label.visible = (text != null);
        if (text != null) {
            _label.text = text;
            _label.height = _label.textHeight + 4;
        }
    }

    protected function handleConfig (event :MouseEvent) :void
    {
        if (_pasteEntry == null) {
            setLabel("Enter the URL of the public flickr photo album you'd like to have " + 
                "this viewer display and press the config button again.");
            _pasteEntry = new TextField();
            _pasteEntry.type = TextFieldType.INPUT;
            _pasteEntry.background = true;
            _pasteEntry.backgroundColor = 0xCCCCFF;
            _pasteEntry.width = WIDTH;
            _pasteEntry.defaultTextFormat = new TextFormat(null, 16);
            _pasteEntry.text = "Wp";
            _pasteEntry.height = _pasteEntry.textHeight + 4;
            _pasteEntry.text = "";
            _pasteEntry.y = _configBtn.y - _pasteEntry.height;
            addChild(_pasteEntry);

        } else {
            var url :String = _pasteEntry.text;

            removeChild(_pasteEntry);
            _pasteEntry = null;
            setLabel(null);

            if (url != "") {
                _userId = url;
                findPhotos();
            }
        }
    }

    protected function findPhotos () :void
    {
        if (_setId != null) {
            _flickr.photosets.getPhotos(_setId);

        } else if (_userId != null) {
            _flickr.people.getPublicPhotos(_userId);
        }
    }

    protected function handleFindUsername (evt :FlickrResultEvent) :void
    {
    }

    /**
     * Handle the results photo search.
     */
    protected function handleGotPhotos (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            trace("Failure looking for photos " +
                "[" + evt.data.error.errorMessage + "]");
            return;
        }

        // save the metadata about photos
        _ourPhotos = evt.data.photos as PagedPhotoList;
        getNextPhotoUrl();
    }

    /**
     * Get the next URL for photos that we ourselves have found via tags.
     */
    protected function getNextPhotoUrl () :void
    {
        if (_ourPhotos == null || _ourPhotos.photos.length == 0) {
            _ourPhotos = null;
            // loop back around
            findPhotos();
            return;
        }

        var photo :Photo = (_ourPhotos.photos.shift() as Photo);
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
            _nextLoader.x = (WIDTH - p.width) / 2;
            _nextLoader.y = HEIGHT - p.height;
            _nextLoader.load(new URLRequest(p.source));

        } else {
            getNextPhotoUrl();
        }
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

    protected function handleImageLoaded (event :Event) :void
    {
        // swap the loaders around
        var lastLoader :Loader = _curLoader;
        _curLoader = _nextLoader;
        _nextLoader = lastLoader;

        handleMouseRoll(null);
        _photoLink = _nextPhotoLink;
        _curLoader.visible = true;
        lastLoader.visible = false;
        _overlay.x = _curLoader.x;
        _overlay.y = _curLoader.y;

        try {
            lastLoader.close();
        } catch (e :Error) {
            // nada
        }
        lastLoader.unload();

        if (_timer == null) {
            _timer = new Timer(7000, 1);
            _timer.addEventListener(TimerEvent.TIMER, handleTimerExpired);
        }
        _timer.reset();
        _timer.start();
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

        var g :Graphics = _overlay.graphics;
        g.clear();
        if (draw) {
            g.lineStyle(1, 0xFF4040);
            g.drawRect(0, 0, _curLoader.width, _curLoader.height);
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
        try {
            _curLoader.close();
        } catch (e :Error) {
            // nada
        }
        try {
            _nextLoader.close();
        } catch (e :Error) {
            // nada
        }
        _curLoader.unload();
        _nextLoader.unload();
        _photoLink = null;
        handleMouseRoll(null);

        // TODO: set a flag so that we don't react to any more asynchronously arriving events
    }

    /** The interface through which we communicate with metasoy. */
    protected var _furni :FurniControl;

    /** The interface through which we make flickr API requests. */
    protected var _flickr :FlickrService;

    /** The currently visible loader. */
    protected var _curLoader :Loader;

    /** Loads up photos for display. */
    protected var _nextLoader :Loader;

    /** Used for drawing UI on top of the photo. */
    protected var _overlay :Sprite;

    /** The photo metadata from the last photo search. */
    protected var _ourPhotos :PagedPhotoList;

    /** The url of the photo we're about to show. */
    protected var _nextPhotoLink :String;

    /** The url of the photo we are currently showing, or null. */
    protected var _photoLink :String;

    /** The photo we're currently showing. */
    protected var _showingPhoto :Array;

    /** Timer used to control loading of photos. */
    protected var _timer :Timer;

    /** The user's photos we're looking for. */
    protected var _userId :String;

    /** The photoset id we're looking for. */
    protected var _setId :String;

    /** A button for editing users to configure this damn thing. */
    protected var _configBtn :SimpleTextButton;

    /** A label we use to prompt the user. */
    protected var _label :TextField;

    /** The place where a configuring user enters the flickr URL. */
    protected var _pasteEntry :TextField;
}
}
