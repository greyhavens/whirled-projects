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
        _owner = parseInt(name.substring(5, name.indexOf("_")));

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
        _destroyed = true;
        _ctrl.destroyActor(this);
        _ctrl.throttle.set(name, null);
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
     * Returns the player id of the owner of this actor.
     */
    public function get owner () :int
    {
        return _owner;
    }

    /**
     * Changes the player id of the owner of this actor.
     */
    public function set owner (value :int) :void
    {
        _owner = value;
    }

    /**
     * Checks whether this actor represents a master copy: i.e., whether it represents the
     * definitive state as opposed to a representation of a remote master.
     */
    public function get amOwner () :Boolean
    {
        return _owner == _ctrl.control.game.getMyId();
    }

    /**
     * For convenience, this method publishes the actor's state if and only if it is a master
     * copy.
     */
    public function maybePublish () :void
    {
        if (amOwner) {
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
        if (_destroyed) {
            return;
        }
        _ctrl.throttle.set(name, state);
    }

    /**
     * Sends a message to the remote instances of this actor.
     */
    protected function send (message :Object) :void
    {
        // send the message through the throttle
        if (_destroyed) {
            return;
        }
        message.sender = _ctrl.control.game.getMyId();
        _ctrl.throttle.sendMessage(name, message);
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
        state.sender = _ctrl.control.game.getMyId();
        return state;
    }

    /** The game controller. */
    protected var _ctrl :BrawlerController;

    /** The game view. */
    protected var _view :BrawlerView;

    /** The player id of the owner of this actor. */
    protected var _owner :int;

    /** The bounds of the actor. */
    protected var _bounds :Sprite;

    /** Set when the actor is destroyed to make sure that no further updates are transmitted. */
    protected var _destroyed :Boolean = false;

    /** Our threshold for coordinate equality. */
    protected static const EPSILON :Number = 0.5;
}
}
