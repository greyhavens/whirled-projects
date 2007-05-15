//
// $Id$

package com.threerings.scorch.client;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;

import com.threerings.media.sprite.Sprite;

import com.whirled.util.WhirledContext;

import com.threerings.scorch.util.PropConfig;

import static com.threerings.scorch.Log.log;

/**
 * Handles extra bits when the board view is used in editor mode.
 */
public class EditorBoardView extends ScorchBoardView
    implements MouseListener, MouseMotionListener
{
    public EditorBoardView (WhirledContext ctx)
    {
        super(ctx);
        addMouseListener(this);
        addMouseMotionListener(this);
    }

    public void init (PropList props)
    {
        _props = props;
    }

    // from interface MouseListener
    public void mousePressed (MouseEvent e)
    {
        switch (e.getButton()) {
        case MouseEvent.BUTTON1:
            if (e.isShiftDown()) {
                addProp(e.getX(), e.getY());
            } else {
                grabProp(e.getX(), e.getY());
            }
            break;

        case MouseEvent.BUTTON2:
            deleteProp(e.getX(), e.getY());
            break;
        }
    }

    // from interface MouseListener
    public void mouseReleased (MouseEvent e)
    {
        releaseProp();
    }

    // from interface MouseListener
    public void mouseClicked (MouseEvent e)
    {
        // nada
    }

    // from interface MouseListener
    public void mouseEntered (MouseEvent e)
    {
        // nada
    }

    // from interface MouseListener
    public void mouseExited (MouseEvent e)
    {
        // nada
    }

    // from interface MouseMotionListener
    public void mouseDragged (MouseEvent e)
    {
        if (_grabbed != null) {
            _grabbed.setLocation(e.getX() + _grabOffset.x, e.getY() + _grabOffset.y);
        }
    }

    // from interface MouseMotionListener
    public void mouseMoved (MouseEvent e)
    {
    }

    @Override // from MediaPanel
    protected void paintBehind (Graphics2D gfx, Rectangle dirtyRect)
    {
        super.paintBehind(gfx, dirtyRect);

        gfx.setColor(Color.white);
        gfx.fill(dirtyRect);
    }

    protected void addProp (int x, int y)
    {
        PropConfig config = _props.getSelectedProp();
        if (config != null) {
            PropSprite sprite = new PropSprite(config);
            sprite.setLocation(x, y);
            addSprite(sprite);
        }
    }

    protected void grabProp (int x, int y)
    {
        Sprite hit = getSpriteManager().getHighestHitSprite(x, y);
        if (hit instanceof PropSprite) {
            _grabbed = (PropSprite)hit;
            _grabOffset = new Point(hit.getX() - x, hit.getY() - y);
        }
    }

    protected void releaseProp ()
    {
        _grabbed = null;
        _grabOffset = null;
    }

    protected void deleteProp (int x, int y)
    {
        Sprite hit = getSpriteManager().getHighestHitSprite(x, y);
        if (hit != null) {
            removeSprite(hit);
        }
    }

    protected PropList _props;

    protected PropSprite _grabbed;
    protected Point _grabOffset;
}
