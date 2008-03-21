// $Id$

package com.threerings.graffiti.tools {

import flash.display.Graphics;

import flash.geom.Point;

import flash.utils.ByteArray;

import com.threerings.util.Equalable;
import com.threerings.util.HashMap;
import com.threerings.util.Log;

public class Tool implements Equalable
{
    public static const BRUSH :int = 1;
    public static const LINE :int = 2;
    public static const ELLIPSE :int = 3;
    public static const RECTANGLE :int = 4;

    public static function createToolFromBytes (bytes :ByteArray, colorLUT :Array = null) :Tool
    {
        var type :int = bytes.readInt();
        var tool :Tool;
        switch (type) {
        case BRUSH: tool = new BrushTool(); break;
        case LINE: tool = new LineTool(); break;
        case ELLIPSE: tool = new EllipseTool(); break;
        case RECTANGLE: tool = new RectangleTool(); break;
        default:
            log.warning("Unknown tool [" + type + "]");
            return null;
        }
    
        tool.deserialize(bytes, colorLUT);
        return tool;
    }

    public function Tool (thickness :int, alpha :Number, color :uint)
    {
        _thickness = thickness;
        _alpha = alpha;
        _color = color;
    }

    // from Equalable
    public function equals (other :Object) :Boolean
    {
        if (!(other is Tool)) {
            return false;
        }

        var otherTool :Tool = other as Tool;
        return otherTool._thickness == _thickness && otherTool._alpha == _alpha &&
            otherTool._color == _color;
    }

    public function mouseDown (graphics :Graphics, point :Point) :void
    {
        // handled by subclasses
    }

    public function dragTo (graphics :Graphics, point :Point, smoothing :Boolean = true) :void
    {
        // handled by subclasses
    }

    public function storeAllPoints () :Boolean
    {
        return true;
    }

    public function serialize (bytes :ByteArray, colorLUT :HashMap) :void
    {
        bytes.writeInt(typeForTool(this));

        bytes.writeInt(_thickness);
        bytes.writeInt(Math.round(_alpha * 100));
        writeColor(_color, bytes, colorLUT);
    }

    protected function deserialize (bytes :ByteArray, colorLUT :Array) :void
    {
        _thickness = bytes.readInt();
        _alpha = bytes.readInt() / 100;
        _color = readColor(bytes, colorLUT);
    }

    protected function typeForTool (tool :Tool) :int
    {
        if (tool is BrushTool) {
            return BRUSH;
        } else if (tool is LineTool) {
            return LINE;
        } else if (tool is EllipseTool) {
            return ELLIPSE;
        } else if (tool is RectangleTool) {
            return RECTANGLE;
        }

        log.warning("unknown tool [" + tool + "]");
        return 0;
    }

    protected function readColor (bytes :ByteArray, colorLUT :Array) :uint
    {
        if (colorLUT != null) {
            return colorLUT[bytes.readInt()];
        } else {
            return bytes.readUnsignedInt();
        }
    }

    protected function writeColor (color :uint, bytes :ByteArray, colorLUT :HashMap) :void
    {
        if (colorLUT != null) {
            if (colorLUT.containsKey(color)) {
                bytes.writeInt(colorLUT.get(color));
            } else {
                var colorKey :int = colorLUT.size();
                colorLUT.put(color, colorKey);
                bytes.writeInt(colorKey);
            }
        } else {
            bytes.writeUnsignedInt(color);
        }
    }

    private static const log :Log = Log.getLog(Tool);

    // properties common to all tools
    protected var _thickness :int;
    protected var _alpha :Number;
    protected var _color :uint;
}
}
