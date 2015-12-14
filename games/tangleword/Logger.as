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
                        INVALID_WORD :String = "invalid",
                        DUPLICATE_WORD :String = "duplicate",
                        SUMMARY_H1 :String = "summaryH1",
                        SUMMARY_H2 :String = "summaryH2";
    
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

        // Init the default style
        addStyle({}, "");

        addStyle({
                color: "#0000ff",
                fontWeight: "bold"
            }, FOUND_WORD_FIRST);

        addStyle({
                color: "#0000ff"
            }, FOUND_WORD);

        addStyle({
                color: "#ff0000"
            }, INVALID_WORD);

        addStyle({
                color: "#a0a0a0"
            }, DUPLICATE_WORD);

        addStyle({
                fontSize: 14,
                fontWeight: "bold"
            }, SUMMARY_H1);

        addStyle({
                fontWeight: "bold"
            }, SUMMARY_H2);
    }

    /** Convenience method to set up a style for the textfield. */
    public function addStyle(css :Object, styleClass :String) :void
    {
        var style :Object = {};

        Util.init(style, css, {
                fontSize: 10,
                fontFamily: "Verdana"
            });

        _text.styleSheet.setStyle("."+styleClass, style);
    }

    /** Adds a line of text to the bottom of the logger */
    public function log (message :String = "", styleClass :String = "") :void
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
