package {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.MovieClip;

import com.threerings.util.Log;

import com.whirled.game.*;

/**
 * The main sprite for the spades game.
 * @TODO Factor certain things into CardGame and/or TrickTakingCardGame.
 * @TODO Strip out excessive debug logging.\
 * @TODO Use localized feeedback.
 */
[SWF(width="800", height="800")]
public class Spades extends Sprite
{
    /** Players required for a game of spades */
    public static const NUM_PLAYERS :int = 4;

    /** Number of cards in a player's hand at the start of a round */
    public static const NUM_CARDS_PER_PLAYER :int = 
        CardArray.FULL_DECK.ordinals.length / NUM_PLAYERS;

    /** Number of "hands" played in a round (i.e. tricks to take) */
    public static const NUM_TRICKS_PER_ROUND :int = NUM_CARDS_PER_PLAYER;

    /** Represents an undefined bid (player has not chosen yet) */
    public static const NO_BID :int = -1;

    /** Maximum amount a player can bid */
    public static const MAX_BID :int = NUM_TRICKS_PER_ROUND;

    /** Kludgy constant sized display (TODO: rely on browser area) */
    public static const DISPLAY :Display = new Display(700, 550);

    /** Positions of other players' on the table (relative to the local player). */
    public static const PLAYER_POSITIONS :Array = [
        new Position(50, 40),  // me
        new Position(25, 25),  // my left
        new Position(50, 10),  // opposite
        new Position(75, 25)   // my right
    ];

    /** Position of the center of the local player's hand. */
    public static const HAND_POSITION :Position = new Position(50, 75);

    /** Position of the center of the bid slider */
    public static const SLIDER_POSITION :Position = new Position(50, 60);

    /** Main entry point. Start a new game of spades. */
    public function Spades ()
    {
        _gameCtrl = new GameControl(this);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED, handleGameEnded);
        _gameCtrl.game.addEventListener(StateChangedEvent.TURN_CHANGED, handleTurnChanged);
        _gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED,
            handleElementChanged);
        _gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED,
            handlePropertyChanged);
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessage);

        // todo: use the config
        var config :Object = _gameCtrl.game.getConfig();

        // todo: clean up scoring paradigm (the idea here is that the score is 
        // shown for each team).
        _gameCtrl.local.setPlayerScores([ 0, "", 0, "" ], [ 1, 1, 0, 0 ]);

        // configure the players
        setUpPlayers();
    }

    / ** For debugging, log a string prefixed with player name and seating position. */
    public function log (str :String) :void
    {
        var myIdx :int = getMySeat();
        var myName :String = _gameCtrl.game.seating.getPlayerNames()[myIdx];
        Log.getLog(this).info("[" + myName + "@seat" + myIdx + "] " + str);
    }

    /** Create and position the player sprites. */
    protected function setUpPlayers () :void
    {
        var names :Array = _gameCtrl.game.seating.getPlayerNames();
        var mySeat :int = getMySeat();

        // For each seat, create a sprite and position relative to local player
        for (var seat :int = 0; seat < NUM_PLAYERS; ++seat) {
            var p :Player = new Player(names[seat] as String);
            var relative :int = (seat - mySeat + NUM_PLAYERS) % NUM_PLAYERS;
            DISPLAY.move(p, PLAYER_POSITIONS[relative] as Position);
            addChild(p);
            _players[seat] = p;
        }
    }

    /** Boot up the game.
     *  @TODO Decide who is going to deal rather than use controller. */
    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        _gameCtrl.local.feedback("Spades superchallenge: go!\n");

        // controlling implies dealing for now
        if (_gameCtrl.game.amInControl()) {

            log("I am the dealer");
            
            // put all cards into a bag
            var deck :Array = CardArray.FULL_DECK.ordinals;
            _gameCtrl.services.bags.create(COMS_DECK, deck);
            
            // deal to each player
            var playerIds :Array = _gameCtrl.game.seating.getPlayerIds();
            for (var seat :int = 0; seat < NUM_PLAYERS; ++seat) {
                _gameCtrl.services.bags.deal(COMS_DECK, NUM_CARDS_PER_PLAYER, 
                    COMS_HAND, null, playerIds[seat]);
            }

            // set up bids and transfer control to the player on my left
            var bids :Array = [NO_BID, NO_BID, NO_BID, NO_BID];
            _gameCtrl.net.set(COMS_BIDS, bids);
            _gameCtrl.game.startNextTurn(getNextPlayer());
        }
    }

    /** Get the id of the player in a particular seat. */
    protected function getPlayerId (seat :int) :int
    {
        var id :int = _gameCtrl.game.seating.getPlayerIds()[seat];
        return id;
    }

    /** Get the id of the player on my left. */
    protected function getNextPlayer () :int
    {
        var mySeat :int = getMySeat();
        return getPlayerId((mySeat + 1) % 4);
    }

    /** Get my seat number. */
    protected function getMySeat () :int
    {
        var mySeat :int = _gameCtrl.game.seating.getMyPosition();
        return mySeat;
    }

    /** End the game.
     *  @TODO award points. */
    protected function handleGameEnded (event :StateChangedEvent) :void
    {
        _gameCtrl.local.feedback("Thank you for playing Spades!");
    }

    /** Update the UI after a turn change. */
    protected function handleTurnChanged (event :StateChangedEvent) :void
    {
        // Make sure the current turn holder is "selected"
        var turnHolder :int = _gameCtrl.game.getTurnHolderId();
        var hotSeat :int = _gameCtrl.game.seating.getPlayerPosition(turnHolder);
        log("Turn changed to " + turnHolder + " in seat " + hotSeat);
        for (var i :int = 0; i < NUM_PLAYERS; ++i) {
            var p :Player = _players[i] as Player;
            p.setTurn(i == hotSeat);
        }

        updateBidding();
        updateMoves();
    }

    /** Main entry point for element changes */
    protected function handleElementChanged (event :ElementChangedEvent) :void
    {
        log("Element changed:" + event.name);

        if (event.name == COMS_BIDS) {
            // Make sure that a player's bid is reflected in his sprite
            var bids :Array = _gameCtrl.net.get(COMS_BIDS) as Array;
            var p :Player = _players[event.index] as Player;
            var bid :int = bids[event.index] as int;
            if (bid == NO_BID) {
                p.clearBid();
            }
            else {
                p.setBid(bid);
                var name :String = _gameCtrl.game.seating.getPlayerNames()[event.index];
                _gameCtrl.local.feedback(name + " bid " + bid);
            }
        }
    }

    /** Main entry point for property changes. */
    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        log("Property changed:" + event.name);
    }

    /** Show or hide the bidding interface. */
    protected function updateBidding () :void
    {
        var bids :Array = _gameCtrl.net.get(COMS_BIDS) as Array;
        var showSlider :Boolean = 
            _gameCtrl.game.isMyTurn() && 
            bids != null && 
            bids[getMySeat()] == NO_BID;

        log("Ready to bid: " + showSlider);

        if (showSlider) {
            if (_bidSlider == null) {
                _bidSlider = new BidSlider(NUM_TRICKS_PER_ROUND, onBid);
                DISPLAY.move(_bidSlider, SLIDER_POSITION);
                addChild(_bidSlider);
            }
        }
        else {
            if (_bidSlider != null) {
                removeChild(_bidSlider);
                _bidSlider = null;
            }
        }
    }

    /** Entry point for when the user selects their bid */
    protected function onBid (bid :int) :void
    {
        _gameCtrl.net.setAt(COMS_BIDS, getMySeat(), bid);
        _gameCtrl.game.startNextTurn();
    }

    /** @TODO Highlight the cards that may now be played. */
    protected function updateMoves () :void
    {
    }

    /** Main entry point for messages. */
    protected function handleMessage (event :MessageReceivedEvent) :void
    {
        log("Received message: " + event.name);
        
        if (event.name == COMS_HAND) {
            // we have been given some cards, record them and add the sprite
            _hand = new CardArray(event.value as Array);
            log("My hand is " + _hand);
            DISPLAY.move(_hand.display, HAND_POSITION);
            addChild(_hand.display);
        }
    }

    /** Our game control object. */
    protected var _gameCtrl :GameControl;

    /** Our hand. */
    protected var _hand :CardArray;

    /** The slider for making a bid (null if not bidding). */
    protected var _bidSlider :BidSlider;

    /** Player instances in the game. */
    protected var _players :Array = new Array(NUM_PLAYERS);

    /** Event message for getting cards. */
    protected static const COMS_HAND :String = "hand";

    /** Name of bag for the deck. */
    protected static const COMS_DECK :String = "deck";

    /** Name of property for bids array. */
    protected static const COMS_BIDS :String = "bids";
}
}

