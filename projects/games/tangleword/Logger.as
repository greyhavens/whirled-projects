package
{

import flash.display.Sprite;    
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.StyleSheet;

import com.threerings.util.Util;

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

        var style :Object, common :Object = {
                fontSize: 10,
                fontFamily: "Verdana"
            };

        _text.styleSheet.setStyle("body", common);

        // A bit of a hack to get around the fact that <span>s don't
        // inherit style properties like true CSS, so do a hard copy
        Util.init(style = {
                color: "#0000ff",
                fontWeight: "bold"
            }, common);
        _text.styleSheet.setStyle('.'+FOUND_WORD_FIRST, style);

        Util.init(style = {
                color: "#0000ff"
            }, common);
        _text.styleSheet.setStyle('.'+FOUND_WORD, style);

        Util.init(style = {
                color: "#ff0000"
            }, common);
        _text.styleSheet.setStyle('.'+INVALID_WORD, style);
    }

    /** Adds a line of text to the bottom of the logger */
    public function log (message :String, styleClass :String = "") :void
    {
        // Cancel out of listing mode
        if (_totalListed > 0) {
            _text.htmlText += "<br/>"
        }
        _totalListed = 0;

        _text.htmlText += "<p class='" + styleClass + "'>" + message + "</p>";
        update();
    }

    public override function update () :void
    {
        super.update();

        // If we can scroll to the bottom, do it
        if (verticalScrollBar.enabled) {
            // This throws an error if verticalScrollBar isn't enabled
            verticalScrollPosition = _text.height;
        }
    }

    public function logListItem (message :String, styleClass :String = "") :void
    {
        if (_totalListed > 0) {
            _text.htmlText += ", ";
        }

        _text.htmlText += "<span class='" + styleClass + "'>" + message + "</span>";
        _totalListed += 1;

        update();
    }

    /** Clears the log */
    public function clear () :void
    {
        _text.htmlText = "";
        update();
    }

    protected var _totalListed :int = 0;
    protected var _text :TextField = new TextField();
}


}
