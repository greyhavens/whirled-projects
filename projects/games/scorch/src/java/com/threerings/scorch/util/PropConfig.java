//
// $Id$

package com.threerings.scorch.util;

import java.awt.image.BufferedImage;
import java.util.HashMap;
import java.util.Properties;

/**
 * Contains information on a single prop.
 */
public class PropConfig
{
    /** The filename tag for mask images. */
    public static final String MASK_TAG = "_mask";

    /** The filename tag for facade images. */
    public static final String FACADE_TAG = "_facade";

    /** A string identifier for this prop. */
    public String ident;

    /** The primary prop image which is rendered behind units and defines the solidity for this
     * prop (via its non-transparent pixels) unless it also has a mask. */
    public BufferedImage image;

    /** A mask which indicates which pixels in this prop are "solid". */
    public BufferedImage mask;

    /** A facade image that is rendered in front of units for props that have a mask. */
    public BufferedImage facade;

    /** TODO: elasticity, density, other possible prop bits. */

    /**
     * Creates a prop configuration using the supplied path, configuration and image table.
     */
    public PropConfig (String path, Properties config, HashMap<String,BufferedImage> images)
    {
        ident = path.substring(path.lastIndexOf("/")+1);
        image = images.get(path);
        mask = images.get(tagPath(path, MASK_TAG));
        facade = images.get(tagPath(path, FACADE_TAG));
        System.err.println("Parsed " + ident + " " + image + " " + mask + " " + facade);
    }

    protected static String tagPath (String path, String tag)
    {
        int didx = path.lastIndexOf(".");
        return (didx == -1) ? (path + tag) : (path.substring(0, didx) + tag + path.substring(didx));
    }
}
