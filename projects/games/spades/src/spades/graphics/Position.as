package spades.graphics {

/**
 * A position within a parent object, represented by percentages.
 */
public class Position
{
    /** Create a position at a horizontal and vertical percentage. */
    public function Position (hpercent :int, vpercent :int)
    {
        _hpercent = hpercent;
        _vpercent = vpercent;
    }

    /** @inheritDoc */
    public function toString () :String
    {
        return "(" + _hpercent + "%, " + _vpercent + "%)";
    }

    /** Access the horizontal position as a percentage of the display. */
    public function get hpercent () :int
    {
        return _hpercent;
    }

    /** Access the vertical position as a percentage of the display. */
    public function get vpercent () :int
    {
        return _vpercent;
    }

    /** Access the horizontal position as a fraction of the display. */
    public function get hfraction () :Number
    {
        return _hpercent / 100;
    }

    /** Access the vertical position as a fraction of the display. */
    public function get vfraction () :Number
    {
        return _vpercent / 100;
    }

    /** Horizontal position as a percentage */
    protected var _hpercent :int;

    /** Vertical position as a percentage */
    protected var _vpercent :int;
}
    
}
