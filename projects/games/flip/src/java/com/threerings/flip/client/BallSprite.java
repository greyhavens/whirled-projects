//
// $Id$

package com.threerings.flip.client;

import com.threerings.media.sprite.ImageSprite;
import com.threerings.media.util.MultiFrameImage;

import com.threerings.flip.data.Ball;

/**
 * Represents a ball on the board.
 */
public class BallSprite extends ImageSprite
{
    /**
     * Create a BallSprite.
     */
    public BallSprite (MultiFrameImage img, Ball ball, FlipBoardView view)
    {
        super(img);
        _view = view;
        setRenderOrder(1);
        updated(ball);
    }

    /**
     * Construct a ball sprite that will just show the potential placement of the ball over the
     * slot that the player is mousing over.
     */
    public BallSprite (MultiFrameImage img)
    {
        super(img);
        setRenderOrder(1);
        _animated = true;
    }

    /**
     * Used for the ball sprite that will show potential placement.
     */
    public void setRotatingQuickly (boolean quick)
    {
        _fast = quick;
    }

    /**
     * Called when the ball we represent has been updated.
     */
    public void updated (Ball ball)
    {
        if (_additional != ball.additional) {
            if (ball.additional > _additional) {
                String sndkey;
                switch (ball.additional) {
                case 1: sndkey = FlipSounds.BALL_DOUBLE; break;
                case 2: sndkey = FlipSounds.BALL_TRIPLE; break;
                default: sndkey = FlipSounds.BALL_QUADRUPLE; break;
                }
                _view.playSound(sndkey);
            }

            _additional = ball.additional;
            if (_additional == 0) {
                _lastFrameStamp = 0L;
                _lastSparkleStamp = 0L;
                _frame = 0;
                _animated = false;

            } else {
                _animated = true;
            }
            updateFrame();
        }
    }

    /**
     * Update which frame is showing.
     */
    protected void updateFrame ()
    {
        setFrameIndex((_additional * FRAME_COUNT) + _frame, false);
    }

    @Override // documentation inherited
    protected void willStart (long stamp)
    {
        super.willStart(stamp);

        if (_animated) {
            _lastFrameStamp = stamp;
        }
    }

    @Override // documentation inherited
    protected void shutdown ()
    {
        super.shutdown();
        _firstTick = 0L;
    }

    @Override // documentation inherited
    public void tick (long stamp)
    {
        super.tick(stamp);

        if (_animated) {
            if (_lastFrameStamp == 0) {
                _lastFrameStamp = stamp;

            } else {
                long dur = (_fast || _additional > 0) ? MS_PER_FRAME : 4 * MS_PER_FRAME;
                if (_lastFrameStamp + dur <= stamp) {
                    _lastFrameStamp += dur;
                    _frame = (_frame + 1) % FRAME_COUNT;
                    updateFrame();
                }
            }

            if (_additional > 0) {
                if (_lastSparkleStamp == 0) {
                    // drop one immediately
                    _lastSparkleStamp = stamp;
                    _view.dropSparkle(this);

                } else {
                    long dur = (MS_PER_SPARKLE / _additional);
                    if (_lastSparkleStamp + dur <= stamp) {
                        _lastSparkleStamp += dur;
                        _view.dropSparkle(this);
                    }
                }
            }
        }
    }

    @Override // documentation inherited
    public void fastForward (long delta)
    {
        super.fastForward(delta);

        if (_lastFrameStamp != 0L) {
            _lastFrameStamp += delta;
        }
        if (_lastSparkleStamp != 0L) {
            _lastSparkleStamp += delta;
        }
    }

    protected FlipBoardView _view;

    /** The number of additional balls represented by this ball sprite. */
    protected int _additional;

    /** Which frame (out of 5) we're on. */
    protected int _frame = 0;

    protected long _lastFrameStamp;

    protected long _lastSparkleStamp;

    protected boolean _animated;

    /** True if we're animating quickly. */
    protected boolean _fast;

    protected static final int MS_PER_FRAME = 30;

    protected static final int MS_PER_SPARKLE = 180;

    protected static final int FRAME_COUNT = 6;
}
