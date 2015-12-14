//
// $Id: AtlantiObject.dobj,v 1.3 2004/08/27 18:56:44 mdb Exp $

package com.samskivert.atlanti.data;

import com.threerings.util.Name;
import com.threerings.presents.dobj.DSet;

import com.threerings.ezgame.data.EZGameObject;

import com.whirled.data.GameData;
import com.whirled.data.WhirledGame;
import com.whirled.data.WhirledGameMarshaller;

/**
 * The distributed object used to maintain state for the game.
 */
public class AtlantiObject extends EZGameObject
    implements WhirledGame
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>whirledGameService</code> field. */
    public static final String WHIRLED_GAME_SERVICE = "whirledGameService";

    /** The field name of the <code>gameData</code> field. */
    public static final String GAME_DATA = "gameData";

    /** The field name of the <code>tiles</code> field. */
    public static final String TILES = "tiles";

    /** The field name of the <code>currentTile</code> field. */
    public static final String CURRENT_TILE = "currentTile";

    /** The field name of the <code>piecens</code> field. */
    public static final String PIECENS = "piecens";

    /** The field name of the <code>scores</code> field. */
    public static final String SCORES = "scores";
    // AUTO-GENERATED: FIELDS END

    /** The whirled game services. */
    public WhirledGameMarshaller whirledGameService;

    /** The set of game data available to this game. */
    public GameData[] gameData;

    /** A set containing all of the tiles that are in play in this game. */
    public DSet<AtlantiTile> tiles = new DSet<AtlantiTile>();

    /** The tile being placed by the current turn holder. This value is only valid while it is
     * someone's turn. */
    public AtlantiTile currentTile = AtlantiTile.STARTING_TILE;

    /** A set containing all of the piecens that are placed on the board. */
    public DSet<Piecen> piecens = new DSet<Piecen>();

    /** The scores for each player. */
    public int[] scores;

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>whirledGameService</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setWhirledGameService (WhirledGameMarshaller value)
    {
        WhirledGameMarshaller ovalue = this.whirledGameService;
        requestAttributeChange(
            WHIRLED_GAME_SERVICE, value, ovalue);
        this.whirledGameService = value;
    }

    /**
     * Requests that the <code>gameData</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setGameData (GameData[] value)
    {
        GameData[] ovalue = this.gameData;
        requestAttributeChange(
            GAME_DATA, value, ovalue);
        this.gameData = (value == null) ? null : value.clone();
    }

    /**
     * Requests that the <code>index</code>th element of
     * <code>gameData</code> field be set to the specified value.
     * The local value will be updated immediately and an event will be
     * propagated through the system to notify all listeners that the
     * attribute did change. Proxied copies of this object (on clients)
     * will apply the value change when they received the attribute
     * changed notification.
     */
    public void setGameDataAt (GameData value, int index)
    {
        GameData ovalue = this.gameData[index];
        requestElementUpdate(
            GAME_DATA, index, value, ovalue);
        this.gameData[index] = value;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>tiles</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    public void addToTiles (AtlantiTile elem)
    {
        requestEntryAdd(TILES, tiles, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>tiles</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    public void removeFromTiles (Comparable key)
    {
        requestEntryRemove(TILES, tiles, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>tiles</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    public void updateTiles (AtlantiTile elem)
    {
        requestEntryUpdate(TILES, tiles, elem);
    }

    /**
     * Requests that the <code>tiles</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    public void setTiles (DSet<com.samskivert.atlanti.data.AtlantiTile> value)
    {
        requestAttributeChange(TILES, value, this.tiles);
        @SuppressWarnings("unchecked") DSet<com.samskivert.atlanti.data.AtlantiTile> clone =
            (value == null) ? null : value.typedClone();
        this.tiles = clone;
    }

    /**
     * Requests that the <code>currentTile</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setCurrentTile (AtlantiTile value)
    {
        AtlantiTile ovalue = this.currentTile;
        requestAttributeChange(
            CURRENT_TILE, value, ovalue);
        this.currentTile = value;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>piecens</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    public void addToPiecens (Piecen elem)
    {
        requestEntryAdd(PIECENS, piecens, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>piecens</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    public void removeFromPiecens (Comparable key)
    {
        requestEntryRemove(PIECENS, piecens, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>piecens</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    public void updatePiecens (Piecen elem)
    {
        requestEntryUpdate(PIECENS, piecens, elem);
    }

    /**
     * Requests that the <code>piecens</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    public void setPiecens (DSet<com.samskivert.atlanti.data.Piecen> value)
    {
        requestAttributeChange(PIECENS, value, this.piecens);
        @SuppressWarnings("unchecked") DSet<com.samskivert.atlanti.data.Piecen> clone =
            (value == null) ? null : value.typedClone();
        this.piecens = clone;
    }

    /**
     * Requests that the <code>scores</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setScores (int[] value)
    {
        int[] ovalue = this.scores;
        requestAttributeChange(
            SCORES, value, ovalue);
        this.scores = (value == null) ? null : value.clone();
    }

    /**
     * Requests that the <code>index</code>th element of
     * <code>scores</code> field be set to the specified value.
     * The local value will be updated immediately and an event will be
     * propagated through the system to notify all listeners that the
     * attribute did change. Proxied copies of this object (on clients)
     * will apply the value change when they received the attribute
     * changed notification.
     */
    public void setScoresAt (int value, int index)
    {
        int ovalue = this.scores[index];
        requestElementUpdate(
            SCORES, index, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.scores[index] = value;
    }
    // AUTO-GENERATED: METHODS END
}
