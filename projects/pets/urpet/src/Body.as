//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Scene;
import flash.events.Event;

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.Random;

import com.whirled.ControlEvent;
import com.whirled.PetControl;

/**
 * Manages a Pet's visualization and animation state.
 */
public class Body
{
    /** Use this to log things. */
    public static var log :Log = Log.getLog(Body);

    /**
     * Creates a body that will manipulate the supplied MovieClip to animate the pet. It will use
     * the supplied control to adjust the pet's attachment to the floor (hotspot). The caller
     * should attach the supplied media to the display hierarchy, the body will simply select
     * scenes in the supplied MovieClip.
     *
     * @param width the width of the "stage" on which your MovieClip was built.
     */
    public function Body (ctrl :PetControl, media :MovieClip, width :int, nameHeight :Number = NaN)
    {
        // register to hear when we start and stop walking
        _ctrl = ctrl;
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);
        _ctrl.addEventListener(Event.UNLOAD, function (event :Event) :void {
            shutdown();
        });

        _media = media;
        _media.addEventListener(Event.ADDED_TO_STAGE, handleAddRemove);
        _media.addEventListener(Event.REMOVED_FROM_STAGE, handleAddRemove);
        // register a frame callback so that we can manage our animations
        if (_media.stage != null) {
            _media.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        _mediaWidth = width;
        _nameHeight = nameHeight;

        // map our scenes by name
        for each (var scene :Scene in _media.scenes) {
            // we handle three types of scenes
            if (scene.name.match("^[a-z]+_[a-z]+$")) { // state_action
                _scenes.put(scene.name, new SceneList(scene.name, scene));

            } else if (scene.name.match("^[a-z]+_to_[a-z]+$")) { // state_to_state
                _scenes.put(scene.name, new SceneList(scene.name, scene));

            } else if (scene.name.match("^[a-z]+_[a-z]+_[0-9]+(:[0-9]+)?$")) { // state_action_N:W
                var idx :int = scene.name.lastIndexOf("_");
                var key :String = scene.name.substring(0, idx);
                var bits :String = scene.name.substring(idx+1);

                // see if we have a weight specification
                var weight :int = 1;
                var cidx :int = bits.indexOf(":");
                if (cidx != -1) {
                    weight = int(bits.substring(cidx+1));
                }

                var list :SceneList = (_scenes.get(key) as SceneList);
                if (list == null) {
                    _scenes.put(key, new SceneList(key, scene, weight));
                } else {
                    list.addScene(scene, weight);
                }

            } else {
                log.warning("Unknown scene type: " + scene.name + ". Skipping.");
            }
        }
    }

    /**
     * Returns true if this body supports the specified state (has animations for it).
     */
    public function supportsState (state :String) :Boolean
    {
        // if we have an idle animation for a state, we support it
        if (!_scenes.containsKey(state + "_idle")) {
            return false;
        }
        // warn if we lack state_to_content or content_to_state
        if (State.getState(state).transitions.indexOf(State.CONTENT) != -1 &&
            !_scenes.containsKey(state + "_to_content")) {
            log.warning("Warning: missing " + state + "_to_content animation.");
        }
        if (State.CONTENT.transitions.indexOf(State.getState(state)) != -1 &&
            !_scenes.containsKey("content_to_" + state)) {
            log.warning("Missing content_to_" + state + " animation.");
        }
        return true;
    }

    /**
     * Switches to a new state, using a transition animation if possible.
     */
    public function switchToState (state :String) :void
    {
        debugMessage("I'm transitioning to '" + state + "'.");

        // queue our transition animation (direct if we have one, through 'content' if we don't)
        var direct :SceneList = (_scenes.get(_state + "_to_" + state) as SceneList);
        if (direct != null) {
            queueScene(direct);
        } else {
            // TODO: if we lack one or both of these, should we do anything special?
            queueScene(_scenes.get(_state + "_to_content") as SceneList);
            queueScene(_scenes.get("content_to_" + state) as SceneList);
        }
        // update our state
        _state = state;
        // queue our new idle animation
        queueScene(findScene("idle"));
    }

    /**
     * Switches to a new idle animation, remaining in the current state.
     */
    public function updateIdle () :void
    {
        queueScene(findScene("idle"));
    }

    /**
     * Returns true if we're currently transitioning between states.
     */
    public function inTransition () :Boolean
    {
        return (_sceneQueue.length > 0);
    }

