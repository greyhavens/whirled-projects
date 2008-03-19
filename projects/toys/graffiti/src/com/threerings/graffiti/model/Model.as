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

    public function unregisterCanvas (canvas :Canvas, editingCanvas :Boolean) :void
    {
        _canvases.removeCanvas(canvas);
    }

    public function beginStroke (id :String, from :Point, to :Point, tool :Tool) :void
    {
        if (id == null || _strokesMap.containsKey(id)) {
            log.warning("Attempting to add a new stroke with null or existing id! [" + id + "]");
            return;
        }

        strokeBegun(new Stroke(from, to, tool, id));
    }

    public function extendStroke (id :String, to :Point, end :Boolean = false) :void
    {
        var stroke :Stroke = _strokesMap.get(id);
        if (stroke == null) {
            log.warning("attempted to extend an unknown stroke [" + id + "]");
            return;
        }

        stroke.extend(to);
        _canvases.drawStroke(stroke, stroke.getSize() - 2);

        if (end) {
            endStroke(id);
        }
    }

    public function endStroke (id :String) :void
    {
        var stroke :Stroke = _strokesMap.get(id);
        if (stroke == null) {
            log.warning("strokes map missing newly ended stroke [" + id + "]");
            return;
        }

        _undoStack.push(stroke);
        if (_undoStack.length > UNDO_STACK_SIZE) {
            forgetUndoStroke(_undoStack.shift());
        }

        _canvases.reportUndoStackSize(_undoStack.length);
    }

    public function getKey () :String
    {
        // this assumes we'll never give out more keys than KEY_BITS.length ^ 2, which is
        // 3844.  Since our current space is limited to 4k, this is a safe assumption.  If in the
        // future we're given more space, then we won't have to be so anal about key encoding
        // length and we can extend the length of the key to deal with more stroke storage space.
        return getKeyString(_localKeys++);
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

    public function serialize () :ByteArray
    {
        var bytes :ByteArray = new ByteArray();

        // write model version number.
        bytes.writeInt(MODEL_VERSION_NUMBER);

        // write the background color and transparency
        bytes.writeUnsignedInt(_backgroundColor);
        bytes.writeBoolean(_backgroundTransparent);

        // write the strokes
        var strokesBytes :ByteArray = new ByteArray();
        strokesBytes.writeInt(_strokesList.length);
        var colorLUT :HashMap = new HashMap();
        for each (var stroke :Stroke in _strokesList) {
            stroke.serialize(strokesBytes, colorLUT);
        }

        // write the LUT
        bytes.writeInt(colorLUT.size());
        var colors :Array = new Array(colorLUT.size());
        for each (var color :uint in colorLUT.keys()) {
            colors[colorLUT.get(color)] = color;
        }
        // now that we have the colors in key order, dump the array
        for each (color in colors) {
            bytes.writeUnsignedInt(color);
        }

        // append the stroke data
        bytes.writeBytes(strokesBytes);

        bytes.compress();
        return bytes;
    }

    public function deserialize (bytes :ByteArray) :void
    {
        if (bytes == null) {
            return;
        }
        bytes.uncompress();

        try {
            var version :int = bytes.readInt();
            _backgroundColor = bytes.readUnsignedInt();
            _backgroundTransparent = bytes.readBoolean();
            
            var colorLUTSize :int = bytes.readInt(); 
            var colors :Array = new Array(colorLUTSize);
            for (var ii :int = 0; ii < colorLUTSize; ii++) {
                colors[ii] = bytes.readUnsignedInt();
            }

            _strokesList = [];
            _strokesMap.clear();
            var numStrokes :int = bytes.readInt();
            for (ii = 0; ii < numStrokes; ii++) {
                var stroke :Stroke = Stroke.createStrokeFromBytes(bytes, colors);
                _strokesList.push(stroke);
                if (stroke.id != null) {
                    _strokesMap.put(stroke.id, stroke);
                }
            }
        } catch (err :Error) {
            log.warning("Unrecoverable error in deserialization!  This Model is not valid! [" +
                err + "]");
        }
    }

    public function calculateFullPercent () :Number
    {
        return serialize().length / MAX_STORAGE_SIZE;
    }

    public function undo () :void
    {
        if (_undoStack.length == 0) {
            log.warning("attempting to undo from an empty undo stack");
            return;
        }

        var stroke :Stroke = _undoStack.pop();
        if (stroke.id == null) {
            log.warning("attempting to remove stroke with null id! [" + stroke + "]");
            return;
        }

        removeStroke(stroke.id);
        _canvases.reportUndoStackSize(_undoStack.length);
    }

    public function removeStroke (id :String) :void
    {
        var stroke :Stroke = _strokesMap.remove(id) as Stroke;
        _canvases.removeStroke(id);

        if (stroke == null) {
            log.warning("removed null stroke! [" + id + "]");
            return;
        }

        var index :int = _strokesList.indexOf(stroke);
        if (index < 0) {
            log.warning("undone stroke not found! [" + stroke + "]");
            return;
        }
        _strokesList.splice(index, 1);

        strokeRemoved(stroke);
    }

    public function getStroke (id :String) :Stroke
    {
        return _strokesMap.get(id);
    }

    public function stripAllIds (prefix :String) :void
    {
        var keys :Array = _strokesMap.keys();
        for each (var key :String in keys) {
            if (key.indexOf(prefix) == 0) {
                stripId(key);
            }
        }
    }

    public function stripId (id :String) :void
    {
        var stroke :Stroke = _strokesMap.remove(id);
        if (stroke != null) {
            _canvases.idStripped(stroke.id);
            stroke.id = null;
        }
    }

    protected function strokeBegun (stroke :Stroke) :void
    {
        _strokesList.push(stroke);
        if (stroke.id != null) {
            _strokesMap.put(stroke.id, stroke);
        }
        _canvases.drawStroke(stroke);
    }

    protected function forgetUndoStroke (stroke :Stroke) :void
    {
        _strokesMap.remove(stroke.id);
    }

    protected function strokeRemoved (stroke :Stroke) :void
    {
        // NOOP
    }

    protected function getKeyString (keyValue :int) :String
    {
        var keyBit0 :int = keyValue % KEY_BITS.length;
        var keyBit1 :int = Math.floor(keyValue / KEY_BITS.length);
        var key :String = KEY_BITS[keyBit1] + KEY_BITS[keyBit0];
        return key;
    }

    private static const log :Log = Log.getLog(Model);

    protected static const MODEL_VERSION_NUMBER :int = 1;
    protected static const MAX_STORAGE_SIZE :int = 4080; // in bytes
    protected static const UNDO_STACK_SIZE :int = 10;

    protected static const KEY_BITS :Array = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    ];

    protected var _canvases :CanvasList = new CanvasList();
    // contains all strokes, in the order in which they should be drawn
    protected var _strokesList :Array = [];
    // contains only the strokes that have a valid id - which are the strokes that may be extended
    // or undone
    protected var _strokesMap :HashMap = new HashMap();
    protected var _backgroundColor :uint = 0xFFFFFF;
    protected var _backgroundTransparent :Boolean = false;
    protected var _localKeys :int = 0;
    protected var _undoStack :Array = [];
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

    public function drawStroke (stroke :Stroke, startPoint :int = -1) :void
    {
        for each (var canvas :Canvas in _canvases) {
            if (startPoint == -1) {
                // respect the canvas' default
                canvas.drawStroke(stroke);
            } else {
                canvas.drawStroke(stroke, startPoint);
            }
        }
    }

    public function removeStroke (id :String) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.removeStroke(id);
        }
    }

    public function replaceStroke (stroke :Stroke, layer :int, oldId :String) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.replaceStroke(stroke, layer, oldId);
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

    public function reportUndoStackSize (size :int) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.reportUndoStackSize(size);
        }
    }

    public function idStripped (id :String) :void
    {
        for each (var canvas :Canvas in _canvases) {
            canvas.idStripped(id);
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
