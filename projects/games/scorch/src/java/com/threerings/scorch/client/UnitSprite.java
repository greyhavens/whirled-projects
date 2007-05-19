//
// $Id$

package com.threerings.scorch.client;

import java.awt.Color;
import java.awt.Graphics2D;
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
        _data.vel.y = -500;
    }

    public void move (long when, boolean left)
    {
        if (when - _lastMoveRequest > LINUX_MOVE_FILTER) {
            _data.vel.x += (left ? -50 : 50);
        }
        _lastMoveRequest = when;
        _data.conaccx = (left ? -250 : 250);
    }

    public void stop ()
    {
        _data.conaccx = 0;
    }

    // from interface PhysicsEngine.Entity
    public void setEntityData (PhysicsEngine.EntityData data)
    {
        _data = data;
    }

    // from interface PhysicsEngine.Entity
    public void setDebug (float ax, float ay, float vx, float vy)
    {
//         boolean dirty = false;
//         String debug = String.format("A:%2.2f,%2.2f", ax, ay);
//         if (!_debug[0].equals(debug)) {
//             _debug[0] = debug;
//             dirty = true;
//         }
//         debug = String.format("V:%2.2f,%2.2f", vx, vy);
//         if (!_debug[1].equals(debug)) {
//             _debug[1] = debug;
//             dirty = true;
//         }
//         if (dirty) {
//             invalidate();
//         }
    }

    @Override // from Sprite
    public void paint (Graphics2D gfx)
    {
        gfx.drawImage(_config.restMedia, _bounds.x, _bounds.y, null);
//         gfx.setColor(Color.black);
//         gfx.drawRect(_bounds.x, _bounds.y, _bounds.width-1, _bounds.height-1);
//         gfx.drawString(_debug[0], _bounds.x+3, _bounds.y+15);
//         gfx.drawString(_debug[1], _bounds.x+3, _bounds.y+30);
    }

    protected UnitConfig _config;
    protected PhysicsEngine.EntityData _data;
//     protected String[] _debug = { "", "" };

    protected long _lastMoveRequest;

    /** Annoying bullshit to cope with undisablable Linux key repeat. */
    protected static final long LINUX_MOVE_FILTER = 250L;
}
