//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.geom.Point;

import flash.events.Event;
import flash.events.KeyboardEvent;

//import com.whirled.RemixUtil;

//[SWF(width="300", height="300")] // data1
//[SWF(width="200", height="200")] // data2
[SWF(width="193", height="400")] // brittney
public class Clock extends Sprite
{
    public function Clock ()
    {
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        configureContent();
        updateDisplayedTime();

        addEventListener(Event.ENTER_FRAME, handleEnterFrame)
    }

    /**
     * Take care of releasing resources when we unload.
     */
    protected function handleUnload (event :Event) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
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
    protected function configureContent () :void
    {
        var center :Point;

        // configure the clock's face
        var face :DisplayObject = getDisplayResource("face");
        if (face != null) {
            addChild(face);

            var faceCenter :Point = RemixUtil.getPoint("faceCenter", Data.data);
            if (faceCenter != null) {
                center = faceCenter;

            } else {
                center = new Point(face.width/2, face.height/2);
            }

        } else {
            trace("No clock face provided");
            center = new Point();
        }

        // TODO: remove, size is something to be applied to the overall swf
        var size :Point = RemixUtil.getPoint("size", Data.data);
        if (size != null) {
            //var size :Array = (content.size as Array);
            //width = int(size[0]);
            //height = int(size[1]);
        }

        var facePos :Point = RemixUtil.getPoint("facePosition", Data.data);
        trace("facePos: " + facePos);
        if (facePos != null) {
            face.x = facePos.x;
            face.y = facePos.y;
            center = center.add(facePos);
        }

        _hourHand = configureHand("hour", center);
        _minuteHand = configureHand("minute", center);
        _secondHand = configureHand("second", center);
        _smoothSeconds = RemixUtil.getBoolean("smoothSeconds", Data.data);

        var decor :DisplayObject = getDisplayResource("decoration");
        if (decor != null) {
            var decorPos :Point = RemixUtil.getPoint("decorationPoint", Data.data);
            if (decorPos != null) {
                decor.x = decorPos.x;
                decor.y = decorPos.y;

            } else {
                decor.x = center.x;
                decor.y = center.y;
            }
            addChild(decor);
        }
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
     * Get an instance of DisplayObject specified by the class with the
     * specified name in the content pack.
     */
    protected function getDisplayResource (name :String) :DisplayObject
    {
        if (name in Data) {
            var prop :Object = Data[name];
            if (prop is DisplayObject) {
                return (prop as DisplayObject);

            } else if (prop is Class) {
                var c :Class = (prop as Class);
                return (new c() as DisplayObject);
            }
        }
        return null;
    }

    /**
     * Find and configure the specified hand's display object.
     */
    protected function configureHand (
        name :String, center :Point, optional :Boolean = false) :DisplayObject
    {
        var hand :DisplayObject = getDisplayResource(name + "Hand");
        if (hand != null) {
            var point :Point = RemixUtil.getPoint(name + "Point", Data.data);
            if (point != null) {
                // create a wrapper for the hand so that we can apply the offset
                var wrap :Sprite = new Sprite();
                hand.x = -point.x;
                hand.y = -point.y;
                wrap.addChild(hand);

                wrap.x = center.x;
                wrap.y = center.y;

                trace("Added wrapped hand '" + name + "', at " + (-point.x) + ", " + (-point.y));
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
