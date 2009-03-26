//
// $Id$

package {

import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.Random;
import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.Point;

/**
 * Manages an Avatar's visualization and animation state.
 */
public class NewBody
{
    /** Use this to log things. */
    public static var log :Log = Log.getLog(NewBody);

    /**
     * Creates a NewBody that will manipulate the supplied MovieClip to animate the avatar. It will
     * use the supplied control to adjust the avatar's attachment to the floor (hotspot). The
     * caller should attach the supplied media to the display hierarchy, the NewBody will simply
     * select scenes in the supplied MovieClip.
     *
     * @param width the width of the "stage" on which your MovieClip was built.
     * @param height the height above the hotspot identifier to display the avatar's name.
     */
    public function NewBody (ctrl :AvatarControl, media :MovieClip, width :int, height :int = -1)
    {
        // register to hear when we start and stop walking
        _ctrl = ctrl;
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);
        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, function (event :ControlEvent) :void {
            triggerAction(event.name);
        });
        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, function (event :ControlEvent) :void {
            switchToState(event.name);
        });
        _ctrl.addEventListener(Event.UNLOAD, function (event :Event) :void {
            shutdown();
        });

        _media = media;
        _media.addEventListener(Event.ADDED_TO_STAGE, handleAddRemove);
        _media.addEventListener(Event.REMOVED_FROM_STAGE, handleAddRemove);
        if (_media.stage != null) {
            // register a frame callback so that we can manage our animations
            _media.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        _mediaWidth = width;
        _mediaHeight = height;

        // Discover all the movies in the media's first frame
        var movieChildren :Array = [];
        var movie :MovieClip;
        for (var ii :int = 0; ii < _media.numChildren; ++ii) {
            movie = _media.getChildAt(ii) as MovieClip;
            if (movie != null) {
                log.info("Found movie", "name", getMovieName(movie));
                movieChildren.push(movie);
            }
        }

        // we'll keep track of all known states and actions
        var states :Array = [];
        var actions :Array = [];

        // map our scenes by name; we support the following types of scenes:
        // (state|action)_NAME(_N.W)
        // state_NAME_(walking|sleeping)(_N.W)
        // state_NAME_(towalking|tosleeping|fromwalking|fromsleeping)
        // NAME_to_NAME
        for each (movie in movieChildren) {
            _media.removeChild(movie);
            registerMovie(movie, states, actions);
        }

        if (actions.length > 0) {
            _ctrl.registerActions(actions);
        }
        if (states.length > 1) { // no point in registering just one state, we'll always be in it
            _ctrl.registerStates(states);
        }

        var startState :String = null;
        if (_ctrl.isConnected()) {
            startState = _ctrl.getState();
        }
        if (startState == null) {
            startState = "default";
        }

        switchToState(startState);
        appearanceChanged(null);
    }

    /**
     * Switches to a new state, using a transition animation if possible.
     */
    public function switchToState (state :String) :void
    {
        const stateScene :MovieList = getMovie("state_" + state);
        if (stateScene == null) {
            return; // ignore it
        }

        log.info("I'm transitioning to '" + state + "'.");
        // transtion from our current state to the new state
        queueTransitions(_state, state);
        // update our internal state variable
        _state = state;
        // queue our new standing animation
        queueMovie(stateScene);
    }

    /**
     * Triggers an action animation, using transition animations if possible.
     */
    public function triggerAction (action :String) :void
    {
        const actionScene :MovieList = getMovie("action_" + action);
        if (actionScene == null) {
            return; // ignore it
        }

        log.info("I'm triggering action '" + action + "'.");
        // transition from our current state to the action
        queueTransitions(_state, action);
        // play the action animation
        queueMovie(actionScene);
        // then transition back to our current state
        queueTransitions(action, _state);
        // and queue our standing animation
        queueMovie(getMovie("state_" + _state));
    }

    /**
     * Returns true if we're currently transitioning between states.
     */
    public function inTransition () :Boolean
    {
        return (_movieQueue.length > 0);
    }

    /**
     * Cleans up after our NewBody, unregistering listeners, etc. Your subclass
     * should also stop any timers, or do anything else needed.
     */
    public function shutdown () :void
    {
        _media.removeEventListener(Event.ADDED_TO_STAGE, handleAddRemove);
        _media.removeEventListener(Event.REMOVED_FROM_STAGE, handleAddRemove);
        // this may already be unregistered, but this won't hurt
        _media.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    protected function getMovieName (movie :MovieClip) :String
    {
        return ClassUtil.getClassName(movie);
    }

    protected function registerMovie (movie :MovieClip, states :Array, actions :Array) :void
    {
        var movieName :String = getMovieName(movie);
        var bits :Array = movieName.split("_");
        if (bits.length < 2) {
            log.warning("Invalid movie name [movie=" + movieName + "].");
            return;
        }

        var loc :Point = new Point(movie.x, movie.y);

        if (bits.length == 3 && String(bits[1]) == "to") { // NAME_to_NAME
            _movies.put(movieName.toLowerCase(), new MovieList(movieName, movie, loc));
            return;
        }

        // see if we have a weight specification
        var weight :int = 1, number :int = 1;
        var wstr :String = String(bits[bits.length-1]);
        if (wstr.match("[0-9]+(\.[0-9]+)")) {
            var cidx :int = wstr.indexOf(".");
            if (cidx != -1) {
                number = int(wstr.substring(0, cidx));
                weight = int(wstr.substring(cidx+1));
            } else {
                number = int(wstr);
            }
            bits.pop();
        }

        var key :String;
        var type :String = String(bits[0]);
        var name :String = String(bits[1]);
        if (type == "action") {
            key = type + "_" + name;
            if (actions.indexOf(name) == -1) {
                actions.push(name);
            }

        } else if (type == "state") {
            if (bits.length < 3) {
                key = type + "_" + name;
            } else {
                var mode :String = String(bits[2]);
                if (mode != "walking" && mode != "towalking" && mode != "fromwalking" &&
                    mode != "sleeping" && mode != "tosleeping" && mode != "fromsleeping") {
                    log.warning("Invalid mode [movie=" + movieName + ", mode=" + mode + "].");
                    return;
                }
                key = type + "_" + name + "_" + mode;
            }
            if (states.indexOf(name) == -1) {
                states.push(name);
            }

        } else {
            log.warning("Invalid type [movie=" + movieName + "].");
            return;
        }

        log.info("Registering movie " + key + " [weight=" + weight + ", num=" + number + "].");
        var list :MovieList = getMovie(key);
        if (list == null) {
            _movies.put(key.toLowerCase(), new MovieList(key, movie, loc, weight));
        } else {
            list.addMovie(movie, loc, weight);
        }
    }

    /**
     * Handles the _media being added or removed from the stage.
     */
    protected function handleAddRemove (event :Event) :void
    {
        if (event.type == Event.ADDED_TO_STAGE) {
            _media.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            // and call it now to update it immediately
            onEnterFrame(event);

        } else {
            _media.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
    }

    protected function onEnterFrame (event :Event) :void
    {
        if (_media == null || _playing == null) {
            return;
        }

        if ((_curMovie != _playing.current) ||
            (_curMovie != null && _curMovie.currentFrame == _curMovie.totalFrames)) {

            // Get the next scene
            if (_movieQueue.length > 0) {
                _playing = (_movieQueue.shift() as MovieList);
            } else {
                _playing.update();
            }

            if (_playing.current != _curMovie) {
                // Remove the currently-playing movie
                if (_curMovie != null) {
                    _media.removeChild(_curMovie);
                    _curMovie = null;
                }

                // And play the new one
                if (_playing.current != null) {
                    _curMovie = _playing.current;
                    _curMovie.x = _playing.currentLoc.x;
                    _curMovie.y = _playing.currentLoc.y;
                    _media.addChild(_curMovie);
                    playMovie(_curMovie);
                    _center = null;
                }
            }
        }

        if (_center == null && _curMovie != null) {
            _center = _curMovie.getChildByName("center");
            if (_center == null) {
                _center = _curMovie.getChildByName("ground");
            }
            if (_center != null) {
                _ctrl.setHotSpot(_center.x, _center.y, _mediaHeight);
            }
        }
    }

    protected function playMovie (movie :MovieClip) :void
    {
        // subclasses can override this to do implementation-specific things when a new
        // movie is played
        movie.gotoAndPlay(1);
    }

    protected function appearanceChanged (event :ControlEvent) :void
    {
        var orient :Number = _ctrl.getOrientation();
        if (orient < 180) {
            _media.x = _mediaWidth;
            _media.scaleX = -1;
        } else {
            _media.x = 0;
            _media.scaleX = 1;
        }

        var mode :String = "";
        if (_ctrl.isMoving()) {
            mode = "walking";
        } else if (_ctrl.isSleeping()) {
            mode = "sleeping";
        }

        if (_mode == mode) {
            return;
        }

        var transition :MovieList = null;
        if (_mode == "") {
            // if we're transitioning from standing, try a toMODE movie if we have one
            transition = getMovie("state_" + _state + "_to" + mode);
        } else if (mode == "") {
            // if we're transitioning to standing, try a fromMODE movie if we have one
            transition = getMovie("state_" + _state + "_from" + _mode);
        }

        var key :String = "state_" + _state + ((mode != "") ? ("_" + mode) : "");
        if (transition != null) {
            queueMovie(transition, true);
            queueMovie(getMovie(key), false);

        } else if (mode == "walking" && getMovie(key) == null) {
            // If we're transitioning to a walking state, and we don't have an animation
            // for this walking state, force the Default_walking animation
            queueMovie(getMovie("state_Default_walking"), true);

        } else {
            queueMovie(getMovie(key), true);
        }

        _mode = mode;
    }

    /**
     * Queues animations that transition between the specified states/actions. If a direct
     * transition is available, it will be used, otherwise we transition through "default".
     */
    protected function queueTransitions (from :String, to :String) :void
    {
        // queue our transition animation (direct if we have one, through 'default' if we don't)
        var direct :MovieList = getMovie(from + "_to_" + to);
        if (direct != null) {
            queueMovie(direct);
        } else {
            // TODO: if we lack one or both of these, should we do anything special?
            queueMovie(getMovie(from + "_to_default"));
            queueMovie(getMovie("default_to_" + to));
        }
    }

    /**
     * Queues a movie up to be played as soon as the other scenes in the queue have completed.
     * Handles queueing of null movies by ignoring the request to simplify other code.
     */
    protected function queueMovie (movieList :MovieList, force :Boolean = false) :void
    {
        if (movieList == null) {
            return;

        } else if (_playing == null || force) {
            log.info("Switching immediately to " + movieList.name + ".");
            _movieQueue.length = 0;
            _playing = movieList;
            _playing.update();
            _movieQueue.push(movieList);

        } else {
            log.info("Queueing " + movieList.name + ".");
            _movieQueue.push(movieList);
        }
    }

    protected function getMovie (key :String) :MovieList
    {
        return _movies.get(key.toLowerCase()) as MovieList;
    }

    protected function getAllMovies () :Array
    {
        var movies :Array = [];
        for each (var movieList :MovieList in _movies.values()) {
            for each (var movie :MovieClip in movieList.movies) {
                movies.push(movie);
            }
        }

        return movies;
    }

    protected var _ctrl :AvatarControl;
    protected var _media :MovieClip;
    protected var _center :DisplayObject;

    protected var _mediaWidth :int;
    protected var _mediaHeight :int;

    protected var _movies :HashMap = new HashMap();

    protected var _state :String;
    protected var _mode :String = "";
    protected var _playing :MovieList;
    protected var _movieQueue :Array = new Array();
    protected var _curMovie :MovieClip;
}
}

import com.threerings.util.Random;
import flash.display.MovieClip;
import flash.geom.Point;

class MovieList
{
    public var name :String;

    public function get current () :MovieClip
    {
        return (_movies[_curidx] as MovieClip);
    }

    public function get currentLoc () :Point
    {
        return (_locs[_curidx] as Point);
    }

    public function MovieList (name :String, movie :MovieClip, loc :Point, weight :int = 1)
    {
        this.name = name;
        addMovie(movie, loc, weight);
    }

    public function addMovie (movie :MovieClip, loc :Point, weight :int = 1) :void
    {
        _movies.push(movie);
        _locs.push(loc);
        _weights.push(weight);
        _totalWeight += weight;
    }

    public function update () :void
    {
        var value :int = _rando.nextInt(_totalWeight);
        for (var ii :int = 0; ii < _movies.length; ii++) {
            if (value < int(_weights[ii])) {
                _curidx = ii;
                return;
            }
            value -= int(_weights[ii]);
        }
    }

    public function get movies () :Array
    {
        return _movies;
    }

    protected var _curidx :int;

    protected var _movies :Array = [];
    protected var _weights :Array = [];
    protected var _locs :Array = [];
    protected var _totalWeight :int = 0;

    protected var _rando :Random = new Random();
}
