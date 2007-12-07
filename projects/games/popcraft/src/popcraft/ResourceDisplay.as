package popcraft {

import core.AppObject;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.GridFitType;
import flash.text.AntiAliasType;

public class ResourceDisplay extends AppObject
{
    public function ResourceDisplay ()
    {
        _parent = new Sprite();

        // create the text fields for all the resources
        var width :int = 0;
        var height :int = 0;

        for each (var resourceType :ResourceType in GameConstants.RESOURCE_TYPES) {
            var format :TextFormat = new TextFormat();
            format.font = FONT_NAME;
            format.color = resourceType.color;
            format.size = FONT_SIZE;

            var label :TextField = new TextField();
            label.autoSize = TextFieldAutoSize.NONE;
            label.selectable = false;
            label.defaultTextFormat = format;
            label.gridFitType = GridFitType.PIXEL;

            // determine what the width should be
            label.text = getDisplayString(resourceType.name, 9999);
            label.width = label.textWidth;
            label.height = label.textHeight;
            label.text = "";

            label.x = width;
            width += label.width + LABEL_OFFSET;
            height = Math.max(height, label.height);

            // can only anti-alias embedded fonts
            //label.antiAliasType = AntiAliasType.ADVANCED;
            //label.sharpness = 400; // max sharpness

            _resourceText.push(label);
            _parent.addChild(label);
        }

        // draw a background for the text
        _parent.graphics.beginFill(BG_COLOR);
        _parent.graphics.lineStyle(1, 0x000000);
        _parent.graphics.drawRect(0, 0, width, height);
        _parent.graphics.endFill();

        updateText();
    }

    override public function get displayObject () :DisplayObject
    {
        return _parent;
    }

    override protected function update (dt :Number) :void
    {
        updateText();
    }

    protected function updateText () :void
    {
        for (var i :uint = 0; i < _resourceText.length; ++i) {
            var label :TextField = _resourceText[i];
            label.text = getDisplayString(
                GameConstants.getResource(i).name,
                GameMode.instance.playerData.getResourceAmount(i));
        }
    }

    protected function getDisplayString (resourceName :String, resourceAmount :int) :String
    {
        return (resourceName + " [" + resourceAmount + "]");
    }

    protected var _parent :Sprite;
    protected var _resourceText :Array = new Array();

    protected static const FONT_NAME :String = "_sans";
    protected static const FONT_SIZE :int = 14;
    protected static const LABEL_OFFSET :int = 3;

    protected static const BG_COLOR :uint = 0x1E5EFF;
}

}
