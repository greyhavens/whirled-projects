package com.threerings.brawler.actor {

import flash.display.Sprite;

import com.threerings.util.ClassUtil;
import com.threerings.util.StringUtil;

import com.threerings.brawler.BrawlerController;
import com.threerings.brawler.BrawlerView;

/**
 * Represents an active element of the game.
 */
public class Actor extends Sprite
{
    /**
     * Creates an actor from the specified initial state.
     */
    public static function createActor (name :String, state :Object) :Actor
    {
        var aclass :Class = ClassUtil.getClassByName("com.threerings.brawler.actor." + state.type);
        var actor :Actor = new aclass();
        actor.name = name;
        return actor;
    }

    /**
     * Initializes the actor for display.
     *
     * @param state the initial state of the actor.
     */
    public function init (ctrl :BrawlerController, state :Object) :void
    {
        _ctrl = ctrl;
        _view = ctrl.view;
        _master = StringUtil.startsWith(name, "actor" + _ctrl.control.getMyId() + "_");

        // give subclasses a chance to set up
        didInit(state);

        // add to the view
        _view.addActor(this);

        // announce master copies
        maybePublish();
    }

    /**
     * Removes this actor from the dobj.
     */
    public function destroy () :void
    {
        _ctrl.throttle.send(function () :void {
            _ctrl.control.set(name, null);
        });
    }

    /**
     * Removes the actor from the view.
     */
    public function wasDestroyed () :void
    {
        _view.removeActor(this);
    }

    /**
     * Returns a reference to the bounds of this actor.
     */
    public function get bounds () :Sprite
    {
        return _bounds;
    }

    /**
     * Checks whether our location is "close enough" to the supplied coordinates.
     */
    public function locationEquals (x :Number, y :Number) :Boolean
    {
        return Math.abs(x - this.x) < EPSILON && Math.abs(y - this.y) < EPSILON;
    }

    /**
     * Finds the distance to the specified other actor.
     */
    public function distance (actor :Actor) :Number
    {
        var dx :Number = x - actor.x, dy :Number = y - actor.y;
        return Math.sqrt(dx*dx + dy*dy);
    }

    /**
     * Checks whether this actor represents a master copy: i.e., whether it represents the
     * definitive state as opposed to a representation of a remote master.
     */
    public function get master () :Boolean
    {
        return _master;
    }

    /**
     * Changes the master state of this actor.
     */
    public function set master (value :Boolean) :void
    {
        _master = value;
    }

    /**
     * For convenience, this method publishes the actor's state if and only if it is a master
     * copy.
     */
    public function maybePublish () :void
    {
        if (_master) {
            publish();
        }
    }

    /**
     * Decodes the state of this actor from the fields in the provided object.
     */
    public function decode (state :Object) :void
    {
        // set the location immediately
        _view.setPosition(this, state.x, state.y);
    }

    /**
     * Processes a message sent to this actor.
     */
    public function receive (message :Object) :void
    {
    }

    /**
     * Called by the view once per frame.
     *
     * @param elapsed the amount of time (in seconds) elapsed since the last update.
     */
    public function enterFrame (elapsed :Number) :void
    {
    }

    /**
     * Override to perform custom initialization.
     */
    protected function didInit (state :Object) :void
    {
        // by default, decode the mutable state
        decode(state);
    }

    /**
     * Publishes the state of this actor.
     */
    protected function publish () :void
    {
        setState(encode());
    }

    /**
     * Sets the state of this actor in the dobj.
     */
    protected function setState (state :Object) :void
    {
        // replace any existing state message from this actor
        _ctrl.throttle.send(function () :void {
            _ctrl.control.set(name, state);
        }, this);
    }

    /**
     * Sends a message to the remote instances of this actor.
     *
     * @param timeout if not equal to -1, the time after which the message will be discard if it
     * is throttled.
     */
    protected function send (message :Object, timeout :int = NORMAL_PRIORITY_TIMEOUT) :void
    {
        // send the message through the throttle with a timeout
        _ctrl.throttle.send(function () :void {
            _ctrl.control.sendMessage(name, message);
        }, null, timeout);
    }

    /**
     * Returns a new object containing the state of this actor.
     */
    protected function encode () :Object
    {
        var state :Object = new Object();
        state.type = ClassUtil.tinyClassName(this);
        state.x = x;
        state.y = y;
        return state;
    }

    /** The game controller. */
    protected var _ctrl :BrawlerController;

    /** The game view. */
    protected var _view :BrawlerView;

    /** Is this the master copy? */
    protected var _master :Boolean = false;

    /** The bounds of the actor. */
    protected var _bounds :Sprite;

    /** The timeout for low priority messages (ms). */
    protected static const LOW_PRIORITY_TIMEOUT :int = 2500;

    /** The timeout for normal priority messages. */
    protected static const NORMAL_PRIORITY_TIMEOUT :int = 5000;

    /** The timeout for high priority messages. */
    protected static const HIGH_PRIORITY_TIMEOUT :int = -1;

    /** Our threshold for coordinate equality. */
    protected static const EPSILON :Number = 0.5;
}
}
