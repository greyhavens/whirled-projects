package spades.graphics {

import com.threerings.flash.Vector2;

import caurina.transitions.Tweener;

import spades.card.CardArray;
import spades.card.CardArrayEvent;

import flash.geom.Point;

/** Graphics for the cards in the trick. */
public class MainTrickSprite extends TrickSprite
{
    /** Create a new trick sprite */
    public function MainTrickSprite (
        target :CardArray, 
        playerSprites :Array, 
        localHand :HandSprite)
    {
        super(target, playerSprites.length);
        _playerSprites = playerSprites;
        _localHand = localHand;
    }

    override protected function cardArrayListener (event :CardArrayEvent) :void
    {
        super.cardArrayListener(event);

        if (event.action == CardArrayEvent.ACTION_PRERESET) {
        }
    }

    /** inheritDoc */
    // from CardArraySprite
    override protected function animateAddition (card :CardSprite) :void
    {
        var idx :int = _cards.length - 1;
        var seat :int = (idx + _leader) % CARD_POSITIONS.length;

        var start :Vector2;

        // check if card is from local player
        if (seat == 0) {

            // use card from the local hand (if available)
            var handCard :CardSprite = 
                _localHand.finalizeMostRecentCardRemoval();
            if (handCard != null) {
                start = new Vector2(handCard.x, handCard.y);
            }
            else {
                start = new Vector2(0, -CardSprite.HEIGHT);
            }
                
            // convert to local coordinates
            start = Vector2.fromPoint(globalToLocal(
                _localHand.localToGlobal(start.toPoint())));
        }
        else {
            start = Vector2.fromPoint(globalToLocal(
                _playerSprites[seat].localToGlobal(new Point(0, 0))));
        }

        // set the starting position
        var card :CardSprite = _cards[idx];
        card.x = start.x;
        card.y = start.y;

        // get the finish position
        var finish :Vector2 = new Vector2();
        getStaticCardPosition(idx, finish);

        // tween it
        var tween :Object = {
            x : finish.x,
            y : finish.y,
            time : FLY_IN_DURATION
        };
        Tweener.addTween(card, tween);
    }

    protected var _playerSprites :Array;
    protected var _localHand :HandSprite;

    protected static const FLY_IN_DURATION :Number = .75;
}

}
