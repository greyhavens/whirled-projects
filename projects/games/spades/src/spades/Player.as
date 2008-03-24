package spades {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

/**
 * Flash object for a player sitting at a trick-taking card game. This is a placeholder for 
 * something nicer, so only the interface is documented in detail.
 */
public class Player extends Sprite
{
    /** Create a new player. */
    public function Player (name :String)
    {
        // setup name in top third of player box
        var nameField :TextField = new TextField();
        nameField.width = WIDTH;
        nameField.height = HEIGHT * 1 / 3;
        nameField.text = name;
        addChild(nameField);

        // setup trick count in bottom third of player box
        _status = new TextField();
        _status.width = WIDTH;
        _status.y = HEIGHT * 2 / 3;
        _status.height = HEIGHT * 1 / 3;
        addChild(_status);

        setTurn(false);
        updateStatus();
    }

    /** Update to reflect the turn status.
     *  @param turn indicates whether it is this player's turn */
    public function setTurn (turn :Boolean) :void
    {
        graphics.clear();
        graphics.beginFill(turn ? 0x00FF00 : 0x808080);
        graphics.drawRect(0, 0, WIDTH, HEIGHT);
        graphics.endFill();
    }

    /** Update to reflect the player's bid. */
    public function setBid (bid :int) :void
    {
        _bid = bid;
        updateStatus();
    }

    /** Update to reflect the player's lack of a bid. */
    public function clearBid () :void
    {
        _bid = NO_BID;
        updateStatus();
    }

    /** Update to reflect the player's number of tricks. */
    public function setTricks (tricks :int) :void
    {
        _tricks = tricks;
        updateStatus();
    }

    protected function updateStatus () :void
    {
        var s :String = "" + _tricks + "/";

        if (_bid == NO_BID)
        {
            s += "?";
        }
        else
        {
            s += _bid;
        }

        _status.text = s;
    }

    protected var _status :TextField;
    protected var _tricks :int = 0;
    protected var _bid :int = -1;

    protected static const WIDTH :int = 100;
    protected static const HEIGHT :int = 60;
    protected static const NO_BID :int = -1;
}

}

