//
// $Id$

package ghostbusters.data {

public class Codes
{
    /**
     * A per-room property that indicates the current state of ghost combat in the room.
     *
     * @see #STATE_SEEKING
     * @see #STATE_APPEARING
     * @see #STATE_FIGHTING
     * @see #STATE_GHOST_TRIUMPH
     * @see #STATE_GHOST_DEFEAT
     */
    public static const PROP_STATE :String = "st";

    /**
     * A state value signifying that there is a hidden ghost that players can see, and hunt,
     * if they turn on their lanterns.
     *
     * @see #PROP_STATE
     */
    public static const STATE_SEEKING :String = "seeking";
    /** A state value signifying the players have fully sought out the ghost, which is
     * running its 'appear' animation.
     *
     * @see #PROP_STATE
     */
    public static const STATE_APPEARING :String = "appearing";
    /** A state value signifying the ghost is visible without lanterns and attacking players
     * in the room.
     *
     * @see #PROP_STATE
     */
    public static const STATE_FIGHTING :String = "fighting";
    /** A state value signifying the ghost has defeated the players, and is playing its
     * triumph animation.
     *
     * @see #PROP_STATE
     */
    public static const STATE_GHOST_TRIUMPH :String = "triumph";
    /** A state value signifying the ghost has been defeated, and is playing its death
     * animation.
     *
     * @see #PROP_STATE
     */
    public static const STATE_GHOST_DEFEAT :String = "defeat";

    /**
     * Notification of the coordinates where a player's lantern is currently shining. 
     *
     * Dispatched by the client in the SEEK phase and ignored otherwise.
     */
    public static const CMSG_LANTERN_POS :String = "lp";

    /**
     * A player successfully hovered over the ghost with their lantern.
     *
     * Dispatched by the client in the SEEK phase and ignored otherwise.
     */
    public static const CMSG_GHOST_ZAP :String = "cgz";

    /**
     * A player has successfully completed their current minigame, damaging the ghost.
     *
     * Dispatched by the client in the FIGHT phase, ignored in other phases or if the
     * player is not associated with an active minigame.
     */
    public static const CMSG_MINIGAME_RESULT :String = "mgr";

    /**
     * A dead player has hit the 'revive me' button.
     *
     * Dispatched by the client in the SEEK phase, ignored in other phases or if the
     * player is not, in fact, dead.
     */
    public static const CMSG_PLAYER_REVIVE :String = "revive";

    /**
     * A player successfully hovered over the ghost with their lantern (server version).
     *
     * Dispatched by the server to the room to notify everybody there that somebody (not
     * necessarily they) zapped the ghost, and they should illustrate this fact.
     */
    public static const SMSG_GHOST_ZAPPED :String = "sgz";

    /**
     * The ghost was attacked by a player.
     *
     * Dispatched by the server to all the AVRG players in a room, and used by the client
     * to visualize the attack. TODO: add a 'attack type' argument.
     */
    public static const SMSG_GHOST_ATTACKED :String = "ga";

    /**
     * A player was attacked by the ghost.
     *
     * Dispatched by the server to all the AVRG players in a room, and used by the client
     * to visualize the attack. TODO: add a 'attack type' argument.
     */
    public static const SMSG_PLAYER_ATTACKED :String = "pa";

    /**
     * A player was killed.
     *
     * Dispatched by the server to all the AVRG players in a room, and used by the client
     * to visualize the player's death. TODO: may be obsoleted by health = 0.
     */
    public static const SMSG_PLAYER_DEATH :String = "pd";

    /**
     * The prefix for the PLAYER dictionary container which summarizes the current state
     * of a player in a room (currently health and max health). The full room property name
     * is constructed by appending the player's numerical id.
     *
     * @see #DICT_PLAYER
     */
    public static const DICT_PFX_PLAYER :String = "p";

    /**
     * The property name for the PLAYER dictionary container which summarizes the current state
     * of a player in their own property space. This data is copied into room properties when
     * the player walks into a new room.
     *
     * @see #DICT_PFX_PLAYER
     */
    public static const DICT_PLAYER :String = "p";

    /**
     * The current health of a player.
     * This is an index within the PLAYER dictionary.
     *
     * @see #DICT_PLAYER
     * @see #DICT_PFX_PLAYER
     */
    public static const IX_PLAYER_CUR_HEALTH :int = 0;

    /**
     * The maximum health of a player.
     * This is an index within the PLAYER dictionary.
     *
     * @see #DICT_PLAYER
     * @see #DICT_PFX_PLAYER
     */
    public static const IX_PLAYER_MAX_HEALTH :int = 1;

    /**
     * The room property name for the GHOST dictionary container which summarizes the current
     * state of a ghost in a room.
     */
    public static const DICT_GHOST :String = "g";

    /**
     * An identifier that summarizes the personality of a ghost: its name, its visualization
     * media on the client, the set of attacks at its disposal, and what method to run to do
     * server-side behaviour (AI).
     *
     * TODO: we should generate a range of possible names from a given id
     * TODO: all ghosts have the same (very small number of) attacks at the moment
     * TODO: all ghosts have the same behaviour
     *
     * This is an index within the GHOST dictionary.
     *
     * @see #DICT_GHOST
     */
    public static const IX_GHOST_ID :int = 0;

    /**
     * The name of the ghost. This is a human-readable string displayed in the UI.
     *
     * TODO: we should generate a range of possible names from a given id
     *
     * This is an index within the GHOST dictionary.
     *
     * @see #DICT_GHOST
     */
    public static const IX_GHOST_NAME:int = 1;

    /**
     * The ghost's level. The ferocity of the ghost's attack depends on its level as does its
     * maximum health (TODO) and zest (TODO). The level is calculated on a per-room basis so
     * that some rooms spawn high level ghosts, some lower-level.
     *
     * This is an index within the GHOST dictionary.
     *
     * @see #DICT_GHOST
     */
    public static const IX_GHOST_LEVEL:int = 2;

    /**
     * The current health of a ghost; players reduce a ghost's health by completing combat-
     * oriented minigames in the FIGHT phase. When a ghost's health reaches zero, the players
     * have won and the room transitions to the GHOST_DEFEAT phase.
     *
     * This is an index within the GHOST dictionary.
     *
     * @see #DICT_GHOST
     */
    public static const IX_GHOST_CUR_HEALTH :int = 3;

    /**
     * The maximum health of a ghost, i.e. the health of a fully healed ghost.
     *
     * This is an index within the GHOST dictionary.
     *
     * @see #DICT_GHOST
     */
    public static const IX_GHOST_MAX_HEALTH :int = 4;

    /**
     * The current zest of a ghost; players reduce a ghost's zest by shining their lanterns
     * on it during the SEEK phase. When zest reaches zero, we enter the APPEAR phase.
     *
     * This is an index within the GHOST dictionary.
     *
     * @see #DICT_GHOST
     */
    public static const IX_GHOST_CUR_ZEST :int = 5;

    /**
     * The maximum zest of a ghost.
     *
     * This is an index within the GHOST dictionary.
     *
     * @see #DICT_GHOST
     */
    public static const IX_GHOST_MAX_ZEST :int = 6;

    /**
     * The current position of the ghost in the room in logical coordinates. This value is
     * mostly of interest in the SEEK phase when the ghost moves around constantly.
     *
     * This is an index within the GHOST dictionary.
     *
     * @see #DICT_GHOST
     */
    public static const IX_GHOST_POS :int = 7;

    /**
     * A dictionary holding the current positions of all the lanterns in a room. Updates to
     * the positions are visualized real-time by each client. This data is deleted when we
     * transition from APPEAR to FIGHTING.
     */
    public static const DICT_LANTERNS :String = "l";

    /**
     * A dictionary holding the cumulative battle statistics for each player in a given
     * room. As different players fight a ghost, they contribute to its demise. When the
     * ghost dies, not all players are necessarily present; similarly, a player may have
     * accumulated kill contributions for several ghosts at once.
     *
     * Whenever a ghost dies in a room, the contents of this dictionary are used to
     * calculate how much of the reward should go to each player.
     */
    public static const DICT_STATS :String = "s";
}
}