//
// $Id$

package com.threerings.flip.client;

import java.awt.Graphics2D;
import java.awt.Shape;

import java.util.LinkedList;

import com.samskivert.util.Tuple;

import com.threerings.media.image.Mirage;
import com.threerings.media.sprite.Sprite;

/**
 * CoinPileSprite.
 */
public class CoinPileSprite extends Sprite
{
    public CoinPileSprite (int x, int y, Mirage img)
    {
        super(img.getWidth(), img.getHeight());
        setLocation(x, y);
        _img = img;
    }

    /**
     * Called to clear the coins being displayed.
     */
    public void clear ()
    {
        addTarget(0, 0, null, false);
    }

    /**
     * Set the number of points we're to show.
     */
    public void setPoints (int points, int outOf, FlipBoardView view)
    {
        addTarget(points, outOf, view, false);
    }

    /**
     * Jump immediately to the target number of points.
     */
    public void jumpPoints (int points, int outOf)
    {
        addTarget(points, outOf, null, true);
    }

    /**
     * Add a new target for us to display.
     */
    protected void addTarget (int points, int outOf, FlipBoardView view, boolean jump)
    {
        int target;
        if (points <= 0) {
            target = 0;

        } else {
            // when there's at least 1 point we show 1 coin, the INITIAL, so we decrement points
            // and target by 1
            points--;
            outOf--;

            // figure out how many additional increments to show
            float perc = Math.min(1f, Math.max(0f, points / (float) outOf));
            int range = (_img.getHeight() - INITIAL) / INCREMENT;
            target = INITIAL + INCREMENT * (int) Math.floor(range * perc);
        }

        if (jump) {
            _show = _target = target;
            invalidate();

        } else {
            _targetQueue.addLast(new Tuple<Integer,FlipBoardView>(Integer.valueOf(target), view));
        }
    }

    @Override // documentation inherited
    public void fastForward (long ms)
    {
        super.fastForward(ms);
        _lastStamp += ms;
    }

    @Override // documentation inherited
    public void tick (long stamp)
    {
        super.tick(stamp);

        if (_target == _show) {
            if (_view != null) {
                _view.openChest();
                _view = null;
            }
            if (_targetQueue.isEmpty()) {
                return;
            }

            Tuple<Integer,FlipBoardView> tup = _targetQueue.removeFirst();
            _target = tup.left.intValue();
            _view = tup.right;

        } else {
            if (_show < _target) {
                _show = Math.min(_target, _show + Math.round((stamp - _lastStamp) * UP_VELOCITY));
                invalidate();

            } else if (_show > _target) {
                _show = Math.max(_target, _show - Math.round((stamp - _lastStamp) * DOWN_VELOCITY));
                invalidate();
            }
        }

        _lastStamp = stamp;
    }

    @Override // documentation inherited
    public void paint (Graphics2D gfx)
    {
        if (_show == 0) { // nothing to paint
            return;
        }

        // otherwise, paint just the showing part in the lower part of our bounds
        Shape oclip = gfx.getClip();
        gfx.clipRect(_bounds.x, _bounds.y, _bounds.width, _bounds.height);
        _img.paint(gfx, _bounds.x, _bounds.y + _img.getHeight() - _show);
        gfx.setClip(oclip);
    }

    protected long _lastStamp;

    /** The current y offset and the desired y offset. */
    protected int _show, _target;

    /** A queue of our next point values that we want to display. */
    protected LinkedList<Tuple<Integer,FlipBoardView>> _targetQueue =
        new LinkedList<Tuple<Integer,FlipBoardView>>();

    /** The image of the coin pile. */
    protected Mirage _img;

    /** The view to notify when we reach our target, if any. */
    protected FlipBoardView _view;

    protected static final float UP_VELOCITY = .05f;

    protected static final float DOWN_VELOCITY = .2f;

    /** How many pixles we show for the first coin. */
    protected static final int INITIAL = 4;

    /** How many pixels we increment the pile by at a time. */
    protected static final int INCREMENT = 3;
}
