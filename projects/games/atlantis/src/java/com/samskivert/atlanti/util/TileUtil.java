//
// $Id: TileUtil.java,v 1.17 2002/12/12 05:51:55 mdb Exp $

package com.samskivert.atlanti.util;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

import com.samskivert.util.RandomUtil;

import com.threerings.presents.dobj.DSet;

import com.samskivert.atlanti.Log;
import com.samskivert.atlanti.data.AtlantiTile;
import com.samskivert.atlanti.data.Feature;
import com.samskivert.atlanti.data.Piecen;
import com.samskivert.atlanti.data.TileCodes;

/**
 * Utility functions relating to the Atlantissonne tiles.
 */
public class TileUtil implements TileCodes
{
    /** Enable to use smaller tileset when testing. */
    public static final boolean TESTING = false;

    /**
     * Returns an instance of the starting tile (properly cloned so that
     * it can be messed with by the server).
     */
    public static AtlantiTile getStartingTile ()
    {
        return AtlantiTile.STARTING_TILE.clone();
    }

    /**
     * Returns a list containing the standard tile set for the
     * Atlantissonne game. The list is a clone, so it can be bent, folded
     * and modified by the caller.
     */
    public static List<AtlantiTile> getStandardTileSet ()
    {
        // we need to deep copy the default tile set, so we can't just use
        // clone
        List<AtlantiTile> tiles = new ArrayList<AtlantiTile>();
        int tsize = TILE_SET.size();
        for (int i = 0; i < tsize; i++) {
            // when testing, we prune out most tiles to make games quicker
            if (!TESTING || RandomUtil.getInt(10) > 8) {
                tiles.add((TILE_SET.get(i)).clone());
            }
        }
        return tiles;
    }

    /**
     * Scans the supplied tile set to determine which of the four
     * orientations of the supplied target tile would result in a valid
     * placement of that tile (valid placement meaning that all of its
     * edges match up with neighboring tiles, it abuts at least one tile
     * and it does not occupy the same space as any existing tile). The
     * position of the target tile is assumed to be the desired placement
     * position and the current orientation of the target tile is ignored.
     *
     * @param tiles a list of the tiles on the board.
     * @param target the tile whose valid orientations we wish to compute.
     *
     * @return an array of boolean values indicating whether or not the
     * tile can be placed in each of the cardinal directions (which match
     * up with the direction constants specified in {@link TileCodes}.
     */
    public static boolean[] computeValidOrients (
        List<AtlantiTile> tiles, AtlantiTile target)
    {
        // this contains a count of tiles that match up with the candidate
        // tile in each of its four orientations
        int[] matches = new int[4];

        for (AtlantiTile tile : tiles) {
            // figure out where this tile is in relation to the candidate
            int xdiff = tile.x - target.x;
            int ydiff = tile.y - target.y;
            int sum = Math.abs(xdiff) + Math.abs(ydiff);

            if (sum == 0) {
                // they overlap, nothing doing
                return new boolean[4];

            } else if (sum ==  1) {
                // they're neighbors, we may have a match
                int targetEdge = EDGE_MAP[(ydiff+1)*3 + xdiff+1];

                // we want the edge of the placed tile that matches up
                // with the tile in the candidate location, but we also
                // need to take into account the orientation of the placed
                // tile
                int tileEdge = (targetEdge+(4-tile.orientation)+2) % 4;

                // we iterate over the four possible orientations of the
                // target tile
                for (int o = 0; o < 4; o++) {
                    // we compare the edge of the placed tile (which never
                    // changes) with the edge of the target tile which is
                    // adjusted based on the target tile's orientation
                    if (getEdge(tile.type, tileEdge) ==
                        getEdge(target.type, (targetEdge+(4-o)) % 4)) {
                        // increment the edge matches
                        matches[o]++;

                    } else {
                        // if we have a mismatch, we want to ensure that
                        // we screw this orientation up for good, so we
                        // deduct a large value from the array to ensure
                        // that it will remain less than zero regardless
                        // of which of the other three tiles match in this
                        // orientation
                        matches[o] -= 10;
                    }
                }
            }
        }

        // for every orientation that we have a positive number of edge
        // matches, we have a valid orientation
        boolean[] orients = new boolean[4];
        for (int i = 0; i < matches.length; i++) {
            orients[i] = (matches[i] > 0);
        }
        return orients;
    }

