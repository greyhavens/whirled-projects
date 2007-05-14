//
// $Id$

package com.threerings.scorch.util;

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

    /**
     * Creates and initializes a unit from the supplied configuration file.
     */
    public UnitConfig (String ident, Properties config)
    {
        this.ident = ident;
        name = config.getProperty(ident + ".name", "Unknown");
        // TODO: other useful bits
    }
}
