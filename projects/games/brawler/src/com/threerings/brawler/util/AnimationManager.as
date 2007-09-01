package com.threerings.brawler.util {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.utils.Dictionary;

/**
 * Handles animations contained in {@link MovieClip}s, marked by labeled frames.
 */
public class AnimationManager
{
    /**
     * Creates a new animation manager.
     */
    public function AnimationManager (disp :DisplayObject)
    {
        // listen for frame events
        disp.root.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    /**
     * Plays an animation on the labeled clip.
     *
     * @param loop if true, loop back to the beginning of the animation after reaching the end.
     * @param callback if non-null (and the animation is not looping), call this function when
     * the animation completes or is cancelled.
     */
    public function play (
        clip :MovieClip, anim :String, loop :Boolean = false, callback :Function = null) :void
    {
        var oanim :Animation = _anims[clip];
        if (oanim != null && oanim.callback != null) {
            oanim.callback();
        }
        _anims[clip] = new Animation(clip, anim, loop, callback);
        clip.gotoAndPlay(anim);
    }

    /**
     * Called on every frame.
     */
    protected function handleEnterFrame (event :Event) :void
    {
        // update the managed animations
        for each (var anim :Animation in _anims) {
            if (anim.clip.currentLabel != anim.name) {
                if (anim.loop) {
                    anim.clip.gotoAndPlay(anim.name);
                } else {
                    anim.clip.prevFrame();
                    delete _anims[anim.clip];
                    if (anim.callback != null) {
                        // call the callback *after* we clear the entry in case the callback
                        // wants to play another clip
                        anim.callback();
                    }
                }
            }
        }
    }

    /** The list of managed animations, mapped by clip. */
    protected var _anims :Dictionary = new Dictionary(true);
}
}

import flash.display.MovieClip;

/**
 * A managed animation.
 */
class Animation
{
    /** The clip playing the animation. */
    public var clip :MovieClip;

    /** The name of the animation. */
    public var name :String;

    /** Whether or not the animation is looping. */
    public var loop :Boolean;

    /** A function to call when the animation completes. */
    public var callback :Function;

    public function Animation (clip :MovieClip, name :String, loop :Boolean, callback :Function)
    {
        this.clip = clip;
        this.name = name;
        this.loop = loop;
        this.callback = callback;
    }
}
