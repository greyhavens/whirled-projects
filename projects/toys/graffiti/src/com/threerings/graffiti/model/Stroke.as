// $Id$

package com.threerings.graffiti.model {

import flash.geom.Point;

import flash.utils.ByteArray;

import com.threerings.util.HashMap;

import com.threerings.graffiti.tools.Brush;

public class Stroke
{
    public static function createStrokeFromBytes (bytes :ByteArray, colorLUT :Array = null) :Stroke
    {
        var stroke :Stroke = new Stroke(null, null, 0, null);
        stroke.deserialize(bytes, colorLUT);
        return stroke;
    }

    public function toString () :String
    {
        return "Stroke [" + _color + ", " + _points[0] + ", " + _points[_points.length - 1] + ", " +
            _points.length + "]"
    }

    public function Stroke (from :Point, to :Point, color :uint, brush :Brush)
    {
        _color = color;
        _brush = brush;
        _points.push(from);
        _points.push(to);
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
        //  - color key into LUT or colur uint if colorLUT is null
        //  - length (number of points including start)
        //  - brush
        //  - continuation points in offset x and y values

        if (colorLUT != null) {
            var colorKey :int;
            if (colorLUT.containsKey(_color)) {
                colorKey = colorLUT.get(_color);
                bytes.writeInt(colorKey);
            } else {
                colorLUT.put(_color, colorKey = colorLUT.size());
                bytes.writeInt(colorKey);
            }
        } else {
            bytes.writeUnsignedInt(_color);
        }

        bytes.writeInt(_points.length);
        _brush.serialize(bytes);

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
        if (colorLUT != null) {
            _color = colorLUT[bytes.readInt()];
        } else {
            _color = bytes.readUnsignedInt();
        }
        var length :int = bytes.readInt();
        _brush = Brush.createBrushFromBytes(bytes);

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
    protected var _color :uint;
    protected var _brush :Brush = new Brush();
}
}
