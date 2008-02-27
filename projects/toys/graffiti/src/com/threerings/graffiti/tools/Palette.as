// $Id$

package com.threerings.graffiti.tools {

import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.geom.Matrix;
import flash.geom.Point;

import com.threerings.util.Log;

public class Palette extends Tool
{
    public function Palette (toolbox :ToolBox, initialColor :uint)
    {
        _toolbox = toolbox;

        buildIndicator(initialColor);
        buildWheel();
        buildGradientBox();
        displayManipulator(_selectedBaseColor = initialColor);
    }

    // from Tool
    public override function get requestedWidth () :Number
    {
        return PALETTE_WIDTH;
    }

    // from Tool
    public override function get requestedHeight () :Number
    {
        return PALETTE_HEIGHT;
    }

    protected function buildIndicator (initialColor :int) :void
    {
        _selectedColor = _hoverColor = initialColor;
        addChild(_indicator = new Sprite());
        _indicator.x = (PALETTE_WIDTH - INDICATOR_WIDTH) / 2;
        _indicator.y = PADDING;
        updateIndicator();
    }

    protected function pickCurrentColor () :void
    {
        _selectedColor = getManipulatorColor(_manipulatorPoint);
        _toolbox.pickColor(_selectedColor);
        updateIndicator();
    }

    protected function updateHoverColor () :void
    {
        _hoverColor = getManipulatorColor(_hoverPoint);
        updateIndicator();
    }

    protected function updateIndicator () :void
    {
        var g :Graphics = _indicator.graphics;
        g.clear();

        g.lineStyle(0, _hoverColor);
        g.beginFill(_hoverColor);
        g.drawRect(1, 1, INDICATOR_WIDTH / 2, INDICATOR_HEIGHT - 1);
        g.endFill();

        g.lineStyle(0, _selectedColor);
        g.beginFill(_selectedColor);
        g.drawRect(INDICATOR_WIDTH / 2, 1, INDICATOR_WIDTH / 2 - 2, INDICATOR_HEIGHT - 1);
        g.endFill();

        g.lineStyle(3, COMPONENT_BORDER_COLOR);
        g.drawRoundRect(0, 0, INDICATOR_WIDTH, INDICATOR_HEIGHT, 2, 2);
    }

    protected function buildWheel () :void
    {
        addChild(_wheel = new Sprite());
        _wheel.x = WHEEL_RADIUS + (PALETTE_WIDTH - WHEEL_RADIUS * 2) / 2;
        _wheel.y = WHEEL_RADIUS + PADDING * 2 + INDICATOR_HEIGHT;
        var g :Graphics = _wheel.graphics;

        // start by drawing a color wheel...
        for (var ii :int = 0; ii < 360; ii++) {
            g.lineStyle(1, colorForAngle(ii));
            g.moveTo(0, 0);
            var end :Point = Point.polar(WHEEL_RADIUS, ii * Math.PI / 180);
            g.lineTo(-end.x, end.y);
        }

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

    protected function colorForAngle (angle :int) :int
    {
        var color :int = 0;
        var shifts :Array = [0, -120, -240];
        for (var ii :int = 0; ii < 3; ii++) {
            color = color << 8;
            var adjustedAngle :int = ((angle + shifts[ii] + 360) % 360) - 180;
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
        _gradientBox = new Sprite();
        var g :Graphics = _gradientBox.graphics;

        g.lineStyle(1);
        var m :Matrix = new Matrix();
        m.createGradientBox(1, MANIPULATOR_HEIGHT, Math.PI / 2);
        for (var ii :int = 0; ii < MANIPULATOR_WIDTH; ii++) {
            var percent :Number = 
                1 - Math.max(Math.min((ii - 5) / (MANIPULATOR_WIDTH * 0.75), 1), 0);
            g.lineGradientStyle(
                GradientType.LINEAR, [0xFFFFFF, 0x888888, 0x888888, 0], [1, percent, percent, 1], 
                [0, 100, 155, 255], m); 
            g.moveTo(ii, 0);
            g.lineTo(ii, MANIPULATOR_HEIGHT);
        }

        addChild(_manipulator = new Sprite());
        _manipulator.x = (PALETTE_WIDTH - MANIPULATOR_WIDTH) / 2;
        _manipulator.y = PADDING * 3 + INDICATOR_HEIGHT + WHEEL_RADIUS * 2;
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

        _hoverPoint = _manipulatorPoint = new Point(MANIPULATOR_WIDTH - 1, MANIPULATOR_HEIGHT / 2);
    }

    protected function displayManipulator (color :uint) :void
    {
        var g :Graphics = _manipulator.graphics;
        g.clear();

        g.beginFill(color);
        g.drawRect(0, 0, MANIPULATOR_WIDTH, MANIPULATOR_HEIGHT);
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
    protected static const INDICATOR_HEIGHT :int = 30;
    protected static const INDICATOR_WIDTH :int = 60;
    protected static const COMPONENT_BORDER_COLOR :int = 0;
    protected static const MANIPULATOR_WIDTH :int = 50;
    protected static const MANIPULATOR_HEIGHT :int = 50;
    protected static const PADDING :int = 5;
    protected static const PALETTE_WIDTH :int = 100;
    protected static const PALETTE_HEIGHT :int = 
            PADDING * 4 + INDICATOR_HEIGHT + WHEEL_RADIUS * 2 + MANIPULATOR_HEIGHT;


    protected var _toolbox :ToolBox;
    protected var _indicator :Sprite;
    protected var _wheel :Sprite;
    protected var _gradientBox :Sprite;
    protected var _manipulator :Sprite;
    protected var _hoverPoint :Point;
    protected var _manipulatorPoint :Point;
    protected var _selectedColor :int;
    protected var _hoverColor :int;
    protected var _selectedBaseColor :int;
}
}
