// $Id$

package com.threerings.graffiti.tools {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.geom.Matrix;
import flash.geom.Point;

import com.threerings.util.Log;

public class Palette extends Sprite
{
    public function Palette (toolbox :ToolBox, initialColor :uint)
    {
        _toolbox = toolbox;

        buildWheel();
        buildGradientBox();
        buildBorder();
        displayManipulator(_selectedBaseColor = initialColor);

        addEventListener(Event.ADDED_TO_STAGE, function (event :Event) :void {
            pickCurrentColor();
        });
    }

    protected function pickCurrentColor () :void
    {
        _toolbox.pickColor(_selectedColor = getManipulatorColor(_manipulatorPoint));
    }

    protected function updateHoverColor () :void
    {
        _toolbox.hoverColor(_hoverColor = getManipulatorColor(_hoverPoint));
    }

    protected function buildWheel () :void
    {
        var wheelGraphics :Shape = new Shape();
        var g :Graphics = wheelGraphics.graphics;
        for (var ii :Number = 0; ii < 360; ii += 0.5) {
            g.lineStyle(1, colorForAngle(ii));
            g.moveTo(0, 0);
            var end :Point = Point.polar(WHEEL_RADIUS, ii * Math.PI / 180);
            g.lineTo(-end.x, end.y);
        }
        var bitmapData :BitmapData = new BitmapData(WHEEL_RADIUS * 2, WHEEL_RADIUS * 2, true, 0);
        var m :Matrix = new Matrix();
        m.translate(WHEEL_RADIUS, WHEEL_RADIUS);
        bitmapData.draw(wheelGraphics, m);
        var bitmap :Bitmap = new Bitmap(bitmapData, "auto", true);
        bitmap.x = bitmap.y = -WHEEL_RADIUS;
        addChild(_wheel = new Sprite());
        _wheel.addChild(bitmap);

        var masker :Sprite = new Sprite();
        g = masker.graphics;
        var corner :Point = Point.polar(WHEEL_RADIUS, -Math.PI / 4);
        g.beginFill(0);
        g.drawRect(-corner.x, -corner.y, corner.x * 2, corner.y * 2);
        g.endFill();
        _wheel.addChild(masker);
        _wheel.mask = masker;

        _wheel.addEventListener(MouseEvent.MOUSE_OUT, function (event :MouseEvent) :void {
            displayManipulator(_selectedBaseColor);
            updateHoverColor();
        });
        _wheel.addEventListener(MouseEvent.MOUSE_MOVE, function (event :MouseEvent) :void {
            var p :Point = _wheel.globalToLocal(new Point(event.stageX, event.stageY));
            var angle :int = Math.round(Math.atan2(p.y, -p.x) * 180 / Math.PI);
            displayManipulator(colorForAngle(angle));
            updateHoverColor();
        });
        _wheel.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            var p :Point = _wheel.globalToLocal(new Point(event.stageX, event.stageY));
            var angle :int = Math.round(Math.atan2(p.y, -p.x) * 180 / Math.PI);
            displayManipulator(_selectedBaseColor = colorForAngle(angle));
            pickCurrentColor();
        });
    }

    protected function colorForAngle (angle :Number) :int
    {
        var color :int = 0;
        var shifts :Array = [0, -120, -240];
        for (var ii :int = 0; ii < 3; ii++) {
            color = color << 8;
            var adjustedAngle :Number = ((angle + shifts[ii] + 360) % 360) - 180;
            if (adjustedAngle > -60 && adjustedAngle < 60) {
                // 120 degrees surrounding the base area for this color, paint the full color value
                color += 0xFF;
            } else if (adjustedAngle > -120 && adjustedAngle < 120) {
                // for the area -60 - -120 and 60 - 120 degrees away from the base area, gradually
                // reduce the value for this color 
                var percent :Number = 1 - (Math.abs(adjustedAngle) - 60) / 60;
                color += percent * 0xFF;
            }
        }
        return color;
    }

    protected function buildGradientBox () :void
    {
        var gradientGraphics :Shape = new Shape();
        var g :Graphics = gradientGraphics.graphics;
        g.lineStyle(1);
        var m :Matrix = new Matrix();
        m.createGradientBox(1, MANIPULATOR_SIZE, Math.PI / 2);
        for (var ii :int = 0; ii < MANIPULATOR_SIZE; ii++) {
            var percent :Number = 
                1 - Math.max(Math.min((ii - 5) / (MANIPULATOR_SIZE * 0.75), 1), 0);
            g.lineGradientStyle(
                GradientType.LINEAR, 
                [0xFFFFFF, 0xFFFFFF, 0x888888, 0x888888, 0, 0], 
                [1, 1, percent, percent, 1, 1], 
                [0, 25, 100, 155, 230, 255], m); 
            g.moveTo(ii, 0);
            g.lineTo(ii, MANIPULATOR_SIZE);
        }
        var bitmapData :BitmapData = new BitmapData(MANIPULATOR_SIZE, MANIPULATOR_SIZE, true, 0);
        bitmapData.draw(gradientGraphics);
        _gradientBox = new Bitmap(bitmapData, "auto", true);

        addChild(_manipulator = new Sprite());
        _manipulator.x = _manipulator.y = -MANIPULATOR_SIZE / 2;
        _manipulator.addChild(_gradientBox);

        _manipulator.addEventListener(MouseEvent.MOUSE_OUT, function (event :MouseEvent) :void {
            _hoverPoint = _manipulatorPoint;
            updateHoverColor();
        });
        _manipulator.addEventListener(MouseEvent.MOUSE_MOVE, function (event :MouseEvent) :void {
            _hoverPoint = _manipulator.globalToLocal(new Point(event.stageX, event.stageY));
            updateHoverColor(); 
        });
        _manipulator.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _manipulatorPoint = _manipulator.globalToLocal(new Point(event.stageX, event.stageY));
            pickCurrentColor();
        });

        _hoverPoint = _manipulatorPoint = new Point(MANIPULATOR_SIZE - 1, MANIPULATOR_SIZE / 2);
    }

    protected function buildBorder () :void
    {
        var wheelBorder :Sprite = new Sprite();
        wheelBorder.x = wheelBorder.y = -WHEEL_BORDER_SIZE / 2;
        addChild(wheelBorder);
        var g :Graphics = wheelBorder.graphics;
        g.lineStyle(2, COMPONENT_BORDER_COLOR);
        g.drawRect(0, 0, WHEEL_BORDER_SIZE, WHEEL_BORDER_SIZE);
        var manipCorner :Number = (WHEEL_BORDER_SIZE - MANIPULATOR_SIZE) / 2;
        g.drawRect(manipCorner, manipCorner, MANIPULATOR_SIZE, MANIPULATOR_SIZE);
    }

    protected function displayManipulator (color :uint) :void
    {
        var g :Graphics = _manipulator.graphics;
        g.clear();

        g.beginFill(color);
        g.drawRect(0, 0, MANIPULATOR_SIZE, MANIPULATOR_SIZE);
        g.endFill();
    }

    protected function getManipulatorColor (location :Point) :uint
    {
        var m :Matrix = new Matrix();
        m.translate(-location.x, -location.y);
        var data :BitmapData = new BitmapData(1, 1);
        data.draw(_manipulator, m);
        return data.getPixel(0, 0);
    }

    private static const log :Log = Log.getLog(Palette);

    protected static const WHEEL_RADIUS :int = 40;
    protected static const COMPONENT_BORDER_COLOR :int = 0xBBBBBB;
    protected static const MANIPULATOR_SIZE :int = WHEEL_RADIUS * 4 / 5;
    protected static const WHEEL_BORDER_SIZE :int = 
        Math.round(Point.polar(WHEEL_RADIUS, -Math.PI / 4).x * 2);

    protected var _toolbox :ToolBox;
    protected var _wheel :Sprite;
    protected var _gradientBox :Bitmap;
    protected var _manipulator :Sprite;
    protected var _hoverPoint :Point;
    protected var _manipulatorPoint :Point;
    protected var _selectedColor :int;
    protected var _hoverColor :int;
    protected var _selectedBaseColor :int;
}
}
