//
// $Id$

package com.threerings.flip.client;

import com.threerings.media.sprite.ImageSprite;
import com.threerings.media.sprite.action.CommandSprite;
import com.threerings.media.sprite.action.HoverSprite;
import com.threerings.media.util.MultiFrameImage;

import com.threerings.flip.data.FlipCodes;

/**
 * Displays the little blippy triangle at the top of each drop slot.
 */
public class LaneSprite extends ImageSprite
    implements CommandSprite, HoverSprite
{
    public LaneSprite (MultiFrameImage img, int lane, FlipBoardView view)
    {
        super(img);
        _lane = lane;
        _view = view;
    }

    // documentation inherited
    public boolean hitTest (int x, int y)
    {
        // we do not want our transparent pixels to not count
        return _bounds.contains(x, y);
    }

    /**
     * Start the lane flashing with the specified parameters.
     */
    public void flash (int delay, int duration, int refractory)
    {
        _delay = delay;
        _duration = duration;
        _refractory = refractory;
        setFrameIndex(0, false);
        _nextStamp = 0L;
        _mode = 0;
    }

    /**
     * Stop flashing.
     */
    public void stop ()
    {
        setFrameIndex(0, false);
        _nextStamp = Long.MAX_VALUE;
    }

    // documentation inherited
    public void tick (long stamp)
    {
        super.tick(stamp);

        if (stamp >= _nextStamp) {
            switch (_mode) {
            case 0:
                _nextStamp = stamp + _delay;
                _mode++;
                break;

            case 1:
                _nextStamp += _duration;
                setFrameIndex(1, false);
                _mode++;
                break;

            case 2:
                _nextStamp += _refractory;
                setFrameIndex(0, false);
                _mode = 1;
                break;
            }
        }
    }

    // documentation inherited
    public void fastForward (long delta)
    {
        super.fastForward(delta);

        _nextStamp += delta;
    }

    // documentation inherited from interface CommandSprite
    public String getActionCommand ()
    {
        return FlipCodes.DROP;
    }

    // documentation inherited from interface CommandSprite
    public Object getCommandArgument ()
    {
        return Byte.valueOf((byte) _lane);
    }

    // documentation inherited from interface HoverSprite
    public void setHovered (boolean hovered)
    {
        _view.laneHovered(_lane, hovered);
    }

    protected FlipBoardView _view;

    /** The argument to out action. */
    protected int _lane;

    protected long _nextStamp = Long.MAX_VALUE;
    protected int _delay, _duration, _refractory;
    protected int _mode;
}
