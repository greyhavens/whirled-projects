//
// $Id$

package com.threerings.scorch.client;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;

import com.threerings.media.sprite.Sprite;
import com.threerings.scorch.util.UnitConfig;

/**
 * Displays a unit.
 */
public class UnitSprite extends Sprite
    implements PhysicsEngine.Entity
{
    public UnitSprite (UnitConfig config)
    {
        super(config.restMedia.getWidth(), config.restMedia.getHeight());

        _renderOrder = Short.MAX_VALUE;
        _config = config;

        // place our hotspot at bottom center
        _oxoff = _bounds.width/2;
        _oyoff = _bounds.height;
    }

    public void jump ()
    {
        if (_data.inContact) {
            _data.vel.y = -300;
        }
    }

    public void move (long when, boolean left)
    {
        _data.convelx = (left ? -50 : 50);
        if (left != _facingLeft) {
            _facingLeft = left;
            invalidate();
        }
    }

    public void stop ()
    {
        _data.convelx = 0;
    }

    // from interface PhysicsEngine.Entity
    public void setEntityData (PhysicsEngine.EntityData data)
    {
        _data = data;
    }

    // from interface PhysicsEngine.Entity
    public void setDebug (float ax, float ay, float vx, float vy)
    {
        // not used currently
    }

    @Override // from Sprite
    public void paint (Graphics2D gfx)
    {
        _xform.setToIdentity();
        _xform.translate(_bounds.x, _bounds.y);
        if (!_facingLeft) {
            _xform.translate(_bounds.width, 0);
            _xform.scale(-1, 1);
        }
        gfx.drawImage(_config.restMedia, _xform, null);
    }

    protected UnitConfig _config;
    protected PhysicsEngine.EntityData _data;

    protected boolean _facingLeft;
    protected AffineTransform _xform = new AffineTransform();

    /** Annoying bullshit to cope with undisablable Linux key repeat. */
    protected static final long LINUX_MOVE_FILTER = 250L;
}
