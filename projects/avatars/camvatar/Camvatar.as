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
import flash.events.TimerEvent;

import flash.geom.Matrix;

import flash.media.Camera;
import flash.media.Video;

import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;

import com.adobe.images.JPGEncoder;
import com.adobe.images.PNGEncoder;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

import com.whirled.contrib.PreferredCamera;

[SWF(width="104", height="78")]
public class Camvatar extends Sprite
{
    public static const WID :int = 104;
    public static const HEI :int = 78;

    public function Camvatar ()
    {
        trace("init");

        _ctrl = new AvatarControl(this);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);
        _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessage);

        _loader = new Loader();
        addChild(_loader);

        if (_ctrl.hasControl()) {
            initSending();
        } else {
            _ctrl.addEventListener(ControlEvent.GOT_CONTROL, initSending);
            _ctrl.requestControl();
        }
    }

    protected function initSending (... ignored) :void
    {
        trace("init sending...");
        _inControl = true;
        _camera = PreferredCamera.getPreferredCamera(_ctrl);
        if (_camera == null) {
            trace("Got no camera");
            return;
        }

        _camera.addEventListener(StatusEvent.STATUS, checkSendBytes);

        _snapshot = new BitmapData(WID, HEI, false);

        //_camera.setMode(WID, HEI, 30);
        _video = new Video();
        _video.width = _camera.width;
        _video.height = _camera.height;
        _video.attachCamera(_camera);

        trace("Camera w/h: " + _camera.width + ", " + _camera.height);

        _encoder = new JPGEncoder();

//        addChild(_video);

        _timer = new Timer(1, 1); // we will configure the delay before each use
        _timer.addEventListener(TimerEvent.TIMER, sendBytes);
        // don't start the timer yet

        // kick things off
        sendBytes();
    }

    protected function takeSnap (event :Event = null) :void
    {
        if (_camera.muted) {
            return;
        }

        // what is this webcam bug all about?
        _snapshot.draw(_video, new Matrix(WID / 160, 0, 0, HEI / 120));

        // turn the image into a jpg
        _pageOfSend = 0;
        _outData = _encoder.encode(_snapshot);
        //_outData = PNGEncoder.encode(_snapshot);
        _outData.position = 0;
    }

    protected function checkSendBytes (event :Event = null) :void
    {
        const now :int = getTimer();
        const wait :int = _nextSend - now;
        if (wait <= 0) {
            sendBytes();
        } else {
            _timer.delay = wait;
            _timer.start();
        }
    }
     

    protected function sendBytes (event :Event = null) :void
    {
        if (_outData == null) {
            takeSnap();
            if (_outData == null) {
                return;
            }
        }
        trace("length: " + _outData.length + ", pos: " + _outData.position);

        // swipe off the next 1000 bytes with a 
        const toSend :int = Math.min(BYTES_PER_SEND, _outData.length - _outData.position);
        trace("toSend: " + toSend);
        const newPosition :int = _outData.position + toSend;

        var tokens :int = NO_TOKENS;
        if (_pageOfSend == 0) {
            tokens |= START_TOKEN;
        }
        if (newPosition == _outData.length) {
            tokens |= END_TOKEN;
        }

        var outBytes :ByteArray = new ByteArray();
        trace("tokens: " + tokens);
        outBytes.writeByte(tokens);
        outBytes.writeBytes(_outData, _outData.position, toSend);
        trace("Out position: " + outBytes.position);
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
        trace("Got inBytes: " + inBytes.position + " of " + inBytes.length);
        const tokens :int = inBytes.readByte();
        trace("Got inBytes: " + inBytes.position + " of " + inBytes.length);
        if ((tokens & START_TOKEN) != NO_TOKENS) {
            _inData = new ByteArray();
        }
        if (_inData == null) {
            return; // we need to wait for a start
        }
        inBytes.readBytes(_inData, _inData.position);
        _inData.position += inBytes.length - 1;
        trace("read some bytes, now positions are inBytes: " + inBytes.position +
            ", inData: " + _inData.position);
        if ((tokens & END_TOKEN) != NO_TOKENS) {
            _loader.unload();
            _inData.position = 0;
            _loader.loadBytes(_inData);
            _inData = null; // await the next picture
        }

        if (_inControl) {
            checkSendBytes();
        }
    }

    /**
     * This is called when your avatar is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        // stop any sounds, clean up any resources that need it.  This specifically includes 
        // unregistering listeners to any events - especially Event.ENTER_FRAME
        _timer.stop();
        _inControl = false;
    }

    protected static const BYTES_KEY :String = "";

    protected static const BYTES_PER_SEND :int = 1000;

    protected static const MIN_SEND_WAIT :int = 250;

    protected static const NO_TOKENS :int = 0;
    protected static const START_TOKEN :int = 1 << 0;
    protected static const END_TOKEN :int = 1 << 1;

    protected var _inControl :Boolean;

    protected var _loader :Loader;

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
