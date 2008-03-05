// $Id$

package com.threerings.graffiti.model {

import flash.geom.Point;

import flash.utils.ByteArray;

import com.threerings.util.HashMap;

import com.threerings.graffiti.tools.Brush;

public class Stroke
{
    public function Stroke (from :Point, to :Point, color :uint, brush :Brush)
    {
        _start = from;
        _color = color;
        _brush = brush;
        _points.push(to);
    }

    public function Stroke (bytes :ByteArray, colorLUT :Array) 
    {
        deserialize(bytes, colorLUT);
    }

    public function get start () :Point
    {
        return _start;
    }

    public function get brush () :Brush
    {
        return _brush;
    }

    public function get color () :uint
    {
        return _color;
    }

    public function getPoint (offset :int) :Point
    {
        if (offset >= _points.length) {
            return null;
        }

        return _points[offset];
    }

    /**
     * Get the number of points after the start point.
     */
    public function getSize () :int
    {
        return _points.length;
    }

    public function extend (to :Point) :void
    {
        _points.push(to);
    }

    public function serialize (bytes :ByteArray, colorLUT :HashMap) :void
    {
        var colorKey :int;
        if (colorLUT.containsKey(_color)) {
            colorKey = colorLUT.get(_color);
        } else {
            colorLUT.put(_color, colorKey = colorLUT.size());
        }

        // serialize format:
        //  - length (number of points after start)
        //  - color key into LUT
        //  - brush
        //  - starting point
        //  - continuation points in offset x and y values
        bytes.writeInt(_points.length);
        bytes.writeInt(colorKey);
        _brush.serialize(bytes);
        bytes.writeInt(Math.round(_start.x));
        bytes.writeInt(Math.round(_start.y));

        var curX :int = Math.round(_start.x);
        var curY :int = Math.round(_start.y);
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
        var length :int = bytes.readInt();
        _color = colurLUT[bytes.readInt()];
        _brush = new Brush(bytes);
        _start = new Point();
        _start.x = bytes.readInt();
        _start.y = bytes.readInt();

        var curX :int = _start.x;
        var curY :int = _start.y;
        for (var ii :int = 0; ii < length; ii++) {
            var point :Point = new Point();
            point.x = _start.x + bytes.readInt();
            point.y = _start.y + bytes.readInt();
            _points.push(point);
            curX = point.x;
            curY = point.y;
        }
    }

    protected var _start :Point;
    protected var _points :Array = [];
    protected var _color :uint;
    protected var _brush :Brush = new Brush();
}
}
