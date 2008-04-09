package spades.card {

import flash.events.EventDispatcher;

import com.whirled.game.GameControl;
import com.whirled.game.MessageReceivedEvent;

import spades.Debug;

/** Represents the local player's hand in a card game. Provides facilities for dealing, playing
 *  and passing cards. Currently oriented mostly towards trick taking games.
 *  TODO: support more non-trick-taking game features like discarding, drawing and dealing a 
 *  fixed number of cards */
public class Hand extends EventDispatcher
{
    /** Create a new hand.
     *  @param gameCtrl the game control to use for table information and for networking
     *  @param prefix the prefix to use for our server variables in case the rules require 
     *  multiple local hands 
     *  @param sorter applies an ordering to cards when they are dealt and prior */
    public function Hand (
        gameCtrl :GameControl, 
        sorter :Sorter, 
        prefix :String=null)
    {
        _gameCtrl = gameCtrl;
        _prefix = prefix;
        _sorter = sorter;
        _cards = new CardArray();

        _gameCtrl.net.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessage);
    }

    /** Reset the deck on the server to the given deck. Note that this method should only be 
     *  called by one of the players in the game, presumably the one for which 
     *  GameSubControl.amInControl returns true. */
    public function prepare (deck :CardArray) :void
    {
        Debug.debug("Uploading deck: " + deck);

        var deckName :String = varName(DECK);

        // create deck bag
        _gameCtrl.services.bags.create(deckName, deck.ordinals);
    }

    /** Deal the given deck to all players, giving each player the same number of cards. Leftover
     *  cards will be held on the server. Note that this method should only be called by one of 
     *  the players in the game, presumably the one for which GameSubControl.amInControl returns 
     *  true. When the cards arrive to the player, each local hand will dispatch a HandEvent.DEALT
     *  message.
     *  @param deck the full deck of cards to store on the server
     *  @param numCards optional number of cards to deal to each player. If 0, cards are dealt 
     *  evenly
     *  TODO: options for what to do with the leftover cards? */
    public function prepareAndDeal (deck :CardArray, numCards :int) :void
    {
        // create deck bag
        prepare(deck);
            
        if (numCards == 0) {
            numCards = deck.length / playerIds.length;
        }

        // deal to each player
        var playerIds :Array = _gameCtrl.game.seating.getPlayerIds();
        for (var seat :int = 0; seat < playerIds.length; ++seat) {
            dealTo(playerIds[seat], numCards);
        }
    }

    /** Deal from the server's deck to one player. 
     *  @param playerId the player to deal to
     *  @param numCards number of cards to deal */
    public function dealTo (playerId :int, numCards :int) :void
    {
        Debug.debug("Dealing " + numCards + " cards to " + playerId);

        var deckName :String = varName(DECK);
        var dealtMsg :String = varName(DEALT);

        _gameCtrl.services.bags.deal(deckName, numCards, 
            dealtMsg, null, playerId);
    }

    /** Begin the local player's turn, enabling the set of cards that may be played. This is not 
     *  a network event and immediately sends HandEvent.BEGAN_TURN. */
    public function beginTurn (enabled :CardArray, count :int=1) :void
    {
        dispatchEvent(new HandEvent(HandEvent.BEGAN_TURN, enabled, 0, count));
    }

    /** Play cards. This is not a network event. It removes the cards from the hand and immediately 
     *  sends a HandEvent.CARDS_SELECTED event. */
    public function playCards (cards :CardArray) :void
    {
        for (var i :int = 0; i < cards.length; ++i) {
            _cards.remove(cards.cards[i] as Card);
        }
        dispatchEvent(new HandEvent(HandEvent.CARDS_SELECTED, cards));
    }

    /** Play a single cards. Convenience function to call playCards with a CardArray containing 
     *  only one card. */
    public function playCard (card :Card) :void
    {
        var cards :CardArray = new CardArray();
        cards.pushOrdinal(card.ordinal);
        playCards(cards);
    }

    /** End the local player's turn. This is not a network event and immediately sends 
     *  HandEvent.ENDED_TURN. */
    public function endTurn () :void
    {
        dispatchEvent(new HandEvent(HandEvent.ENDED_TURN));
    }

    /** Add some face down cards. */
    public function addFaceDownCards (numCards :int) :void
    {
        var toInsert :CardArray = new CardArray();
        for (var i :int = 0; i < numCards; ++i) {
            toInsert.push(Card.createFaceDownCard());
        }

        if (_cards.length == 0) {
            _cards.reset(toInsert.ordinals);
        }
        else {
            _sorter.insert(toInsert, _cards);
        }
    }

    /** Access the number of cards in the hand. */
    public function get length () :int
    {
        return _cards.length;
    }

    /** Access the underlying array of cards. The caller MUST NOT modify the array directly. */
    public function get cards () :CardArray
    {
        return _cards;
    }

    protected function handleMessage (event :MessageReceivedEvent) :void
    {
        if (event.name == varName(DEALT)) {

            // reset our cards with sorted array
            var cards :CardArray = new CardArray(event.value as Array);
            _sorter.sort(cards);
            _cards.reset(cards.ordinals);

            Debug.debug("Hand is " + _cards);

            dispatchEvent(new HandEvent(HandEvent.DEALT, _cards));
        }
    }

    protected function varName (name :String) :String
    {
        if (_prefix != null) {
            return _prefix + "." + name;
        }
        return name;
    }

    protected var _gameCtrl :GameControl;
    protected var _prefix :String;
    protected var _sorter :Sorter;
    protected var _cards :CardArray;

    /** Name of bag for the deck. */
    protected static const DECK :String = "hand.deck";

    /** Event message for getting cards. */
    protected static const DEALT :String = "hand.dealt";
}

}
