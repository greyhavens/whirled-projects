package popcraft {

import core.AppObject;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

public class ResourceDisplay extends AppObject
{
    public function ResourceDisplay ()
    {
        _parent = new Sprite();

        // create the text fields for all the resources
        for each (var resourceType :ResourceType in GameConstants.RESOURCE_TYPES) {
            var format :TextFormat = new TextFormat();
            format.font = FONT_NAME;
            format.color = FONT_COLOR;
            format.size = FONT_SIZE;

            var label :TextField = new TextField();
            label.autoSize = TextFieldAutoSize.LEFT;
            label.selectable = false;
            label.defaultTextFormat = format;
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _parent;
    }

    protected function updateText () :void
    {

    }

    protected var _parent :Sprite;
    protected var _resourceText :Array = new Array();

    protected static const FONT_NAME :String = "Verdana";
    protected static const FONT_SIZE :int = 12;
    protected static const FONT_COLOR :uint = 0x000000;
}

}
