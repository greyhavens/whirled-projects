//
// $Id$

package dictattack {

import flash.events.Event;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import flash.display.Shape;
import flash.display.Sprite;

public class Letter extends Sprite
{
    public function Letter (content :Content, type :int)
    {
        _content = content;
        _type = type;
        _main = new Sprite();
        _main.addChild(_invader = makeInvader());
        _main.addChild(_label = makeLabel());
        addChild(_main);
        setPlayable(false);
    }

    public function setText (text :String) :void
    {
        _label.text = text.toUpperCase();
        _label.y = (Content.TILE_SIZE - _label.height)/2 + FONT_ADJUST_HACK;
    }

    public function setPlayable (playable :Boolean, dghost :int = -1) :void
    {
        _invader.transform.colorTransform =
            playable ? _content.invaderColors[_type] : _content.dimInvaderColors[_type];

        if (dghost > 0 && _ghost == null) {
            _targety = (Content.TILE_SIZE + Board.GAP) * dghost;
            _ghost = new Sprite();

            var invader :Sprite = makeInvader();
            invader.transform.colorTransform = _content.ghostInvaderColors[_type];
            _ghost.addChild(invader);

            var label :TextField = makeLabel();
            label.text = _label.text;
            label.y = (Content.TILE_SIZE - label.height)/2 + FONT_ADJUST_HACK;
            _ghost.addChild(label);

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            addChild(_ghost);
        }
    }

    public function setHighlighted (highlighted :Boolean) :void
    {
        _label.setTextFormat(highlighted ? makeHighlightFormat() : makePlainFormat());
    }

    public function clearGhost () :void
    {
        if (_ghost != null) {
            removeChild(_ghost);
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            _ghost = null;
        }
    }

    protected function makeInvader () :Sprite
    {
        var invader :Sprite = _content.createInvader(_type);
        invader.x = Content.TILE_SIZE/2;
        invader.y = Content.TILE_SIZE/2;
        invader.width = Content.TILE_SIZE;
        invader.height = Content.TILE_SIZE;
        return invader;
    }

    protected function makeLabel () :TextField
    {
        var label :TextField = new TextField();
        label.autoSize = TextFieldAutoSize.CENTER;
        label.selectable = false;
        label.defaultTextFormat = makePlainFormat();
        label.x = 0;
        label.width = Content.TILE_SIZE;
        label.embedFonts = true;
        label.gridFitType = GridFitType.PIXEL;
        label.sharpness = 400; // magic! (400 is the maximum sharpness)
        return label;
    }

    protected function onEnterFrame (event :Event) :void
    {
        if (_main.y != _targety) {
            _main.y++; // TODO: decouple from the framerate
        }
        if (_main.y == _targety) {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
    }

    protected static function makePlainFormat () : TextFormat
    {
        var format : TextFormat = new TextFormat();
        format.font = "Letter";
        format.bold = true;
        format.color = Content.LETTER_FONT_COLOR;
        format.size = Content.TILE_FONT_SIZE;
        return format;
    }

    protected static function makeHighlightFormat () : TextFormat
    {
        var format : TextFormat = new TextFormat();
        format.font = "Letter";
        format.bold = true;
        format.color = Content.HIGH_FONT_COLOR;
        format.size = Content.TILE_FONT_SIZE;
        return format;
    }

    protected var _content :Content;
    protected var _type :int;

    protected var _main :Sprite;
    protected var _invader :Sprite;
    protected var _label :TextField;

    protected var _ghost :Sprite;
    protected var _targety :int = -1;

    protected static const FONT_ADJUST_HACK :int = 2;
}

}
