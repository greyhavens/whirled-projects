package core.components {

public interface MeterComponent
{
    function get value () :Number;
    function set value (val :Number) :void;

    function get minValue () :Number;
    function set minValue (val :Number) :void;

    function get maxValue () :Number;
    function set maxValue (val :Number) :void;
}

}
