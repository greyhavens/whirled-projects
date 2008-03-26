package spades.graphics {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

/**
 * Flash object for a player sitting at a trick-taking card game. This is a placeholder for 
 * something nicer, so only the interface is documented in detail.
 */
public class PlayerSprite extends Sprite
{
    /** Create a new player. */
    public function PlayerSprite (name :String)
    {
        // setup name in top third of player box
        var nameField :TextField = new TextField();
        nameField.autoSize = TextFieldAutoSize.CENTER;
        nameField.x = 0;
        nameField.y = -HEIGHT / 2;
        nameField.text = name;
        nameField.selectable = false;
        addChild(nameField);

        // setup trick count in bottom third of player box
        _status = new TextField();
        _status.autoSize = TextFieldAutoSize.CENTER;
        _status.x = 0;
        _status.y = HEIGHT / 6;
        _status.selectable = false;
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
        graphics.drawRect(-WIDTH / 2, -HEIGHT / 2, WIDTH, HEIGHT);
        graphics.endFill();
    }

    /** Update to reflect the player's bid. */
    public function setBid (bid :int) :void
    {
        _bid = bid;
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

        if (_bid == NO_BID) {
            s += "?";
        }
        else {
            s += _bid;
        }

        _status.text = s;
    }

    protected var _status :TextField;
    protected var _tricks :int = 0;
    protected var _bid :int = -1;

    protected static const WIDTH :int = 100;
    protected static const HEIGHT :int = 72;
    protected static const NO_BID :int = TableSprite.NO_BID;
}

}