    /**
     * Cleans up after our body, unregistering listeners, etc. Your subclass should
     * also stop any Timers or do anything else it needs to.
     */
    public function shutdown () :void
    {
        _media.removeEventListener(Event.ADDED_TO_STAGE, handleAddRemove);
        _media.removeEventListener(Event.REMOVED_FROM_STAGE, handleAddRemove);
        // this may already be unregistered, but this won't hurt
        _media.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
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

        if (_media.currentScene.name != _playing.current.name) {
            if (_sceneQueue.length > 0) {
                _playing = (_sceneQueue.shift() as SceneList);
            } else {
                _playing.updateScene();
            }
            _media.gotoAndPlay(1, _playing.current.name);
            _center = null;
        }

        if (_center == null) {
            _center = _media.getChildByName("center");
            if (_center == null) {
                _center = _media.getChildByName("ground");
            }
            if (_center != null) {
                _ctrl.setHotSpot(_center.x, _center.y, _nameHeight);
            }
        }
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

        // if we're finishing a walk and have selected a _fromwalk animation to use, play that now
        var force :Boolean = true;
        if (!_ctrl.isMoving() && _fromWalk != null) {
            queueScene(_fromWalk, true);
            force = false;
        }

        // if we're about to start a walk, check to see if we have a _towalk and _fromwalk that
        // should be used
        if (_ctrl.isMoving()) {
            var state :String = (findScene("walk", false) == null) ? "content" : _state;
            // if we have a _towalk, start that playing immediately
            var towalk :SceneList = (_scenes.get(state + "_towalk") as SceneList);
            if (towalk != null) {
                queueScene(towalk, true);
                force = false;
            }
            // note the _fromwalk we'll want to use when we stop walking
            _fromWalk = (_scenes.get(state + "_fromwalk") as SceneList);
        }

        // we force an immediate transition here because we're switching from standing to walking
        // or vice versa which looks weird if we allow the animation to complete
        queueScene(findScene(_ctrl.isMoving() ? "walk" : "idle"), force);
    }

    /**
     * Queues a scene up to be played as soon as the other scenes in the queue have completed.
     * Handles queueing of null scenes by ignoring the request to simplify other code.
     */
    protected function queueScene (scene :SceneList, force :Boolean = false) :void
    {
        if (scene == null) {
            return;

        } else if (_playing == null || force) {
            debugMessage("Switching immediately to " + scene.name + ".");
            _sceneQueue.length = 0;
            _playing = scene;
            _playing.updateScene();
            // Apparently the following line can be omitted with no ill side-effects and
            // it fixes flickering in a remixed project.
            //_media.gotoAndPlay(1, _playing.current.name);
            _sceneQueue.push(scene); // and this line is added instead

        } else {
            debugMessage("Queueing " + scene.name + ".");
            _sceneQueue.push(scene);
        }
    }

    /**
     * Locates a scene that will perform the desired action potentially selecting from a list of
     * alternatives or falling back to a generic version of the action if a specific one is not
     * available for our current state.
     */
    protected function findScene (action :String, fallback :Boolean = true) :SceneList
    {
        var scene :SceneList = (_scenes.get(_state + "_" + action) as SceneList);
        if (scene == null && fallback) {
            scene = (_scenes.get("content_" + action) as SceneList);
        }
        if (scene == null) {
            log.warning("Unable to find scene [state=" + _state + ", action=" + action + "].");
        }
        return scene;
    }

    protected function debugMessage (message :String) :void
    {
        if (Brain.debug && _ctrl.isConnected()) {
            _ctrl.sendChat(message);
        } else {
            log.info(message);
        }
    }

    protected var _ctrl :PetControl;
    protected var _media :MovieClip;
    protected var _center :DisplayObject;
    protected var _mediaWidth :int;
    protected var _nameHeight :Number;

    protected var _scenes :HashMap = new HashMap();
    protected var _rando :Random = new Random();

    protected var _state :String;
    protected var _playing :SceneList;
    protected var _fromWalk :SceneList;
    protected var _sceneQueue :Array = new Array();
}
}

import flash.display.Scene;

import com.threerings.util.Random;

class SceneList
{
    public var name :String;

    public function get current () :Scene
    {
        return (_scenes[_curidx] as Scene);
    }

    public function SceneList (name :String, scene :Scene, weight :int = 1)
    {
        this.name = name;
        addScene(scene, weight);
    }

    public function addScene (scene :Scene, weight :int = 1) :void
    {
        _scenes.push(scene);
        _weights.push(weight);
        _totalWeight += weight;
    }

    public function updateScene () :void
    {
        var value :int = _rando.nextInt(_totalWeight);
        for (var ii :int = 0; ii < _scenes.length; ii++) {
            if (value < int(_weights[ii])) {
                _curidx = ii;
                return;
            }
            value -= int(_weights[ii]);
        }
    }

    protected var _curidx :int;

    protected var _scenes :Array = new Array();
    protected var _weights :Array = new Array();
    protected var _totalWeight :int = 0;

    protected var _rando :Random = new Random();
}