    /**
     * Returns true if the position and orientation of the target tile is
     * legal given the placement of all of the existing tiles.
     *
     * @param tiles a list of the tiles already on the board.
     * @param target the tile whose validity we want to determine.
     *
     * @return true if the target tile is configured with a valid position
     * and orientation, false if it is not.
     */
    public static boolean isValidPlacement (
        List<AtlantiTile> tiles, AtlantiTile target)
    {
        boolean matchedAnEdge = false;

        for (AtlantiTile tile : tiles) {
            // figure out where this tile is in relation to the candidate
            int xdiff = tile.x - target.x;
            int ydiff = tile.y - target.y;
            int sum = Math.abs(xdiff) + Math.abs(ydiff);

            if (sum == 0) {
                // they overlap, nothing doing
                Log.warning("Tile overlaps another [candidate=" + target +
                            ", overlapped=" + tile + "].");
                return false;

            } else if (sum ==  1) {
                // they're neighbors, we may have a match
                int targetEdge = EDGE_MAP[(ydiff+1)*3 + xdiff+1];

                // we want the edge of the placed tile that matches up
                // with the tile in the candidate location, but we also
                // need to take into account the orientation of the placed
                // tile
                int tileEdge = (targetEdge+(4-tile.orientation)+2) % 4;

                // now rotate the target edge according to our orientation
                targetEdge = ((targetEdge+(4-target.orientation)) % 4);

                // see if the edges match
                if (getEdge(tile.type, tileEdge) ==
                    getEdge(target.type, targetEdge)) {
                    // make a note that we matched at least one edge
                    matchedAnEdge = true;

                } else {
                    // the edges don't match, nothing doing
                    Log.warning("Edge mismatch [candidate=" + target +
                                ", tile=" + tile +
                                ", candidateEdge=" + targetEdge +
                                ", tileEdge=" + tileEdge + "].");
                    return false;
                }
            }
        }

        // if we got this far, we didn't have any mismatches, so we need
        // only know that we matched at least one edge
        return matchedAnEdge;
    }

    /**
     * When a tile is placed on the board, this method should be called on
     * it to propagate existing claims to the appropriate features on this
     * tile.  It will determine if any city features are connected to
     * cities that are already claimed, and if any road features are
     * connected to roads that are already claimed and if any grassland is
     * connected to grassland that is claimed.
     *
     * <p> If, in the process of initializing the claims for this tile, we
     * discover that this tile connects two previously disconnected
     * claims, those claims will be joined. The affected tiles and piecens
     * will have their claim groups updated.
     *
     * @param tiles a sorted list of the tiles on the board (which need
     * not include the tile whose features are being configured).
     * @param tile the tile whose features should be configured.
     */
    public static void inheritClaims (List<AtlantiTile> tiles, AtlantiTile tile)
    {
        List<TileFeature> flist = new ArrayList<TileFeature>();

        // for each feature in the tile, load up its claim group and make
        // sure all features in that group (which will include our new
        // feature) now have the same claim number
        for (int i = 0; i < tile.features.length; i ++) {
            int claimGroup = 0;

            // clear out the tilefeatures list before enumerating
            flist.clear();

            // enumerate the claim group for this feature
            enumerateGroup(tiles, tile, i, flist);

            // find the first non-zero claim number
            for (int t = 0; t < flist.size(); t++) {
                TileFeature feat = flist.get(t);
                int fcg = feat.tile.claims[feat.featureIndex];
                if (fcg != 0) {
                    claimGroup = fcg;
                    break;
                }
            }

            // if we found no non-zero claim number, we've nothing to
            // inherit
            if (claimGroup == 0) {
                continue;
            }

            // otherwise, assign our new claim number to all members of
            // the group (potentially causing some to inherit the new
            // claim number)
            for (int t = 0; t < flist.size(); t++) {
                TileFeature feat = flist.get(t);
                // set the claim group in the tile
                feat.tile.claims[feat.featureIndex] = claimGroup;
                // also set the claim group on the piecen if the tile has
                // an associated piecen that is on this feature
                Piecen p = feat.tile.piecen;
                if (p != null && p.featureIndex == feat.featureIndex) {
                    p.claimGroup = claimGroup;
                }
            }
        }
    }

