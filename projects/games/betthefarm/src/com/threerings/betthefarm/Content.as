//
// $Id$

package com.threerings.betthefarm {

import flash.geom.Rectangle;
import flash.geom.Point;

/**
 * Defines skinnable content.
 */
public class Content
{
    /** The types of the rounds. */
    public static const ROUND_TYPES :Array = [
        Model.ROUND_LIGHTNING,
        Model.ROUND_BUZZ,
        Model.ROUND_WAGER,
    ];

    /** The names of the rounds. */
    public static const ROUND_NAMES :Array = [
        "Lightning Round",
        "Buzz Round",
        "Wager Round"
    ];

    /** The duration of the rounds, where applicable; measured in seconds or questions. */
    public static const ROUND_DURATIONS :Array = [
        10,
        5,
        -1,
    ];

    /** The basic text font. */
    public static const FONT_NAME :String = "Verdana";

    /** The foreground text color. */
    public static const FONT_COLOR :uint = uint(0x000000);

    /** The location and dimensions of the question field. */
    public static const QUESTION_RECT :Rectangle = new Rectangle(175, 225, 255, 250);

    /** The location and dimensions of the answer field. */
    public static const ANSWER_RECT :Rectangle = new Rectangle(175, 225, 255, 250);

    /** The location and dimensions of the round name field. */
    public static const ROUND_RECT :Rectangle = new Rectangle(170, 145, 245, 40);

    /** The location and dimensions of the buzz button. */
    public static const BUZZBUTTON_RECT :Rectangle = new Rectangle(70, 120, 115, 40);

    /** The location and dimensions of the text entry field for free response questions. */
    public static const FREE_RESPONSE_RECT :Rectangle = new Rectangle(70, 170, 115, 20);

    /** The relative location of each answer field for multiple choice answers. */
    public static const ANSWER_RECTS :Array = [
        new Rectangle(5, 120, 120, 60),
        new Rectangle(130, 120, 120, 60),
        new Rectangle(5, 185, 120, 60),
        new Rectangle(130, 185, 120, 60)
    ];


    /** The location of the four headshots of the four players. */
    public static const HEADSHOT_LOCS :Array = [
        new Point(542, 280),
        new Point(645, 292),
        new Point(748, 304),
        new Point(851, 316),
    ];

    [Embed(source="../../../../rsrc/Background.jpg")]
    public static const BACKGROUND :Class;

}

}
