package spades.graphics {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import spades.card.Card;

/**
 * Represents a card graphic (placeholder).
 */
public class CardSprite extends Sprite
{
    /** Width of a card sprite. */
    public static const WIDTH :int = 70;

    /** Height of a card sprite. */
    public static const HEIGHT :int = 100;

    public function CardSprite (card :Card) {
        _card = card;
        
        graphics.clear();
        graphics.beginFill(0x000000);
        graphics.drawRect(-WIDTH / 2, -HEIGHT / 2, WIDTH, HEIGHT);
        graphics.endFill();

        //        width = WIDTH;
        //        height = HEIGHT;

        _text = new TextField();
        _text.width = WIDTH;
        _text.height = HEIGHT;
        _text.background = true;
        _text.border = true;
        _text.selectable = false;
        _text.multiline = true; // (needed for rank + CR + suit)
        _text.text = 
            Card.rankString(card.rank) + "\n" + 
            Card.suitString(card.suit);
        _text.x = -WIDTH / 2;
        _text.y = -HEIGHT / 2;
        addChild(_text);

        addEventListener(MouseEvent.MOUSE_OVER, mouseOverListener);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOutListener);

        update();
    }

    public function get card () :Card
    {
        return _card;
    }

    public function set enabled (on :Boolean) :void
    {
        _enabled = on;
        update();
    }

    public function get enabled () :Boolean
    {
        return _enabled;
    }

    protected function update () :void
    {
        if (_enabled) {
            if (_highlighted) {
                _text.backgroundColor = 0xFF8080;
            }
            else {
                _text.backgroundColor = 0x77FF77;
            }
        }
        else {
            _text.backgroundColor = 0x888888;
        }
    }

    protected function mouseOverListener (event :MouseEvent) :void {
        if (_enabled) {
            _highlighted = true;
            update();
        }
    }

    protected function mouseOutListener (event :MouseEvent) :void {
        if (_enabled) {
            _highlighted = false;
            update();
        }
    }

    protected var _card :Card;
    protected var _text :TextField;
    protected var _enabled :Boolean = false;
    protected var _highlighted :Boolean = false;
}

}
