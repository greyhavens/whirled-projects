//
// $Id: AtlantiTile.java,v 1.18 2004/08/27 18:56:44 mdb Exp $

package com.samskivert.atlanti.data;

import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Composite;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.Polygon;

import java.awt.geom.AffineTransform;
import java.awt.geom.Point2D;

import java.io.IOException;

import java.util.List;
import com.samskivert.util.StringUtil;

import com.threerings.media.image.ImageManager;
import com.threerings.media.tile.Tile;
import com.threerings.media.tile.TileManager;
import com.threerings.media.tile.UniformTileSet;

import com.threerings.io.ObjectInputStream;
import com.threerings.presents.dobj.DSet;

import com.samskivert.atlanti.Log;
import com.samskivert.atlanti.util.FeatureUtil;
import com.samskivert.atlanti.util.PiecenUtil;
import com.samskivert.atlanti.util.TileUtil;

/**
 * Represents a single tile in play on the game board.
 *
 * <p><em>Note:</em> this should really be split into a pure data class
 * and an associated visualization class in the
 * <code>atlanti.client</code> package.
 */
public class AtlantiTile
    implements DSet.Entry, TileCodes, Cloneable, Comparable<AtlantiTile>
{
    /** The starting tile. */
    public static final AtlantiTile STARTING_TILE =
        new AtlantiTile(CITY_ONE_ROAD_STRAIGHT, false, NORTH, 0, 0);

    /** Activate this to render a piecen on every feature (useful for the
     * tile geometry test). */
    public static boolean piecenDebug = false;

    /** The tile type. */
    public int type;

    /** Whether this tile has a shield on it. */
    public boolean hasShield;

    /** The tile's orientation. */
    public int orientation;

    /** The tile's x and y coordinates. */
    public int x,  y;

    /** An array of claim group values that correspond to the features of
     * this tile. If a piecen has claimed a feature on this tile or that
     * connects to this tile, it will be represented here by a non-zero
     * claim group in the array slot that corresponds to the claimed
     * feature. */
    public transient int[] claims;

    /** A reference to our static feature descriptions. */
    public transient Feature[] features;

    /** A reference to the piecen on this tile or null if no piecen has
     * been placed on this tile. */
    public transient Piecen piecen;

    /**
     * Constructs a tile with all of the supplied tile information.
     */
    public AtlantiTile (int type, boolean hasShield, int orientation,
                        int x, int y)
    {
        this.type = type;
        this.hasShield = hasShield;
        this.orientation = orientation;
        this.x = x;
        this.y = y;

        // initialize our feature info
        initFeatures();
    }

    /**
     * Constructs a tile with the type information set, but in the default
     * <code>NORTH</code> orientation and with no position.
     */
    public AtlantiTile (int type, boolean hasShield)
    {
        this(type, hasShield, NORTH, 0, 0);
    }

    /**
     * Used for making a key when looking up a tile in an index of tiles.
     */
    public AtlantiTile (int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    /**
     * Constructs a blank tile, suitable for unserialization.
     */
    public AtlantiTile ()
    {
        // nothing doing
    }

    /**
     * Returns true if this tile has at least one unclaimed feature.
     */
    public boolean hasUnclaimedFeature ()
    {
        return (getUnclaimedCount() > 0);
    }

    /**
     * Returns the count of unclaimed features on this tile.
     */
    public int getUnclaimedCount ()
    {
        int count = 0;
        for (int ii = 0; ii < claims.length; ii++) {
            if (claims[ii] == 0) {
                count++;
            }
        }
        return count;
    }

    /**
     * Looks for a feature in this tile that matches the supplied feature
     * edge mask and returns the index of that feature in this tile's
     * {@link #claims} array.
     *
     * @return the index of the matching feature or -1 if no feature
     * matched.
     */
    public int getFeatureIndex (int edgeMask)
    {
        // translate the feature mask into our orientation
        edgeMask = FeatureUtil.translateMask(edgeMask, -orientation);

        // look for a feature with a matching edge mask
        for (int i = 0; i < features.length; i ++) {
            if ((features[i].edgeMask & edgeMask) != 0) {
                return i;
            }
        }

        // no match
        return -1;
    }

    /**
     * Returns the index of the feature that contains the supplied mouse
     * coordinates (which will have been translated relative to the tile's
     * origin).
     *
     * @return the index of the feature that contains the mouse
     * coordinates. Some feature should always contain the mouse.
     */
    public int getFeatureIndex (int mouseX, int mouseY)
    {
        // we search our features in reverse order because road features
        // overlap grass features geometrically and are known to be
        // specified after the grass features
        for (int i = features.length-1; i >= 0; i--) {
            if (features[i].contains(mouseX, mouseY, orientation)) {
                return i;
            }
        }

        // something is hosed; fake it
        Log.warning("Didn't find matching feature for mouse coordinates!? " +
                    "[tile=" + this + ", mx=" + mouseX +
                    ", my=" + mouseY + "].");
        return 0;
    }

    /**
     * Looks for a feature in this tile that matches the supplied feature
     * edge mask and returns the claim group to which that feature belongs
     * (which may be zero).
     *
     * @return the claim group to which the feature that matches the
     * supplied mask belongs, or zero if no feature matched the supplied
     * mask.
     */
    public int getFeatureGroup (int edgeMask)
    {
        int fidx = getFeatureIndex(edgeMask);
        return fidx < 0 ? 0 : claims[fidx];
    }

    /**
     * Sets the claim group for the feature with the specified index. This
     * also updates the claim group for any piecen that was placed on that
     * feature as well.
     *
     * @param featureIndex the index of the feature to update.
     * @param claimGroup the claim group to associate with the feature.
     */
    public void setClaimGroup (int featureIndex, int claimGroup)
    {
        // update the claim group slot for this feature
        claims[featureIndex] = claimGroup;

        // if we have a piecen placed on the feature identified by this
        // feature index, we need to update its claim group as well
        if (piecen != null && piecen.featureIndex == featureIndex) {
            piecen.claimGroup = claimGroup;
        }
    }

    /**
     * Places the specified piecen on this tile. The {@link
     * Piecen#featureIndex} field is assumed to be initialized to the
     * feature index of this tile on which the piecen is to be placed.
     *
     * <p> Note that this will call {@link TileUtil#setClaimGroup} to
     * propagate the claiming of this feature to all neighboring tiles if
     * a non-null tiles array is supplied to the function.
     *
     * @param piecen the piecen to place on this tile (with an
     * appropriately configured feature index).
     * @param tiles a sorted list of all of the tiles on the board that
     * we can use to propagate our new claim group to all features
     * connected to this newly claimed feature or null if propagation of
     * the claim group is not desired at this time.
     */
    public void setPiecen (Piecen piecen, List<AtlantiTile> tiles)
    {
        int claimGroup = 0;

        // if we're adding a piecen to a feature that's already claimed,
        // we want to inherit the claim number (this could happen when we
        // show up in an in progress game)
        if (claims[piecen.featureIndex] != 0) {
            Log.warning("Requested to add a piecen to a feature " +
                        "that has already been claimed [tile=" + this +
                        ", piecen=" + piecen + "]. Inheriting.");
            claimGroup = claims[piecen.featureIndex];

        } else {
            // otherwise we generate a new claim group
            claimGroup = TileUtil.nextClaimGroup();
            Log.debug("Creating claim group [cgroup=" + claimGroup +
                      ", tile=" + this +
                      ", fidx=" + piecen.featureIndex + "].");
        }

        // keep a reference to this piecen and configure its position
        this.piecen = piecen;
        piecen.x = x;
        piecen.y = y;

        // assign a brand spanking new claim group to the feature and the
        // piecen and propagate it to neighboring features
        if (tiles != null) {
            TileUtil.setClaimGroup(
                tiles, this, piecen.featureIndex, claimGroup);
            // update our piecen with the claim group as well
            piecen.claimGroup = claimGroup;
        }
    }

    /**
     * Clears out any piecen reference that was previously set (does not
     * clear out its associated claim group, however).
     */
    public void clearPiecen ()
    {
        piecen = null;
    }

    /**
     * Paints this tile to the specified graphics context at its assigned
     * location, accounting for the supplied x and y offsets of the
     * origin.
     *
     * @param g the graphics context to use when painting the tile.
     * @param xoff the offset (in tile units) of the origin in the x
     * direction.
     * @param yoff the offset (in tile units) of the origin in the y
     * direction.
     */
    public void paint (Graphics2D g, int xoff, int yoff)
    {
        int tidx = type-1;

        // obtain our tile image
        if (_tileImage == null) {
            _tileImage = getTileImage(type);
        }

        // compute our screen coordinates
        int sx = (x + xoff) * TILE_WIDTH;
        int sy = (y + yoff) * TILE_HEIGHT;

        // translate to our screen coordinates
        g.translate(sx, sy);

        // render our tile image
        if (_tileImage != null) {
            if (orientation > 0) {
                g.drawImage(_tileImage, _xforms[orientation], null);
            } else {
                g.drawImage(_tileImage, 0, 0, null);
            }

        } else {
            Log.warning("No tile image!? [type=" + type +
                        ", img=" + _tileImage + "].");
        }

//         // render our features
//         for (int i = 0; i < features.length; i++) {
//             // paint the feature
//             features[i].paint(g, orientation, claims[i]);
//         }

        // if we have a shield, draw a square in the lower right
        if (hasShield) {
            Point2D sspot = FeatureUtil.getShieldSpot(orientation);
            Image image = getShieldImage();

            if (image != null) {
                int iwidth = image.getWidth(null);
                int iheight = image.getHeight(null);
                Composite ocomp = g.getComposite();
                g.setComposite(ALPHA_PLACING);
                g.drawImage(image, (int)(sspot.getX() - iwidth/2),
                            (int)(sspot.getY() - iheight/2), null);
                g.setComposite(ocomp);

            } else {
                g.setColor(Color.orange);
                g.drawRect((int)(sspot.getX()-5),
                           (int)(sspot.getY()-5), 10, 10);
            }
        }

        // if we have a piecen on this tile, render it as well
        if (piecen != null || piecenDebug) {
            for (int i = 0; i < features.length; i++) {
                if (piecenDebug) {
                    Image pimg = PiecenUtil.getPiecenImage(0);
                    features[i].paintPiecen(g, orientation, pimg, 0);

                } else if (piecen.featureIndex == i) {
                    Image pimg = PiecenUtil.getPiecenImage(piecen.owner);
                    features[i].paintPiecen(
                        g, orientation, pimg, piecen.claimGroup);
                }
            }
        }

//          // draw a rectangular outline
//          g.setColor(Color.black);
//          g.drawRect(0, 0, TILE_WIDTH-1, TILE_HEIGHT-1);

        // translate back out
        g.translate(-sx, -sy);
    }

    /**
     * Returns a copy of this tile object.
     */
    public AtlantiTile clone ()
    {
        return new AtlantiTile(type, hasShield, orientation, x, y);
    }

    /**
     * Used to order tiles (which is done by board position).
     */
    public int compareTo (AtlantiTile tile)
    {
        return (tile == null) ? -1 :
            ((tile.x == x) ? y - tile.y : x - tile.x);
    }

    // documentation inherited
    public boolean equals (Object other)
    {
        if (other instanceof AtlantiTile) {
            return (compareTo((AtlantiTile)other) == 0);
        } else {
            return false;
        }
    }

    // documentation inherited
    public Comparable getKey ()
    {
        // a key is the coordinates conflated into one integer
        return new Integer((x + 128) * 256 + y + 128);
    }

    /**
     * After we've been unserialized we have to initialize some derived
     * fields.
     */
    public void readObject (ObjectInputStream in)
        throws IOException, ClassNotFoundException
    {
        in.defaultReadObject();
        initFeatures();
    }

    /**
     * Initializes this tile's feature management data structures.
     */
    protected void initFeatures ()
    {
        if (type > 0) {
            // grab a reference to our feature information
            features = FeatureUtil.getTileFeatures(type);

            // create our claims array
            claims = new int[features.length];

        } else {
            Log.warning("Requested to init features without valid type " +
                        this + ".");
            Thread.dumpStack();
        }
    }

    /**
     * Generates a string representation of this tile instance.
     */
    public String toString ()
    {
        return "[type=" + type + ", shield=" + hasShield +
            ", orient=" + ORIENT_NAMES[orientation] +
            ", pos=" + x + "/" + y +
            ", claims=" + StringUtil.toString(claims) +
            ", piecen=" + piecen + "]";
    }

    /**
     * Someone needs to configure this so that we can display tiles on
     * screen.
     */
    public static void setManagers (ImageManager imgr, TileManager tmgr)
    {
        _imgr = imgr;
        _tmgr = tmgr;
    }

    /**
     * Fetches the image for the tile of the specified type.
     */
    protected static Image getTileImage (int type)
    {
        // load up the tile set if we haven't already
        if (_tset == null) {
            _tset = _tmgr.loadTileSet(TILES_IMG_PATH, TILE_WIDTH, TILE_HEIGHT);
        }

        // fetch the tile
        return _tset.getRawTileImage(type-1);
    }

    /**
     * Fetches the shield image.
     */
    protected static Image getShieldImage ()
    {
        // load up the tile set if we haven't already
        if (_stset == null) {
            _stset = _tmgr.loadTileSet(
                SHIELD_IMG_PATH, SHIELD_SIZE, SHIELD_SIZE);
        }

        // fetch the tile
        return _stset.getRawTileImage(0);
    }

    /** The tile image that we use to render this tile. */
    protected transient Image _tileImage;

    /** Our image manager. */
    protected static ImageManager _imgr;

    /** Our tile manager. */
    protected static TileManager _tmgr;

    /** Our tile image tileset. */
    protected static UniformTileSet _tset;

    /** Our shield image tileset. */
    protected static UniformTileSet _stset;

    /** The path to our tileset image. */
    protected static final String TILES_IMG_PATH = "media/tiles.png";

    /** The path to our shield image. */
    protected static final String SHIELD_IMG_PATH = "media/shield.png";

    /** The size of the shield image (width and height). */
    protected static final int SHIELD_SIZE = 17;

    /** Three affine transforms for rendering an image in three rotated
     * orientations. */
    protected static AffineTransform[] _xforms;

    static {
        // the first element will be left blank
        _xforms = new AffineTransform[4];

        // create our three orientation transforms
        AffineTransform xform = new AffineTransform();
        for (int orient = 1; orient < 4; orient++) {
            // rotate the xform into the next orientation
            xform.translate(TILE_WIDTH, 0);
            xform.rotate(Math.PI/2);
            // and save it
            _xforms[orient] = (AffineTransform)xform.clone();
        }
    }

    /** For rendering shields with alpha. */
    protected static final Composite ALPHA_PLACING =
	AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.6f);
}
