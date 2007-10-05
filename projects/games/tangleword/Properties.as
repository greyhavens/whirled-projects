package
{
import flash.geom.Rectangle;

/**
   Constants which would normally be read from a config file;
   in this case, however, it seems we want them to be embedded in the SWF.
*/
public class Properties
{
    /** Default language/culture settings */
    public static const LOCALE : String = "en-us";

    /** Default round length, in seconds */
    public static const ROUND_LENGTH :int = 120;

    /** Default pause length */
    public static const PAUSE_LENGTH :int = 30;

    /** The duration of the tick counter, must divide evenly into ROUND_LENGTH and PAUSE_LENGTH. */
    public static const TICK_SECONDS :int = 5;

    /**
       Game display is composed of the letter board, and various
       status windows TBD. This display size is the bounding box
       of all these elements.
    */
    public static const DISPLAY : Rectangle = new Rectangle (0, 0, 700, 500);

    /**
       The board contains a collection of letters arranged in a square.
       The letter matrix will fill the board completely.
    */
    public static const BOARD : Rectangle = new Rectangle (48, 102, 250, 250);

    /**
       Position of a text box that displays currently selected word.
    */
    public static const WORDFIELD : Rectangle = new Rectangle (50, 370, 190, 28);

    /**
       Position of the OK button
    */
    public static const OKBUTTON : Rectangle = new Rectangle (250, 370, 50, 28);

    /**
       Position of the score box
    */
    public static const SCOREFIELD : Rectangle = new Rectangle (360, 109, 178, 100);

    /**
       Position of the log text field
    */
    public static const LOGFIELD : Rectangle = new Rectangle (360, 226, 178, 130);

    /**
       Position of the timer
    */
    public static const TIMER : Rectangle = new Rectangle (360, 370, 178, 28);

    /** Each letter is a simple square - but we want to know how big to draw them.
        This is the width and height of each letter in pixels. */
    public static const LETTER_SIZE : int = 50;

    /** Letter display is arranged in a square; this number specifies the width
        and height of the letter matrix. */
    public static const LETTERS : int = 5;

    /** The total number of letters in the matrix. */
    public static const LETTER_COUNT : int = LETTERS * LETTERS;
}
} // package
