package popcraft {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import popcraft.data.*;

public class ResourceDisplay extends SceneObject
{
    public function ResourceDisplay ()
    {
        _parent = new Sprite();

        // create the text fields for all the resources
        var width :int = 0;
        var height :int = 0;

        for each (var resource :ResourceData in GameContext.gameData.resources) {
            var format :TextFormat = new TextFormat();
            format.font = FONT_NAME;
            format.color = resource.color;
            format.size = FONT_SIZE;

            var label :TextField = new TextField();
            label.autoSize = TextFieldAutoSize.NONE;
            label.selectable = false;
            label.defaultTextFormat = format;
            label.gridFitType = GridFitType.PIXEL;

            // determine what the width should be
            label.text = getDisplayString(resource.displayName, 9999);
            label.width = label.textWidth;
            label.height = label.textHeight + 3;
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
        _parent.graphics.drawRect(0, 0, width, height);
        _parent.graphics.endFill();

        updateText();
    }

    // from SceneObject
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
            var resource :ResourceData = GameContext.gameData.resources[i];
            label.text = getDisplayString(
                resource.displayName,
                GameContext.localPlayerInfo.getResourceAmount(i));
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

    protected static const BG_COLOR :uint = 0x000000;
}

}
