package spades.graphics {


import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import com.threerings.flash.Vector2;

import caurina.transitions.Tweener;

/** Represents a team display. Includes a placeholder box and last trick display. 
 *  TODO: names, score and trick totals. */
public class TeamSprite extends Sprite
{
    public static const NO_BID :int = TableSprite.NO_BID;

    /** Create a new team sprite. Long names will be truncated with an ellipsis.
     *  @param name1 the first name to appear in the label
     *  @param name2 the second name to appear in the label
     *  @param mainTrickPos the global coordinates of the main trick - used for animating the 
     *  taking of a trick.
     *  @lastTrickPos the relative position of the scaled down last trick icon */
    public function TeamSprite (
        name1 :String, 
        name2 :String, 
        mainTrickPos :Vector2,
        lastTrickPos :Vector2)
    {
        _mainTrickPos = mainTrickPos.clone();
        _lastTrickPos = lastTrickPos.clone();

        _lastTrick = new LastTrickSprite();
        addChild(_lastTrick);

        var nameField :TextField = new TextField();
        nameField.autoSize = TextFieldAutoSize.CENTER;
        nameField.x = 0;
        nameField.y = -HEIGHT / 2;
        nameField.text = makeNameString(name1, name2);
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

    /** Set the bid for a player. If the bid of any player is NO_BID, then a "?" is shown, 
     *  otherwise the sum of bids is shown.
     *  @player the index of the player in the team (either 0 or 1) */
    public function setBid (player :int, bid :int) :void
    {
        _bids[player] = bid;
        updateTricks();
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

        if (_bids[0] == NO_BID || _bids[1] == NO_BID) {
            text += "?";
        }
        else {
            text += _bids[0] + _bids[1];
        }

        _tricksScore.text = text;
        _tricksScore.y = -_tricksScore.textHeight / 2;
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

    /** Sprite for the last trick display */
    protected var _lastTrick :LastTrickSprite;

    /** Position of main trick, in global coordinates */
    protected var _mainTrickPos :Vector2;

    /** Static position of our last trick display */
    protected var _lastTrickPos :Vector2;

    /** Bids */
    protected var _bids :Array = [NO_BID, NO_BID];

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
