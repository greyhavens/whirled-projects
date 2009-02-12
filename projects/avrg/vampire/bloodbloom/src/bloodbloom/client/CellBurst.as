package bloodbloom.client {

import bloodbloom.*;

import com.whirled.contrib.simplegame.tasks.*;

public class CellBurst extends CollidableObj
{
    public function CellBurst (cellType :int, radiusMin :Number, radiusMax :Number)
    {
        _cellType = cellType;
        _radius = radiusMin;
        _radiusMax = radiusMax;
    }

    public function get radiusMin () :Number
    {
        return _radius;
    }

    public function get radiusMax () :Number
    {
        return _radiusMax;
    }

    public function get targetScale () :Number
    {
        return (_radiusMax / _radius);
    }

    public function get cellType () :int
    {
        return _cellType;
    }

    override protected function addedToDB () :void
    {
        beginBurst();
    }

    protected function beginBurst () :void
    {
    }

    protected var _cellType :int;
    protected var _radiusMax :Number;
}

}
