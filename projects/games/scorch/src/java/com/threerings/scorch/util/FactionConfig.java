//
// $Id$

package com.threerings.scorch.util;

import java.util.ArrayList;
import java.util.Properties;

import com.samskivert.util.StringUtil;

/**
 * Does something extraordinary.
 */
public class FactionConfig
{
    /** The string identifier for this faction. */
    public String ident;

    /** The human readable name of this faction. */
    public String name;

    /** TODO: a logo for this faction? */

    /** The units that make up this faction. */
    public ArrayList<UnitConfig> units = new ArrayList<UnitConfig>();

    /**
     * Creates and initializes a faction from the supplied configuration file.
     */
    public FactionConfig (String ident, Properties config)
    {
        this.ident = ident;
        name = config.getProperty(ident + ".name", "Unknown");
        for (String unit : StringUtil.parseStringArray(config.getProperty(ident + ".units", ""))) {
            units.add(new UnitConfig(unit, config));
        }
    }
}
