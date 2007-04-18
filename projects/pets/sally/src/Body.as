//
// $Id$

package {

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
                _scenes.put(scene.name, scene);

            } else if (scene.name.match("^[a-z]+_to_[a-z]+$")) { // state_to_state
                _scenes.put(scene.name, scene);

            } else if (scene.name.match("^[a-z]+_[a-z]+_[0-9]+$")) { // state_to_action_N
                var idx :int = scene.name.lastIndexOf("_");
                var key :String = scene.name.substring(0, idx);
                var list :Object = _scenes.get(key);
                if (list is Array) {
                    (list as Array).push(scene);
                } else {
                    var nlist :Array = new Array();
                    if (list is Scene) {
                        nlist.push(list);
                    } // otherwise it's null
                    nlist.push(scene);
                    _scenes.put(key, nlist);
                }

            } else {
                trace("Unknown scene type: " + scene.name + ". Skipping.");
            }
        }
    }

    /**
     * Switches to a new state, using a transition animation if possible.
     */
    public function switchToState (state :String) :void
    {
        // TEMP: hackery
        if (state == "sleeping" && _state != "sleepy") {
            switchToState("sleepy");
        }
        // END TEMP

        trace("Changing state from " + _state + " to " + state + ".");
        // queue our transition animation (direct if we have one, through 'content' if we don't)
        var direct :Scene = (_scenes.get(_state + "_to_" + state) as Scene);
        if (direct != null) {
            trace("Transitioning using " + direct.name);
            queueScene(direct);
        } else {
            // TODO: if we lack one or both of these, should we do anything special?
            trace("Transitioning through content?");
            queueScene(_scenes.get(_state + "_to_content"));
            queueScene(_scenes.get("content_to_" + state));
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
        if (_media == null || _curScene == null) {
            return;
        }

        var scene :Scene = _media.currentScene;
        if (scene.name != _curScene.name) {
            if (_sceneQueue.length > 0) {
                _curScene = (_sceneQueue.shift() as Scene);
                trace("Switching to " + _curScene.name);
            } else {
                trace("Looping " + _curScene.name);
            }
            _media.gotoAndPlay(1, _curScene.name);
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
    protected function queueScene (scene :Scene, force :Boolean = false) :void
    {
        if (scene == null) {
            return;

        } else if (_curScene == null || force) {
            _sceneQueue.length = 0;
            _curScene = scene;
            _media.gotoAndPlay(1, _curScene.name);
//             for (var ii :int = 0; ii < _media.numChildren; ii++) {
//                 trace("Child " + ii + ": " + _media.getChildAt(ii));
//             }

        } else {
            trace("Queueing " + scene.name + " (f: " + scene.numFrames + ").");
            _sceneQueue.push(scene);
        }
    }

    /**
     * Locates a scene that will perform the desired action potentially selecting from a list of
     * alternatives or falling back to a generic version of the action if a specific one is not
     * available for our current state.
     */
    protected function findScene (action :String, fallback :Boolean = true) :Scene
    {
        var value :Object = _scenes.get(_state + "_" + action);
        if (value == null && fallback) {
            value = _scenes.get("content_" + action);
        }
        if (value is Array) {
            return (value[_rando.nextInt((value as Array).length)] as Scene);

        } else if (value is Scene) {
            return (value as Scene);

        } else {
            // uh oh...
            trace("Unable to find scene [state=" + _state + ", action=" + action + "].");
            return null;
        }
    }

    protected var _ctrl :PetControl;
    protected var _media :MovieClip;

    protected var _scenes :HashMap = new HashMap();
    protected var _rando :Random = new Random();

    protected var _state :String;
    protected var _curScene :Scene;
    protected var _sceneQueue :Array = new Array();
}
}
