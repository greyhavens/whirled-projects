//
// $Id$

package com.threerings.flip.client;

import com.threerings.media.sprite.ImageSprite;
import com.threerings.media.util.MultiFrameImage;

import com.threerings.flip.data.Flip;

/**
 * Represents a flip on the board.
 */
public class FlipSprite extends ImageSprite
{
    public FlipSprite (MultiFrameImage img, Flip flip, FlipBoardView view)
    {
        super(img);
        _view = view;
        setFrameIndex(flip.leftPosition ? 0 : 4, false);
    }

    /**
     * Called from the board view to add flippings.
     */
    public void didFlip (int times)
    {
        _queuedFlips += times;
    }

    /**
     * Compute the initial delay for flipping, given the specified evolve duration.
     */
    public static long initialDelay (long duration)
    {
        return duration * 7 / 20;
    }

    @Override // documentation inherited
    public void fastForward (long delta)
    {
        super.fastForward(delta);
        _lastStamp += delta;
    }

    @Override // documentation inherited
    public void tick (long tickStamp)
    {
        super.tick(tickStamp);

        if (_step > 0) {
            long evDur = _view.getEvolveDuration();
            long nextStamp = _lastStamp +
                ((_step == 1) ? initialDelay(evDur) : (evDur / 10));
            if (tickStamp >= nextStamp) {
                int newFrame = _frameIdx + (_leftwards ? -1 : 1);
                setFrameIndex(newFrame, false);
                if (newFrame == 0 || newFrame == 4) {
                    // we're done
                    _step = 0; // possibly queue the next flip, below

                } else {
                    if (_step == 1) {
                        _view.playSound(FlipSounds.SWITCH_FLIP);
                    }
                    _step++;
                    _lastStamp = tickStamp;
                }
            }
        }

        // maybe start a flip (possibly immediately after the "if" above)
        if (_step == 0 && _queuedFlips > 0) {
            _queuedFlips--;
            _step = 1;
            _lastStamp = tickStamp;
            _leftwards = (_frameIdx == 4);
        }
    }

    protected FlipBoardView _view;

    /** The tick stamp of the last animation/flip event. */
    protected long _lastStamp;

    /** The number of flips we have queued up. */
    protected int _queuedFlips;

    protected int _step;

    protected boolean _leftwards;
}
