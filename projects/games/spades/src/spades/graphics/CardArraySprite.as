package spades.graphics {

import flash.display.Sprite;
import flash.events.Event;

import spades.card.Card;
import spades.card.CardArray;
import spades.card.CardArrayEvent;
import spades.card.CardException;
import spades.Debug;

/**
 * Display of an array of cards. 
 */
public class CardArraySprite extends Sprite
{
    /** Create a new sprite for a CardArray. The sprite will always listen for all changes on the 
     *  array events and unregister when removed from the display list. Re-adding to the display 
     *  list is not supported. */
    public function CardArraySprite (target :CardArray)
    {
        _target = target;

        _target.addEventListener(CardArrayEvent.CARD_ARRAY, cardArrayListener);

        addEventListener(Event.REMOVED, removedListener);

        refresh();

        layout();
    }

    /** Disable clicking on all cards. */
    public function disable () :void
    {
        _cards.forEach(disableSprite);

        function disableSprite (c :CardSprite, index :int, array :Array) :void
        {
            c.enabled = false;
        }
    }
    
    /** Enable clicking on specific cards. 
     *  @param subset the cards to enable, or all if null (default)
     *  @throws CardException is the resulting set of enabled cards is empty since otherwise
     *  the game will be waiting forever. */
    public function enable (subset :CardArray=null) :void
    {
        var count :int = 0;

        // todo: make linear time N + M instead of quadratic N * M
        _cards.forEach(enableSprite);

        if (count == 0) {
            throw new CardException("Enabling zero cards");
        }

        function enableSprite (c :CardSprite, index :int, array :Array) :void
        {
            var enable :Boolean = subset == null || subset.has(c.card);
            c.enabled = enable;
            if (enable) {
                ++count;
            }
        }
    }

    /** Update our card sprites with the contents of the target card array. */
    protected function refresh () :void
    {
        _cards.forEach(removeSprite);
        _cards.splice(0, _cards.length);
        _target.cards.forEach(addCard);

        function removeSprite (c :CardSprite, index :int, array :Array) :void
        {
            removeChild(c);
        }

        function addCard (c :Card, index :int, array :Array) :void
        {
            _cards.push(new CardSprite(c));
            addChild(_cards[index] as Sprite);
        }
    }

    /** Layout the sprites in the _cards member and set the width and height. */
    protected function layout () :void
    {
        // very basic layout
        var left :int = 0;
        var wid :int = 0;

        if (_cards.length > 0) {
            wid = (_cards.length + 1) * CardSprite.WIDTH / 2;
            left = -wid / 2;
        }

        graphics.clear();
        graphics.beginFill(0x000000);
        graphics.drawRect(
            left, -CardSprite.HEIGHT / 2, 
            wid, CardSprite.HEIGHT);
        graphics.endFill();

        _cards.forEach(layoutSprite);

        function layoutSprite(c :CardSprite, index :int, arr :Array) :void
        {
            var x :int = (index + 1) * CardSprite.WIDTH / 2;
            c.x = left + x;
            c.y = 0;
        }
    }

    /** When the card array changes, update our child sprites and re-layout
     *  TODO: animate */
    protected function cardArrayListener (event :CardArrayEvent) :void
    {
        Debug.debug("CardArrayEvent received " + event);

        switch (event.action) {

        case CardArrayEvent.ACTION_RESET:
            refresh();
            break;

        case CardArrayEvent.ACTION_ADDED:
            _cards.splice(event.index, 0, new CardSprite(event.card));
            addChild(_cards[event.index] as CardSprite);
            break;

        case CardArrayEvent.ACTION_REMOVED:
            removeChild(_cards[event.index] as CardSprite);
            _cards.splice(event.index, 1);
            break;

        case CardArrayEvent.ACTION_PRERESET:
            return;

        default:
            // We should handle all events
            throw new Error("CardArrayEvent " + event + " not handled");

        }

        layout();
    }

    protected function removedListener (event :Event) :void
    {
        if (event.target == this) {
            // stop listening to array since we will no longer be displayed
            _target.removeEventListener(CardArrayEvent.CARD_ARRAY, cardArrayListener);
        }
    }

    protected var _cards :Array = new Array();
    protected var _target :CardArray;
}

}