    /**
     * Sets the claim group for the specified feature in this tile and
     * propagates that claim group to all connected features.
     *
     * @param tiles a sorted list of the tiles on the board.
     * @param tile the tile that contains the feature whose claim group is
     * being set.
     * @param featureIndex the index of the feature.
     * @param claimGroup the claim group value to set.
     */
    public static void setClaimGroup (
        List<AtlantiTile> tiles, AtlantiTile tile, int featureIndex,
        int claimGroup)
    {
        // load up this feature group
        List<TileFeature> flist = new ArrayList<TileFeature>();
        enumerateGroup(tiles, tile, featureIndex, flist);

        // and assign the claim number to all features in the group
        for (int t = 0; t < flist.size(); t++) {
            TileFeature feat = flist.get(t);
            feat.tile.claims[feat.featureIndex] = claimGroup;
        }
    }

    /**
     * Computes the score for the specified feature and returns it. If the
     * feature is complete (has no unconnected edges), the score will be
     * positive. If it is incomplete, the score will be negative.
     *
     * @param tiles a sorted list of the tiles on the board.
     * @param tile the tile that contains the feature whose score should
     * be computed.
     * @param featureIndex the index of the feature in the containing
     * tile.
     *
     * @return a positive score for a completed feature group, a negative
     * score for a partial feature group.
     */
    public static int computeFeatureScore (
        List<AtlantiTile> tiles, AtlantiTile tile, int featureIndex)
    {
        Feature feature = tile.features[featureIndex];

        if (feature.type == CLOISTER) {
            // cloister's score specially
            return computeCloisterScore(tiles, tile);

        } else if (feature.type == GRASS) {
            // grass doesn't score
            return 0;
        }

        // if we're here, it's a road or city feature, which we score by
        // loading up the group and counting the number of tiles in it
        List<TileFeature> flist = new ArrayList<TileFeature>();
        boolean complete = enumerateGroup(tiles, tile, featureIndex, flist);

        // we sort the group which will order the tile feature objects by
        // their tiles, ensuring that features on the same tile are next
        // to one another, so that we can only count them once
        Collections.sort(flist);

        // now iterate over the list, counting only unique tiles
        int score = 0;
        AtlantiTile lastTile = null;
        int fsize = flist.size();
        for (int i = 0; i < fsize; i++) {
            TileFeature feat = flist.get(i);
            if (feat.tile != lastTile) {
                score++;
                lastTile = feat.tile;
            }
        }

        // for city groups, we need to add a bonus of one for every tile
        // that contains a shield and mutiply by two if the city is
        // complete and larger than two tiles
        if (feature.type == CITY) {
            for (int t = 0; t < flist.size(); t++) {
                TileFeature feat = flist.get(t);
                if (feat.tile.hasShield) {
                    score++;
                }
            }
            if (complete && score > 2) {
                score *= 2;
            }
        }

        // incomplete scores are reported in the negative
        return complete ? score : -score;
    }

    /**
     * A helper function for {@link
     * #computeFeatureScore(List,AtlantiTile,int)}.
     */
    protected static int computeCloisterScore (
        List<AtlantiTile> tiles, AtlantiTile tile)
    {
        int score = 0;

        // all we need to know are how many neighbors this guy has (we
        // count ourselves as well, just for code simplicity)
        for (int dx = -1; dx < 2; dx++) {
            for (int dy = -1; dy < 2; dy++) {
                if (findTile(tiles, tile.x + dx, tile.y + dy) != null) {
                    score++;
                }
            }
        }

        // incomplete cloisters return a negative score
        return (score == 9) ? 9 : -score;
    }

