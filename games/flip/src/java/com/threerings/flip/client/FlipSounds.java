//
// $Id$

package com.threerings.flip.client;

import com.threerings.media.sound.Sounds;

/**
 * Defines sounds used by the flip game.
 */
public class FlipSounds extends Sounds
{
    /** The package path that this class is in. */
    public static final String PACKAGE_PATH = getPackagePath(FlipSounds.class);

    /** Played when the user's turn is nearly over and they have yet to submit a move to the
     * server. */
    public static final String YOUR_TURN = "your_turn";

    /** The game is just starting. */
    public static final String GAME_START = "game_start";

    /** A ball is dropped into the board. */
    public static final String BALL_DROP = "ball_drop";

    /** A ball comes to rest on a flip. */
    public static final String BALL_LAND = "ball_land";

    /** A ball switches the position of a flip. */
    public static final String SWITCH_FLIP = "switch_flip";

    /** A ball hits another and then passes to the side. */
    public static final String BALL_PASS = "ball_pass";

    /** A ball pops up due to the switch it was resting on flipping. */
    public static final String BALL_POPUP = "ball_popup";

    /** A ball has fused into a double ball. */
    public static final String BALL_DOUBLE = "ball_double";

    /** A ball has fused into a triple ball. */
    public static final String BALL_TRIPLE = "ball_triple";

    /** A ball has fused into a quadruple ball. */
    public static final String BALL_QUADRUPLE = "ball_quadruple";

    /** A ball has split apart some. */
    public static final String BALL_SPLIT = "ball_split";

    /** A ball has scored some points. */
    public static final String BALL_SCORED = "ball_scored";

    /** A chest has opened. */
    public static final String CHEST_OPEN = "chest_open";

    /** Ye win! */
    public static final String YE_WIN = "ye_win";

    /** Ye lose... */
    public static final String YE_LOSE = "ye_lose";

    /** The sounds we lock. */
    public static final String[] LOCK_KEYS = {
        BALL_DROP, BALL_LAND, SWITCH_FLIP, BALL_PASS, BALL_POPUP,
        BALL_DOUBLE, BALL_TRIPLE, BALL_QUADRUPLE, BALL_SPLIT, BALL_SCORED
    };

    /**
     * Compute the delay after which to play the wee warning sound to a player.
     *
     * @param turnDelay the total time allocated to a player's turn.
     */
    public static long turnSoundDelay (long turnDuration)
    {
        // wait about 2/3 of the way through the player's turn
        return (long) (turnDuration * .65);
    }
}
