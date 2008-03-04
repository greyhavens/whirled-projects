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
        strokeBegun(id, new Stroke(from, to, color, brush));
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

    protected function strokeBegun (id :String, stroke :Stroke) :void
    {
        if (_strokes.get(id) != null) {
            log.warning("Attempting to add a new stroke with existing id! [" + id + "]");
            return;
        }

        _strokes.put(id, stroke);
        _canvas.strokeBegun(id, stroke);

        var bytes :int = serialize().length;
        _canvas.reportFillPercent(bytes / MAX_STORAGE_SIZE);
    }

    protected function strokeExtended (id :String, to :Point) :void
    {
        var stroke :Stroke = _strokes.get(id);
        if (stroke == null) {
            log.warning("attempted to extend an unknown stroke [" + id + "]");
            return;
        }

        stroke.extend(to);
        _canvas.strokeExtended(id, to);

        var bytes :int = serialize().length;
        _canvas.reportFillPercent(bytes / MAX_STORAGE_SIZE);
    }

    protected function serialize () :ByteArray 
    {
        var bytes :ByteArray = new ByteArray();

        // write model version number.
        bytes.writeInt(MODEL_VERSION_NUMBER);

        // write the background color
        bytes.writeUnsignedInt(_backgroundColor);

        // write the strokes
        bytes.writeInt(_strokes.size()); // number of strokes
        var colorLUT :HashMap = new HashMap();
        for each (var stroke :Stroke in _strokes.values()) {
            stroke.serialize(bytes, colorLUT);
        }

        // write the LUT - its the last thing in the data chunk, so we don't need to write the
        // size
        for each (var color :uint in colorLUT.keys()) {
            bytes.writeUnsignedInt(color);
            bytes.writeInt(colorLUT.get(color));
        }

        bytes.compress();
        return bytes;
    }

    private static const log :Log = Log.getLog(Model);

    protected static const MODEL_VERSION_NUMBER :int = 1;

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
