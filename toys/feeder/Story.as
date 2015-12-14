package {

import flash.display.*;
import flash.events.*;
import flash.text.*;

import flash.net.*;

public class Story extends TextField
{
    public function Story (entry :Object)
    {
        width = 320;
        multiline = true;
        wordWrap = true;
        autoSize = TextFieldAutoSize.LEFT;

        styleSheet = createStyleSheet();

        htmlText = proc("<a class='title' href='"+entry.link+"'>"+entry.title+"</a>");
        htmlText += "<br><span class='date'>"+entry.publishedDate+"</span><br>";
        htmlText += "<br><span class='text'>"+proc(entry.content)+"</span><br>";
        //htmlText = "<a href='event:http://www.google.com'>hardcoded</a> hello world "+unfuck("<a href='http://www.google.com'>blah</a>");

        // TODO: Umm, this doesn't get fired when this TextField is in a scrollpane... ugh.
        addEventListener(TextEvent.LINK, function (event :TextEvent) :void {
            navigateToURL(new URLRequest(event.text));
        });
    }

    // Apparently web links don't work inside flex, so we have to prepend 'event:' to them and
    // listen for LINK events
    public static function proc (html :String) :String
    {
        //return html.replace(/<a\s+(.*)href=['"](.*)?['"]/g, "<a $1 href='event:$2'");
        //return html.replace(/href=['"](.*)?['"]/g, "href='event:$1'");
        return html;
    }

    // TODO: Move to Resources.as
    public static function createStyleSheet () :StyleSheet
    {
        var sheet :StyleSheet = new StyleSheet();
        sheet.setStyle("a", {
            color: "#0000ff",
            textDecoration: "underline"
        });
        sheet.setStyle(".title", {
            fontSize: "24px"
        });
        sheet.setStyle(".text", {
            fontSize: "14px"
        });

        return sheet;
    }
}

}
