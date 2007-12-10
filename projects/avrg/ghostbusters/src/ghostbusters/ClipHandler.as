//
// $Id$

package ghostbusters {

import flash.display.MovieClip;
import flash.display.Scene;
import flash.events.Event;

/**
 * A simple utility class that binds to a MovieClip and then plays scenes of that clip on request,
 * executing a callback method when the scene is finished.
 */
public class ClipHandler
{
    public var scenes :Object;

    public function ClipHandler (clip :MovieClip)
    {
        _clip = clip;

        scenes = new Object();
        for (var ii :int = 0; ii < clip.scenes.length; ii ++) {
            var scene :Scene = _clip.scenes[ii];
            Game.log.debug("Indexing [scene=" + scene.name + ", frames=" + scene.numFrames +
                           ", labels=" + scene.labels + "]");
            scenes[scene.name] = scene;
        }
    }

    public function unload () :void
    {
        disengage();
    }

    public function gotoScene (sceneName :String, done :Function = null) :Boolean
    {
        _scene = scenes[sceneName];
        if (_scene) {
            _callback = done;
            _clip.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
            _clip.gotoAndPlay(1, sceneName);
            Game.log.debug("Playing: " + sceneName);
            return true;
        }
        return false;
    }

    public function gotoSceneNumber (sceneNum: int, done :Function = null) :Boolean
    {
        _scene = _clip.scenes[sceneNum];
        _callback = done;
        _clip.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
        _clip.gotoAndPlay(1);
        Game.log.debug("Playing: <" + sceneNum + ">");
        return true;
    }

    public function disengage () :void
    {
        _callback = null;
        _scene = null;
        _clip.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    protected function handleEnterFrame (event :Event) :void
    {
        // if the clip was manipuulated from elsewhere, let's lose interest
        if (_clip.currentScene.name != _scene.name) {
            disengage();
            return;
        }

        // otherwise perhaps we're done?
        if (_clip.currentFrame == _scene.numFrames) {
            Game.log.debug("Clip done, ending [numFrames=" + _scene.numFrames + "]");
            // if so trigger the callback (if any)
            if (_callback != null) {
                _callback();
            }
            // and stop paying attention
            disengage();
            return;
        }
    }

    protected var _clip :MovieClip;
    protected var _scene :Scene;
    protected var _callback :Function;
}
}
