//
// $Id$

package ghostbusters {

import flash.display.MovieClip;
import flash.display.Scene;

import flash.events.Event;

import flash.utils.ByteArray;

import com.threerings.util.EmbeddedSwfLoader;

/**
 * A simple utility class that binds to a MovieClip and then plays scenes of that clip on request,
 * executing a callback method when the scene is finished.
 */
public class ClipHandler
{
    public var scenes :Object;

    public function ClipHandler (data :ByteArray, loaded :Function)
    {
        _loaded = loaded;

        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, clipLoaded);
        loader.load(data);
    }

    protected function clipLoaded (evt :Event) :void
    {
        _clip = MovieClip(EmbeddedSwfLoader(evt.target).getContent());

        scenes = new Object();

        for (var ii :int = 0; ii < _clip.scenes.length; ii ++) {
            var scene :Scene = _clip.scenes[ii];
            Game.log.debug("Indexing [scene=" + scene.name + ", frames=" + scene.numFrames +
                           ", labels=" + scene.labels + "]");
            scenes[scene.name] = scene;
        }

        if (_loaded != null) {
            _loaded(_clip);
        }
    }

    public function unload () :void
    {
        disengage();
    }

    public function stop () :void
    {
        _clip.stop();
    }

    public function gotoScene (scene :Object, done :Function = null, toFrame :int = -1,
                               play :Boolean = true) :int
    {
        if (scene is String) {
            _scene = scenes[String(scene)];
        } else if (scene is Number) {
            _scene = _clip.scenes[Number(scene)];
        } else {
            throw new Error("Argument #1 to gotoScene() must be a String or a Number.");
        }
        if (_scene) {
            _callback = done;
            _lastFrame = toFrame >= 0 ? toFrame : _scene.numFrames;
            _clip.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
            if (_scene.name) {
                _clip.gotoAndPlay(1, _scene.name);
            } else {
                _clip.gotoAndPlay(1);
            }
            return _lastFrame;
        }
        return 0;
    }

    public function disengage () :void
    {
        _callback = null;
        _scene = null;
        _clip.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    protected function handleEnterFrame (event :Event) :void
    {
        if (_clip.currentFrame == _lastFrame) {
            if (_callback != null) {
                var next :String = _callback();
                if (next != null) {
                    _scene = scenes[next];
                    if (_scene != null) {
                        _clip.gotoAndPlay(1, next);
                        return;
                    }
                }
            }
            disengage();
            return;
        }
    }

    protected var _clip :MovieClip;
    protected var _loaded :Function;
    protected var _scene :Scene;
    protected var _callback :Function;
    protected var _lastFrame :int;
}
}
