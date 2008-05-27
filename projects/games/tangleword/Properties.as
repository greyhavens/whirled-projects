package
{

import flash.geom.Point;
import flash.geom.Rectangle;

/**
   Constants which would normally be read from a config file;
   in this case, however, it seems we want them to be embedded in the SWF.
*/
public class Properties
{
    /** Default language/culture settings */
    public static const LOCALE :String = "en-us";

    /** Default round length, in seconds */
    public static const ROUND_LENGTH :int = 120;
    //public static const ROUND_LENGTH :int = 10;

    /** Default pause length */
    public static const PAUSE_LENGTH :int = 20;

    /**
     * Game display is composed of the letter board, and various
     * status windows TBD. This display size is the bounding box
     * of all these elements.
     */
    public static const DISPLAY :Rectangle = new Rectangle (0, 0, 600, 500);

    /**
     * The board contains a collection of letters arranged in a square.
     * The letter matrix will fill the board completely.
     */
    public static const BOARD :Rectangle = new Rectangle (48, 102, 250, 250);
    public static const BOARDPOS :Point = new Point(BOARD.x, BOARD.y);

    /** Position of a text box that displays currently selected word. */
    public static const WORDFIELD :Rectangle = new Rectangle (50, 370, 190, 28);

    /** Position of the OK button (automatically sized) */
    public static const OKBUTTON :Point = new Point (240, 362);

    /** Position of the log text field */
    public static const LOGFIELD :Rectangle = new Rectangle (360, 110, 178, 240);

    /** Position of the timer */
    public static const TIMER :Rectangle = new Rectangle (360, 370, 178, 28);

    /** Positions of the various stats display elements. */
    public static const STATS_TOPPLAYER :Rectangle =
        new Rectangle (100, 170, DISPLAY.width - 200, 40);
    public static const STATS_TOPSCORE  :Rectangle =
        new Rectangle (100, 200, DISPLAY.width - 200, 40);
    public static const STATS_WORDLIST  :Rectangle =
        new Rectangle (100, 240, DISPLAY.width - 200, 200);

    /** Each letter is a simple square - but we want to know how big to draw them.
        This is the width and height of each letter in pixels. */
    public static const LETTER_SIZE :int = 50;

    /** Letter display is arranged in a square; this number specifies the width
        and height of the letter matrix. */
    public static const LETTERS :int = 5;

    /** The total number of letters in the matrix. */
    public static const LETTER_COUNT :int = LETTERS * LETTERS;

    /** Splash screen: play button. */
    public static const PLAY :Point = new Point(328, 385);
    
    /** Splash screen: help button. */
    public static const HELP :Point = new Point(290, 420);
}
} // package
