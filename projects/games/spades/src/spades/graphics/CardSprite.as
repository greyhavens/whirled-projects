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

    /** Create a new card sprite. */
    public function CardSprite (card :Card)
    {
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

        update();
    }

    /** Access the underlying card object. */
    public function get card () :Card
    {
        return _card;
    }

    /** Access the enabled flag. Enabling is intended to indicate that a click will cause an action 
     *  to happen. Clearing the enabled flag also clears the highlighted flag. */
    public function set enabled (on :Boolean) :void
    {
        _enabled = on;
        if (!on) {
            _highlighted = false;
        }
        update();
    }

    /** Access the enabled flag. */
    public function get enabled () :Boolean
    {
        return _enabled;
    }

    /** Access the emphasis flag. Emphasis is to make the card stand out for a game-specific 
     *  reason. */
    public function set emphasis (on :Boolean) :void
    {
        _emphasis = on;
        update();
    }

    /** Access the emphasis flag. */
    public function get emphasis () :Boolean
    {
        return _emphasis;
    }

    /** Access the highlighted flag. Highlighted is intended to indicate that the mouse is hovering 
     *  over the card.*/
    public function set highlighted (on :Boolean) :void
    {
        _highlighted = on;
        update();
    }

    /** Access the highlighted flag. */
    public function get highlighted () :Boolean
    {
        return _highlighted;
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
        else if (_emphasis) {
            _text.backgroundColor = 0x0077ff;
        }
        else {
            _text.backgroundColor = 0x888888;
        }
    }

    protected var _card :Card;
    protected var _text :TextField;
    protected var _enabled :Boolean = false;
    protected var _highlighted :Boolean = false;
    protected var _emphasis :Boolean = false;
}

}
