package
{

import flash.display.Sprite;    
import flash.text.TextField;
import flash.text.TextFormat; // TODO: Remove
import flash.text.StyleSheet;


/**
   Logger class is an on-screen widget that takes lines of text and displays them.
   Pretty straightforward, no? :)
*/
public class Logger extends TextField
{
    /** Max number of lines displayed in the log window */
    public static const MAX_LINES : uint = 16;

    public static const FOUND_WORD_FIRST :String = "foundFirst",
                        FOUND_WORD :String = "found",
                        INVALID_WORD :String = "invalid";
    
    // Constructor, sets everything up
    public function Logger ()
    {
        this.selectable = false;
        this.borderColor = Resources.defaultBorderColor;
//        this.border = true;
        this.multiline = true;

        styleSheet = new StyleSheet();

        styleSheet.setStyle("body", {
            fontSize: 10,
            fontFamily: "Verdana"
        });
        styleSheet.setStyle('.'+FOUND_WORD_FIRST, {
            color: "#0000ff"
        });
        styleSheet.setStyle('.'+FOUND_WORD, {
            color: "#0000cc"
        });
        styleSheet.setStyle('.'+INVALID_WORD, {
            color: "#ff0000"
        });
    }

    /** Adds a line of text to the bottom of the logger */
    public function Log (message : String, styleClass :String = "") : void
    {
        _lines.push ("<p class='" + styleClass + "'>" + message + "</p>");
        if (_lines.length > MAX_LINES) {
            _lines.shift ();
        }
        redraw ();
    }

    /** Clears the log */
    public function Clear () : void
    {
        _lines = new Array ();
        redraw ();
    }

    /** Redraws the text */
    private function redraw () : void
    {
        this.text = "";
        for each (var s: String in _lines) {
            this.htmlText += s;
        }
    }


    // PRIVATE VARIABLES
    private var _lines : Array = new Array ();
    

}


}
