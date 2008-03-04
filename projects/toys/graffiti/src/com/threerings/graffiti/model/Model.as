// $Id$

package com.threerings.graffiti.model {

import flash.geom.Point;

import flash.utils.ByteArray;

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.Random;

import com.whirled.FurniControl;

import com.threerings.graffiti.Canvas;

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
        _canvas.paintBackground(_backgroundColor = color);
    }

    public function getBackgroundColor () :uint
    {
        return _backgroundColor;
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
        // TODO: bump strokes into an Array so they can retain their creation order.  Also, use
        // a real object for strokes, since we're implementing custom serialization anyway.
        _strokes.put(id, stroke);

        var bytes :int = serialize().length;
        _canvas.reportFillPercent((bytes / MAX_STORAGE_SIZE) * 100);
    }

    protected function serialize () :ByteArray 
    {
        var colorLUT :HashMap = new HashMap();
        var strokes :Array = _strokes.values();
        for each (var stroke :Array in strokes) {
            var color :uint = strokes[0][2];
            if (!colorLUT.containsKey(color)) {
                colorLUT.put(color, colorLUT.size() + 1);
            }
        }

        // TODO: push the LUT to the end so that we only have to process the strokes once in 
        // serialization, as its the more common operation.
        var bytes :ByteArray = new ByteArray();
        // serialized format:
        //  - Background color (uint);
        //  - LUT size (int)
        //    - LUT entry: color (uint), key (int)
        //  - Strokes: 
        //    - stroke length (int);
        //    - beginning stroke: from (int x, int y), to (int x, int y), color (int key into LUT),
        //                        brush thickness (int), brush alpha (int percent)
        //    - extension stroke: from (int offset from last x, int offset from last y)

        // background color
        bytes.writeUnsignedInt(_backgroundColor);

        // write the LUT
        bytes.writeInt(colorLUT.size());
        for each (color in colorLUT.keys()) {
            bytes.writeUnsignedInt(color);
            bytes.writeInt(colorLUT.get(color));
        }

        // write the strokes
        for each (stroke in strokes) {
            // length
            bytes.writeInt(stroke.length);

            // from
            bytes.writeInt(Math.round(stroke[0][1].x));
            bytes.writeInt(Math.round(stroke[0][1].y));

            // to
            var currentX :int = Math.round(stroke[0][0].x);
            bytes.writeInt(currentX);
            var currentY :int = Math.round(stroke[0][0].y);
            bytes.writeInt(currentY);

            // color
            bytes.writeInt(colorLUT.get(stroke[0][2]));
            // brush thickness
            var brush :Brush = stroke[0][3] as Brush;
            bytes.writeInt(brush.thickness);
            // brush alpha
            bytes.writeInt(Math.round(brush.alpha * 100));

            // stroke extensions
            for (var ii :int = 1; ii < stroke.length; ii++) {
                var extension :Point = stroke[ii] as Point;
                var extX :int = Math.round(extension.x);
                var extY :int = Math.round(extension.y);
                bytes.writeInt(extX - currentX);
                bytes.writeInt(extY - currentY);
                currentX = extX;
                currentY = extX;
            }
        }

        bytes.compress();
        return bytes;
    }

    private static const log :Log = Log.getLog(Model);

    protected static const MAX_STORAGE_SIZE :int = 4 * 1024; // in bytes

    protected var _canvas :Canvas;
    protected var _strokes :HashMap;
    protected var _backgroundColor :uint = 0xFFFFFF;

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
