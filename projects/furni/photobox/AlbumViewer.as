//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;

import flash.net.URLRequest;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.utils.Timer;

import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

import com.threerings.flash.SimpleTextButton;

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

[SWF(width="500", height="500")]
public class AlbumViewer extends Sprite
{
    public static const WIDTH :int = 500;
    public static const HEIGHT :int = 500;

    public static const RESULTS_PER_PAGE :int = 20;

    public function AlbumViewer ()
    {
        // be prepared to clean up after ourselves...
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload, false, 0, true);

        // configure our conrol
        _furni = new FurniControl(this);

        // Set up the flickr service
        // This is my (Ray Greenwell)'s personal Flickr key for the AlbumViewer!! Get your own!
        _flickr = new FlickrService("f7d0090207c8e05dbced9ba2ec206647");
//        _flickr.addEventListener(FlickrResultEvent.PEOPLE_FIND_BY_USERNAME,
//            handleFindUsername);
        _flickr.addEventListener(FlickrResultEvent.URLS_LOOKUP_USER, handleLookupUser);
        _flickr.addEventListener(FlickrResultEvent.PEOPLE_GET_PUBLIC_PHOTOS,
            handleGotPeoplePhotos);
        _flickr.addEventListener(FlickrResultEvent.PHOTOSETS_GET_PHOTOS,
            handleGotSetPhotos);
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
            showConfig = true;
        }

        // show the config button in contexts where the user may configure it
        if (!_furni.isConnected() || _furni.canEditRoom()) {
            _configBtn = new SimpleTextButton("config");
            _configBtn.x = WIDTH - _configBtn.width;
            _configBtn.y = HEIGHT - _configBtn.height;
            _configBtn.addEventListener(MouseEvent.CLICK, handleConfig);
            addChild(_configBtn);
        }

        _overlay = new Sprite();
        addChild(_overlay);

        if (_furni.isConnected()) {
            _furni.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);
            getSourceFromMemory();

        } else {
            setLabel("This flickr AlbumViewer is normally used inside whirled. You may configure " +
                "it here just for testing.");
        }

        // TESTING
        //configureSource("roguenet", "72157600249803400");
        //configureSource("76219749@N00");
    }

    protected function handleMemoryChanged (evt :ControlEvent) :void
    {
        if (evt.name == "userId" || evt.name == "setId") {
            getSourceFromMemory();
        }
    }

    protected function getSourceFromMemory () :void
    {
        configureSource(_furni.lookupMemory("userId", null) as String,
            _furni.lookupMemory("setId", null) as String);
    }

    protected function configureSource (userId :String, setId :String = null) :void
    {
        _userId = userId;
        _setId = setId;
        _nextPage = 1;

        if (_furni.isConnected() && _furni.canEditRoom()) {
            if (userId != _furni.lookupMemory("userId", null)) {
                _furni.updateMemory("userId", userId);
            }
            if (setId != _furni.lookupMemory("setId", null)) {
                _furni.updateMemory("setId", setId);
            }
        }

        findPhotos();
    }

    /**
     * Set the text to be displayed in a label inside the viewer.
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

    protected function handleConfig (... ignored) :void
    {
        setLabel(null);
        if (_configPanel == null) {
            _configPanel = new ConfigPanel(this, _userId, _setId);
        }
        if (!_configPanel.stage) {
            if (_furni.isConnected()) {
                _furni.showPopup("Configure the album viewer", _configPanel, 
                    ConfigPanel.WIDTH, _configPanel.height);
            } else {
                addChild(_configPanel);
            }
        }
    }

    public function removeConfigPanel () :void
    {
        if (_furni.isConnected()) {
            _furni.clearPopup();
        } else {
            removeChild(_configPanel);
        }
    }

    public function configPanelRemoved () :void
    {
        _configPanel = null;
    }

    /**
     * @return true if the configPanel should be removed.
     */
    public function checkPastedText (text :String) :Boolean
    {
        // if there's no text, just stop configuring
        if (text == "") {
            return true;
        }

        var result :Object;
        result = (new RegExp("flickr\\.com/photos/([^/]+)/sets/([^/]+)")).exec(text);
        if (result) {
            configureSource(result[1], result[2]);
            return true;
        }

        result = (new RegExp("flickr\\.com/photos/(.+?)\\@(...)/?$")).exec(text);
        if (result) {
            configureSource(result[1] + "@" + result[2]);
            return true;
        }

        result = (new RegExp("flickr\\.com/photos/([^/]*)")).exec(text);
        if (result) {
            _flickr.urls.lookupUser(text);
            return false;
        }

        result = (new RegExp("^(.+?)\\@(...)$")).exec(text);
        if (result) {
            configureSource(result[1] + "@" + result[2]);
            return true;
        }

        // otherwise, assume it's a username
        _flickr.people.findByUsername(text);
        return false;
    }

    protected function findPhotos () :void
    {
        if (_setId != null) {
            _flickr.photosets.getPhotos(_setId);

        } else if (_userId != null) {
            _flickr.people.getPublicPhotos(_userId, "", RESULTS_PER_PAGE, _nextPage);
        }
    }

