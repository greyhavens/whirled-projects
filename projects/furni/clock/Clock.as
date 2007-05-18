//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.geom.Point;

import flash.events.Event;
import flash.events.KeyboardEvent;

import com.whirled.DataPack;

//[SWF(width="300", height="300")] // data1
//[SWF(width="200", height="200")] // data2
[SWF(width="193", height="400")] // brittney
public class Clock extends Sprite
{
    public function Clock ()
    {
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _dataPack = new DataPack(
            "http://tasman.sea.earth.threerings.net:8080/ClockPack.dpk");
        _dataPack.addEventListener(Event.COMPLETE, handleDataPackLoaded);
    }

    protected function handleDataPackLoaded (... ignored) :void
    {
        _dataPack.getDisplayObjects(
            ["face", "hourHand", "minuteHand", "secondHand", "decoration"],
            gotDisplayObjects);
    }

    protected function gotDisplayObjects (disps :Object) :void
    {
        configureContent(disps);
        updateDisplayedTime();

        addEventListener(Event.ENTER_FRAME, handleEnterFrame)
    }

    /**
     * Take care of releasing resources when we unload.
     */
    protected function handleUnload (event :Event) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleEnterFrame);

        if (_dataPack) {
            _dataPack.close();
            _dataPack = null;
        }
    }

    /**
     * Update the position of each hand of the clock every frame.
     */
    protected function handleEnterFrame (evt :Event) :void
    {
        updateDisplayedTime();
    }

    /**
     * Configure the clock face and hands.
     */
    protected function configureContent (disps :Object) :void
    {
        var center :Point;

        // configure the clock's face
        var face :DisplayObject = disps["face"] as DisplayObject;
        if (face != null) {
            addChild(face);

            var faceCenter :Point = _dataPack.getPoint("faceCenter");
            if (faceCenter != null) {
                center = faceCenter;

            } else {
                center = new Point(face.width/2, face.height/2);
            }

        } else {
            trace("No clock face provided");
            center = new Point();
        }

        var facePos :Point = _dataPack.getPoint("facePosition");
        if (facePos != null) {
            face.x = facePos.x;
            face.y = facePos.y;
            center = center.add(facePos);
        }

        _hourHand = configureHand(disps, "hour", center);
        _minuteHand = configureHand(disps, "minute", center);
        _secondHand = configureHand(disps, "second", center);
        _smoothSeconds = _dataPack.getBoolean("smoothSeconds");

        var decor :DisplayObject = disps["decoration"] as DisplayObject;
        if (decor != null) {
            var decorPos :Point = _dataPack.getPoint("decorationPoint");
            if (decorPos != null) {
                decor.x = decorPos.x;
                decor.y = decorPos.y;

            } else {
                decor.x = center.x;
                decor.y = center.y;
            }
            addChild(decor);
        }

        // and now we're done with the datapack
        _dataPack = null;
    }

    /**
     * Update the time. Called every frame.
     */
    protected function updateDisplayedTime () :void
    {
        var d :Date = new Date();

        updateHand(_hourHand,
            (d.hours % 12) * 60 * 60 + (d.minutes * 60) + d.seconds,
            12 * 60 * 60);
        updateHand(_minuteHand,
            (d.minutes * 60) + d.seconds, 60 * 60);

        // the second hand is optional
        if (_secondHand != null) {
            if (_smoothSeconds) {
                updateHand(_secondHand,
                    (d.seconds * 1000) + d.milliseconds, 60000);
            } else {
                updateHand(_secondHand, d.seconds, 60);
            }
        }
    }

    /**
     * Update the rotation of the specified hand.
     */
    protected function updateHand (
        hand :DisplayObject, current :Number, total :Number) :void
    {
        hand.rotation = (current * 360) / total;
    }

    /**
     * Find and configure the specified hand's display object.
     */
    protected function configureHand (
        disps :Object, name :String, center :Point, optional :Boolean = false)
        :DisplayObject
    {
        var hand :DisplayObject = disps[name + "Hand"] as DisplayObject;
        if (hand != null) {
            var point :Point = _dataPack.getPoint(name + "Point");
            if (point != null) {
                // create a wrapper for the hand so that we can apply the offset
                var wrap :Sprite = new Sprite();
                hand.x = -point.x;
                hand.y = -point.y;
                wrap.addChild(hand);

                wrap.x = center.x;
                wrap.y = center.y;

                addChild(wrap);
                // our caller doesn't need to know that it's getting
                // the wrapper
                return wrap;

            } else {
                trace("No " + name + " point specified.");
            }

        } else if (!optional) {
            trace("No " + name + " hand provided");
        }
        return null;
    }

    protected var _dataPack :DataPack;

    /** The hours hand. */
    protected var _hourHand :DisplayObject;

    /** The minutes hand. */
    protected var _minuteHand :DisplayObject;

    /** The seconds hand. */
    protected var _secondHand :DisplayObject;

    /** Whether we're smoothing the second hand, or ticking it. */
    protected var _smoothSeconds :Boolean;
}
}
