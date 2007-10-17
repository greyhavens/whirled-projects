package com.threerings.brawler.util {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.utils.Dictionary;

/**
 * Handles animations contained in {@link MovieClip}s.
 */
public class AnimationManager
{
    /** The name of the event sent by animations when they run to completion. */
    public static const ANIMATION_COMPLETE :String = "animationComplete";

    /**
     * Plays an animation on the labeled clip.
     *
     * @param callback if non-null, call this function when the animation completes or is
     * cancelled.
     */
    public function play (clip :MovieClip, anim :String, callback :Function = null) :void
    {
        var oanim :Animation = _anims[clip];
        if (oanim == null) {
            clip.addEventListener(ANIMATION_COMPLETE, handleAnimationComplete);
        } else if (oanim.callback != null) {
            delete _anims[clip]; // prevent stack overflow if the callback tries to play a clip
            oanim.callback();
        }
        _anims[clip] = new Animation(clip, callback);
        clip.gotoAndPlay(anim);
    }

    /**
     * Called when animations complete.
     */
    protected function handleAnimationComplete (event :Event) :void
    {
        var anim :Animation = _anims[event.target];
        if (anim != null) {
            anim.clip.removeEventListener(ANIMATION_COMPLETE, handleAnimationComplete);
            delete _anims[anim.clip];
            if (anim.callback != null) {
                // call the callback *after* we clear the entry in case the callback
                // wants to play another clip
                anim.callback();
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

    /** A function to call when the animation completes. */
    public var callback :Function;

    public function Animation (clip :MovieClip, callback :Function)
    {
        this.clip = clip;
        this.callback = callback;
    }
}