//    protected function handleFindUsername (evt :FlickrResultEvent) :void
//    {
//        if (_shutdown) {
//            return;
//
//        } else if (!evt.success) {
//            _configPanel.setLabel("Failure identifying username " +
//                "[" + evt.data.error.errorMessage + "] Please try again.");
//            return;
//        }
//
//        removeConfigPanel();
//        configureSource(evt.data.user.nsid);
//    }

    protected function handleLookupUser (evt :FlickrResultEvent) :void
    {
        if (_shutdown) {
            return;

        } else if (!evt.success) {
            _configPanel.setLabel("Failure identifying user " +
                "[" + evt.data.error.errorMessage + "] Please try again.");
            return;
        }

        removeConfigPanel();
        configureSource(evt.data.user.nsid);
    }

    /**
     * Handle the photoset photo search results.
     */
    protected function handleGotSetPhotos (evt :FlickrResultEvent) :void
    {
        if (_shutdown) {
            return;

        } else if (!evt.success) {
            trace("Failure looking for photos " +
                "[" + evt.data.error.errorMessage + "]");
            return;
        }

        // save the metadata about photos
        _ourPhotos = evt.data.photoSet.photos;
        getNextPhotoUrl();
    }

    /**
     * Handle the people photo search results.
     */
    protected function handleGotPeoplePhotos (evt :FlickrResultEvent) :void
    {
        if (_shutdown) {
            return;

        } else if (!evt.success) {
            trace("Failure looking for photos " +
                "[" + evt.data.error.errorMessage + "]");
            return;
        }

        // save the metadata about photos
        var list :PagedPhotoList = evt.data.photos as PagedPhotoList;
        _ourPhotos = list.photos;
        if (list.pages > _nextPage) {
            _nextPage++;
        } else {
            _nextPage = 1;
        }

        getNextPhotoUrl();
    }

    /**
     * Get the next URL for photos that we ourselves have found via tags.
     */
    protected function getNextPhotoUrl () :void
    {
        if (_ourPhotos == null || _ourPhotos.length == 0) {
            _ourPhotos = null;
            // loop back around
            findPhotos();
            return;
        }

        var photo :Photo = (_ourPhotos.shift() as Photo);
        _nextPhotoLink = "http://www.flickr.com/photos/" + _userId + "/" + photo.id;
        //_nextPhotoLink = "http://www.flickr.com/photos/" + photo.ownerId + "/" + photo.id;
        _flickr.photos.getSizes(photo.id);
    }

    /**
     * Handle data arriving as a result of a getSizes() request.
     */
    protected function handlePhotoUrlKnown (evt :FlickrResultEvent) :void
    {
        if (_shutdown) {
            return;

        } else if (!evt.success) {
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
        if (_shutdown) {
            return;
        }

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
        var draw :Boolean = (event != null && event.type == MouseEvent.ROLL_OVER) &&
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

        _shutdown = true;
    }

    /** The interface through which we communicate with metasoy. */
    protected var _furni :FurniControl;

    /** The interface through which we make flickr API requests. */
    protected var _flickr :FlickrService;

    /** If true, we're shut down and should stop doing things. */
    protected var _shutdown :Boolean;

    /** The currently visible loader. */
    protected var _curLoader :Loader;

    /** Loads up photos for display. */
    protected var _nextLoader :Loader;

    /** Used for drawing UI on top of the photo. */
    protected var _overlay :Sprite;

    /** The photo metadata from the last photo search. */
    protected var _ourPhotos :Array;

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

    /** The next page of photos we should load. */
    protected var _nextPage :int;

    /** A button for editing users to configure this damn thing. */
    protected var _configBtn :SimpleTextButton;

    /** A label we use to prompt the user. */
    protected var _label :TextField;

    /** The place where a configuring user enters the flickr URL. */
    protected var _pasteEntry :TextField;

    protected var _configPanel :ConfigPanel;
}
}

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.ui.Keyboard;

