//
// $Id$

package com.threerings.scorch.client;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Graphics;
import java.awt.Rectangle;
import java.awt.Toolkit;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

import com.threerings.media.MediaPanel;
import com.threerings.media.sprite.Sprite;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceObject;

import com.whirled.util.WhirledContext;

import com.threerings.scorch.data.ScorchObject;

/**
 * Displays the main game interface (the board).
 */
public class ScorchBoardView extends MediaPanel
    implements PlaceView, KeyListener
{
    /**
     * Constructs a view which will initialize itself and prepare to display the game board.
     */
    public ScorchBoardView (WhirledContext ctx)
    {
        super(ctx.getFrameManager());
        _ctx = ctx;
    }

    public void setActiveUnit (UnitSprite sprite)
    {
        _active = sprite;
    }

    // from interface PlaceView
    public void willEnterPlace (PlaceObject plobj)
    {
        _gameobj = (ScorchObject)plobj;
        _ctx.getKeyDispatcher().addGlobalKeyListener(this);
    }

    // from interface PlaceView
    public void didLeavePlace (PlaceObject plobj)
    {
        _ctx.getKeyDispatcher().removeGlobalKeyListener(this);
    }

    // from interface KeyListener
    public void keyTyped (KeyEvent e)
    {
        // not used
    }

    // from interface KeyListener
    public void keyPressed (KeyEvent e)
    {
        if (_active == null) {
            return;
        }

        switch (e.getKeyCode()) {
        case KeyEvent.VK_LEFT:
            _active.move(e.getWhen(), true);
            break;
        case KeyEvent.VK_RIGHT:
            _active.move(e.getWhen(), false);
            break;
        case KeyEvent.VK_SPACE:
            _active.jump();
            break;
        }
    }

    // from interface KeyListener
    public void keyReleased (KeyEvent e)
    {
        if (_active == null) {
            return;
        }

        switch (e.getKeyCode()) {
        case KeyEvent.VK_LEFT:
        case KeyEvent.VK_RIGHT:
            _active.stop();
            break;
        }
    }

    @Override // from MediaPanel
    public void addSprite (Sprite sprite)
    {
        super.addSprite(sprite);

        if (sprite instanceof PhysicsEngine.Entity) {
            _engine.addEntity((PhysicsEngine.Entity)sprite);
        }
    }

    @Override // from MediaPanel
    public void removeSprite (Sprite sprite)
    {
        super.removeSprite(sprite);

        if (sprite instanceof PhysicsEngine.Entity) {
            _engine.removeEntity((PhysicsEngine.Entity)sprite);
        }
    }

    @Override // from MediaPanel
    public void clearSprites ()
    {
        super.clearSprites();
        _engine.clearEntities();
    }

    @Override // from MediaPanel
    protected void willTick (long tickStamp)
    {
        super.willTick(tickStamp);

        // tick our physics engine
        _engine.tick(tickStamp);
    }

    @Override // from MediaPanel
    protected void paintBehind (Graphics2D gfx, Rectangle dirtyRect)
    {
        super.paintBehind(gfx, dirtyRect);
        gfx.setColor(Color.white);
        gfx.fill(dirtyRect);
    }

    /** Provides access to client services. */
    protected WhirledContext _ctx;

    /** Handles our (primitive) physics. */
    protected PhysicsEngine _engine = new PhysicsEngine();

    /** A reference to our game object. */
    protected ScorchObject _gameobj;

    /** The currently active unit sprite. */
    protected UnitSprite _active;
}
