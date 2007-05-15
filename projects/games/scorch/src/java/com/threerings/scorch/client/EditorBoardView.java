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

import java.util.ArrayList;

import com.threerings.media.sprite.Sprite;

import com.whirled.util.WhirledContext;

import com.threerings.scorch.data.ScorchBoard;
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

    public void init (EditorControlPanel ctrl)
    {
        _ctrl = ctrl;
    }

    public void setBoard (ScorchBoard board)
    {
        clearSprites();
        for (int ii = 0, ll = board.getPropCount(); ii < ll; ii++) {
            addProp(board.getPropConfig(ii), board.getPropX(ii), board.getPropY(ii));
        }
    }

    public ScorchBoard exportBoard ()
    {
        ScorchBoard board = new ScorchBoard();
        ArrayList<PropConfig> props = new ArrayList<PropConfig>();
        ArrayList<Point> locs = new ArrayList<Point>();
        for (Sprite sprite : getSpriteManager().getSprites()) {
            if (!(sprite instanceof PropSprite)) {
                continue;
            }
            props.add(((PropSprite)sprite).getPropConfig());
            locs.add(new Point(sprite.getX(), sprite.getY()));
        }
        board.setProps(_ctrl.getPackId(), props, locs);
        return board;
    }

    // from interface MouseListener
    public void mousePressed (MouseEvent e)
    {
        PropSprite prop = null;
        Sprite hit = getSpriteManager().getHighestHitSprite(e.getX(), e.getY());
        if (hit instanceof PropSprite) {
            prop = (PropSprite)hit;
        }

        switch (e.getButton()) {
        case MouseEvent.BUTTON1:
            if (e.isControlDown()) {
                if (prop != null) {
                    prop.setRenderOrder(e.isShiftDown() ? getLowestRenderOrder(prop)-1 :
                                        getHighestRenderOrder(prop)+1);
                }

            } else if (prop != null && !e.isShiftDown()) {
                _grabbed = prop;
                _grabOffset = new Point(prop.getX() - e.getX(), prop.getY() - e.getY());

            } else {
                addProp(_ctrl.getSelectedProp(), e.getX(), e.getY());
            }
            break;

        case MouseEvent.BUTTON3:
            if (prop != null) {
                removeSprite(prop);
            }
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

    protected void addProp (PropConfig config, int x, int y)
    {
        if (config != null) {
            PropSprite sprite = new PropSprite(config);
            sprite.setRenderOrder(getHighestRenderOrder(null)+1);
            sprite.setLocation(x, y);
            addSprite(sprite);
        }
    }

    protected void releaseProp ()
    {
        _grabbed = null;
        _grabOffset = null;
    }

    protected int getHighestRenderOrder (Sprite skip)
    {
        int highest = 0;
        for (Sprite sprite : getSpriteManager().getSprites()) {
            if (sprite == skip) {
                continue;
            }
            highest = Math.max(sprite.getRenderOrder(), highest);
        }
        return highest;
    }

    protected int getLowestRenderOrder (Sprite skip)
    {
        int lowest = 0;
        for (Sprite sprite : getSpriteManager().getSprites()) {
            if (sprite == skip) {
                continue;
            }
            lowest = Math.min(sprite.getRenderOrder(), lowest);
        }
        return lowest;
    }

    protected EditorControlPanel _ctrl;
    protected PropSprite _grabbed;
    protected Point _grabOffset;
}
