//
// $Id$

package vampire.data {

import com.whirled.net.NetConstants;

public class Codes
{


    
//    /**
//     * A player has successfully completed their current minigame, damaging the ghost.
//     *
//     * Dispatched by the client in the FIGHT phase, ignored in other phases or if the
//     * player is not associated with an active minigame.
//     */
//    public static const CMSG_MINIGAME_RESULT :String = "mgr";
//
//    /**
//     * A dead player has hit the 'revive me' button.
//     *
//     * Dispatched by the client in the SEEK phase, ignored in other phases or if the
//     * player is not, in fact, dead.
//     */
//    public static const CMSG_PLAYER_REVIVE :String = "revive";
//
//    /**
//     * Debug request from the client. These are only granted by the agent if we're
//     * properly worthy. See below for message values.
//     */
//    public static const CMSG_DEBUG_REQUEST :String = "dbg";
//
//    /**
//     * Avatar choice request from the client. This happens when a new player has been shown the
//     * welcome screen and chosen either the male or the female avatar. The value is either
//     * AVT_MALE or AVT_FEMALE.
//     */
//    public static const CMSG_CHOOSE_AVATAR :String = "choose_avatar";
//
//    /**
//     * The player is done with the welcome splash screen and is ready to begin playing. This
//     * just toggles the IS_PLAYING property on the server.
//     */
//    public static const CMSG_BEGIN_PLAYING :String = "begin_playing";
//
//    /**
//     * A player successfully hovered over the ghost with their lantern (server version).
//     *
//     * Dispatched by the server to the room to notify everybody there that somebody (not
//     * necessarily they) zapped the ghost, and they should illustrate this fact.
//     */
//    public static const SMSG_GHOST_ZAPPED :String = "sgz";
//
//    /**
//     * The ghost was attacked by a player.
//     *
//     * Dispatched by the server to all the AVRG players in a room, and used by the client
//     * to visualize the attack. TODO: add a 'attack type' argument.
//     */
//    public static const SMSG_GHOST_ATTACKED :String = "ga";
//
//    /**
//     * A player was attacked by the ghost.
//     *
//     * Dispatched by the server to all the AVRG players in a room, and used by the client
//     * to visualize the attack. TODO: add a 'attack type' argument.
//     */
//    public static const SMSG_PLAYER_ATTACKED :String = "pa";
//
//    /**
//     * Debug request response from the agent. The value is just the original request (see below).
//     */
//    public static const SMSG_DEBUG_RESPONSE :String = "dbg";
//
//    /**
//     * The agent orders you to display a reboot warning.
//     */
//    public static const SMSG_REBOOT_WARNING :String = "rbw";
//
//    /**
//     * The prefix for the PLAYER dictionary container which summarizes the current state
//     * of a player in a room (currently health and max health). The full room property name
//     * is constructed by appending the player's numerical id.
//     */
//    public static const DICT_PFX_PLAYER :String = "p";
//
//    /**
//     * The current health of a player in a room. This is an index within the PLAYER dictionary.
//     *
//     * @see #DICT_PFX_PLAYER
//     */
//    public static const IX_PLAYER_CUR_HEALTH :int = 0;
//
//    /**
//     * The maximum health of a player in a room. This is an index within the PLAYER dictionary.
//     *
//     * @see #DICT_PFX_PLAYER
//     */
//    public static const IX_PLAYER_MAX_HEALTH :int = 1;
//
//    /**
//     * The number of ectopoints a player in a room has. This is an index within the PLAYER
//     * dictinoary.
//     *
//     * @see #DICT_PFX_PLAYER
//     */
//    public static const IX_PLAYER_POINTS :int = 2;
//
//    /**
//     * The level of a player in a room. This is an index within the PLAYER dictinoary.
//     *
//     * @see #DICT_PFX_PLAYER
//     */
//    public static const IX_PLAYER_LEVEL :int = 3;
//
//    /**
//     * Whether or not this player is taking active part in the game. This property is
//     * persistently stored in that player's property space.
//     */
//    public static const PROP_IS_PLAYING :String = NetConstants.makePersistent("playing");
//
//    /**
//     * The health of a player, persistently stored in that player's property space. This value
//     * is copied into a room's property space when a player enters that room.
//     */
//    public static const PROP_MY_BLOOD :String = NetConstants.makePersistent("health");
//
//    /**
//     * The ectopoints a player has, persistently stored in that player's property space. This
//     * value is copied into a room's property space when a player enters that room.
//     *
//     * This value cannot exceed the number of ectopoints needed for the next level; promotion
//     * happens automatically.
//     */
//    public static const PROP_MY_POINTS :String = NetConstants.makePersistent("points");
//
//    /**
//     * The level of a player, persistently stored in that player's property space. This value
//     * is copied into a room's property space when a player enters that room.
//     */
//    public static const PROP_MY_LEVEL :String = NetConstants.makePersistent("level");
//
//    /**
//     * The sex of this player's initial avatar choice. This value is null if the player
//     * has not yet chosen, else either AVT_MALE or AVT_FEMALE.
//     */
//    public static const PROP_AVATAR_TYPE :String = NetConstants.makePersistent("avtype");
//
//    /**
//     * The room property name for the GHOST dictionary container which summarizes the current
//     * state of a ghost in a room.
//     */
//    public static const DICT_GHOST :String = "g";
//
//    /**
//     * An identifier that summarizes the personality of a ghost: its name, its visualization
//     * media on the client, the set of attacks at its disposal, and what method to run to do
//     * server-side behaviour (AI).
//     *
//     * TODO: we should generate a range of possible names from a given id
//     * TODO: all ghosts have the same (very small number of) attacks at the moment
//     * TODO: all ghosts have the same behaviour
//     *
//     * This is an index within the GHOST dictionary.
//     *
//     * @see #DICT_GHOST
//     */
//    public static const IX_GHOST_ID :int = 0;
//
//    /**
//     * The name of the ghost. This is a human-readable string displayed in the UI.
//     *
//     * TODO: we should generate a range of possible names from a given id
//     *
//     * This is an index within the GHOST dictionary.
//     *
//     * @see #DICT_GHOST
//     */
//    public static const IX_GHOST_NAME:int = 1;
//
//    /**
//     * The ghost's level. The ferocity of the ghost's attack depends on its level as does its
//     * maximum health (TODO) and zest (TODO). The level is calculated on a per-room basis so
//     * that some rooms spawn high level ghosts, some lower-level.
//     *
//     * This is an index within the GHOST dictionary.
//     *
//     * @see #DICT_GHOST
//     */
//    public static const IX_GHOST_LEVEL:int = 2;
//
//    /**
//     * The current health of a ghost; players reduce a ghost's health by completing combat-
//     * oriented minigames in the FIGHT phase. When a ghost's health reaches zero, the players
//     * have won and the room transitions to the GHOST_DEFEAT phase.
//     *
//     * This is an index within the GHOST dictionary.
//     *
//     * @see #DICT_GHOST
//     */
//    public static const IX_GHOST_CUR_HEALTH :int = 3;
//
//    /**
//     * The maximum health of a ghost, i.e. the health of a fully healed ghost.
//     *
//     * This is an index within the GHOST dictionary.
//     *
//     * @see #DICT_GHOST
//     */
//    public static const IX_GHOST_MAX_HEALTH :int = 4;
//
//    /**
//     * The current zest of a ghost; players reduce a ghost's zest by shining their lanterns
//     * on it during the SEEK phase. When zest reaches zero, we enter the APPEAR phase.
//     *
//     * This is an index within the GHOST dictionary.
//     *
//     * @see #DICT_GHOST
//     */
//    public static const IX_GHOST_CUR_ZEST :int = 5;
//
//    /**
//     * The maximum zest of a ghost.
//     *
//     * This is an index within the GHOST dictionary.
//     *
//     * @see #DICT_GHOST
//     */
//    public static const IX_GHOST_MAX_ZEST :int = 6;
//
//    /**
//     * The current position of the ghost in the room in logical coordinates. This value is
//     * mostly of interest in the SEEK phase when the ghost moves around constantly.
//     *
//     * This is an index within the GHOST dictionary.
//     *
//     * @see #DICT_GHOST
//     */
//    public static const IX_GHOST_POS :int = 7;
//
//    /**
//     * A dictionary holding the current positions of all the lanterns in a room. Updates to
//     * the positions are visualized real-time by each client. This data is deleted when we
//     * transition from APPEAR to FIGHTING.
//     */
//    public static const DICT_LANTERNS :String = "l";
//
//    /**
//     * A dictionary holding the cumulative battle statistics for each player in a given
//     * room. As different players fight a ghost, they contribute to its demise. When the
//     * ghost dies, not all players are necessarily present; similarly, a player may have
//     * accumulated kill contributions for several ghosts at once.
//     *
//     * Whenever a ghost dies in a room, the contents of this dictionary are used to
//     * calculate how much of the reward should go to each player.
//     */
//    public static const DICT_STATS :String = "s";
//
//    /**
//     * A task identifier that signifies we defeated the current ghost!
//     */
//    public static const TASK_GHOST_DEFEATED :String = "ghost_defeated";
//
//    /** Debug requests -- see CMSG_DEBUG_REQUEST. */
//    public static const DBG_GIMME_PANEL :String = "gp";
//    public static const DBG_LEVEL_UP :String = "lu";
//    public static const DBG_LEVEL_DOWN :String = "ld";
//    public static const DBG_RESET_ROOM :String = "rr";
//    public static const DBG_END_STATE :String = "es";
//    public static const DBG_REBOOT_WARNING :String = "rw";
//
//    /** Trophy related per-player properties. */
//    public static const PROP_MINIGAME_PREFIX :String = NetConstants.makePersistent("minigame_");
//    public static const PROP_BLASTER_GAMES :String = NetConstants.makePersistent("blaster_games");
//    public static const PROP_OUIJA_GAMES :String = NetConstants.makePersistent("ouija_games");
//    public static const PROP_POTIONS_GAMES :String = NetConstants.makePersistent("potions_games");
//
//    public static const PROP_MEAN_KILLS :String = NetConstants.makePersistent("mean_kills");
//    public static const PROP_LEAGUE_KILLS :String = NetConstants.makePersistent("league_kills");
//    public static const PROP_LIBRARY_KILLS :String = NetConstants.makePersistent("library_kills");
//    public static const PROP_KILLS :String = NetConstants.makePersistent("kills");



    
    


//    /** Per-player properties. */
//    public static const PLAYER_SHARED_STATE_KEY :String = NetConstants.makePersistent("sharedPlayerState");
//    
//    /** Per-player properties. */
//    public static const PLAYER_FULL_STATE_KEY :String = NetConstants.makePersistent("fullPlayerState");
//    
//    
//    
//    /** Current amount of blood*/
//    public static const PLAYER_PROP_PREFIX_BLOOD :String = NetConstants.makePersistent("blood_");
//    
//    /** Current level.  This controls the max amount of blood*/
//    public static const PLAYER_PROP_PREFIX_LEVEL :String = NetConstants.makePersistent("level_");
//    
//    /** 
//    * Blood slowly drains away, even when you are asleep.  When starting a game, lose an amount
//    * of blood proportional to how long you have been asleep. 
//    */
//    public static const PLAYER_PROP_PREFIX_PREVIOUS_TIME_AWAKE :String = NetConstants.makePersistent("time_");
//    
//    /** 
//    * List of minions (people you invite into the game).
//    */
//    public static const PLAYER_PROP_PREFIX_MINIONS :String = NetConstants.makePersistent("minions_");
//    
//    /** 
//    * The vampire who makes you into a vampire.
//    */
//    public static const PLAYER_PROP_PREFIX_SIRE :String = NetConstants.makePersistent("sire_");
//    
//    /** 
//    * Player(s) currently bloodbonded to you.  Bloodbonding is romantic with minor game effects.
//    */
//    public static const PLAYER_PROP_PREFIX_BLOODBONDED :String = NetConstants.makePersistent("bloodbonded_");
    
    
    /**
     * Whether or not this player is taking active part in the game. This property is
     * persistently stored in that player's property space.
     */
    public static const PROP_IS_PLAYING :String = NetConstants.makePersistent("playing");


    

}
}
