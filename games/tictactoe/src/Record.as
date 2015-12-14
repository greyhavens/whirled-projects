package {

import flash.display.Sprite;
import flash.text.TextField;

/**
 * Sprite to show a player's win/loss record.
 */
public class Record extends Sprite
{
    /**
     * Creates a new Record sprite.
     */
    public function Record ()
    {
        _str = new TextField();
        _str.background = true;
        _str.backgroundColor = 0xFFFFFF;
        addChild(_str);
        update(null);
    }

    /**
     * Updates the text based on the given cookie.
     */
    public function update (cookie :Object) :void
    {
        if (cookie == null) {
            _str.text = "No record";

        } else {
            _str.text = "" + cookie.won + " won, " + cookie.lost + " lost";
        }
    }

    /** The text showing the win/loss record. */
    protected var _str :TextField;
}
}
