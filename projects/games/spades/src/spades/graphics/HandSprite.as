package spades.graphics {

import flash.events.MouseEvent;
import com.threerings.flash.Vector2;
import spades.card.CardArray;
import spades.card.CardArrayEvent;
import spades.card.CardException;
import spades.card.Hand;
import spades.card.HandEvent;
import spades.Debug;


import caurina.transitions.Tweener;

/** Display for a hand of cards */
public class HandSprite extends CardArraySprite
{
    /** Create a new hand sprite. 
     *  @param target the card array this sprite represents */
    public function HandSprite (hand :Hand)
    {
        super(hand.cards);

        _hand = hand;

        addEventListener(MouseEvent.MOUSE_OVER, mouseOverListener);
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOutListener);
        addEventListener(MouseEvent.CLICK, clickListener);

        _hand.addEventListener(HandEvent.BEGAN_TURN, handListener);
        _hand.addEventListener(HandEvent.ENDED_TURN, handListener);
    }

    /** After a card is clicked and tweened towards the central spot, the TrickSprite
     *  must call this prior to adding the card as its own child. */
    public function finalizeMostRecentCardRemoval () :CardSprite
    {
        var recent :CardSprite = _mostRecentlyRemovedCard;
        _mostRecentlyRemovedCard = null;
        if (recent != null) {
            Tweener.removeTweens(recent, ["x", "y"]);
            removeChild(recent);
        }
        return recent;
    }

    protected function handListener (event :HandEvent) :void
    {
        if (event.type == HandEvent.BEGAN_TURN) {
            enable(event.cards);
        }
        else if (event.type == HandEvent.ENDED_TURN) {
            disable();
        }
    }

    /** Disable clicking on all cards. */
    protected function disable () :void
    {
        _cards.forEach(disableSprite);

        popDown();

        function disableSprite (c :CardSprite, index :int, array :Array) :void
        {
            c.state = CardSprite.DISABLED;
        }
    }
    
    /** Enable clicking on specific cards. 
     *  @param subset the cards to enable, or all if null (default)
     *  @throws CardException is the resulting set of enabled cards is empty since otherwise
     *  the game will be waiting forever. */
    protected function enable (subset :CardArray=null) :void
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
            if (enable) {
                ++count;
                c.state = CardSprite.NORMAL;
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
                _popupCard.state = CardSprite.HIGHLIGHTED;
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
            if (_popupCard.state == CardSprite.HIGHLIGHTED) {
                _popupCard.state = CardSprite.NORMAL;
            }
        }
        _popupCard = null;
        _popup = -1;
    }

    // TODO: animations when cards are added and removed
    override protected function cardArrayListener (event :CardArrayEvent) :void
    {
        super.cardArrayListener(event);

        if (event.type == CardArrayEvent.RESET) {
            // game logic will do this soon, but call now to make sure there is no flashing
            disable();
        }
    }

    override protected function animateRemoval (card :CardSprite) :void
    {
        if (_mostRecentlyRemovedCard != null) {
            removeChild(_mostRecentlyRemovedCard);
        }

        popDown();
        
        _mostRecentlyRemovedCard = card;
        card.state = CardSprite.NORMAL;
        var tween :Object = {
            x : 0,
            y : -CardSprite.HEIGHT,
            time: REMOVAL_DURATION
        };
        Tweener.addTween(card, tween);

        var pos :Vector2 = new Vector2();
        
        _cards.forEach(squeeze);

        function squeeze (c :CardSprite, i :int, a :Array) :void {
            Tweener.removeTweens(c, ["x", "y"]);
            getStaticCardPosition(i, pos);
            var tween :Object = {
                x : pos.x,
                y : pos.y,
                time: SQUEEZE_DURATION
            };
            Tweener.addTween(c, tween);
        }
    }

    protected function mouseOverListener (event :MouseEvent) :void
    {
        // pop up the card if it is enabled
        var card :CardSprite = exposeCard(event.target);
        if (card != null && card.state != CardSprite.DISABLED) {
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

    protected function clickListener (event :MouseEvent) :void
    {
        var card :CardSprite = exposeCard(event.target);
        if (card != null && card.state != CardSprite.DISABLED) {
            _hand.selectCard(card.card);
        }
    }

    protected var _popup :Number;
    protected var _popupCard :CardSprite;
    protected var _mostRecentlyRemovedCard :CardSprite;
    protected var _hand :Hand;

    protected static const POPUP :Number = 20;
    protected static const POPUP_DURATION :Number = .2;
    protected static const REMOVAL_DURATION :Number = .75;
    protected static const SQUEEZE_DURATION :Number = .75;
}

}
