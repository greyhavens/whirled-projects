// $Id$

package com.threerings.graffiti {

import flash.geom.Point;

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.Random;

import com.whirled.FurniControl;

import com.threerings.graffiti.tools.Brush;

public class Model
{
    public function Model (canvas :Canvas)
    {
        _canvas = canvas;

        _strokes = new HashMap();
    }

    public function beginStroke (id :String, from :Point, to :Point, color :int, brush :Brush) :void
    {
        strokeBegun(id, from, to, color, brush);
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

    public function setBackgroundColor (color :uint) :void
    {
        _canvas.paintBackground(color);
    }

    protected function strokeBegun (id :String, from :Point, to :Point, color :int,     
        brush :Brush) :void
    {
        pushBub(id, [ to, from, color, brush ]);
        _canvas.strokeBegun(id, from, to, color, brush);
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
        return stroke;
    }

    protected function putStroke (id :String, stroke :Array) :void
    {
        _strokes.put(id, stroke);
        var total :int;
        for each (var stroke :Array in _strokes.values()) {
            total += stroke.length;
        }
        var size :int = (7 * _strokes.size() + (total - _strokes.size()) * 2) * 4;
        log.debug("total size [" + size + "]");
    }

    private static const log :Log = Log.getLog(Model);

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
