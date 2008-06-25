package {

import flash.geom.Point;

public interface Observer
{
    /** Called by the model when a letter changed on the board. */
    function letterDidChange(position :Point, letter :String) :void;
}

}
