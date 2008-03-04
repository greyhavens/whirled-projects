// $Id$

package com.threerings.graffiti.tools {

import flash.events.Event;

import flash.display.Graphics;
import flash.display.Sprite;

import flash.text.TextFieldAutoSize;

import fl.controls.Label;
import fl.controls.Slider;

import fl.events.SliderEvent;

import com.threerings.util.Log;

public class BrushTool extends Tool
{
    public function BrushTool (toolBox :ToolBox) 
    {
        _toolBox = toolBox;
        _toolBox.addEventListener(ToolEvent.COLOR_PICKED, colorPicked);

        _brush = new Brush();

        buildBrushDisplay();
        buildSliders();

        addEventListener(Event.ADDED_TO_STAGE, function (event :Event) :void {
            _toolBox.brushPicked(_brush);
        });
    }

    // from Tool
    public override function get requestedWidth () :Number
    {
        return BRUSH_TOOL_WIDTH;
    }

    // from Tool
    public override function get requestedHeight () :Number
    {
        return _alphaSlider.y + SLIDER_HEIGHT + PADDING;
    }

    protected function colorPicked (event :ToolEvent) :void
    {
        _color = event.value as uint;
        updateBrushDisplay();
    }

    protected function updateBrushDisplay () :void
    {
        if (_brushDisplay == null || isNaN(_color)) {
            return;
        }

        var g :Graphics = _brushDisplay.graphics;
        g.clear();
        g.lineStyle(_brush.thickness, _color);
        g.moveTo(-10, 0);
        g.lineTo(10, 0);
    }

    protected function buildBrushDisplay () :void
    {
        addChild(_brushDisplay = new Sprite());
        _brushDisplay.alpha = _brush.alpha;
        _brushDisplay.x = BRUSH_TOOL_WIDTH / 2;
        _brushDisplay.y = PADDING + MAX_BRUSH_SIZE / 2;
        updateBrushDisplay();
    }

    protected function buildSliders () :void
    {
        var thicknessLabel :Label = new Label();
        thicknessLabel.autoSize = TextFieldAutoSize.LEFT;
        thicknessLabel.text = "Thickness";
        thicknessLabel.x = (BRUSH_TOOL_WIDTH - SLIDER_WIDTH) / 2;
        thicknessLabel.y = PADDING * 2 + MAX_BRUSH_SIZE;
        addChild(thicknessLabel);

        addChild(_thicknessSlider = new Slider());
        _thicknessSlider.width = SLIDER_WIDTH;
        _thicknessSlider.x = (BRUSH_TOOL_WIDTH - SLIDER_WIDTH) / 2;
        _thicknessSlider.y = thicknessLabel.y + LABEL_HEIGHT + 2;
        _thicknessSlider.liveDragging = true;
        _thicknessSlider.minimum = MIN_BRUSH_SIZE;
        _thicknessSlider.maximum = MAX_BRUSH_SIZE;
        _thicknessSlider.value = _brush.thickness;
        _thicknessSlider.snapInterval = 1;
        _thicknessSlider.addEventListener(SliderEvent.CHANGE, function (event :SliderEvent) :void {
            _brush.thickness = _thicknessSlider.value;
            updateBrushDisplay();
            _toolBox.brushPicked(_brush);
        });

        var alphaLabel :Label = new Label();
        alphaLabel.autoSize = TextFieldAutoSize.LEFT;
        alphaLabel.text = "Alpha";
        alphaLabel.x = (BRUSH_TOOL_WIDTH - SLIDER_WIDTH) / 2;
        alphaLabel.y = _thicknessSlider.y + SLIDER_HEIGHT + PADDING;
        addChild(alphaLabel);

        addChild(_alphaSlider = new Slider());
        _alphaSlider.width = SLIDER_WIDTH;
        _alphaSlider.x = (BRUSH_TOOL_WIDTH - SLIDER_WIDTH) / 2;
        _alphaSlider.y = alphaLabel.y + LABEL_HEIGHT + 2;
        _alphaSlider.liveDragging = true;
        _alphaSlider.maximum = 1;
        _alphaSlider.minimum = 0;
        _alphaSlider.value = _brush.alpha;
        _alphaSlider.snapInterval = 0.05;
        _alphaSlider.addEventListener(SliderEvent.CHANGE, function (event :SliderEvent) :void {
            _brush.alpha = _alphaSlider.value;
            _brushDisplay.alpha = _alphaSlider.value;
            _toolBox.brushPicked(_brush);
        });
    }

    private static const log :Log = Log.getLog(BrushTool);

    protected var MIN_BRUSH_SIZE :int = 2;
    protected var MAX_BRUSH_SIZE :int = 60;
    protected var BRUSH_TOOL_WIDTH :int = 100;
    protected var SLIDER_WIDTH :int = 75;

    // values that more or less match up with the defaults that they get drawn at
    protected var SLIDER_HEIGHT :int = 15;
    protected var LABEL_HEIGHT :int = 15;

    protected var _toolBox :ToolBox;
    protected var _brush :Brush;
    protected var _brushDisplay :Sprite;
    protected var _color :uint = 0xFFFFFF;
    protected var _thicknessSlider :Slider;
    protected var _alphaSlider :Slider;
}
}
