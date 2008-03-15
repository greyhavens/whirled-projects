// $Id$

package com.threerings.graffiti.model {

import flash.geom.Point;

import flash.utils.ByteArray;

import com.threerings.util.HashMap;

import com.threerings.graffiti.tools.BrushTool;
import com.threerings.graffiti.tools.Tool;

public class Stroke
{
    public static function createStrokeFromBytes (bytes :ByteArray, colorLUT :Array = null) :Stroke
    {
        var stroke :Stroke = new Stroke(null, null, null);
        stroke.deserialize(bytes, colorLUT);
        return stroke;
    }

    public function toString () :String
    {
        return "Stroke [" + _points[0] + ", " + _points[_points.length - 1] + ", " +
            _points.length + "]"
    }

    public function Stroke (from :Point, to :Point, tool :Tool)
    {
        _tool = tool;
        _points.push(from);
        _points.push(to);
    }

    public function get tool () :Tool
    {
        return _tool;
    }

    public function getPoint (offset :int) :Point
    {
        if (offset >= _points.length) {
            return null;
        }

        return _points[offset];
    }

    /**
     * Returns the number of points, including the start.
     */
    public function getSize () :int
    {
        return _points.length;
    }

    public function extend (to :Point) :void
    {
        _points.push(to);
    }

    public function serialize (bytes :ByteArray, colorLUT :HashMap = null) :void
    {
        // serialize format:
        //  - tool
        //  - length (number of points including start)
        //  - continuation points in offset x and y values

        _tool.serialize(bytes, colorLUT);

        bytes.writeInt(_points.length);
        var curX :int = 0;
        var curY :int = 0;
        for each (var point :Point in _points) {
            var thisX :int = Math.round(point.x);
            var thisY :int = Math.round(point.y);
            bytes.writeInt(thisX - curX);
            bytes.writeInt(thisY - curY);
            curX = thisX;
            curY = thisY;
        }
    }

    protected function deserialize (bytes :ByteArray, colorLUT :Array) :void
    {
        _tool = Tool.createToolFromBytes(bytes, colorLUT);

        var length :int = bytes.readInt();
        var curX :int = 0;
        var curY :int = 0;
        _points = [];
        for (var ii :int = 0; ii < length; ii++) {
            var point :Point = new Point();
            point.x = curX + bytes.readInt();
            point.y = curY + bytes.readInt();
            _points.push(point);
            curX = point.x;
            curY = point.y;
        }
    }

    protected var _points :Array = [];
    protected var _tool :Tool = new BrushTool();
}
}
