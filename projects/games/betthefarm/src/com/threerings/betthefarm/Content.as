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

    [Embed(source="../../../../rsrc/Background.jpg")]
    public static const BACKGROUND :Class;

    [Embed(source="../../../../rsrc/AnswerBubble1.png")]
    public static const ANSWER_BUBBLE_1 :Class;

    [Embed(source="../../../../rsrc/AnswerBubble2.png")]
    public static const ANSWER_BUBBLE_2 :Class;

    [Embed(source="../../../../rsrc/AnswerBubble3.png")]
    public static const ANSWER_BUBBLE_3 :Class;

    [Embed(source="../../../../rsrc/AnswerBubble4.png")]
    public static const ANSWER_BUBBLE_4 :Class;

    [Embed(source="../../../../rsrc/BuzzButton.png")]
    public static const BUZZ_BUTTON :Class;

    [Embed(source="../../../../rsrc/PlayerBuzz.png")]
    public static const PLAQUE_BUZZED :Class;

    [Embed(source="../../../../rsrc/PlayerCorrect.png")]
    public static const PLAQUE_CORRECT :Class;

    [Embed(source="../../../../rsrc/PlayerIncorrect.png")]
    public static const PLAQUE_INCORRECT :Class;

    [Embed(source="../../../../rsrc/PlayerNormal.png")]
    public static const PLAQUE_NORMAL :Class;

    [Embed(source="../../../../rsrc/You Did Great.mp3")]
    public static const SND_Q_CORRECT :Class;

    [Embed(source="../../../../rsrc/You Lose.mp3")]
    public static const SND_Q_INCORRECT :Class;

    [Embed(source="../../../../rsrc/Happy Country Loop.mp3")]
    public static const SND_GAME_INTRO :Class;

    [Embed(source="../../../../rsrc/Bet The Farm Round.mp3")]
    public static const SND_ROUND_INTRO :Class;

    [Embed(source="../../../../rsrc/steelfish.ttf", fontName="font")]
    public static const FONT :Class;

    public static const NUMBERS :Array = [
        "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"
    ];

    /** The types of the rounds. */
    public static const ROUND_TYPES :Array = [
        Model.ROUND_INTRO,
        Model.ROUND_LIGHTNING,
        Model.ROUND_BUZZ,
        Model.ROUND_WAGER,
    ];

    /** The names of the rounds. */
    public static const ROUND_NAMES :Array = [
        "Welcome to the farm",
        "Lightning Round",
        "Buzz Round",
        "Wager Round"
    ];

    /** The duration of the rounds, where applicable; measured in seconds or questions. */
    public static const ROUND_DURATIONS :Array = [
        -1,
        10,
        3,
        -1,
    ];

    /** The duration of the rounds, where applicable; measured in seconds or questions. */
    public static const ROUND_INTRO_DURATIONS :Array = [
        4,
        4,
        4,
        4,
    ];

    /** The duration of the round introductions, in seconds. */
    public static const INTRO_DURATION :int = 4;

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
    public static const BUZZBUTTON_RECT :Rectangle = new Rectangle(70, 110, 115, 40);

    /** The location and dimensions of the text entry field for free response questions. */
    public static const FREE_RESPONSE_RECT :Rectangle = new Rectangle(10, 170, 235, 80);

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

    /** The location of the four plaques of the four players. */
    public static const PLAQUE_LOCS :Array = [
        new Point(542, 384),
        new Point(645, 406),
        new Point(748, 418),
        new Point(851, 430),
    ];
}
}
