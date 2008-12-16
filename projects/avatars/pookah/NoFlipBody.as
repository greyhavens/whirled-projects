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

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

/**
 * Manages an Avatar's visualization and animation state.
 */
public class NoFlipBody
{
    /** Use this to log things. */
    public static var log :Log = Log.getLog(NoFlipBody);

    /**
     * Creates a body that will manipulate the supplied MovieClip to animate the avatar. It will
     * use the supplied control to adjust the avatar's attachment to the floor (hotspot). The
     * caller should attach the supplied media to the display hierarchy, the body will simply
     * select scenes in the supplied MovieClip.
     *
     * @param width the width of the "stage" on which your MovieClip was built.
     * @param height the height above the hotspot identifier to display the avatar's name.
     */
    public function NoFlipBody (ctrl :AvatarControl, media :MovieClip, width :int, height :int = -1)
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

        // we'll keep track of all known states and actions
        var states :Array = [];
        var actions :Array = [];

        // map our scenes by name; we support the following types of scenes:
        // (state|action)_NAME(_N:W)
        // state_NAME_(walking|sleeping)(_N:W)
        // state_NAME_(towalking|tosleeping|fromwalking|fromsleeping)
        // NAME_to_NAME
        for each (var scene :Scene in _media.scenes) {
            var bits :Array = scene.name.split("_");
            if (bits.length < 2) {
                if (scene.name != "main") {
                    log.warning("Invalid scene name [scene=" + scene.name + "].");
                }
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
                    key = type + "_" + name;
                } else {
                    var mode :String = String(bits[2]);
                    if (mode != "walking" && mode != "towalking" && mode != "fromwalking" &&
                        mode != "sleeping" && mode != "tosleeping" && mode != "fromsleeping") {
                        log.warning("Invalid mode [scene=" + scene.name + ", mode=" + mode + "].");
                        continue;
                    }
                    key = type + "_" + name + "_" + mode;
                }
                if (states.indexOf(name) == -1) {
                    states.push(name);
                }

            } else {
                log.warning("Invalid type [scene=" + scene.name + "].");
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
        if (states.length > 1) { // no point in registering just one state, we'll always be in it
            _ctrl.registerStates(states);
        }

        var startState :String = null;
        if (_ctrl.isConnected()) {
            startState = _ctrl.getState();
        }
        if (startState == null) {
            startState = "Standing";
        }
        switchToState(startState);
        appearanceChanged(null);
    }

    /**
     * Switches to a new state, using a transition animation if possible.
     */
    public function switchToState (state :String) :void
    {
        log.info("I'm transitioning to '" + state + "'.");

        // transtion from our current state to the new state
        queueTransitions(_state, state);
        // update our internal state variable
        _state = state;
        // queue our new standing animation
        queueScene(getScene("state_" + _state));
    }

    /**
     * Triggers an action animation, using transition animations if possible.
     */
    public function triggerAction (action :String) :void
    {
        log.info("I'm triggering action '" + action + "'.");

        // transition from our current state to the action
        queueTransitions(_state, action);
        // play the action animation
        queueScene(getScene("action_" + action));
        // then transition back to our current state
        queueTransitions(action, _state);
        // and queue our standing animation
        queueScene(getScene("state_" + _state));
    }

    /**
     * Returns true if we're currently transitioning between states.
     */
    public function inTransition () :Boolean
    {
        return (_sceneQueue.length > 0);
    }

    /**
     * Cleans up after our body, unregistering listeners, etc. Your subclass
     * should also stop any timers, or do anything else needed.
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
                _ctrl.setHotSpot(_center.x, _center.y, _mediaHeight);
            }
        }
    }

    protected function appearanceChanged (event :ControlEvent) :void
    {
        var orient :Number = _ctrl.getOrientation();
            _media.x = 0;
            _media.scaleX = 1;

        var mode :String = "";
        if (_ctrl.isMoving()) {
            mode = "walking";
        } else if (_ctrl.isSleeping()) {
            mode = "sleeping";
        }
        if (_mode == mode) {
            return;
        }

        var transition :SceneList = null;
        if (_mode == "") {
            // if we're transitioning from standing, try a toMODE scene if we have one
            transition = getScene("state_" + _state + "_to" + mode);
        } else if (mode == "") {
            // if we're transitioning to standing, try a fromMODE scene if we have one
            transition = getScene("state_" + _state + "_from" + _mode);
        }
        var key :String = "state_" + _state + ((mode != "") ? ("_" + mode) : "");
        if (transition != null) {
            queueScene(transition, true);
            queueScene(getScene(key), false);
        } else {
            queueScene(getScene(key), true);
        }
        _mode = mode;
    }

    /**
     * Queues animations that transition between the specified states/actions. If a direct
     * transition is available, it will be used, otherwise we transition through "Standing".
     */
    protected function queueTransitions (from :String, to :String) :void
    {
        // queue our transition animation (direct if we have one, through 'Standing' if we don't)
        var direct :SceneList = getScene(from + "_to_" + to);
        if (direct != null) {
            queueScene(direct);
        } else {
            // TODO: if we lack one or both of these, should we do anything special?
            queueScene(getScene(from + "_to_Standing"));
            queueScene(getScene("Standing_to_" + to));
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
    protected function findStateScene (action :String) :SceneList
    {
        var scene :SceneList = getScene("state_" + _state + "_" + action);
        if (scene == null) {
            scene = getScene("state_Standing_" + action);
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

    protected var _ctrl :AvatarControl;
    protected var _media :MovieClip;
    protected var _center :DisplayObject;

    protected var _mediaWidth :int;
    protected var _mediaHeight :int;

    protected var _scenes :HashMap = new HashMap();

    protected var _state :String;
    protected var _mode :String = "";
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
