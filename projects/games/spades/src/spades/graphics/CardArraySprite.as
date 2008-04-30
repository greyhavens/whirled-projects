package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.Event;

import com.whirled.contrib.card.Card;
import com.whirled.contrib.card.CardArray;
import com.whirled.contrib.card.CardArrayEvent;
import spades.Debug;

import com.threerings.flash.AnimationManager;
import com.threerings.flash.Vector2;
import com.threerings.flash.Animation;

import caurina.transitions.Tweener;

/**
 * Superclass to display of an array of cards. Delegates layout and some animation to subclasses.
 */
public class CardArraySprite extends Sprite
{
    /** Utility function to get the CardSprite ancestor from a display object. This is useful 
     *  for event listeners that want to act on the card sprite even if the event occurred on a 
     *  descendant of the card. */
    public static function exposeCard (obj :Object) :CardSprite
    {
        if (obj is DisplayObject) {
            var target :DisplayObject = DisplayObject(obj);
            while (!(target is CardArraySprite)) {
                if (target is CardSprite) {
                    return target as CardSprite;
                }
                target = target.parent;
            }
        }
        return null;
    }

    /** Create a new sprite for a CardArray. The sprite will always listen for all changes on the 
     *  array events and unregister when removed from the display list. Re-adding to the display 
     *  list is not supported. */
    public function CardArraySprite (target :CardArray, doPositioning :Boolean = true)
    {
        _target = target;

        _target.addEventListener(CardArrayEvent.RESET, cardArrayListener);
        _target.addEventListener(CardArrayEvent.ADDED, cardArrayListener);
        _target.addEventListener(CardArrayEvent.REMOVED, cardArrayListener);

        addEventListener(Event.REMOVED, removedListener);

        refresh();

        if (doPositioning) {
            positionCards();
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

    /** Get the x, y position of a card in the array. If a card is currently moving, this 
     *  should calculate the destination position. */
    protected function getStaticCardPosition (i :int, pos :Vector2) :void
    {
        var wid :Number = (_cards.length + 1) * CardSprite.WIDTH / 2;
        var left :Number = -wid / 2;
        pos.x = left + (i + 1) * CardSprite.WIDTH / 2;
        pos.y = 0;
    }

    /** Positions all cards (that are not currently animating).
     *  TODO: now that Tweener is being used, it would make much more sense
     *  to fly the cards in somehow rather that layout statically. */
    protected function positionCards () :void
    {
        var pos :Vector2 = new Vector2();
        _cards.forEach(positionSprite);

        function positionSprite(c :CardSprite, index :int, arr :Array) :void
        {
            if (!Tweener.isTweening(c)) {
                getStaticCardPosition(index, pos);
                c.x = pos.x;
                c.y = pos.y;
            }
        }
    }

    /** When the card array changes, update our child sprites and re-layout. */
    protected function cardArrayListener (event :CardArrayEvent) :void
    {
        Debug.debug("CardArrayEvent received " + event);

        switch (event.type) {

        case CardArrayEvent.RESET:
            refresh();
            break;

        case CardArrayEvent.ADDED:
            _cards.splice(event.index, 0, new CardSprite(event.card));
            addChildAt(_cards[event.index] as CardSprite, event.index);
            animateAddition(_cards[event.index]);
            break;

        case CardArrayEvent.REMOVED:
            var c: CardSprite = _cards[event.index] as CardSprite;
            _cards.splice(event.index, 1);
            animateRemoval(c);
            break;

        }

        positionCards();
    }

    /** Animates the removal of a card. The _cards array will be taken care of, this function must 
     *  only guarantee that removeChild is called later. By default, just calls removeChild 
     *  immediately. */
    protected function animateRemoval (card :CardSprite) :void
    {
        removeChild(card);
    }

    /** Animates the addition of the card. Default does nothing. Subclasses should set the 
     *  starting position of the card and use slide to move it into its static position. */
    protected function animateAddition (card :CardSprite) :void
    {
    }

    protected function removedListener (event :Event) :void
    {
        if (event.target == this) {
            // stop listening to array since we will no longer be displayed
            _target.removeEventListener(CardArrayEvent.ADDED, cardArrayListener);
            _target.removeEventListener(CardArrayEvent.REMOVED, cardArrayListener);
            _target.removeEventListener(CardArrayEvent.RESET, cardArrayListener);
        }
    }

    protected var _cards :Array = new Array();
    protected var _target :CardArray;
    protected var _animations :Array = new Array();
}

}

