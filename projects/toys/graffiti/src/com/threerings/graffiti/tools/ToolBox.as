// $Id$

package com.threerings.graffiti.tools {

import fl.controls.CheckBox;
import fl.controls.ComboBox;
import fl.controls.Slider;

import fl.events.SliderEvent;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

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

    public function pickColor (color :uint) :void
    {
        dispatchEvent(new ToolEvent(ToolEvent.COLOR_PICKING, false));
        _swatchSet.deactivateCurrentSelection();
        if (_currentSwatch == null) {
            return;
        }

        fillSwatch(_currentSwatch.swatchShape, color);

        switch (_currentSwatch.type) {
        case Swatch.BRUSH:
            _brushColor = color;
            toolSettingsChanged();
            break;

        case Swatch.OUTLINE:
            _outlineColor = color
            toolSettingsChanged();
            break;

        case Swatch.FILL:
            _fillColor = color
            toolSettingsChanged();
            break;

        case Swatch.BACKGROUND:
            dispatchEvent(new ToolEvent(ToolEvent.BACKGROUND_COLOR, color));
            break;

        default:
            log.debug("Unknown swatch type [" + _currentSwatch.type + "]");
        }

        _currentSwatch = null;
    }
    
    public function hoverColor (color :uint) :void
    {
        // TODO
    }

    public function setBackgroundColor (color :uint) :void
    {
        dispatchEvent(new ToolEvent(ToolEvent.BACKGROUND_COLOR, color));
    }

    public function displayFillPercent (percent :Number) :void
    {
        _sizeLimit.gotoAndStop(Math.ceil(percent * 100));
    }

    public function managerMessageReceived (event :ThrottleEvent) :void
    {
        if (event.message is AlterBackgroundMessage) {
            var backgroundMessage :AlterBackgroundMessage = event.message as AlterBackgroundMessage;
            if (backgroundMessage.type == AlterBackgroundMessage.COLOR) {
                fillSwatch(_backgroundColorSwatch.swatchShape, backgroundMessage.value as uint);
            } else if (backgroundMessage.type == AlterBackgroundMessage.TRANSPARENCY) {
                _noBackgroundCheckbox.selected = backgroundMessage.value as Boolean;
            }
        }
    }

    protected function toolSettingsChanged () :void
    {
        if (_currentToolType == 0) {
            return;
        }

        updateBrushPreview();

        switch(_currentToolType) {
        case Tool.BRUSH:
            dispatchEvent(new ToolEvent(ToolEvent.TOOL_PICKED, 
                new BrushTool(_thickness, _alpha, _brushColor)));
            break;
        
        case Tool.LINE:
            dispatchEvent(new ToolEvent(ToolEvent.TOOL_PICKED,
                new LineTool(_thickness, _alpha, _brushColor)));
            break;

        case Tool.ELLIPSE:
            dispatchEvent(new ToolEvent(ToolEvent.TOOL_PICKED,
                new EllipseTool(_thickness, _alpha, _outlineColor, _outlineButton.selected, 
                                _fillColor, _fillButton.selected)));
            break;

        case Tool.RECTANGLE:
            dispatchEvent(new ToolEvent(ToolEvent.TOOL_PICKED,
                new RectangleTool(_thickness, _alpha, _outlineColor, _outlineButton.selected,
                                  _fillColor, _fillButton.selected)));
            break;

        default:
            log.warning("unknown tool [" + _currentToolType + "]");
        }
    }

    protected function updateBrushPreview () :void
    {
        if (_brushPreview == null) {
            return;
        }

        var g :Graphics = _brushPreview.graphics;
        g.clear();
        g.beginFill(_brushColor, _alpha);
        g.drawCircle(MAX_BRUSH_SIZE / 2, MAX_BRUSH_SIZE / 2, _thickness / 2);
    }

    protected function fillSwatch (shape :Shape, color :uint) :void
    {
        var w :int = shape.width;
        var h :int = shape.height;
        shape.graphics.clear();
        shape.graphics.beginFill(color);
        shape.graphics.drawRect(-w/2, -h/2, w, h);
        shape.graphics.endFill();
    }

    protected function checkFillOutline (button :ToggleButton) :void
    {
        button.selected = !button.selected;

        if (!_fillButton.selected && !_outlineButton.selected) {
            if (button == _fillButton) {
                _outlineButton.selected = true;
            } else if (button == _outlineButton) {
                _fillButton.selected = true;
            } else {
                log.warning("unknown button [" + button + "]");
            }
        }

        toolSettingsChanged();
    }
    
    protected function handleUILoaded (ui :MovieClip) :void
    {
        ui.x = POPUP_WIDTH - FLA_WIDTH;
        addChild(ui);
        
        // initialize the swatches
        _swatchSet = new RadioButtonSet();
        _swatchSet.addEventListener(RadioEvent.BUTTON_SELECTED, function (event :RadioEvent) :void {
            _currentSwatch = event.value as Swatch;
            dispatchEvent(new ToolEvent(ToolEvent.COLOR_PICKING, true));
        });
        var swatches :Array = 
            [ ui.brushcolor_swatch, ui.bgcolor_swatch, ui.fillcolor_swatch, ui.linecolor_swatch ];
        var buttons :Array = [ ui.brush_color, ui.bg_color, ui.fill_color, ui.line_color ];
        var types :Array = [ Swatch.BRUSH, Swatch.BACKGROUND, Swatch.FILL, Swatch.OUTLINE ];
        for (var ii :int = 0; ii < swatches.length; ii++) {
            swatches[ii].mouseEnabled = false;
            var swatch :Swatch = new Swatch(swatches[ii].getChildAt(0) as Shape, types[ii]);
            _swatchSet.addButton(new ToggleButton(buttons[ii] as SimpleButton, swatch), ii == 0);
            if (types[ii] == Swatch.BACKGROUND) {
                _backgroundColorSwatch = swatch;
            }
        }
        
        // fill in the current background color on the background swatch
        fillSwatch(ui.bgcolor_swatch.getChildAt(0) as Shape, _initialBackgroundColor);

        // add color palette
        var palette :Palette = new Palette(this, 0xFF0000);
        palette.x = ui.x + PALETTE_X_OFFSET;
        palette.y = ui.y + PALETTE_Y_OFFSET;
        addChild(palette);

        // set up tool radio
        var buttonSet :RadioButtonSet = new RadioButtonSet();
        buttonSet.addEventListener(RadioEvent.BUTTON_SELECTED, function (event :RadioEvent) :void {
            _currentToolType = event.value as int;
            toolSettingsChanged();
        });
        buttons = [ ui.brushtool, ui.linetool, ui.ellipsetool, ui.recttool ];
        types = [ Tool.BRUSH, Tool.LINE, Tool.ELLIPSE, Tool.RECTANGLE ];
        for (ii = 0; ii < buttons.length; ii++) {
            buttonSet.addButton(new ToggleButton(buttons[ii] as SimpleButton, types[ii]), ii == 0);
        }

        // fill and outline buttons
        ui.FillOnOff.overState = ui.FillOnOff.upState;
        _fillButton = new ToggleButton(ui.FillOnOff, null);
        _fillButton.button.addEventListener(MouseEvent.MOUSE_DOWN, 
            function (event :MouseEvent) :void {
                checkFillOutline(_fillButton);
            });
        _fillButton.selected = true;
        ui.LineOnOff.overState = ui.LineOnOff.upState;
        _outlineButton = new ToggleButton(ui.LineOnOff, null);
        _outlineButton.button.addEventListener(MouseEvent.MOUSE_DOWN, 
            function (event :MouseEvent) :void {
                checkFillOutline(_outlineButton);
            });
        _outlineButton.selected = false;

        // transparent background checkbox
        _noBackgroundCheckbox = ui.nobg_checkbox;
        _noBackgroundCheckbox.selected = _initialBackgroundTransparent;
        _noBackgroundCheckbox.addEventListener(MouseEvent.CLICK, 
            function (event :MouseEvent) :void {
                dispatchEvent(new ToolEvent(
                    ToolEvent.BACKGROUND_TRANSPARENCY, _noBackgroundCheckbox.selected));
            });

        // brush thickness slider
        var thicknessSlider :Slider = ui.size_slider;
        thicknessSlider.liveDragging = true;
        thicknessSlider.minimum = MIN_BRUSH_SIZE;
        thicknessSlider.maximum = MAX_BRUSH_SIZE;
        thicknessSlider.value = _thickness;
        thicknessSlider.snapInterval = 1;
        thicknessSlider.addEventListener(SliderEvent.CHANGE, function (event :SliderEvent) :void {
            _thickness = thicknessSlider.value;
            toolSettingsChanged();
        });

        // brush alpha slider
        var alphaSlider :Slider = ui.alpha_slider;
        alphaSlider.liveDragging = true;
        alphaSlider.maximum = 1;
        alphaSlider.minimum = 0;
        alphaSlider.value = _alpha;
        alphaSlider.snapInterval = 0.05;
        alphaSlider.addEventListener(SliderEvent.CHANGE, function (event :SliderEvent) :void {
            _alpha = alphaSlider.value;
            toolSettingsChanged();
        });

        // brush preview
        addChild(_brushPreview = new Shape());
        _brushPreview.x = ui.x + BRUSH_PREVIEW_X_OFFSET;
        _brushPreview.y = ui.y + BRUSH_PREVIEW_Y_OFFSET;
        updateBrushPreview();

        // size limit indicator
        _sizeLimit = ui.sizelimit;
        _sizeLimit.gotoAndStop(Math.ceil(_initialFillPercent * 100));

        // done button
        var doneButton :SimpleButton = ui.done_button;
        doneButton.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            dispatchEvent(new ToolEvent(ToolEvent.DONE_EDITING));
        });
    }

    private static const log :Log = Log.getLog(ToolBox);

    [Embed(source="../../../../../rsrc/graffiti_UI.swf", mimeType="application/octet-stream")]
    protected static const TOOLBOX_UI :Class;

    protected static const TOOLBAR_WIDTH :int = 80;
    protected static const FLA_WIDTH :int = 485;
    protected static const PALETTE_X_OFFSET :int = 445;
    protected static const PALETTE_Y_OFFSET :int = 65;
    protected static const BRUSH_PREVIEW_X_OFFSET :int = 430;
    protected static const BRUSH_PREVIEW_Y_OFFSET :int = 122;

    protected var MIN_BRUSH_SIZE :int = 2;
    protected var MAX_BRUSH_SIZE :int = 40;

    protected var _canvas :Canvas;
    protected var _currentSwatch :Swatch;
    protected var _backgroundColorSwatch :Swatch;
    protected var _initialBackgroundColor :uint;
    protected var _initialBackgroundTransparent :Boolean;
    protected var _initialFillPercent :Number;
    protected var _currentToolType :int = 0;
    protected var _brushColor :uint;
    protected var _outlineColor :uint;
    protected var _fillColor :uint;
    protected var _thickness :int = 10;
    protected var _alpha :Number = 1.0;
    protected var _fillButton :ToggleButton;
    protected var _outlineButton :ToggleButton;
    protected var _brushPreview :Shape;
    protected var _noBackgroundCheckbox :CheckBox;
    protected var _sizeLimit :MovieClip;
    protected var _swatchSet :RadioButtonSet;
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
