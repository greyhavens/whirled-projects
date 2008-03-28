package spades.graphics {

import flash.events.MouseEvent;
import com.threerings.flash.Vector2;
import spades.card.CardArray;
import spades.card.CardArrayEvent;
import spades.card.CardException;
import spades.Debug;

import caurina.transitions.Tweener;

/** Display for a hand of cards */
public class HandSprite extends CardArraySprite
{
    /** Create a new hand sprite. */
    public function HandSprite (target :CardArray)
    {
        super(target);

        addEventListener(MouseEvent.MOUSE_OVER, mouseOverListener);
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOutListener);
    }

    /** Disable clicking on all cards. */
    public function disable () :void
    {
        _cards.forEach(disableSprite);

        popDown();

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

        popDown();

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

    /** Slide a card vertically to indicate that clicking it will play it. 
     *  @param y the mouse position in the card's coordinates. */
    protected function popUp (card :CardSprite, y :int) :void
    {
        var offset :Number;

        // prevent hysteresis by popping the card up if the mouse is in the top half of the hand
        // and down if in the bottom half
        if (y + card.y > CardSprite.HEIGHT / 2) {
            offset = POPUP;
        }
        else {
            offset = -POPUP;
        }

        if (_popupCard != card) {
            popDown();
        }

        if (_popupCard != card || _popup != offset) {

            var index :int = _cards.indexOf(card);
            if (index >= 0) {
                var pos :Vector2 = new Vector2();
                getStaticCardPosition(index, pos);
                
                var tween :Object = {
                    y: pos.y + offset, 
                    time: POPUP_DURATION};

                Tweener.removeTweens(card, "y");
                Tweener.addTween(card, tween);

                _popupCard = card;
                _popup = offset;
                _popupCard.highlighted = true;
            }
        }
    }

    /** Slide the currently offset card back into its usual location. */
    protected function popDown () :void
    {
        if (_popupCard != null) {
            var index :int = _cards.indexOf(_popupCard);
            if (index >= 0) {
                var pos :Vector2 = new Vector2();
                getStaticCardPosition(_cards.indexOf(_popupCard), pos);

                var tween :Object = {
                    y: pos.y, 
                    time: POPUP_DURATION};

                Tweener.removeTweens(_popupCard, "y");
                Tweener.addTween(_popupCard, tween);
            }
            else {
                Tweener.removeTweens(_popupCard, "y");
            }
            _popupCard.highlighted = false;
        }
        _popupCard = null;
        _popup = -1;
    }

    // TODO: animations when cards are added and removed
    override protected function cardArrayListener (event :CardArrayEvent) :void
    {
        super.cardArrayListener(event);
    }

    protected function mouseOverListener (event :MouseEvent) :void
    {
        // pop up the card if it is enabled
        var card :CardSprite = exposeCard(event.target);
        if (card != null && card.enabled) {
            popUp(card, event.localY);
        }
    }

    protected function mouseMoveListener (event :MouseEvent) :void
    {
        // pop up the card if it is enabled
        var card :CardSprite = exposeCard(event.target);
        if (card != null && card == _popupCard) {
            popUp(card, event.localY);
        }
    }

    protected function mouseOutListener (event :MouseEvent) :void
    {
        // pop down the card if it is popped up
        var card :CardSprite = exposeCard(event.target);
        if (card != null && card == _popupCard) {
            popDown();
        }
    }

    protected var _popup :Number;
    protected var _popupCard :CardSprite;

    protected static const POPUP :Number = 20;
    protected static const POPUP_DURATION :Number = .2;
}

}
