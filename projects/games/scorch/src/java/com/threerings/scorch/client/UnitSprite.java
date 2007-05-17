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
        super(50, 20);

        // place our hotspot at bottom center
        _oxoff = _bounds.width/2;
        _oyoff = _bounds.height;
    }

    public void setVelocity (float velx, float vely)
    {
        _data.velx = velx;
        _data.vely = vely;
    }

    public void setAcceleration (float accx, float accy)
    {
        _data.accx = accx;
        _data.accy = accy;
    }

    // from interface PhysicsEngine.Entity
    public void setEntityData (PhysicsEngine.EntityData data)
    {
        _data = data;
    }

    @Override // from Sprite
    public void paint (Graphics2D gfx)
    {
        gfx.setColor(Color.black);
        gfx.drawRect(_bounds.x, _bounds.y, _bounds.width-1, _bounds.height-1);
    }

    protected PhysicsEngine.EntityData _data;
}
