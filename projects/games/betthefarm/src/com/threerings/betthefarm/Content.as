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

    [Embed(source="../../../../rsrc/farmbackground.png")]
    public static const BACKGROUND :Class;

    [Embed(source="../../../../rsrc/AnswerBubbles/AnswerBubble1.png")]
    public static const ANSWER_BUBBLE_1 :Class;

    [Embed(source="../../../../rsrc/AnswerBubbles/AnswerBubble2.png")]
    public static const ANSWER_BUBBLE_2 :Class;

    [Embed(source="../../../../rsrc/AnswerBubbles/AnswerBubble3.png")]
    public static const ANSWER_BUBBLE_3 :Class;

    [Embed(source="../../../../rsrc/AnswerBubbles/AnswerBubble4.png")]
    public static const ANSWER_BUBBLE_4 :Class;

    [Embed(source="../../../../rsrc/BuzzButton.png")]
    public static const BUZZ_BUTTON :Class;

    [Embed(source="../../../../rsrc/PlayerColors/PlayerBuzz.png")]
    public static const PLAQUE_TYPING :Class;

    [Embed(source="../../../../rsrc/PlayerColors/PlayerCorrect.png")]
    public static const PLAQUE_CORRECT :Class;

    [Embed(source="../../../../rsrc/PlayerColors/PlayerIncorrect.png")]
    public static const PLAQUE_INCORRECT :Class;

    [Embed(source="../../../../rsrc/PlayerColors/PlayerNormal.png")]
    public static const PLAQUE_NORMAL :Class;

    [Embed(source="../../../../rsrc/You Did Great.mp3")]
    public static const SND_Q_CORRECT :Class;

    [Embed(source="../../../../rsrc/You Lose.mp3")]
    public static const SND_Q_INCORRECT :Class;

    [Embed(source="../../../../rsrc/Happy Country Loop.mp3")]
    public static const SND_GAME_INTRO :Class;

    [Embed(source="../../../../rsrc/Bet The Farm Round.mp3")]
    public static const SND_ROUND_INTRO :Class;

    [Embed(source="../../../../rsrc/WelcomeFrontPage/WelcomeToTheFarm.png")]
    public static const IMG_WELCOME :Class;

    [Embed(source="../../../../rsrc/Rounds/LightningRound.png")]
    public static const IMG_ROUND_LIGHTNING :Class;

    [Embed(source="../../../../rsrc/Rounds/BuzzRound.png")]
    public static const IMG_ROUND_BUZZ :Class;

    [Embed(source="../../../../rsrc/Rounds/WagerRound.png")]
    public static const IMG_ROUND_WAGER :Class;

    // TIMER

    [Embed(source="../../../../rsrc/Timers/RoundTimer.png")]
    public static const IMG_TIMER_FACE :Class;

    [Embed(source="../../../../rsrc/Timers/HandNeedle.swf")]
    public static const SWF_TIMER_HAND :Class;

    public static const TIMER_LOC :Point = new Point(400, 165);


//    [Embed(source="../../../../rsrc/verdana.ttf",
//           fontWeight="normal", fontName="font")]
//    public static const FONT :Class;

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
        IMG_WELCOME,
        IMG_ROUND_BUZZ,
        IMG_ROUND_LIGHTNING,
        IMG_ROUND_WAGER,
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
    public static const DOOR_RECT :Rectangle = new Rectangle(150, 225, 270, 250);

    /** The location and dimensions of the answer field. */
    public static const ANSWER_RECT :Rectangle = new Rectangle(160, 225, 285, 250);

    /** The location and dimensions of the round name field. */
    public static const ROUND_RECT :Rectangle = new Rectangle(170, 145, 200, 40);

    /** The location and dimensions of the buzz button. */
    public static const BUZZ_LOC :Point = new Point(75, 90);

    /** The location and dimensions of the text entry field for free response questions. */
    public static const FREE_RESPONSE_RECT :Rectangle = new Rectangle(10, 170, 235, 80);

    /** The relative location of each answer field for multiple choice answers. */
    public static const ANSWER_BUBBLES :Array = [
        new Point(5, 120), new Point(130, 120), new Point(5, 185), new Point(130, 185)
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