import com.threerings.flash.SimpleTextButton;

class ConfigPanel extends Sprite
{
    public static const WIDTH :int = 350;

    public function ConfigPanel (av :AlbumViewer, userId :String, setId :String)
    {
        _av = av;

        var okBtn :SimpleTextButton = new SimpleTextButton("OK");
        okBtn.x = WIDTH - okBtn.width;
        okBtn.addEventListener(MouseEvent.CLICK, checkEntry);
        addChild(okBtn);

        // set up the pasteEntry
        _pasteEntry = new TextField();
        _pasteEntry.type = TextFieldType.INPUT;
        _pasteEntry.defaultTextFormat = new TextFormat(null, 16);
        _pasteEntry.text = "Wp"; // for measuring
        _pasteEntry.height = _pasteEntry.textHeight + 4;
        _pasteEntry.text = "";
        _pasteEntry.width = WIDTH - (okBtn.width + 5);
        _pasteEntry.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyEntry);

        // add a skin for the text entry area
        var entrySkin :DisplayObject = DisplayObject(new ENTRY_SKIN());
        entrySkin.width = _pasteEntry.width;
        entrySkin.height = _pasteEntry.height;
        addChild(entrySkin);
        addChild(_pasteEntry);

        // create the label
        _label = new TextField();
        _label.background = true;
        _label.backgroundColor = 0xFFFFFF;
        _label.autoSize = TextFieldAutoSize.LEFT;
        _label.wordWrap = true;
        _label.defaultTextFormat = new TextFormat(null, 16);
        _label.width = WIDTH;
        _label.y = Math.max(_pasteEntry.height, okBtn.height) + 1;
        addChild(_label);

        var prompt :String = "To configure this album viewer, enter a flickr username or the URL " +
            "of a public flickr photo album. The url should be in one " +
            "of the following formats: http://www.flickr.com/photos/[userId]/ or " +
            "http://www.flickr.com/photos/[userId]/sets/[photoSetId]/.";
        if (userId != null) {
            prompt += "\n\nCurrently displaying userId=" + userId;
            if (setId != null) {
                prompt += ", setId=" + setId;
            }
            prompt += ".";
        }
        setLabel(prompt);

        // listen for the end..
        addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
    }

    public function setLabel (text :String) :void
    {
        _label.text = text;
        _label.height = _label.textHeight + 4;
    }

    protected function handleKeyEntry (event :KeyboardEvent) :void
    {
        if (event.keyCode == Keyboard.ENTER) {
            checkEntry();
        }
    }

    protected function checkEntry (... ignored) :void
    {
        if (_av.checkPastedText(_pasteEntry.text)) {
            _av.removeConfigPanel();
        }
    }

    protected function handleRemovedFromStage (event :Event) :void
    {
        _av.configPanelRemoved();
    }

    protected var _av :AlbumViewer;

    protected var _label :TextField;
    protected var _pasteEntry :TextField;

    [Embed(source="skins.swf#textbox")]
    protected const ENTRY_SKIN :Class;
}
