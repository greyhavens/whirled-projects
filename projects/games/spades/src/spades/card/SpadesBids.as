package spades.card {

import com.whirled.game.GameControl;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.contrib.card.trick.Bids;
import com.whirled.contrib.card.trick.BidEvent;
import com.whirled.contrib.card.CardException;

/** Bids object extension for handling spades specific bidding behavior, blind nils */
public class SpadesBids extends Bids
{
    /** Non-bid value to be passed into the Bids.request method as a maximum value. Spades 
     *  listeners should catch this value and e.g. show the blind nil / show cards buttons */
    public static const REQUESTED_BLIND_NIL :int = -1;

    /** Non-bid value to be passed into the Bids.select method as a selected value. The spades
     *  controller will want to catch this value and place the blind nil response. */
    public static const SELECTED_BLIND_NIL :int = -1;

    /** Non-bid value to be passed into the Bids.select method as a selected value. The spades
     *  controller will want to catch this value and place the blind nil response. */
    public static const SELECTED_SHOW_CARDS :int = -2;

    /** Event type for when a blind nil is accepted or refused by some player at the table. For
     *  this event type, the player property is the player who has responded to the blind nil
     *  request, the value is 0 if it was refused and 1 if it was accepted.
     *  TODO: should BidEvent event types be defined outside of BidEvent? */
    public static const BLIND_NIL_RESPONDED :String = 
        BidEvent.newEventType("bids.spades.blindnil.responded");

    /** Create a new object for bids in a game of spades. */
    public function SpadesBids (gameCtrl :GameControl, max :int)
    {
        super(gameCtrl, max);
    }

    /** @inheritDoc */
    // from Bids
    public override function reset () :void
    {
        _gameCtrl.doBatch(batch);

        super.reset();

        function batch () :void {
            _gameCtrl.net.set(BLIND_NIL_ACCEPTED, 0);
            _gameCtrl.net.set(BLIND_NIL_REFUSED, 0);
        }
    }

    /** Accept or refuse a blind nil request. When this arrives on clients, a BidEvent with type
     *  BLIND_NIL_RESPONDED will be dispatched. 
     *  @throws CardException if the player has already bid or some other player has bid blind 
     *  nil. */
    public function placeBlindNilResponse (accepted :Boolean) :void
    {
        var id :int = _gameCtrl.game.getMyId();
        if (hasBid(_gameCtrl.game.seating.getMyPosition())) {
            throw new CardException("Player may not respond to blind nil " + 
                "after bidding");
        }
        if (accepted && _blindNilAccepted > 0) {
            throw new CardException("Only one player may bid blind nil");
        }

        var name :String = accepted ? BLIND_NIL_ACCEPTED : BLIND_NIL_REFUSED;
        _gameCtrl.net.set(name, id);

        if (accepted) {
            placeBid(0);
        }
    }

    /** Check if the player in the given absolute seating position has bid blind. */
    public function isBlind (seat :int) :Boolean
    {
        var players :Array = _gameCtrl.game.seating.getPlayerIds();
        return players[seat] == _blindNilAccepted;
    }

    /** Check if the player in the given absolute seating position has decided not to bid blind. */
    public function hasResponded (seat :int) :Boolean
    {
        var players :Array = _gameCtrl.game.seating.getPlayerIds();
        return players[seat] == _blindNilRefused || players[seat] == _blindNilAccepted;
    }

    /** Access the absolute seating position of the player that bid blind nil, or -1 if noone has. */
    public function get blindBidder () :int
    {
        var players :Array = _gameCtrl.game.seating.getPlayerIds();
        return players.indexOf(_blindNilAccepted);
    }

    protected override function handlePropertyChanged (
        event :PropertyChangedEvent) :void
    {
        super.handlePropertyChanged(event);

        if (event.name == BLIND_NIL_ACCEPTED) {
            _blindNilAccepted = event.newValue as int;
            if (event.newValue > 0) {
                dispatchEvent(new BidEvent(BLIND_NIL_RESPONDED, _blindNilAccepted, 1));
            }
        }
        else if (event.name == BLIND_NIL_REFUSED) {
            _blindNilRefused = event.newValue as int;
            if (event.newValue > 0) {
                dispatchEvent(new BidEvent(BLIND_NIL_RESPONDED, _blindNilRefused, 0));
            }
        }
    }

    protected var _blindNilAccepted :int = 0;
    protected var _blindNilRefused :int = 0;

    protected static const BLIND_NIL_ACCEPTED :String = "blindnil.accepted";
    protected static const BLIND_NIL_REFUSED :String = "blindnil.refused";

}

}
