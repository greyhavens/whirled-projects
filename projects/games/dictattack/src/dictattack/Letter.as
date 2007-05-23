//
// $Id$

package dictattack {

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;

import flash.display.Shape;
import flash.display.Sprite;

public class Letter extends Sprite
{
    public function Letter (content :Content, type :int)
    {
        _content = content;
        _type = type;

        _invader = content.createInvader(type);
        _invader.x = Content.TILE_SIZE/2;
        _invader.y = Content.TILE_SIZE/2;
        _invader.width = Content.TILE_SIZE;
        _invader.height = Content.TILE_SIZE;
        addChild(_invader);

        _label = new TextField();
        _label.autoSize = TextFieldAutoSize.CENTER;
        _label.selectable = false;
        _label.defaultTextFormat = makePlainFormat();
        _label.x = 0;
        _label.width = Content.TILE_SIZE;
        addChild(_label);

        setPlayable(false);
    }

    public function setText (text :String) :void
    {
        _label.text = text.toUpperCase();
        _label.y = (Content.TILE_SIZE - _label.height)/2 + FONT_ADJUST_HACK;
    }

    public function setPlayable (playable :Boolean) :void
    {
        _invader.transform.colorTransform = _content.invaderColors[_type];
        if (!playable) {
            _invader.transform.colorTransform.alphaOffset = -128;
        }
    }

    public function setHighlighted (highlighted :Boolean) :void
    {
        _label.setTextFormat(highlighted ? makeHighlightFormat() : makePlainFormat());
    }

    protected static function makePlainFormat () : TextFormat
    {
        var format : TextFormat = new TextFormat();
        format.font = Content.FONT_NAME;
        format.bold = true;
        format.color = Content.LETTER_FONT_COLOR;
        format.size = Content.TILE_FONT_SIZE;
        return format;
    }

    protected static function makeHighlightFormat () : TextFormat
    {
        var format : TextFormat = new TextFormat();
        format.font = Content.FONT_NAME;
        format.bold = true;
        format.color = Content.HIGH_FONT_COLOR;
        format.size = Content.TILE_FONT_SIZE;
        return format;
    }

    protected var _content :Content;
    protected var _type :int;
    protected var _invader :Sprite;
    protected var _label :TextField;

    protected static const FONT_ADJUST_HACK :int = 2;
}

}
