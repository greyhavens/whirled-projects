package {

import flash.display.Sprite;
import flash.text.TextField;

public class Record extends Sprite
{
    public function Record ()
    {
        _str = new TextField();
        _str.background = true;
        _str.backgroundColor = 0xFFFFFF;
        addChild(_str);
        update(null);
    }

    public function update (cookie :Object) :void
    {
        if (cookie == null) {
            _str.text = "No record";

        } else {
            _str.text = "" + cookie.won + " won, " + cookie.lost + " lost";
        }
    }

    protected var _str :TextField;
}

}
