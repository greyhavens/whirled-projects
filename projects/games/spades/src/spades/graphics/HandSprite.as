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
    /** Create a new hand sprite. 
     *  @param target the card array this sprite represents */
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
            c.state = CardSprite.DISABLED;
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
            if (enable) {
                ++count;
                c.state = CardSprite.NORMAL;
            }
        }
    }

    public function finalizeMostRecentCardRemoval () :CardSprite
    {
        if (_mostRecentlyRemovedCard != null) {
            Tweener.removeTweens(_mostRecentlyRemovedCard, ["x", "y"]);
            removeChild(_mostRecentlyRemovedCard);
        }
        return _mostRecentlyRemovedCard;
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

        if (event.action == CardArrayEvent.ACTION_RESET) {
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

    protected var _popup :Number;
    protected var _popupCard :CardSprite;
    protected var _mostRecentlyRemovedCard :CardSprite;

    protected static const POPUP :Number = 20;
    protected static const POPUP_DURATION :Number = .2;
    protected static const REMOVAL_DURATION :Number = .75;
    protected static const SQUEEZE_DURATION :Number = .75;
}

}
