//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Scene;
import flash.events.Event;

import com.threerings.util.HashMap;
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
     */
    public function Body (ctrl :PetControl, media :MovieClip)
    {
        // register to hear when we start and stop walking
        _ctrl = ctrl;
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);

        // register a frame callback so that we can manage our animations
        _media = media;
        _media.addEventListener(Event.ENTER_FRAME, onEnterFrame);

        // map our scenes by name
        for each (var scene :Scene in _media.scenes) {
            // we handle three types of scenes
            if (scene.name.match("^[a-z]+_[a-z]+$")) { // state_action
                _scenes.put(scene.name, new SceneList(scene.name, scene));

            } else if (scene.name.match("^[a-z]+_to_[a-z]+$")) { // state_to_state
                _scenes.put(scene.name, new SceneList(scene.name, scene));

            } else if (scene.name.match("^[a-z]+_[a-z]+_[0-9]+$")) { // state_to_action_N
                var idx :int = scene.name.lastIndexOf("_");
                var key :String = scene.name.substring(0, idx);
                var list :SceneList = (_scenes.get(key) as SceneList);
                if (list == null) {
                    _scenes.put(key, new SceneList(key, scene));
                } else {
                    list.addScene(scene);
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
        log.info("Changing state from " + _state + " to " + state + ".");

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
     * Cleans up after our body, unregistering listeners, etc.
     */
    public function shutdown () :void
    {
        // clear our enter frame callback
        _media.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
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
                _ctrl.setHotSpot(_center.x, _center.y, 160);
            }
        }
    }

    protected function appearanceChanged (event :ControlEvent) :void
    {
        var orient :Number = _ctrl.getOrientation();
        if (orient < 180) {
            _media.x = 350; // TODO
            _media.scaleX = -1;
        } else {
            _media.x = 0;
            _media.scaleX = 1;
        }

        // we force an immediate transition here because we're switching from standing to walking
        // or vice versa which looks weird if we allow the animation to complete
        queueScene(findScene(_ctrl.isMoving() ? "walk" : "idle"), true);
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
            log.info("Switching immediately to " + scene.name + ".");
            _sceneQueue.length = 0;
            _playing = scene;
            _playing.updateScene();
            _media.gotoAndPlay(1, _playing.current.name);

        } else {
            log.info("Queueing " + scene.name + ".");
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

    protected var _ctrl :PetControl;
    protected var _media :MovieClip;
    protected var _center :DisplayObject;

    protected var _scenes :HashMap = new HashMap();
    protected var _rando :Random = new Random();

    protected var _state :String;
    protected var _playing :SceneList;
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

    public function SceneList (name :String, scene :Scene)
    {
        this.name = name;
        addScene(scene);
    }

    public function addScene (scene :Scene) :void
    {
        _scenes.push(scene);
    }

    public function updateScene () :void
    {
        _curidx = _rando.nextInt(_scenes.length);
    }

    protected var _curidx :int;
    protected var _scenes :Array = new Array();
    protected var _rando :Random = new Random();
}