    /**
     * Clears out the claim group information for incomplete cities so
     * that we can ignore them during farm scoring. Assigns new claim
     * group values to any completed cities that were unclaimed.
     *
     * @param tiles a sorted list of tiles on the board.
     */
    public static void prepCitiesForScoring (List<AtlantiTile> tiles)
    {
        List<TileFeature> flist = new ArrayList<TileFeature>();

        // iterate over the tiles, marking every city completed or not
        for (AtlantiTile tile : tiles) {
            // iterate over each feature on this tile
            for (int f = 0; f < tile.features.length; f++) {
                // skip non-city features
                if (tile.features[f].type != TileCodes.CITY) {
                    continue;
                }

                // clear out the feature group list before processing
                flist.clear();

                // enumerate the features in the group with this feature
                if (enumerateGroup(tiles, tile, f, flist)) {
                    // if it's complete, we want to ensure that all of
                    // these features have a claim number
                    if (tile.claims[f] != 0) {
                        // it's complete and has a claim number. move on
                        continue;
                    }

                    // assign the claim number to all features in the group
                    int claimGroup = nextClaimGroup();
                    for (int t = 0; t < flist.size(); t++) {
                        TileFeature feat = flist.get(t);
                        feat.tile.claims[feat.featureIndex] = claimGroup;
                        if (t == 0) {
                            Log.debug("Claiming complete city " +
                                      "[claim=" + feat.tile.claims[
                                          feat.featureIndex] + "].");
                        }
                    }

                } else {
                    // it's incomplete, so we want to clear out the claim
                    // number from all tiles in the group
                    for (int t = 0; t < flist.size(); t++) {
                        TileFeature feat = flist.get(t);
                        if (t == 0) {
                            Log.debug("Clearing incomplete city " +
                                      "[claim=" + feat.tile.claims[
                                          feat.featureIndex] + "].");
                        }
                        feat.tile.claims[feat.featureIndex] = 0;
                    }
                }
            }
        }
    }

    /**
     * Enumerates all of the features that are in the group of which the
     * specified feature is a member.
     *
     * @param tiles a sorted list of the tiles on the board.
     * @param tile the tile that contains the feature whose group is to be
     * enumerated.
     * @param featureIndex the index of the feature whose group is to be
     * enumerated.
     * @param group the list into which instances of {@link TileFeature}
     * will be placed that represent the features that are members of the
     * group.
     *
     * @return true if the group is complete (has no unconnected
     * features), false if it is not.
     */
    protected static boolean enumerateGroup (
        List<AtlantiTile> tiles, AtlantiTile tile, int featureIndex,
        List<TileFeature> group)
    {
        // create a tilefeature for this feature
        TileFeature feat = new TileFeature(tile, featureIndex);

        // determine whether or not this feature is already in the group
        if (group.contains(feat)) {
            return true;
        }

        // otherwise add this feature to the group and process this
        // feature's neighbors
        group.add(feat);

        boolean complete = true;
        int ftype = tile.features[featureIndex].type;
        int fmask = tile.features[featureIndex].edgeMask;

        // iterate over all of the possible adjacency possibilities
        for (int c = 0; c < FeatureUtil.ADJACENCY_MAP.length; c += 3) {
            int mask = FeatureUtil.ADJACENCY_MAP[c];
            int opp_mask = FeatureUtil.ADJACENCY_MAP[c+2];

            // if this feature doesn't have this edge, skip it
            if ((fmask & mask) == 0) {
                continue;
            }

            // look up our neighbor
            AtlantiTile neighbor = null;
            int dir = FeatureUtil.ADJACENCY_MAP[c+1];
            dir = (dir + tile.orientation) % 4;
            switch (dir) {
            case NORTH: neighbor = findTile(tiles, tile.x, tile.y-1); break;
            case EAST: neighbor = findTile(tiles, tile.x+1, tile.y); break;
            case SOUTH: neighbor = findTile(tiles, tile.x, tile.y+1); break;
            case WEST: neighbor = findTile(tiles, tile.x-1, tile.y); break;
            }

            // make sure we have a neighbor in this direction
            if (neighbor == null) {
                // if we don't have a neighbor in a direction that we
                // need, we're an incomplete feature. alas
                complete = false;
                continue;
            }

            // translate the target mask into our orientation
            mask = FeatureUtil.translateMask(mask, tile.orientation);
            opp_mask = FeatureUtil.translateMask(opp_mask, tile.orientation);

            // obtain the index of the feature on the opposing tile
            int nFeatureIndex = neighbor.getFeatureIndex(opp_mask);
            if (nFeatureIndex < 0) {
                Log.warning("Tile mismatch while grouping [tile=" + tile +
                            "featIdx=" + featureIndex +
                            ", neighbor=" + neighbor +
                            ", nFeatIdx=" + nFeatureIndex +
                            ", srcEdge=" + mask +
                            ", destEdge=" + opp_mask + "].");
                continue;
            }

            // add this feature and its neighbors to the group
            if (!enumerateGroup(tiles, neighbor, nFeatureIndex, group)) {
                // if our neighbor was incomplete, we become incomplete.
                // as dr. evil might say, "you incomplete me."
                complete = false;
            }
        }

        return complete;
    }

