//
// $Id$

package com.threerings.scorch.client;

import java.awt.Color;
import java.awt.Graphics2D;

import com.threerings.media.sprite.Sprite;

/**
 * Displays a unit.
 */
public class UnitSprite extends Sprite
    implements PhysicsEngine.Entity
{
    public UnitSprite ()
    {
        super(150, 50);

        // place our hotspot at bottom center
        _oxoff = _bounds.width/2;
        _oyoff = _bounds.height;
    }

    public void setVelocity (float velx, float vely)
    {
        _data.vel.set(velx, vely);
    }

    public void addAcceleration (float accx, float accy)
    {
        _data.acc.add(accx, accy);
    }

    public void setContactAcceleration (float conaccx)
    {
        _data.conaccx = conaccx;
    }

    // from interface PhysicsEngine.Entity
    public void setEntityData (PhysicsEngine.EntityData data)
    {
        _data = data;
    }

    // from interface PhysicsEngine.Entity
    public void setDebug (float ax, float ay, float vx, float vy)
    {
        boolean dirty = false;
        String debug = String.format("A:%2.2f,%2.2f", ax, ay);
        if (!_debug[0].equals(debug)) {
            _debug[0] = debug;
            dirty = true;
        }
        debug = String.format("V:%2.2f,%2.2f", vx, vy);
        if (!_debug[1].equals(debug)) {
            _debug[1] = debug;
            dirty = true;
        }
        if (dirty) {
            invalidate();
        }
    }

    @Override // from Sprite
    public void paint (Graphics2D gfx)
    {
        gfx.setColor(Color.black);
        gfx.drawRect(_bounds.x, _bounds.y, _bounds.width-1, _bounds.height-1);
        gfx.drawString(_debug[0], _bounds.x+3, _bounds.y+15);
        gfx.drawString(_debug[1], _bounds.x+3, _bounds.y+30);
    }

    protected PhysicsEngine.EntityData _data;
    protected String[] _debug = { "", "" };
}
