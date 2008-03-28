package spades.graphics {

import flash.display.Sprite;
import flash.display.Scene;
import flash.events.MouseEvent;
import spades.card.Card;
import spades.Debug;
import com.threerings.util.MultiLoader;
import flash.display.MovieClip;


/**
 * Represents a card graphic (placeholder).
 */
public class CardSprite extends Sprite
{
    /** Width of a card sprite. */
    public static const WIDTH :int = 60;

    /** Height of a card sprite. */
    public static const HEIGHT :int = 80;

    public static var dump :Boolean = true;

    /** Create a new card sprite. */
    public function CardSprite (card :Card)
    {
        _card = card;

        MultiLoader.getContents(DECK, gotDeck);

        function gotDeck (clip :MovieClip) :void
        {
            if (dump) {
                Debug.debug("Got deck: " + clip.width + " x " + clip.height);
                dump = false;
            }

            _deck = clip;
            _deck.gotoAndStop(card.string);
            _deck.x = -WIDTH / 2;
            _deck.y = -HEIGHT / 2;
            _deck.scaleX = WIDTH / _deck.width;
            _deck.scaleY = HEIGHT / _deck.height;
            addChild(_deck);
            update();
        }
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
        if (_deck == null) {
            return;
        }
    }

    protected var _card :Card;
    protected var _enabled :Boolean = false;
    protected var _highlighted :Boolean = false;
    protected var _emphasis :Boolean = false;
    protected var _deck :MovieClip;

    [Embed(source="../../../rsrc/deck.swf", mimeType="application/octet-stream")]
    protected static const DECK :Class;
}

}
