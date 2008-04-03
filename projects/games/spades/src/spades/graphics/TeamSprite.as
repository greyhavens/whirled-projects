package spades.graphics {


import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import com.threerings.flash.Vector2;

import caurina.transitions.Tweener;

import spades.card.Bids;
import spades.card.BidEvent;
import spades.card.Table;


/** Represents a team display. Includes a placeholder box and last trick display. 
 *  TODO: names, score and trick totals. */
public class TeamSprite extends Sprite
{
    public static const NO_BID :int = TableSprite.NO_BID;

    /** Create a new team sprite. Long names will be truncated with an ellipsis.
     *  @param table the table we are sitting at
     *  @param seats the relative seating positions of the players on this team
     *  @param bids the bids object for the game 
     *  @param mainTrickPos the global coordinates of the main trick - used for animating the 
     *  taking of a trick.
     *  @param lastTrickPos the relative position of the scaled down last trick icon 
     *  @param playerSeats the absolute seating positions of the players on this team */
    public function TeamSprite (
        table :Table, 
        seats :Array,
        bids :Bids,
        mainTrickPos :Vector2,
        lastTrickPos :Vector2)
    {
        _table = table;
        _seats = seats;
        _bids = bids;
        _mainTrickPos = mainTrickPos.clone();
        _lastTrickPos = lastTrickPos.clone();

        _lastTrick = new LastTrickSprite();
        addChild(_lastTrick);

        var nameField :TextField = new TextField();
        nameField.autoSize = TextFieldAutoSize.CENTER;
        nameField.x = 0;
        nameField.y = -HEIGHT / 2;
        nameField.text = makeNameString(
            _table.getNameFromRelative(_seats[0]), 
            _table.getNameFromRelative(_seats[1]));
        nameField.selectable = false;
        addChild(nameField);

        _tricksScore = new TextField();
        _tricksScore.autoSize = TextFieldAutoSize.CENTER;
        _tricksScore.x = 0;
        _tricksScore.selectable = false;
        addChild(_tricksScore);

        _score = new TextField();
        _score.autoSize = TextFieldAutoSize.CENTER;
        _score.x = 0;
        _score.selectable = false;
        addChild(_score);

        graphics.clear();
        graphics.beginFill(0x808080);
        graphics.drawRect(-WIDTH / 2, -HEIGHT/2, WIDTH, HEIGHT);
        graphics.endFill();

        updateTricks();

        bids.addEventListener(BidEvent.RESET, bidListener);
        bids.addEventListener(BidEvent.PLACED, bidListener);
    }

    /** Take the array of card sprites and animate them to this team's last trick slot. The 
     *  animation includes x,y position and scale. */
    public function takeTrick (cards :Array) :void
    {
        var localStartPos :Vector2 = Vector2.fromPoint(
            globalToLocal(_mainTrickPos.toPoint()));

        _lastTrick.setCards(cards);
        _lastTrick.x = localStartPos.x;
        _lastTrick.y = localStartPos.y;
        _lastTrick.scaleX = 1.0;
        _lastTrick.scaleY = 1.0;

        var tween :Object = {
            x: _lastTrickPos.x,
            y: _lastTrickPos.y,
            scaleX: TRICK_SCALE,
            scaleY: TRICK_SCALE,
            time: TRICK_DURATION
        };

        Tweener.addTween(_lastTrick, tween);
    }

    /** Clear the card sprites. */
    public function clearLastTrick () :void
    {
        _lastTrick.clear();
    }

    /** Set the tricks a player has taken. */
    public function setTricks (player :int, tricks :int) :void
    {
        _tricks[player] = tricks;
        updateTricks();
    }

    /** Set the team's score display. */
    public function setScore (current :int, target :int) :void
    {
        _score.text = "" + current + "/" + target;
        _score.y = HEIGHT / 2 - _score.textHeight;
    }

    /** Update the tricks/bid status text. */
    protected function updateTricks () :void
    {
        var totalTricks :int = _tricks[0] + _tricks[1];
        var text :String = "" + totalTricks + "/";
        var seats :Array = [
            _table.getAbsoluteFromRelative(_seats[0]),
            _table.getAbsoluteFromRelative(_seats[1])];

        if (!_bids.hasBid(seats[0]) || !_bids.hasBid(seats[1])) {
            text += "?";
        }
        else {
            text += _bids.getBid(seats[0]) + _bids.getBid(seats[1]);
        }

        _tricksScore.text = text;
        _tricksScore.y = -_tricksScore.textHeight / 2;
    }

    protected function bidListener (event :BidEvent) :void
    {
        if (event.type == BidEvent.RESET) {
            _tricks[0] = 0;
            _tricks[1] = 0;
            updateTricks();
        }
        else if (event.type == BidEvent.PLACED) {
            updateTricks();
        }
    }

    /** Utility function to truncate a name. */
    protected static function truncName (name: String) :String
    {
        if (name.length > MAX_NAME_LENGTH) {
            name = name.substr(0, MAX_NAME_LENGTH) + "...";
        }
        return name;
    }

    /** Utility function to truncate and concatenate two names. */
    protected static function makeNameString (
        name1: String, 
        name2 :String) :String
    {
        name1 = truncName(name1);
        name2 = truncName(name2);
        return name1 + "/" + name2;
    }

    /** The table we are sitting at */
    protected var _table :Table;

    /** The seats of our team members */
    protected var _seats :Array;

    /** The bids for the game */
    protected var _bids :Bids;

    /** Sprite for the last trick display */
    protected var _lastTrick :LastTrickSprite;

    /** Position of main trick, in global coordinates */
    protected var _mainTrickPos :Vector2;

    /** Static position of our last trick display */
    protected var _lastTrickPos :Vector2;

    /** Tricks */
    protected var _tricks :Array = [0, 0];

    /** Tricks score, e.g. "1/5" */
    protected var _tricksScore :TextField;

    /** Score score, e.g. "172/300" */
    protected var _score :TextField;

    protected static const TRICK_SCALE :Number = 0.5;
    protected static const TRICK_DURATION :int = 1.0;

    protected static const MAX_NAME_LENGTH :int = 12;

    protected static const WIDTH :int = 180;
    protected static const HEIGHT :int = 80;
}

}
