//
// $Id$

package com.threerings.scorch.client;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;

import com.threerings.media.AbstractMedia;
import com.threerings.media.sprite.Sprite;

import com.threerings.scorch.util.PropConfig;

/**
 * Displays a prop being placed during editing mode.
 */
public class PropSprite extends Sprite
{
    public PropSprite (PropConfig config)
    {
        super(config.image.getWidth(), config.image.getHeight());
        _config = config;
    }

    /**
     * Returns the configuration for this prop sprite.
     */
    public PropConfig getPropConfig ()
    {
        return _config;
    }

    @Override // from Sprite
    public void paint (Graphics2D gfx)
    {
        gfx.drawImage(_config.image, _bounds.x, _bounds.y, null);
        if (_config.facade != null) {
            gfx.drawImage(_config.facade, _bounds.x, _bounds.y, null);
        }
    }

    @Override // from Sprite
    public boolean hitTest (int x, int y)
    {
        if (!super.hitTest(x, y)) {
            return false;
        }

        // if we have a mask, use that, otherwise use our main image
        BufferedImage mask = (_config.mask == null) ? _config.image : _config.mask;
        int pixel = mask.getRGB(x - _bounds.x, y - _bounds.y);
        return (pixel & 0xFF000000) != 0;
    }

    protected PropConfig _config;
}
