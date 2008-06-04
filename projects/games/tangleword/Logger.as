package
{

import flash.display.Sprite;    
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.StyleSheet;

import fl.containers.ScrollPane;
import fl.controls.ScrollPolicy;
import fl.skins.DefaultScrollPaneSkins;

/**
   Logger class is an on-screen widget that takes lines of text and displays them.
   Pretty straightforward, no? :)
*/
public class Logger extends ScrollPane
{
    /** Max number of lines displayed in the log window */
    public static const MAX_LINES : uint = 16;

    public static const FOUND_WORD_FIRST :String = "foundFirst",
                        FOUND_WORD :String = "found",
                        INVALID_WORD :String = "invalid";
    
    // Set up the default skin for scroll pane
    DefaultScrollPaneSkins;

    // Constructor, sets everything up
    public function Logger (text :TextField)
    {
        _text = text;

        source = _text;
        verticalScrollPolicy = ScrollPolicy.ON;
        horizontalScrollPolicy = ScrollPolicy.OFF;

        _text.selectable = false;
        _text.borderColor = Resources.defaultBorderColor;
        _text.multiline = true;

        _text.autoSize = TextFieldAutoSize.LEFT;
        _text.wordWrap = true;

        _text.styleSheet = new StyleSheet();

        _text.styleSheet.setStyle("body", {
                fontSize: 10,
                fontFamily: "Verdana"
            });
        _text.styleSheet.setStyle('.'+FOUND_WORD_FIRST, {
                color: "#0000ff",
                fontWeight: "bold"
            });
        _text.styleSheet.setStyle('.'+FOUND_WORD, {
                color: "#0000ff"
            });
        _text.styleSheet.setStyle('.'+INVALID_WORD, {
                color: "#ff0000"
            });
    }

    /** Adds a line of text to the bottom of the logger */
    public function log (message :String, styleClass :String = "") :void
    {
        _text.htmlText += "<p class='" + styleClass + "'>" + message + "</p>";
        update();

        // If we can scroll to the bottom, do it
        if (verticalScrollBar.enabled) {
            // This throws an error if verticalScrollBar isn't enabled
            verticalScrollPosition = _text.height;
        }
    }

    /** Clears the log */
    public function clear () :void
    {
        _text.htmlText = "";
        update();
    }

    protected var _text :TextField = new TextField();
}


}
