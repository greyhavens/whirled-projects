//
// $Id$
//
// Camvatar - an avatar for Whirled

package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.geom.Matrix;

import flash.media.Camera;
import flash.media.Video;

import flash.utils.Timer;

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
        // listen for an unload event
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _ctrl = new AvatarControl(this);

        _data = new BitmapData(WID, HEI, false);
        _image = new Bitmap(_data);
        addChild(_image);

        _camera = PreferredCamera.getPreferredCamera(_ctrl);
        if (_camera == null) {
            trace("Got no camera");
            return;
        }

        //_camera.setMode(WID, HEI, 30);
        _video = new Video();
        _video.width = _camera.width;
        _video.height = _camera.height;
        _video.attachCamera(_camera);

        trace("Camera w/h: " + _camera.width + ", " + _camera.height);

//        addChild(_video);

        _timer = new Timer(1000);
        _timer.addEventListener(TimerEvent.TIMER, updateFrame);
        _timer.start();
        //addEventListener(Event.ENTER_FRAME, updateFrame);
    }

    protected function updateFrame (event :Event) :void
    {
        // fucking unbelievable flash bugs. Unbelievable. I cannot believe they ship these bugs.
        _data.draw(_video, new Matrix(WID / 160, 0, 0, HEI / 120));

        var brightness :uint;

        // now go through the data and massage every pixel to black or white
        var total :Number = 0;
        for (var yy :int = 0; yy < HEI; yy++) {
            for (var xx :int = 0; xx < WID; xx++) {
                var pixel :uint = _data.getPixel(xx, yy);
                // the brightness is the maximum of the 3 color channels
                brightness = Math.max(Math.max(pixel & 0xFF, (pixel >> 8) & 0xFF),
                    (pixel >> 16) & 0xFF);
                _data.setPixel(xx, yy, brightness);
                total += brightness;
            }
        }

        var mean :Number = total / (WID * HEI);
        trace("total: " + total + ", mean: " + mean);

        for (var yy :int = 0; yy < HEI; yy++) {
            for (var xx :int = 0; xx < WID; xx++) {
                brightness = _data.getPixel(xx, yy);
                _data.setPixel(xx, yy, brightness > mean ? 0xFFFFFF : 0x000000);
            }
        }
//                var pix :uint;
//                if (max > 192) {
//                    pix = 0xFFFFFF;
//                } else if (max > 128) {
//                    pix = 0xBBBBBB;
//                } else if (max > 64) {
//                    pix = 0x666666;
//                } else {
//                    pix = 0x000000;
//                }
//                _data.setPixel(xx, yy, pix); //max > 127 ? 0xFFFFFF : 0x000000);
//            }
//        }
    }

    /**
     * This is called when your avatar is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        // stop any sounds, clean up any resources that need it.  This specifically includes 
        // unregistering listeners to any events - especially Event.ENTER_FRAME
        _timer.stop();
        removeEventListener(Event.ENTER_FRAME, updateFrame);
    }

    protected var _ctrl :AvatarControl;

    protected var _timer :Timer;

    protected var _video :Video;

    protected var _camera :Camera;

    protected var _image :Bitmap; 
    protected var _data :BitmapData; 
}
}
