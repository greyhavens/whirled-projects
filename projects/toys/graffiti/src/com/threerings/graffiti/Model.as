// $Id$

package com.threerings.graffiti {

import flash.geom.Point;

import com.threerings.util.HashMap;
import com.threerings.util.Random;

import com.whirled.FurniControl;

public class Model
{
    public function Model (canvas :Canvas)
    {
        _canvas = canvas;

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

    public function getStrokes () :HashMap
    {
        return _strokes;
    }

    public function getKey () :String
    {
        var key :String;
        do {
            key = KEY_BITS[_rnd.nextInt(KEY_BITS.length)] +
                KEY_BITS[_rnd.nextInt(KEY_BITS.length)] +
                KEY_BITS[_rnd.nextInt(KEY_BITS.length)];
        } while (_strokes.get(key) != null);

        return key;
    }

    protected function strokeBegun (id :String, from :Point, to :Point, colour :int) :void
    {
        pushBub(id, [ to, from, colour ]);
        _canvas.strokeBegun(id, from, to, colour);
    }

    protected function strokeExtended (id :String, to :Point) :void
    {
        pushBub(id, to);
        _canvas.strokeExtended(id, to);
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

    protected var _canvas :Canvas;
    protected var _strokes :HashMap;

    protected var _rnd :Random = new Random();
 
    protected const KEY_BITS :Array = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    ];
}
}