    /**
     * Locates and returns the tile with the specified coordinates.
     *
     * @param tiles a sorted list of tiles.
     *
     * @return the tile with the requested coordinates or null if no tile
     * exists at those coordinates.
     */
    public static AtlantiTile findTile (List<AtlantiTile> tiles, int x, int y)
    {
        AtlantiTile key = new AtlantiTile();
        key.x = x;
        key.y = y;
        int tidx = Collections.binarySearch(tiles, key);
        return (tidx >= 0) ? tiles.get(tidx) : null;
    }

    /**
     * Returns the number of piecens on the board owned the specified
     * player. This can be used when we need to count piecens and the
     * server potentially hasn't gotten around to processing piecen
     * removal events quite yet.
     *
     * @param tiles a list of the tiles on the board.
     * @param playerIndex the index of the player whose piecen count is
     * desired.
     */
    public static int countPiecens (List<AtlantiTile> tiles, int playerIndex)
    {
        int count = 0;
        for (int i = 0; i < tiles.size(); i++) {
            AtlantiTile tile = tiles.get(i);
            if (tile.piecen != null &&
                tile.piecen.owner == playerIndex) {
                count++;
            }
        }
        return count;
    }

    /**
     * Returns the number of piecens on the board owned the specified
     * player.
     *
     * @param piecens the piecens set from the game object.
     * @param playerIndex the index of the player whose piecen count is
     * desired.
     */
    public static int countPiecens (DSet piecens, int playerIndex)
    {
        int count = 0;
        Iterator iter = piecens.iterator();
        while (iter.hasNext()) {
            if (((Piecen)iter.next()).owner == playerIndex) {
                count++;
            }
        }
        return count;
    }

    /**
     * Returns the edge type for specified edge of the specified tile
     * type.
     *
     * @param tileType the type of the tile in question.
     * @param edge the direction constant indicating the edge in which we
     * are interested.
     *
     * @return the edge constant for the edge in question.
     */
    public static int getEdge (int tileType, int edge)
    {
        return TILE_EDGES[4*tileType + edge];
    }

    /**
     * Returns the next unused claim group value.
     */
    public static int nextClaimGroup ()
    {
        return ++_claimGroupCounter;
    }

    /** Used to generate our standard tile set. */
    protected static void addTiles (
        int count, List<AtlantiTile> list, AtlantiTile tile)
    {
        for (int i = 0; i  < count; i++) {
            list.add(tile);
        }
    }

    /** Used to keep track of actual features on tiles. */
    protected static final class TileFeature
        implements Comparable<TileFeature>
    {
        /** The tile that contains the feature. */
        public AtlantiTile tile;

        /** The index of the feature in the tile. */
        public int featureIndex;

        /** Constructs a new tile feature. */
        public TileFeature (AtlantiTile tile, int featureIndex)
        {
            this.tile = tile;
            this.featureIndex = featureIndex;
        }

        /** Properly implement equality. */
        public boolean equals (Object other)
        {
            if (other == null ||
                !(other instanceof TileFeature)) {
                return false;

            } else {
                TileFeature feat = (TileFeature)other;
                return (feat.tile == tile &&
                        feat.featureIndex == featureIndex);
            }
        }

        /** We sort based on our tiles. */
        public int compareTo (TileFeature other)
        {
            return tile.compareTo(other.tile);
        }

        /** Generate a string representation. */
        public String toString ()
        {
            return "[tile=" + tile + ", fidx=" + featureIndex + "]";
        }
    }

    /** Used to generate claim group values. */
    protected static int _claimGroupCounter;

    /** Used to figure out which edges match up to which when comparing
     * adjacent tiles. */
    protected static final int[] EDGE_MAP = {
        -1, NORTH, -1,
        WEST, -1, EAST,
        -1, SOUTH, -1
    };

