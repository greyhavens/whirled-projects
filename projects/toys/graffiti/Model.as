//
// $Id$

package {

import flash.geom.Point;
import flash.utils.Dictionary;

import com.threerings.util.HashMap;

public class Model
{
    public function Model (board :Board)
    {
        _board = board;

        _strokes = new HashMap();
    }

    public function beginStroke (id :String, from :Point, to :Point, colour :int) :void
    {
        strokeBegun(id, from, to, colour);
    }

    public function extendStroke (id :String, to :Point) :void
    {
        strokeExtended(id, to);
    }

    protected function strokeBegun (id :String, from :Point, to :Point, colour :int) :void
    {
        pushBub(id, [ to, from, colour ]);
        _board.strokeBegun(id, from, to, colour);
    }

    protected function strokeExtended (id :String, to :Point) :void
    {
        pushBub(id, to);
        _board.strokeExtended(id, to);
    }

    protected function pushBub (id :String, bub :Object) :Array
    {
        var stroke :Array;

        stroke = _strokes.get(id);
        if (!stroke) {
            stroke = new Array();
        }
        stroke.push(bub);
        putStroke(id, stroke);
        _strokes.put(id, stroke);
        return stroke;
    }

    protected function putStroke (id :String, stroke :Array) :void
    {
        _strokes.put(id, stroke);
    }

    protected var _board :Board;
    protected var _strokes :HashMap;
}
}