//
// $Id$
//
// Camvatar - an avatar for Whirled

package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.StageScaleMode;

import flash.events.Event;
import flash.events.StatusEvent;
import flash.events.TimerEvent;

import flash.geom.Matrix;

import flash.media.Camera;
import flash.media.Video;

import flash.system.Security;
import flash.system.SecurityPanel;

import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;

import com.adobe.images.JPGEncoder;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.DataPack;

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
        _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessage);

        DataPack.load(_ctrl.getDefaultDataPack(), gotPack);

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

        _timer = new Timer(1, 1); // we will configure the delay before each use
        _timer.addEventListener(TimerEvent.TIMER, sendBytes);
        // don't start the timer yet

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

        checkSendBytes();
    }

    protected function checkSendBytes (event :Event = null) :void
    {
        if (!_inControl) {
            return;
        }
        const now :int = getTimer();
        const wait :int = _nextSend - now;
        if (wait <= 0) {
            sendBytes();
        } else {
            _timer.delay = wait;
            _timer.start();
        }
    }
     
    protected function takeSnap (event :Event = null) :void
    {
        if (_camera.muted) {
            trace("Camera muted");
            return;
        }

        // what is this webcam bug all about?
        _snapshot.draw(_video, new Matrix(_width / _oWidth, 0, 0, _height / _oHeight));

//        if (_video.x == 0) {
//            _video.x = 220;
//            _video.y = 20;
//            addChild(_video);
//        }

        // turn the image into a jpg
        _pageOfSend = 0;
        _outData = _encoder.encode(_snapshot);
        //_outData = PNGEncoder.encode(_snapshot);
        _outData.position = 0;
    }

    protected function sendBytes (event :Event = null) :void
    {
        if (_outData == null) {
            takeSnap();
            if (_outData == null) {
                return;
            }
//            trace("Data: " + _outData.length);
        }
        //trace("length: " + _outData.length + ", pos: " + _outData.position);

        // swipe off the next 1000 bytes with a 
        const toSend :int = Math.min(BYTES_PER_SEND, _outData.length - _outData.position);
        //trace("toSend: " + toSend);
        const newPosition :int = _outData.position + toSend;

        var tokens :int = NO_TOKENS;
        if (_pageOfSend == 0) {
            tokens |= START_TOKEN;
        }
        if (newPosition == _outData.length) {
            tokens |= END_TOKEN;
        }

        var outBytes :ByteArray = new ByteArray();
        //trace("tokens: " + tokens);
        outBytes.writeByte(tokens);
        outBytes.writeBytes(_outData, _outData.position, toSend);
        //trace("Out position: " + outBytes.position);
        _outData.position = newPosition;

        _ctrl.sendMessage(BYTES_KEY, outBytes);
        _nextSend = getTimer() + MIN_SEND_WAIT;
        _pageOfSend++;

        if (newPosition == _outData.length) {
            _outData = null;
        }

        // Then, just wait for the message to come back to us before sending another...
    }

    protected function handleMessage (event :ControlEvent) :void
    {
        if (event.name == BYTES_KEY) {
            handleBytes(event.value as ByteArray);
        }
    }

    protected function handleBytes (inBytes :ByteArray) :void
    {
        //trace("Got inBytes: " + inBytes.position + " of " + inBytes.length);
        const tokens :int = inBytes.readByte();
        if ((tokens & START_TOKEN) != NO_TOKENS) {
            _inData = new ByteArray();
        }
        if (_inData == null) {
            return; // we need to wait for a start
        }
        inBytes.readBytes(_inData, _inData.position);
        _inData.position += inBytes.length - 1;
        //trace("read some bytes, now positions are inBytes: " + inBytes.position +
        //    ", inData: " + _inData.position);
        if ((tokens & END_TOKEN) != NO_TOKENS) {
            _inData.position = 0;
            _nextLoader.loadBytes(_inData);
            _inData = null; // await the next picture
        }

        checkSendBytes();
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

    /**
     * This is called when your avatar is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        // stop any sounds, clean up any resources that need it.  This specifically includes 
        // unregistering listeners to any events - especially Event.ENTER_FRAME
        if (_timer != null) {
            _timer.stop();
        }
        _inControl = false;
    }

    protected static const BYTES_KEY :String = "";

    protected static const BYTES_PER_SEND :int = 1000;

    protected static const MIN_SEND_WAIT :int = 250;

    protected static const NO_TOKENS :int = 0;
    protected static const START_TOKEN :int = 1 << 0;
    protected static const END_TOKEN :int = 1 << 1;

    protected var _config :Boolean;
    protected var _width :int;
    protected var _height :int;
    protected var _oWidth :int;
    protected var _oHeight :int;
    protected var _quality :Number;

    protected var _inControl :Boolean;

    protected var _loader :Loader;

    protected var _nextLoader :Loader;

    protected var _ctrl :AvatarControl;

    protected var _encoder :JPGEncoder;

    protected var _timer :Timer;

    protected var _video :Video;

    protected var _camera :Camera;

    protected var _inData :ByteArray;

    protected var _outData :ByteArray;

    protected var _snapshot :BitmapData; 

    protected var _nextSend :int;
    protected var _pageOfSend :int;
}
}
