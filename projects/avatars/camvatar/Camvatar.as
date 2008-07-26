//
// $Id$
//
// Camvatar - an avatar for Whirled

package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.StatusEvent;

import flash.geom.Matrix;

import flash.media.Camera;
import flash.media.Video;

import flash.system.Security;
import flash.system.SecurityPanel;

import flash.utils.ByteArray;

import com.adobe.images.JPGEncoder;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.DataPack;

import com.whirled.contrib.Chunker;

[SWF(width="600", height="450")]
public class Camvatar extends Sprite
{
    public function Camvatar ()
    {
        //trace("init");
        _loader = new Loader();
        _nextLoader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderComplete);
        _nextLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderComplete);
        addChild(_loader);

        _ctrl = new AvatarControl(this);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);

        // initialize the chunker that takes care of sending our data between instances
        _chunker = new Chunker(_ctrl, "", chunkReceived);

        DataPack.load(_ctrl.getDefaultDataPack(), gotPack);

        _suspended = (this.stage == null);
        addEventListener(Event.ADDED_TO_STAGE, handleAddRemove);
        addEventListener(Event.REMOVED_FROM_STAGE, handleAddRemove);

        if (_ctrl.hasControl()) {
            initSending();
        } else {
            _ctrl.addEventListener(ControlEvent.GOT_CONTROL, initSending);
            _ctrl.requestControl();
        }
    }

    protected function gotPack (pack :DataPack) :void
    {
        //trace("got pack");
        _config = pack.getBoolean("showCameraConfig");
        _width = pack.getNumber("width");
        _height = pack.getNumber("height");
        _oWidth = pack.getNumber("camWidth");
        _oHeight = pack.getNumber("camHeight");
        _quality = pack.getNumber("quality");

        _ctrl.setHotSpot(_width / 2, _height, _height + 10);

        initSending();
    }

    protected function initSending (... ignored) :void
    {
        if (!_ctrl.hasControl() || _width == 0) {
            //trace("init:abort:" + _width);
            return;
        }

        if (_config) {
            Security.showSettings(SecurityPanel.CAMERA);
        }

        //trace("init sending...");
        _inControl = true;
        _camera = _ctrl.getCamera();
        if (_camera == null) {
            trace("Got no camera");
            return;
        }
        //trace("Camera w/h: " + _camera.width + ", " + _camera.height);
        //trace("Camera setting to: " + _width + ", " + _height);

        _camera.addEventListener(StatusEvent.STATUS, gotStatus);

        _encoder = new JPGEncoder(_quality);

//        addChild(_video);

        // kick things off
        gotStatus(); // try it
    }


    protected function gotStatus (... ignored) :void
    {
        _camera.setMode(_width, _height, _camera.fps);

        if (_video != null) {
            _video.clear();
            if (_video.x != 0) {
                removeChild(_video);
            }
        }

        _video = new Video();
        _video.width = _width; // _camera.width;
        _video.height = _height; // _camera.height;
        _video.attachCamera(_camera);

        _snapshot = new BitmapData(_video.width, _video.height, false);
//        var bmp :Bitmap = new Bitmap(_snapshot);
//        bmp.x = 400;
//        addChild(bmp);

        checkSend();
    }

    protected function checkSend () :void
    {
        if (!_inControl || _suspended) {
            return;
        }
        if (_camera.muted) {
            trace("Camera muted");
            return;
        }

        // what is this webcam bug all about?
        _snapshot.draw(_video, new Matrix(_width / _oWidth, 0, 0, _height / _oHeight));

// Doesn't work?!
//        var allWhite :Boolean = true;
//        for (var yy :int = 0; yy < _snapshot.height; yy++) {
//            for (var xx :int = 0; xx < _snapshot.width; xx++) {
//                if (_snapshot.getPixel(xx, yy) != 0xFFFFFF) {
//                    allWhite = false;
//                    break;
//                }
//            }
//        }
//        if (allWhite) {
//            return;
//        }

//        if (_video.x == 0) {
//            _video.x = 220;
//            _video.y = 20;
//            addChild(_video);
//        }

        // turn the image into a jpg
        _chunker.send(_encoder.encode(_snapshot));
    }

    protected function chunkReceived (data :Object) :void
    {
        _nextLoader.loadBytes(data as ByteArray);
        checkSend();
    }

    protected function handleLoaderComplete (event :Event) :void
    {
        addChild(_nextLoader);
        _loader.unload();
        removeChild(_loader);
        var tmp :Loader = _loader;
        _loader = _nextLoader;
        _nextLoader = tmp;
    }

    protected function handleAddRemove (event :Event) :void
    {
        _suspended = (event.type == Event.REMOVED_FROM_STAGE);
        //trace("Now suspended: " + _suspended);
        checkSend();
    }

    /**
     * This is called when your avatar is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        // stop any sounds, clean up any resources that need it.  This specifically includes 
        // unregistering listeners to any events - especially Event.ENTER_FRAME
        _inControl = false;
    }

    protected var _config :Boolean;
    protected var _width :int;
    protected var _height :int;
    protected var _oWidth :int;
    protected var _oHeight :int;
    protected var _quality :Number;

    protected var _inControl :Boolean;
    protected var _suspended :Boolean;

    protected var _loader :Loader;

    protected var _nextLoader :Loader;

    protected var _ctrl :AvatarControl;

    protected var _encoder :JPGEncoder;

    protected var _video :Video;

    protected var _camera :Camera;

    protected var _snapshot :BitmapData; 

    protected var _chunker :Chunker;
}
}
