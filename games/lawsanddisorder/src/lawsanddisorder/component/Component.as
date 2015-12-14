package lawsanddisorder.component {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.Timer;

import lawsanddisorder.Context;

/**
 * Primary class that all sprites extend
 */
public class Component extends Sprite
{
    /**
     * Constructor
     */
    public function Component (ctx :Context)
    {
        _ctx = ctx;
        initDisplay();
        updateDisplay();
        
        moveTimer.addEventListener(TimerEvent.TIMER, animateFrameEntered);
    }

    /**
     * Check this object and its children against a target and return true if there is
     * a match.
     */
    public function isTarget (target :DisplayObject) :Boolean
    {
        if (this == target) {
            return true;
        }
        if (this.contains(target)) {
            return true;
        }
        return false;
    }

    /**
     * Bring a child component above other siblings.
     */
    public function bringToFront (child :DisplayObject) :void
    {
        if (!contains(child)) {
            _ctx.error("component doesn't contain child in bringToFrong");
            return;
        }
        var topChild :DisplayObject = getChildAt(numChildren-1);
        swapChildren(child, topChild);
    }
    
    /**
     * Move a sprite across the board from one point to another.
     */
    public function animateMove (
        fromPoint :Point, toPoint :Point, doneListener :Function = null) :void
    {
        fromPoint = _ctx.board.globalToLocal(fromPoint);
        toPoint = _ctx.board.globalToLocal(toPoint);
        
        this.x = fromPoint.x;
        this.y = fromPoint.y;
        this.moveToPoint = toPoint;
        this.moveDoneListener = doneListener;
        
        _ctx.board.addChild(this);
        // start up a timer for max animation time of one second
        moveTimer.start();
        addEventListener(Event.ENTER_FRAME, animateFrameEntered);
    }
    
    /**
     * Perform one step of the animation.
     */
    protected function animateFrameEntered (event :Event) :void
    {
        if (moveToPoint == null) {
            return;
        }
        this.x += (moveToPoint.x - this.x)/4;
        this.y += (moveToPoint.y - this.y)/4;
        
        if (event is TimerEvent 
            || Math.abs(x - moveToPoint.x) < 1 || Math.abs(y - moveToPoint.y) < 1) {
            moveTimer.stop();
            removeEventListener(Event.ENTER_FRAME, animateFrameEntered);
            if (_ctx.board.contains(this)) {
                _ctx.board.removeChild(this);
            }
            if (moveDoneListener != null) {
                moveDoneListener();
            }
            moveToPoint = null;
            moveDoneListener = null;
        }
    }

    /**
     * Display static graphics
     */
    protected function initDisplay () :void
    {
        // abstract method
    }

    /**
     * Change display of dynamic graphics
     */
    protected function updateDisplay () :void
    {
        // abstract method
    }

    /** Main game logic */
    protected var _ctx :Context;
    
    /** When animating, this is the destination point on the board */
    protected var moveToPoint :Point;
    
    /** When animation, this is the function to call when destination reached */
    protected var moveDoneListener :Function;
    
    /** When moving, this determines the maximum animation time */
    protected var moveTimer :Timer = new Timer(1000);
}
}