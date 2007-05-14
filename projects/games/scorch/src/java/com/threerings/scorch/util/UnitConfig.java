//
// $Id$

package com.threerings.scorch.util;

import java.awt.image.BufferedImage;
import java.util.HashMap;
import java.util.Properties;

/**
 * Contains configuration information about a particular unit.
 */
public class UnitConfig
{
    /** The string identifier for this unit. */
    public String ident;

    /** The human readable name of this unit. */
    public String name;

    /** The image data for this unit's rest animation. */
    public BufferedImage restMedia;

    /**
     * Creates and initializes a unit from the supplied configuration file.
     */
    public UnitConfig (String ident, Properties config, HashMap<String,BufferedImage> images)
    {
        this.ident = ident;
        name = config.getProperty(ident + ".name", "Unknown");
        restMedia = images.get("units/" + ident + "/" + REST_MEDIA);
        // TODO: other useful bits
    }

    protected static final String REST_MEDIA = "rest.png";
}