    /** A table indicating which tiles have which edges. */
    protected static final int[] TILE_EDGES = {
        -1, -1, -1, -1, // null tile
        CITY, CITY, CITY, CITY, // CITY_FOUR
        CITY, CITY, GRASS, CITY, // CITY_THREE
        CITY, CITY, ROAD, CITY, // CITY_THREE_ROAD
        CITY, GRASS, GRASS, CITY, // CITY_TWO
        CITY, ROAD, ROAD, CITY, // CITY_TWO_ROAD
        GRASS, CITY, GRASS, CITY, // CITY_TWO_ACROSS
        CITY, CITY, GRASS, GRASS, // TWO_CITY_TWO
        GRASS, CITY, GRASS, CITY, // TWO_CITY_TWO_ACROSS
        CITY, GRASS, GRASS, GRASS, // CITY_ONE
        CITY, ROAD, ROAD, GRASS, // CITY_ONE_ROAD_RIGHT
        CITY, GRASS, ROAD, ROAD, // CITY_ONE_ROAD_LEFT
        CITY, ROAD, ROAD, ROAD, // CITY_ONE_ROAD_TEE
        CITY, ROAD, GRASS, ROAD, // CITY_ONE_ROAD_STRAIGHT
        GRASS, GRASS, GRASS, GRASS, // CLOISTER_PLAIN
        GRASS, GRASS, ROAD, GRASS, // CLOISTER_ROAD
        ROAD, ROAD, ROAD, ROAD, // FOUR_WAY_ROAD
        GRASS, ROAD, ROAD, ROAD, // THREE_WAY_ROAD
        ROAD, GRASS, ROAD, GRASS, // STRAIGHT_ROAD
        GRASS, GRASS, ROAD, ROAD, // CURVED_ROAD
    };

    /** The standard tile set for a game of Atlantissonne. */
    protected static ArrayList<AtlantiTile> TILE_SET =
        new ArrayList<AtlantiTile>();

    // create our standard tile set
    static {
        addTiles(1, TILE_SET, new AtlantiTile(CITY_FOUR, true));

        addTiles(3, TILE_SET, new AtlantiTile(CITY_THREE, false));
        addTiles(1, TILE_SET, new AtlantiTile(CITY_THREE, true));
        addTiles(1, TILE_SET, new AtlantiTile(CITY_THREE_ROAD, false));
        addTiles(2, TILE_SET, new AtlantiTile(CITY_THREE_ROAD, true));

        addTiles(3, TILE_SET, new AtlantiTile(CITY_TWO, false));
        addTiles(2, TILE_SET, new AtlantiTile(CITY_TWO, true));
        addTiles(3, TILE_SET, new AtlantiTile(CITY_TWO_ROAD, false));
        addTiles(2, TILE_SET, new AtlantiTile(CITY_TWO_ROAD, true));
        addTiles(1, TILE_SET, new AtlantiTile(CITY_TWO_ACROSS, false));
        addTiles(2, TILE_SET, new AtlantiTile(CITY_TWO_ACROSS, true));

        addTiles(2, TILE_SET, new AtlantiTile(TWO_CITY_TWO, false));
        addTiles(3, TILE_SET, new AtlantiTile(TWO_CITY_TWO_ACROSS, false));

        addTiles(5, TILE_SET, new AtlantiTile(CITY_ONE, false));
        addTiles(3, TILE_SET, new AtlantiTile(CITY_ONE_ROAD_RIGHT, false));
        addTiles(3, TILE_SET, new AtlantiTile(CITY_ONE_ROAD_LEFT, false));
        addTiles(3, TILE_SET, new AtlantiTile(CITY_ONE_ROAD_TEE, false));
        addTiles(3, TILE_SET, new AtlantiTile(CITY_ONE_ROAD_STRAIGHT, false));

        addTiles(4, TILE_SET, new AtlantiTile(CLOISTER_PLAIN, false));
        addTiles(2, TILE_SET, new AtlantiTile(CLOISTER_ROAD, false));

        addTiles(1, TILE_SET, new AtlantiTile(FOUR_WAY_ROAD, false));
        addTiles(4, TILE_SET, new AtlantiTile(THREE_WAY_ROAD, false));
        addTiles(8, TILE_SET, new AtlantiTile(STRAIGHT_ROAD, false));
        addTiles(9, TILE_SET, new AtlantiTile(CURVED_ROAD, false));
    }
}
