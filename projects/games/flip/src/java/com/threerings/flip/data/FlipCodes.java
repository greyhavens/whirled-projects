//
// $Id$

package com.threerings.flip.data;

import java.awt.Font;

/**
 * Codes for the game of Flip.
 */
public interface FlipCodes
{
    /** The Flip message bundle. */
    public static final String FLIP_MESSAGE_BUNDLE = "roister.board.flip";

    /** Name of the message a player sends the server to drop a ball. */
    public static final String DROP = "drop";

    /** The height of the board. */
    public static final int HEIGHT = 5;

    /** The total number of rounds in a game. */
    public static final int ROUNDS = 4;

    /** Point structure constants. */
    public static final int STANDARD_POINTS = 0;
    public static final int ROUND_4_HALVED = 1;

    /** The points structure for each round. */
    public static final short[][][] POINTS = new short[][][] {
        {
            {  2,  2,  2,  2,  2,  2,  2,  2,  2 },
            { 34, 21, 13,  8,  5,  3,  2,  1,  1 },
            {  9,  8,  7,  6,  5,  4,  3,  2,  1 },
            { 64, 49, 36, 25, 16,  9,  4,  1, -1 }
        },
        {
            {  2,  2,  2,  2,  2,  2,  2,  2,  2 },
            { 34, 21, 13,  8,  5,  3,  2,  1,  1 },
            {  9,  8,  7,  6,  5,  4,  3,  2,  1 },
            { 32, 24, 18, 12,  8,  4,  2,  1, -1 }
        }
    };

    /** The target number of points needed to finish the round. */
    public static final int[] POINT_TARGETS = new int[] { 10, 40, 20, 80 };

    // TODO
    public static final Font SMALL_FONT = new Font("Dialog", Font.PLAIN, 12);
    public static final Font MEDIUM_FONT = new Font("Dialog", Font.PLAIN, 14);
    public static final Font BIG_FONT = new Font("Dialog", Font.PLAIN, 18);
    public static final Font HUGE_FONT = new Font("Dialog", Font.PLAIN, 30);
}
