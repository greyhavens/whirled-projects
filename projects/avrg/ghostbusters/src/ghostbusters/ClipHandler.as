//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Scene;

import flash.events.Event;

import flash.utils.ByteArray;
import flash.utils.getTimer;

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.FrameSprite;
import com.threerings.util.EmbeddedSwfLoader;

/**
 * A simple utility class that binds to a MovieClip and then plays scenes of that clip on request,
 * executing a callback method when the scene is finished.
 */
public class ClipHandler extends FrameSprite
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
        addChild(_clip);

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

    public function stop () :void
    {
        var t :uint = getTimer();

        // do the brutal recursive stop
        DisplayUtil.applyToHierarchy(_clip, function (disp :DisplayObject) :void {
            if (disp is MovieClip) {
                MovieClip(disp).stop();
            }
        });

        Game.log.debug("It took " + (getTimer() - t) + " ms to stop the clip: " + _clip);
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
            if (_scene.name) {  
                Game.log.debug("Playing [scene=" + _scene.name + ", frames=" + _scene.numFrames +
                               ", labels=" + _scene.labels + "]");
                _clip.gotoAndPlay(1, _scene.name);
            } else {
                _clip.gotoAndPlay(1);
            }
            return _lastFrame;
        }
        throw new Error("Can't goto scene [scene=" + scene + "]");
    }

    protected var counter :int;

    override protected function handleFrame (... ignored) :void
    {
        if (--counter < 0) {
            counter = Game.FRAMES_PER_REPORT;
            Game.log.debug("Frame handler running: " + this);
        }

        if (_clip == null || _lastFrame < 0) {
            return;
        }
        if (_clip.currentFrame == _lastFrame) {
            // now preserve the callback
            var cb :Function = _callback;
            _callback = null;

            // and the name while we're debugging
            var name :String = _scene != null ? _scene.name : "N/A";
            _scene = null;

            // call back if needed
            if (cb != null) {
                Game.log.debug("Executing callback for: " + name);

                // keep in mind this may change _callback and _scene
                var next :String = cb();
                if (next != null) {
                    _scene = scenes[next];
                    if (_scene != null) {
                        Game.log.debug("Repeating scene: " + next);
                        // if a string was returned, restore the callback (this is a bit ugly)
                        _callback = cb;
                        _clip.gotoAndPlay(1, next);
                    }
                }
            }
        }
    }

    protected var _clip :MovieClip;
    protected var _loaded :Function;
    protected var _scene :Scene;
    protected var _callback :Function;
    protected var _lastFrame :int;
}
}
