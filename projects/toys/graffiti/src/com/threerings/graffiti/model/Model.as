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
    public function Model ()
    {
        _strokes = new HashMap();
    }

    public function registerCanvas (canvas :Canvas) :void
    {
        _canvases.addCanvas(canvas);
    }

    public function unregisterCanvas (canvas :Canvas) :void
    {
        _canvases.removeCanvas(canvas);
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
        _canvases.paintBackground(_backgroundColor = color);
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
        _canvases.strokeBegun(id, stroke);

        serialize();
    }

    protected function strokeExtended (id :String, to :Point) :void
    {
        var stroke :Stroke = _strokes.get(id);
        if (stroke == null) {
            log.warning("attempted to extend an unknown stroke [" + id + "]");
            return;
        }

        stroke.extend(to);
        _canvases.strokeExtended(id, to);

        serialize();
    }

    protected function serialize () :void 
    {
        _serializedStrokes = new ByteArray();

        // write model version number.
        _serializedStrokes.writeInt(MODEL_VERSION_NUMBER);

        // write the background color
        _serializedStrokes.writeUnsignedInt(_backgroundColor);

        // write the strokes
        var strokesBytes :ByteArray = new ByteArray();
        strokesBytes.writeInt(_strokes.size()); // number of strokes
        var colorLUT :HashMap = new HashMap();
        for each (var stroke :Stroke in _strokes.values()) {
            stroke.serialize(strokesBytes, colorLUT);
        }

        // write the LUT
        _serializedStrokes.writeInt(colorLUT.size());
        var colors :Array = new Array(colorLUT.size());
        for each (var color :uint in colorLUT.keys()) {
            colors[colorLUT.get(color)] = color;
        }
        // now that we have the colors in key order, dump the array
        for each (color in colors) {
            _serializedStrokes.writeUnsignedInt(color);
        }

        // append the stroke data
        _serializedStrokes.writeBytes(strokesBytes);

        _serializedStrokes.compress();
        _canvases.reportFillPercent(_serializedStrokes.length / MAX_STORAGE_SIZE);
    }

    protected function deserialize (bytes :ByteArray) :void
    {
        bytes.uncompress();

        var version :int = bytes.readInt();
        _backgroundColor = bytes.readUnsignedInt();
        
        var colorLUTSize :int = bytes.readInt(); 
        var colors :Array = new Array(colorLUTSize);
        for (var ii :int = 0; ii < colorLUTSize; ii++) {
            colors[ii] = bytes.readUnsignedInt();
        }

        _strokes.clear();
        var numStrokes :int = bytes.readInt();
        for (ii = 0; ii < numStrokes; ii++) {
            var stroke :Stroke = Stroke.createStrokeFromBytes(bytes, colors);
            _strokes.put(getKey(), stroke);
        }
    }

    private static const log :Log = Log.getLog(Model);

    protected static const MODEL_VERSION_NUMBER :int = 1;

    protected static const MAX_STORAGE_SIZE :int = 4 * 1024; // in bytes

    protected var _canvases :CanvasList = new CanvasList();
    protected var _strokes :HashMap;
    protected var _backgroundColor :uint = 0xFFFFFF;

    protected var _rnd :Random = new Random();

    protected var _serializedStrokes :ByteArray;
 
    protected const KEY_BITS :Array = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    ];
}
}

import flash.geom.Point;

import com.threerings.graffiti.Canvas;

import com.threerings.graffiti.model.Stroke;

class CanvasList 
{
    public function paintBackground (color :uint) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.paintBackground(color);
        }
    }

    public function strokeBegun (id :String, stroke :Stroke) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.strokeBegun(id, stroke);
        }
    }

    public function strokeExtended (id :String, to :Point) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.strokeExtended(id, to);
        }
    }

    public function reportFillPercent (percent :Number) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.reportFillPercent(percent);
        }
    }

    public function addCanvas (canvas :Canvas) :void
    {
        var ii :int = _canvases.indexOf(canvas);
        if (ii == -1) {
            _canvases.push(canvas);
        }
    }

    public function removeCanvas (canvas :Canvas) :void
    {
        var ii :int = _canvases.indexOf(canvas);
        if (ii != -1) {
            _canvases.splice(ii, 1);
        }
    }

    protected var _canvases :Array = [];
}
