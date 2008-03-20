// $Id$

package com.threerings.graffiti.tools {

import fl.controls.CheckBox;
import fl.controls.Slider;

import fl.events.SliderEvent;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.geom.Point;
import flash.geom.Matrix;

import flash.system.ApplicationDomain;

import com.threerings.flash.DisplayUtil;

import com.threerings.util.Log;
import com.threerings.util.MultiLoader;

import com.threerings.graffiti.Canvas;

import com.threerings.graffiti.throttle.AlterBackgroundMessage;
import com.threerings.graffiti.throttle.ThrottleEvent;

[Event(name="colorPicking", type="ToolEvent")];
[Event(name="toolPicked", type="ToolEvent")];
[Event(name="backgroundColor", type="ToolEvent")];
[Event(name="backgroundTransparency", type="ToolEvent")];
[Event(name="hideFurni", type="ToolEvent")];
[Event(name="undoOnce", type="ToolEvent")];

public class ToolBox extends Sprite 
{
    public static const POPUP_WIDTH :int = Canvas.CANVAS_WIDTH + TOOLBAR_WIDTH;
    public static const POPUP_HEIGHT :int = 465;

    public function ToolBox (canvas :Canvas, backgroundColor :uint, backgroundTransparent :Boolean,
        fillPercent :Number) 
    {
        addChild(_canvas = canvas);
        _initialBackgroundColor = backgroundColor;
        _initialBackgroundTransparent = backgroundTransparent;
        _initialFillPercent = fillPercent;
        MultiLoader.getContents(TOOLBOX_UI, handleUILoaded, false, ApplicationDomain.currentDomain);
    }

    public function pickColor (color :uint, clear :Boolean = false) :void
    {
    }

    public function displayFillPercent (percent :Number) :void
    {
    }

    public function managerMessageReceived (event :ThrottleEvent) :void
    {
    }

    public function setUndoEnabled (enabled :Boolean) :void
    {
    }

    protected function toolSelected (event :RadioEvent) :void
    {
        var tool :int = event.value as int;
        if (tool != PICKER_TOOL) {
            setupUi(tool);
        }
    }

    protected function setupUi (tool :int) :void
    {
        _ui.gotoAndStop(tool);
        _sizeSlider.alpha = _alphaSlider.alpha = tool == CANVAS_TOOL ? 0 : 1;
    }

    protected function sizeSliderUpdate (event :SliderEvent) :void 
    {
    }

    protected function alphaSliderUpdate (event :SliderEvent) :void
    {
    }

    protected function handleUILoaded (ui :MovieClip) :void
    {
        _ui = ui;
        _ui.x = POPUP_WIDTH - FLA_WIDTH;
        addChild(_ui);

        // size slider
        _sizeSlider = _ui.size_slider;
        _sizeSlider.liveDragging = true;
        _sizeSlider.minimum = MIN_BRUSH_SIZE;
        _sizeSlider.maximum = MAX_BRUSH_SIZE;
        _sizeSlider.value = DEFAULT_BRUSH_SIZE;
        _sizeSlider.snapInterval = 1;
        _sizeSlider.addEventListener(SliderEvent.CHANGE, sizeSliderUpdate);

        // alpha slider
        _alphaSlider = _ui.alpha_slider;
        _alphaSlider.liveDragging = true;
        _alphaSlider.minimum = 0;
        _alphaSlider.maximum = 1;
        _alphaSlider.value = 1;
        _alphaSlider.snapInterval = 0.05;
        _alphaSlider.addEventListener(SliderEvent.CHANGE, alphaSliderUpdate);

        // tool buttons
        var toolSet :RadioButtonSet = new RadioButtonSet();
        toolSet.addEventListener(RadioEvent.BUTTON_SELECTED, toolSelected);
        var buttons :Array = [ _ui.brushtool, _ui.linetool, _ui.rectangletool, _ui.elipsetool, 
                               _ui.canvastool, _ui.pickertool ]
        var tools :Array = [ BRUSH_TOOL, LINE_TOOL, RECTANGLE_TOOL, ELIPSE_TOOL, CANVAS_TOOL,
                             PICKER_TOOL ];
        for (var ii :int = 0; ii < buttons.length; ii++) {
            toolSet.addButton(new ToggleButton(buttons[ii] as SimpleButton, tools[ii]), ii == 0);
        }

        _showFurniture = _ui.hidefurni;
    }

    private static const log :Log = Log.getLog(ToolBox);

    [Embed(source="../../../../../rsrc/graffiti_UI.swf", mimeType="application/octet-stream")]
    protected static const TOOLBOX_UI :Class;

    [Embed(source="../../../../../rsrc/eyedropper.png")]
    protected static const EYEDROPPER :Class;

    protected static const BRUSH_TOOL :int = 1;
    protected static const LINE_TOOL :int = 2;
    protected static const RECTANGLE_TOOL :int = 3;
    protected static const ELIPSE_TOOL :int = 4;
    protected static const CANVAS_TOOL :int = 5;
    protected static const PICKER_TOOL :int = 10;

    protected static const TOOLBAR_WIDTH :int = 80;
    protected static const FLA_WIDTH :int = 485;
    protected static const BRUSH_PREVIEW_X_OFFSET :int = 430;
    protected static const BRUSH_PREVIEW_Y_OFFSET :int = 122;

    protected static const MIN_BRUSH_SIZE :int = 2;
    protected static const MAX_BRUSH_SIZE :int = 40;
    protected static const DEFAULT_BRUSH_SIZE :int = 10;

    protected var _canvas :Canvas;
    protected var _ui :MovieClip;
    protected var _initialBackgroundColor :uint;
    protected var _initialBackgroundTransparent :Boolean;
    protected var _initialFillPercent :Number;
    protected var _sizeSlider :Slider;
    protected var _alphaSlider :Slider;
    protected var _showFurniture :CheckBox;
}
}

import flash.display.Shape;

class Swatch 
{
    public static const BRUSH :int = 1;
    public static const BACKGROUND :int = 2;
    public static const OUTLINE :int = 3;
    public static const FILL :int = 4;

    public var swatchShape :Shape;
    public var type :int;

    public function Swatch (swatchShape :Shape, type :int) 
    {
        this.swatchShape = swatchShape;
        this.type = type;
    }
}
