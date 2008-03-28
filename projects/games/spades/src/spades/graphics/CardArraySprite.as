package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.Event;

import spades.card.Card;
import spades.card.CardArray;
import spades.card.CardArrayEvent;
import spades.Debug;

import com.threerings.flash.AnimationManager;
import com.threerings.flash.Vector2;
import com.threerings.flash.Animation;


/**
 * Superclass to display of an array of cards. Delegates layout to subclasses and supports 
 * animation.
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
    public function CardArraySprite (target :CardArray)
    {
        _target = target;

        _target.addEventListener(CardArrayEvent.CARD_ARRAY, cardArrayListener);

        addEventListener(Event.REMOVED, removedListener);

        refresh();

        positionCards();
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

    /** Positions all cards (that are not currently animating). */
    protected function positionCards () :void
    {
        var pos :Vector2 = new Vector2();
        _cards.forEach(positionSprite);

        function positionSprite(c :CardSprite, index :int, arr :Array) :void
        {
            if (!isSliding(c)) {
                getStaticCardPosition(index, pos);
                c.x = pos.x;
                c.y = pos.y;
            }
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
            animateAddition(_cards[event.index]);
            break;

        case CardArrayEvent.ACTION_REMOVED:
            var c: CardSprite = _cards[event.index] as CardSprite;
            _cards.splice(event.index, 1);
            animateRemoval(c);
            break;

        case CardArrayEvent.ACTION_PRERESET:
            return;

        default:
            // We should handle all events
            throw new Error("CardArrayEvent " + event + " not handled");

        }

        positionCards();
    }

    /** Detect if a card is currently sliding. This allows the layout function to exempt 
     *  animating cards from the routine. */
    protected function isSliding (card :CardSprite) :Boolean
    {
        return _animations.some(isTheOne);

        function isTheOne (ani :Animation, i :int, a :Array) :Boolean {
            if (ani is SlideAnim) {
                return SlideAnim(ani).sprite == card;
            }
            return false;
        }
    }

    /** Slide a card from its current position to a destination position over a time span. 
     *  If the card is already sliding, the current slide will be stopped.
     *  @param card the card to slide. Its current position is the starting position.
     *  @param dest the final destination position
     *  @param milliseconds the time span over which to do the move
     *  @param callback optional function to call when the animation is complete
     */
    public function slide (
        card :CardSprite, 
        dest: Vector2, 
        milliseconds :Number,
        callback :Function = null) :void
    {
        endSlide(card, false);

        var slide :SlideAnim = new SlideAnim(card, dest, milliseconds, removeIt);
        _animations.push(slide);

        AnimationManager.start(slide);

        // chaining callback. first removes the animation, then calls the incoming
        // callback
        function removeIt () :void {
            var index :int = _animations.indexOf(slide);
            _animations.splice(index, 1);
            if (callback != null) {
                callback();
            }
        }
    }

    /** Terminate the sliding, if any, of a card.
     *  @param card the card to stop sliding
     *  @param moveToDest if true, move the card to the given destination of its slide. */
    public function endSlide (card :CardSprite, moveToDest: Boolean) :void
    {
        _animations.some(finish);

        function finish (ani :Animation, i :int, a :Array) :Boolean {
            if (ani is SlideAnim) {
                if (SlideAnim(ani).sprite == card) {
                    SlideAnim(ani).finish(moveToDest);
                    return true;
                }
            }
            return false;
        }
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
            _target.removeEventListener(CardArrayEvent.CARD_ARRAY, cardArrayListener);
        }
        else if (event.target is CardSprite) {
            // forcibly stop all animations on the target
            endSlide(event.target as CardSprite, false);
        }
    }

    protected var _cards :Array = new Array();
    protected var _target :CardArray;
    protected var _animations :Array = new Array();
}

}

