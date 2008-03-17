// $Id$

package com.threerings.graffiti.model {

import flash.geom.Point;

import flash.utils.ByteArray;

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.Random;

import com.whirled.FurniControl;

import com.threerings.graffiti.Canvas;

import com.threerings.graffiti.tools.Tool;

public class Model
{
    public function registerCanvas (canvas :Canvas) :void
    {
        _canvases.addCanvas(canvas);
    }

    public function unregisterCanvas (canvas :Canvas) :void
    {
        _canvases.removeCanvas(canvas);
    }

    public function beginStroke (id :String, from :Point, to :Point, tool :Tool) :void
    {
        if (id == null || _tempStrokesMap.get(id) != null) {
            log.warning("Attempting to add a new stroke with null or existing id! [" + id + "]");
            return;
        }

        strokeBegun(id, new Stroke(from, to, tool));
    }

    public function extendStroke (id :String, to :Point, end :Boolean = false) :void
    {
        var stroke :Stroke = _tempStrokesMap.get(id);
        if (stroke == null) {
            log.warning("attempted to extend an unknown stroke [" + id + "]");
            return;
        }

        stroke.extend(to);
        _canvases.tempStroke(id, stroke, stroke.getSize() - 2);

        if (end) {
            endStroke(id);
        }
    }

    public function endStroke (id :String) :void
    {
        // ignored here - used by subclasses
    }

    public function clearCanvas () :void
    {
        _tempStrokes = [];
        _canvasStrokes = [];
        _tempStrokesMap.clear();
        _backgroundColor = 0xFFFFFF;
        _canvases.clear();
    }

    public function getCanvasStrokes () :Array
    {
        return _canvasStrokes;
    }

    public function getTempStrokeIds () :Array
    {
        return _tempStrokes;
    }

    public function getTempStroke (id :String) :Stroke
    {
        return _tempStrokesMap.get(id) as Stroke;
    }

    public function getKey () :String
    {
        var key :String;
        do {
            key = KEY_BITS[_rnd.nextInt(KEY_BITS.length)] +
                KEY_BITS[_rnd.nextInt(KEY_BITS.length)] +
                KEY_BITS[_rnd.nextInt(KEY_BITS.length)];
        } while (_tempStrokesMap.get(key) != null);

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

    public function setBackgroundTransparent (transparent :Boolean) :void
    {
        _canvases.setBackgroundTransparent(_backgroundTransparent = transparent);
    }

    public function getBackgroundTransparent () :Boolean
    {
        return _backgroundTransparent;
    }

    public function serialize (includeTempStrokes :Boolean = false) :ByteArray 
    {
        var canvasBytes :ByteArray = new ByteArray();

        // write model version number.
        canvasBytes.writeInt(MODEL_VERSION_NUMBER);

        // write the background color and transparency
        canvasBytes.writeUnsignedInt(_backgroundColor);
        canvasBytes.writeBoolean(_backgroundTransparent);

        // write the strokes
        var strokesBytes :ByteArray = new ByteArray();
        if (includeTempStrokes) {
            strokesBytes.writeInt(_canvasStrokes.length + _tempStrokes.length);
        } else {
            strokesBytes.writeInt(_canvasStrokes.length);
        }
        var colorLUT :HashMap = new HashMap();
        for each (var stroke :Stroke in _canvasStrokes) {
            stroke.serialize(strokesBytes, colorLUT);
        }

        // temp strokes
        if (includeTempStrokes) {
            for each (var strokeId :String in _tempStrokes) {
                (_tempStrokesMap.get(strokeId) as Stroke).serialize(strokesBytes, colorLUT);
            }
        }

        // write the LUT
        canvasBytes.writeInt(colorLUT.size());
        var colors :Array = new Array(colorLUT.size());
        for each (var color :uint in colorLUT.keys()) {
            colors[colorLUT.get(color)] = color;
        }
        // now that we have the colors in key order, dump the array
        for each (color in colors) {
            canvasBytes.writeUnsignedInt(color);
        }

        // append the stroke data
        canvasBytes.writeBytes(strokesBytes);

        canvasBytes.compress();
        _canvases.reportFillPercent(canvasBytes.length / MAX_STORAGE_SIZE);
        return canvasBytes;
    }

    public function deserialize (bytes :ByteArray) :void
    {
        if (bytes == null) {
            return;
        }
        bytes.uncompress();

        var version :int = bytes.readInt();
        _backgroundColor = bytes.readUnsignedInt();
        _backgroundTransparent = bytes.readBoolean();
        
        var colorLUTSize :int = bytes.readInt(); 
        var colors :Array = new Array(colorLUTSize);
        for (var ii :int = 0; ii < colorLUTSize; ii++) {
            colors[ii] = bytes.readUnsignedInt();
        }

        _canvasStrokes = [];
        var numStrokes :int = bytes.readInt();
        for (ii = 0; ii < numStrokes; ii++) {
            _canvasStrokes.push(Stroke.createStrokeFromBytes(bytes, colors));
        }
    }

    protected function strokeBegun (id :String, stroke :Stroke) :void
    {
        _tempStrokesMap.put(id, stroke);
        _tempStrokes.push(id);
        _canvases.tempStroke(id, stroke);
    }

    protected function removeFromTempStrokes (id :String) :void
    {
        _tempStrokesMap.remove(id);
        var ii :int = _tempStrokes.indexOf(id);
        if (ii != -1) {
            _tempStrokes.splice(ii, 1);
        }
    }

    protected function pushToCanvas (stroke :Stroke) :void
    {
        _canvasStrokes.push(stroke);
        _canvases.canvasStroke(stroke);
    }

    private static const log :Log = Log.getLog(Model);

    protected static const MODEL_VERSION_NUMBER :int = 1;

    protected static const MAX_STORAGE_SIZE :int = 4080; // in bytes

    protected var _canvases :CanvasList = new CanvasList();
    protected var _tempStrokesMap :HashMap = new HashMap;
    protected var _tempStrokes :Array = [];
    protected var _canvasStrokes :Array = [];
    protected var _backgroundColor :uint = 0xFFFFFF;
    protected var _backgroundTransparent :Boolean = false;

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

import flash.geom.Point;

import com.threerings.graffiti.Canvas;

import com.threerings.graffiti.model.Stroke;

class CanvasList 
{
    public function setBackgroundTransparent (transparent :Boolean) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.setBackgroundTransparent(transparent);
        }
    }

    public function paintBackground (color :uint) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.paintBackground(color);
        }
    }

    public function tempStroke (id :String, stroke :Stroke, startPoint :int = -1) :void
    {
        for each (var canvas :Canvas in _canvases) {
            if (startPoint == -1) {
                // respect canvas' default
                canvas.tempStroke(id, stroke);
            } else {
                canvas.tempStroke(id, stroke, startPoint);
            }
        }
    }

    public function canvasStroke (stroke :Stroke) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.canvasStroke(stroke);
        }
    }

    public function reportFillPercent (percent :Number) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.reportFillPercent(percent);
        }
    }

    public function clear () :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.clear();
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
