//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Scene;
import flash.events.Event;

import com.threerings.util.HashMap;
import com.threerings.util.Random;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

/**
 * Manages an Avatar's visualization and animation state.
 */
public class Body
{
    /** Use this to log things. */
    public static var log :Log = Log.getLog(Body);

    /** Used to enable debugging feedback. */
    public static var debug :Boolean = false;

    /**
     * Creates a body that will manipulate the supplied MovieClip to animate the avatar. It will
     * use the supplied control to adjust the avatar's attachment to the floor (hotspot). The
     * caller should attach the supplied media to the display hierarchy, the body will simply
     * select scenes in the supplied MovieClip.
     */
    public function Body (ctrl :AvatarControl, media :MovieClip)
    {
        // register to hear when we start and stop walking
        _ctrl = ctrl;
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);
        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, actionTriggered);
        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, stateChanged);

        // register a frame callback so that we can manage our animations
        _media = media;
        _media.addEventListener(Event.ENTER_FRAME, onEnterFrame);

        // we'll keep track of all known states and actions
        var states :Array = [];
        var actions :Array = [];

        // map our scenes by name; we support the following types of scenes:
        // (state|action)_NAME_(idle|walk)(_N:W)
        // NAME_to_NAME
        for each (var scene :Scene in _media.scenes) {
            var bits :Array = scene.name.split("_");
            if (bits.length < 2) {
                log.warning("Invalid scene name: " + scene.name);
                continue;
            }

            if (bits.length == 3 && String(bits[1]) == "to") { // NAME_to_NAME
                _scenes.put(scene.name.toLowerCase(), new SceneList(scene.name, scene));
                continue;
            }

            // see if we have a weight specification
            var weight :int = 1, number :int = 1;
            var wstr :String = String(bits[bits.length-1]);
            if (wstr.match("[0-9]+(:[0-9]+)")) {
                var cidx :int = wstr.indexOf(":");
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
                    log.warning("State scene missing mode ('walk' or 'idle'): " + scene.name);
                    continue;
                }
                var mode :String = String(bits[2]);
                if (mode != "walk" && mode != "idle") {
                    log.warning("Invalid state mode (must be 'walk' or 'idle'): " + scene.name);
                    continue;
                }
                key = type + "_" + name + "_" + mode;
                if (states.indexOf(name) == -1) {
                    states.push(name);
                }

            } else {
                log.warning("Scene should start with 'state' or 'action': " + scene.name);
                continue;
            }

            log.info("Registering scene " + key + " [weight=" + weight + ", num=" + number + "].");
            var list :SceneList = getScene(key);
            if (list == null) {
                _scenes.put(key.toLowerCase(), new SceneList(key, scene, weight));
            } else {
                list.addScene(scene, weight);
            }
        }

        if (actions.length > 0) {
            _ctrl.registerActions(actions);
        }
        if (states.length > 0) {
            _ctrl.registerStates(states);
        }

		switchToState("default");
    }

    /**
     * Switches to a new state, using a transition animation if possible.
     */
    public function switchToState (state :String) :void
    {
        debugMessage("I'm transitioning to '" + state + "'.");

        // transtion from our current state to the new state
        queueTransitions(_state, state);
        // update our internal state variable
        _state = state;
        // queue our new idle animation
//        queueScene(findStateScene("idle"));
        queueScene(findStateScene("walk"));
    }

    /**
     * Triggers an action animation, using transition animations if possible.
     */
    public function triggerAction (action :String) :void
    {
        debugMessage("I'm triggering action '" + action + "'.");

        // transition from our current state to the action
        queueTransitions(_state, action);
        // play the action animation
        queueScene(getScene("action_" + action));
        // then transition back to our current state
        queueTransitions(action, _state);
    }

    /**
     * Switches to a new idle animation, remaining in the current state.
     */
    public function updateIdle () :void
    {
        queueScene(findStateScene("idle"));
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
            _media.x = 200;
            _media.scaleX = -1;
        } else {
            _media.x = 0;
            _media.scaleX = 1;
        }

        // we force an immediate transition here because we're switching from standing to walking
        // or vice versa which looks weird if we allow the animation to complete
        queueScene(findStateScene(_ctrl.isMoving() ? "walk" : "idle"), true);
    }

    protected function actionTriggered (event :ControlEvent) :void
    {
        switch (event.name) {
        }
    }

    protected function stateChanged (event :ControlEvent) :void
    {
        switchToState(event.name);
    }

    /**
     * Queues animations that transition between the specified states/actions. If a direct
     * transition is available, it will be used, otherwise we transition through "default".
     */
    protected function queueTransitions (from :String, to :String) :void
    {
        // queue our transition animation (direct if we have one, through 'default' if we don't)
        var direct :SceneList = getScene(from + "_to_" + to);
        if (direct != null) {
            queueScene(direct);
        } else {
            // TODO: if we lack one or both of these, should we do anything special?
            queueScene(getScene(from + "_to_default"));
            queueScene(getScene("default_to_" + to));
        }
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
            _media.gotoAndPlay(1, _playing.current.name);

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
    protected function findStateScene (action :String) :SceneList
    {
        var scene :SceneList = getScene("state_" + _state + "_" + action);
        if (scene == null) {
            scene = getScene("state_default_" + action);
        }
        if (scene == null) {
            log.warning("Unable to find scene [state=" + _state + ", action=" + action + "].");
        }
        return scene;
    }

	protected function getScene (key :String) :SceneList
	{
		return _scenes.get(key.toLowerCase()) as SceneList;
	}

	protected function debugMessage (message :String) :void
    {
        log.info(message);
    }

    protected var _ctrl :AvatarControl;
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
                _curidx == ii;
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
