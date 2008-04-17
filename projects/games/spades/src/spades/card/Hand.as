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

    /** Request that one player pass some cards to another player. This will dispatch a 
     *  HandEvent.PASS_REQUESTED event on the client who perform the pass and set the
     *  passTarget property to indicate the target player.  
     *  @param fromPlayer the id of the player who is to perform the pass
     *  @param toPlayer the id of the player to receive the passed cards
     *  @param numCards the number of cards to pass */
    public function requestPass (
        fromPlayer :int, 
        toPlayer :int, 
        numCards :int) :void
    {
        _gameCtrl.net.sendMessage(varName(PASS_REQUEST), 
            [toPlayer, numCards], fromPlayer);
    }

    /** Pass the given cards to fulfill a pass request. The cards are sent to the pass target using 
     *  a HandEvent.PASSED event. Other players are also notified via a HandEvent.PASSED event with 
     *  no cards. */
    public function passCards (cards :CardArray) :void
    {
        if (_passTarget == 0) {
            throw new CardException("Passing cards when no pass is in progress");
        }

        if (cards.length != _passCount) {
            throw new CardException("Passing " + cards + 
                ", expected " + _passCount);
        }

        var value :Array = new Array();
        value.push(_gameCtrl.game.getMyId());
        cards.ordinals.forEach(function (ord :int, ...x) :void {
            value.push(ord);
        });

        _gameCtrl.net.sendMessage(varName(PASS_FULFILL), 
            value, _passTarget);
        _gameCtrl.net.sendMessage(varName(PASS_NOTIFY), 
            [_gameCtrl.game.getMyId(), _passTarget, _passCount]);

        _passTarget = 0;
        _passCount = 0;
    }

    /** Access the target player for the local player's pass in progress. 0 if no pass has been 
     *  requested. */
    public function get passTarget () :int
    {
        return _passTarget;
    }

    /** Access the numr of cards requested to be passed by the local player. 0 if no pass has been 
     *  requested. */
    public function get passCount () :int
    {
        return _passCount;
    }

    /** Access whether the local player is currently passing. */
    public function get isPassing () :Boolean
    {
        return _passTarget != 0;
    }

    /** Allow the selection of cards, but not actually playing them. This is not 
     *  a network event and immediately sends HandEvent.ALLOW_SELECT. */
    public function allowSelection (enabled :CardArray, count :int=1) :void
    {
        dispatchEvent(new HandEvent(HandEvent.ALLOWED_SELECTION, enabled, 0, count));
    }

    /** Allow the local player to play some cards from a given allowed set. This is not 
     *  a network event and immediately sends HandEvent.BEGAN_TURN. */
    public function allowPlay (enabled :CardArray, count :int=1) :void
    {
        dispatchEvent(new HandEvent(HandEvent.ALLOWED_PLAY, enabled, 0, count));
        _hasPlayed = false;
    }

    /** Disallow card selection, typically called when it is no longer the player's turn and there 
     *  is no reasonable selection he or she could make. This is not a network event and 
     *  immediately sends HandEvent.DISALLOWED_SELECTION. */
    public function disallowSelection () :void
    {
        dispatchEvent(new HandEvent(HandEvent.DISALLOWED_SELECTION));
    }

    /** Select some cards to play. This is not a network event. It immediately sends a 
     *  HandEvent.CARDS_PLAYED event. */
    public function playCards (cards :CardArray) :void
    {
        dispatchEvent(new HandEvent(HandEvent.CARDS_PLAYED, cards));
        _hasPlayed = true;
    }

    /** Play a single card. Convenience function to call playCards with a CardArray containing 
     *  only one card. */
    public function playCard (card :Card) :void
    {
        var cards :CardArray = new CardArray();
        cards.pushOrdinal(card.ordinal);
        playCards(cards);
    }

    /** Remove a single card from the hand. Normally the controller will call this in conjunction 
     *  with another call to place the card elsewhere on the table, return it to the deck, etc. 
     *  Does not send any events. */
    public function removeCard (card :Card) :void
    {
        _cards.remove(card);
    }

    /** Remove cards from the hand. Normally the controller will call this in conjunction with
     *  another call to place the cards elsewhere on the table, return them to the deck, etc. 
     *  Does not send any events. */
    public function removeCards (cards :CardArray) :void
    {
        for (var i :int = 0; i < cards.length; ++i) {
            _cards.remove(cards.cards[i] as Card);
        }
    }

    /** Add some face down cards to a given player. */
    public function dealFaceDownTo (id :int, numCards :int) :void
    {
        _gameCtrl.net.sendMessage(varName(DEALT_FACE_DOWN), numCards, id);
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

    /** Access whether or not some cards have been selected since the last call to beginTurn. This 
     *  is necessary for the auto-play feature where cards are randomly selected by the controller 
     *  if the player takes too long to make a move. */
    public function get hasPlayed () :Boolean
    {
        return _hasPlayed;
    }

    protected function handleMessage (event :MessageReceivedEvent) :void
    {
        var cards :CardArray;
        var info :Array;

        var dbgVal :String = String(event.value);
        if (event.value is Array) {
            dbgVal = (event.value as Array).join(", ");
        }
        Debug.debug("Received message " + event.name + ", value: " + dbgVal);

        if (event.name == varName(DEALT)) {

            // reset our cards with sorted array
            cards = new CardArray(event.value as Array);
            _sorter.sort(cards);
            _cards.reset(cards.ordinals);

            Debug.debug("Hand is " + _cards);

            dispatchEvent(new HandEvent(HandEvent.DEALT, _cards));
        }
        else if (event.name == varName(DEALT_FACE_DOWN)) {
            var numCards :int = int(event.value);
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
        else if (event.name == varName(PASS_REQUEST)) {
            // we have been told to pass some cards
            info = event.value as Array;
            _passTarget = info[0] as int;
            _passCount = info[1] as int;
            Debug.debug("Request received to pass " + _passCount + 
                " cards to be passed to player id " + _passTarget);
            dispatchEvent(new HandEvent(HandEvent.PASS_REQUESTED, 
                null, _gameCtrl.game.getMyId(), _passCount, _passTarget));
        }
        else if (event.name == varName(PASS_FULFILL)) {
            // we have been given some cards
            var from :int = (event.value as Array)[0] as int;
            cards = new CardArray((event.value as Array).slice(1));
            _sorter.insert(cards, _cards);
            Debug.debug("Received passed cards: " + cards + " from " + from);
            dispatchEvent(new HandEvent(HandEvent.PASSED, 
                cards, from, cards.length, _gameCtrl.game.getMyId()));
        }
        else if (event.name == varName(PASS_NOTIFY)) {
            // someone has been given some cards
            info = event.value as Array;
            Debug.debug("Received notification of " + info[2] + 
                " cards passed from " + info[0] + " to " + info[1]);
            // only send if I am not the receiver
            if (info[1] != _gameCtrl.game.getMyId()) {
                dispatchEvent(new HandEvent(HandEvent.PASSED, 
                    null, info[0] as int, info[2] as int, info[1] as int));
            }
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
    protected var _passTarget :int;
    protected var _passCount :int;
    protected var _hasPlayed :Boolean;

    /** Name of bag for the deck. */
    protected static const DECK :String = "hand.deck";

    /** Event message for getting cards. */
    protected static const DEALT :String = "hand.dealt";

    /** Event message for getting face down cards. */
    protected static const DEALT_FACE_DOWN :String = "hand.dealt.face.down";

    /** Event message for receiving the pass request. */
    protected static const PASS_REQUEST :String = "hand.pass.request";

    /** Event message for receiving passed cards. */
    protected static const PASS_FULFILL :String = "hand.pass.fulfill";

    /** Event message for notifying other players of the pass. */
    protected static const PASS_NOTIFY :String = "hand.pass.notify";
}

}
