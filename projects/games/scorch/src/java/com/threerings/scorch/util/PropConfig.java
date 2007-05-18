//
// $Id$

package com.threerings.scorch.util;

import java.awt.image.BufferedImage;
import java.awt.image.IndexColorModel;

import java.util.Arrays;
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

    /** An integer identifier for this prop, unique to its content pack and safe for use in
     * encoding boards (meaning it does not change when props are added to or deleted from the pack
     * during development). Note: these values are negative for the default content pack. */
    public short propId;

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

        // if there's no mask image, create one by replacing the color map of the main image with
        // one where all colors are white (the transparent color will still not render)
        if (mask == null) {
            // we reject non-index color model images at image loading time
            IndexColorModel model = (IndexColorModel)image.getColorModel();
            byte[] alphas = new byte[model.getMapSize()];
            byte[] whites = new byte[model.getMapSize()];
            Arrays.fill(whites, (byte)0xFF);
            model.getAlphas(alphas);
            IndexColorModel mmodel = new IndexColorModel(
                model.getPixelSize(), model.getMapSize(), whites, whites, whites, alphas);
            mask = new BufferedImage(mmodel, image.getRaster(), false, null);
        }
    }

    @Override // from Object
    public String toString ()
    {
        return ident;
    }

    protected static String tagPath (String path, String tag)
    {
        int didx = path.lastIndexOf(".");
        return (didx == -1) ? (path + tag) : (path.substring(0, didx) + tag + path.substring(didx));
    }
}
