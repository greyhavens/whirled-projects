﻿package vampire.data
{
import com.threerings.flash.Vector2;

public class VConstants
{
    public static var LOCAL_DEBUG_MODE :Boolean = false;

    public static const PLAYERS_IN_ROOM_TRIGGERING_BALANCING :int = 8;
    /**
    * If you're not related to the ubervamp
    */
    public static const UBER_VAMP_ID :int = 383387;
    //ubervamp localhost == 12
    //ubervamp dev.whirled == 1877, 382856
    //uvervamp Whirled == 383387

    public static const FEEDING_ROUNDS_TO_FORM_BLOODBOND :int = 6;

    public static const UNIQUE_BLOOD_STRAINS :int = 12;

    /**
    * The fraction of xp gained from feeding that your bloodbond also gets.
    */
    public static const BLOOD_BOND_FEEDING_XP_BONUS :Number = 0.05;


    /**
    * Blood gains are shared with sires.
    * e.g.
    * Blood gained by minion = 50
    * Minion has 10 sires.
    * Blood shared among all sires = 0.1*50 = 5
    * Each sire gets 5/10=0.5 blood.
    */
    public static const XP_GAIN_FRACTION_SHARED_WITH_IMMEDIATE_SIRE :Number = 0.01;

    public static const XP_GAIN_FRACTION_SHARED_WITH_GRANDSIRES :Number = 0.001;

    /**
    * For every unit of blood gained from feeding, how much experience is gained.
    */
    public static const XP_GAINED_FROM_FEEDING_PER_BLOOD_UNIT :Number = 1;

    /**
    * Max blood non-players
    */
    public static const MAX_BLOOD_NONPLAYERS :Number = 80;

    /**We cap the max level for now.*/
    public static const MAXIMUM_VAMPIRE_LEVEL :int = 10;

    //Possible avatar states
    public static const AVATAR_STATE_DEFAULT :String = "Default";
    public static const AVATAR_STATE_MOVING_TO_FEED :String = "MoveToFeeding";
    public static const AVATAR_STATE_FEEDING :String = "Feeding";
    public static const AVATAR_STATE_BARED :String = "Bared";

    //Game states.  There is a mapping from game state to player state
    public static const PLAYER_STATE_DEFAULT :String = "Default";
    public static const PLAYER_STATE_MOVING_TO_FEED :String = "MoveToFeed";
    public static const PLAYER_STATE_BARED :String = "Bared";
    public static const PLAYER_STATE_ARRIVED_AT_FEEDING_LOCATION :String = "ArrivedToFeed";
    public static const PLAYER_STATE_FEEDING_PREDATOR :String = "FeedingPredator";
    public static const PLAYER_STATE_FEEDING_PREY :String = "FeedingPrey";


    public static const NOTIFICATION_TIME_XP :Number = 60 ;//* 10;

    /**
    * If the vampire 'feeds' on non-players, this is the player Id to use.
    *
    */
    public static const PLAYER_ID_NON_PLAYER :int = 0;

    public static const TEXT_INVITE :String = "Join my Bloodline!";
    public static const TEXT_NEW_LEVEL :String = "You have achieved level ";
    public static const TEXT_CONFIM_SIRE :String = "If you feed from this Lineage vampire, " +
        "they will become your permanent sire, allowing you to draw power from your progeny.  " +
        "Are you sure?";

    protected static const p4 :Number = Math.cos(Math.PI/4);
    public static const PREDATOR_LOCATIONS_RELATIVE_TO_PREY :Array = [
        [  0, 0,  0.01], //Behind
        [  1, 0,  0], //Left
        [ -1, 0,  0], //right
        [ p4, 0, p4], //North east
        [-p4, 0, p4],
        [ p4, 0,-p4],
        [-p4, 0,-p4],
        [ -2, 0,  0],
        [  2, 0,  0],
        [ -3, 0,  0],
        [  3, 0,  0],
        [ -4, 0,  0],
        [  5, 0,  0],
        [ -6, 0,  0],
        [  6, 0,  0]
    ];

    public static const BLOOD_STRAIN_NAMES :Array = [
        "Aries",
        "Taurus",
        "Gemini",
        "Cancer",
        "Leo",
        "Virgo",
        "Libra",
        "Scorpio",
        "Sagittarius",
        "Capricorn",
        "Aquarius",
        "Pisces"
    ];


}
}