package spades.graphics {

/** Represents the state of a card sprite. */
public class CardState
{
    /** Create a card state. A state is the color and opacity of a rectangular sprite overlaying 
     *  the card. */
    public function CardState (color :uint, alpha :Number, name :String=null)
    {
        _color = color;
        _alpha = alpha;
        _name = name;
    }

    public function get alpha () :Number
    {
        return _alpha;
    }

    public function get color () :uint
    {
        return _color;
    }

    public function get name () :String
    {
        return _name;
    }

    /** @inheritDoc */
    // from Object
    public function toString () :String
    {
        if (_name != null) {
            return _name;
        }
        return "Color: " + _color.toString(16) + ", Alpha: " + _alpha;
    }

    private var _color :uint;
    private var _alpha :Number;
    private var _name :String;
}

}
