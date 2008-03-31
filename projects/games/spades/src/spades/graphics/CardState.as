package spades.graphics {

/** Represents the state of a card sprite. */
public class CardState
{
    /** Create a card state. A state is the color and opacity of a rectangular sprite overlaying 
     *  the card. */
    public function CardState (color :uint, alpha :Number)
    {
        _color = color;
        _alpha = alpha;
    }

    public function get alpha () :Number
    {
        return _alpha;
    }

    public function get color () :uint
    {
        return _color;
    }

    private var _color :uint;
    private var _alpha :Number;
}

}
