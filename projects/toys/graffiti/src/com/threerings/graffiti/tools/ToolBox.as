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

    public function displayFillPercent (percent :Number) :void
    {
        _sizeLimit.gotoAndStop(Math.ceil(percent * 100));
    }

    public function managerMessageReceived (event :ThrottleEvent) :void
    {
        if (event.message is AlterBackgroundMessage) {
            var backgroundMessage :AlterBackgroundMessage = event.message as AlterBackgroundMessage;
            if (backgroundMessage.type == AlterBackgroundMessage.COLOR) {
                _colors[PRIMARY_COLOR][toolsetForTool(CANVAS_TOOL)] = 
                    backgroundMessage.value as int;
                _colorEnableds[PRIMARY_COLOR][toolsetForTool(CANVAS_TOOL)] = true;
            } else if (backgroundMessage.type == AlterBackgroundMessage.TRANSPARENCY) {
                _colorEnableds[PRIMARY_COLOR][toolsetForTool(CANVAS_TOOL)] = 
                    !(backgroundMessage.value as Boolean);
            }

            if (_currentDrawingTool == CANVAS_TOOL) {
                if (_colorEnableds[PRIMARY_COLOR][toolsetForTool(CANVAS_TOOL)]) {
                    fillSwatch(_swatches[PRIMARY_COLOR], 
                        _colors[PRIMARY_COLOR][toolsetForTool(CANVAS_TOOL)]);
                } else {
                    clearSwatch(_swatches[PRIMARY_COLOR]);
                }
            }
        }
    }

    public function setUndoEnabled (enabled :Boolean) :void
    {
        _undoButton.enabled = enabled;
    }

    protected function toolUpdate () :void
    {
        updateBrushPreview();

        var toolset :int = toolsetForTool(_currentTool);
        var tool :Tool = null;
        if (_currentTool == BRUSH_TOOL) {
            tool = new BrushTool(_sizes[toolset], _alphas[toolset], 
                                 _colors[PRIMARY_COLOR][toolset]);
        } else if (_currentTool == LINE_TOOL) {
            tool = new LineTool(_sizes[toolset], _alphas[toolset],
                                _colors[PRIMARY_COLOR][toolset]);
        } else if (_currentTool == RECTANGLE_TOOL) {
            tool = new RectangleTool(_sizes[toolset], _alphas[toolset],
                _colors[SECONDARY_COLOR][toolset], _colorEnableds[SECONDARY_COLOR][toolset],
                _colors[PRIMARY_COLOR][toolset], _colorEnableds[PRIMARY_COLOR][toolset]);
        } else if (_currentTool == ELIPSE_TOOL) {
            tool = new EllipseTool(_sizes[toolset], _alphas[toolset],
                _colors[SECONDARY_COLOR][toolset], _colorEnableds[SECONDARY_COLOR][toolset],
                _colors[PRIMARY_COLOR][toolset], _colorEnableds[PRIMARY_COLOR][toolset]);
        }
        dispatchEvent(new ToolEvent(ToolEvent.TOOL_PICKED, tool));
    }

    protected function updateBrushPreview () :void
    {
        var toolset :int = toolsetForTool(_currentTool);
        if (toolset < MEDIUM_TOOLSET) {
            _brushPreview.visible = false;
            return;
        }

        _brushPreview.visible = true;
        var g :Graphics = _brushPreview.graphics;
        g.clear();
        var color :uint;
        if (toolset == FULL_TOOLSET) {
            if (_colorEnableds[SECONDARY_COLOR][toolset]) {
                color = _colors[SECONDARY_COLOR][toolset];
            } else {
                // leave clear
                return;
            }
        } else if (_colorEnableds[PRIMARY_COLOR][toolset]) {
            color = _colors[PRIMARY_COLOR][toolset];
        } else {
            // leave clear
            return;
        }
        g.beginFill(color, _alphas[toolset]);
        g.drawCircle(0, 0, _sizes[toolset] / 2);
        g.endFill();
    }

    protected function toolsetForTool (tool :int) :int 
    {
        if (tool == CANVAS_TOOL) {
            return BASIC_TOOLSET;
        } 
        
        if (tool == BRUSH_TOOL || tool == LINE_TOOL) {
            return MEDIUM_TOOLSET;
        } 
        
        if (tool == RECTANGLE_TOOL || tool == ELIPSE_TOOL) {
            return FULL_TOOLSET;
        }
        
        return NO_TOOLSET;
    }

    protected function setupUi (tool :int) :void
    {
        var toolset :int = toolsetForTool(_currentTool = tool);
        if (toolset == NO_TOOLSET) {
            toolUpdate();
            return;
        }

        // stupid flash and it's non-zero-based indexing of frames
        _ui.gotoAndStop(_currentDrawingTool = tool);

        // sliders visibility
        _sizeSlider.alpha = _alphaSlider.alpha = toolset == BASIC_TOOLSET ? 0 : 1;

        if (toolset < FULL_TOOLSET) {
            // only primary color is shown for these tools, so make sure it's selected
            _swatchButtonSet.buttonClicked(PRIMARY_COLOR);
        }

        for each (var color :int in [ PRIMARY_COLOR, SECONDARY_COLOR ]) {
            if (_colorEnableds[color][toolset]) {
                fillSwatch(_swatches[color], _colors[color][toolset]);
            } else {
                clearSwatch(_swatches[color]);
            }
        }

        _sizeSlider.value = _sizes[toolset];
        _alphaSlider.value = _alphas[toolset];

        toolUpdate();
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

    protected function clearSwatch (shape :Shape) :void
    {
        var w :int = shape.width;
        var h :int = shape.height;
        shape.graphics.clear();
        shape.graphics.beginFill(0xFFFFFF);
        shape.graphics.drawRect(-w/2, -h/2, w, h);
        shape.graphics.endFill();
        shape.graphics.lineStyle(3, 0xFF0000);
        shape.graphics.moveTo(w/2 - 2, -h/2 + 2);
        shape.graphics.lineTo(-w/2 + 2, h/2 - 2);
    }

    protected function sizeSliderUpdate (event :SliderEvent) :void 
    {
        _sizes[toolsetForTool(_currentDrawingTool)] = event.value;
        toolUpdate();
    }

    protected function alphaSliderUpdate (event :SliderEvent) :void
    {
        _alphas[toolsetForTool(_currentDrawingTool)] = event.value;
        toolUpdate();
    }

    protected function undo (event :MouseEvent) :void
    {
        if (!_undoButton.enabled) {
            return;
        }

        dispatchEvent(new ToolEvent(ToolEvent.UNDO_ONCE));
    }

    protected function clearCurrentSwatch (event :MouseEvent) :void
    {
        var toolset :int = toolsetForTool(_currentDrawingTool);
        _colorEnableds[_currentSwatch][toolset] = false;
        clearSwatch(_swatches[_currentSwatch]);

        if (toolset == FULL_TOOLSET) {
            // since we just turned off one of the two color swatches, make sure the other
            // one is on.
            _colorEnableds[(_currentSwatch + 1) % 2][toolset] = true;
            fillSwatch(_swatches[(_currentSwatch + 1) % 2], 
                _colors[(_currentSwatch + 1) % 2][toolset]);
        }

        if (_currentDrawingTool == CANVAS_TOOL) {
            dispatchEvent(new ToolEvent(ToolEvent.BACKGROUND_TRANSPARENCY, true));
        } else {
            toolUpdate();
        }
    }

    protected function pickClickedColor (event :MouseEvent) :void
    {
        var toolset :int = toolsetForTool(_currentDrawingTool);
        _colors[_currentSwatch][toolset] = 
            colorFromGlobalPoint(new Point(event.stageX, event.stageY));
        _colorEnableds[_currentSwatch][toolset] = true;
        fillSwatch(_swatches[_currentSwatch], _colors[_currentSwatch][toolset]);

        if (_currentDrawingTool == CANVAS_TOOL) {
            dispatchEvent(new ToolEvent(ToolEvent.BACKGROUND_TRANSPARENCY, false));
            dispatchEvent(
                new ToolEvent(ToolEvent.BACKGROUND_COLOR, _colors[_currentSwatch][toolset]));
        } else {
            toolUpdate();
        }
    }

    protected function pickerHover (event :MouseEvent) :void
    {
        _eyeDropper.visible = true;
        var local :Point = globalToLocal(new Point(event.stageX, event.stageY));
        _eyeDropper.x = local.x;
        _eyeDropper.y = local.y - _eyeDropper.height;
        showHoveredColor(event);
    }

    protected function showHoveredColor (event :MouseEvent) :void
    {
        fillSwatch(_swatches[_currentSwatch], 
            colorFromGlobalPoint(new Point(event.stageX, event.stageY)));
    }

    protected function colorPickerMouseOut (event :MouseEvent) :void
    {
        var toolset :int = toolsetForTool(_currentDrawingTool);
        if (_colorEnableds[_currentSwatch][toolset]) {
            fillSwatch(_swatches[_currentSwatch], _colors[_currentSwatch][toolset]);
        } else {
            clearSwatch(_swatches[_currentSwatch]);
        }

        _eyeDropper.visible = false;
    }

    protected function colorFromGlobalPoint (point :Point) :uint
    {
        var location :Point = globalToLocal(point);
        var m :Matrix = new Matrix();
        m.translate(-location.x, -location.y);
        var data :BitmapData = new BitmapData(1, 1);
        data.draw(this, m);
        return data.getPixel(0, 0);
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
        _sizeSlider.snapInterval = 1;
        _sizeSlider.addEventListener(SliderEvent.CHANGE, sizeSliderUpdate);

        // alpha slider
        _alphaSlider = _ui.alpha_slider;
        _alphaSlider.liveDragging = true;
        _alphaSlider.minimum = 0;
        _alphaSlider.maximum = 1;
        _alphaSlider.snapInterval = 0.05;
        _alphaSlider.addEventListener(SliderEvent.CHANGE, alphaSliderUpdate);

        // color swatches
        _ui.primarycolor_swatch.mouseEnabled = false;
        _swatches[PRIMARY_COLOR] = _ui.primarycolor_swatch.getChildAt(0) as Shape;
        _ui.secondarycolor_swatch.mouseEnabled = false;
        _swatches[SECONDARY_COLOR] = _ui.secondarycolor_swatch.getChildAt(0) as Shape;
        _swatchButtonSet = new RadioButtonSet();
        _swatchButtonSet.addEventListener(RadioEvent.BUTTON_SELECTED, 
            function (event :RadioEvent) :void {
                _currentSwatch = event.value;
            });
        _swatchButtonSet.addButton(
            new ToggleButton(_ui.primary_color as SimpleButton, PRIMARY_COLOR), true);
        _swatchButtonSet.addButton(
            new ToggleButton(_ui.secondary_color as SimpleButton, SECONDARY_COLOR));

        // color picker
        ui.rainbow.addEventListener(MouseEvent.CLICK, pickClickedColor);
        ui.rainbow.addEventListener(MouseEvent.MOUSE_MOVE, pickerHover);
        ui.rainbow.addEventListener(MouseEvent.MOUSE_OUT, colorPickerMouseOut);
        ui.nocolor.addEventListener(MouseEvent.CLICK, clearCurrentSwatch);
        addChild(_eyeDropper = new EYEDROPPER() as DisplayObject);
        _eyeDropper.visible = false;

        // brush preview
        addChild(_brushPreview = new Shape());
        _brushPreview.x = ui.x + BRUSH_PREVIEW_X_OFFSET;
        _brushPreview.y = ui.y + BRUSH_PREVIEW_Y_OFFSET;
        
        // undo button - disabled by default because we have nothing to undo yet
        _undoButton = new MovieClipButton(_ui.undo);
        _undoButton.enabled = false;
        _ui.undo.addEventListener(MouseEvent.CLICK, undo);

        // show furni checkbox - I know this logic looks backwards, but the instance name never
        // got changed...
        _ui.hidefurni.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            dispatchEvent(new ToolEvent(ToolEvent.HIDE_FURNI, !_ui.hidefurni.selected));
        });
        _ui.hidefurni.selected = false;

        // done button
        _ui.done_button.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            dispatchEvent(new ToolEvent(ToolEvent.DONE_EDITING));
        });

        // size limit indicator
        _sizeLimit = ui.sizelimit;

        // setup init values
        _colorEnableds[PRIMARY_COLOR][toolsetForTool(CANVAS_TOOL)] = !_initialBackgroundTransparent;
        _colors[PRIMARY_COLOR][toolsetForTool(CANVAS_TOOL)] = _initialBackgroundColor;
        _sizeLimit.gotoAndStop(Math.ceil(_initialFillPercent * 100));

        // tool buttons - set this up last, as it initiates a general UI setup for the brush tool, 
        // and all the member variables need to be initialized.
        _toolButtonSet = new RadioButtonSet();
        _toolButtonSet.addEventListener(RadioEvent.BUTTON_SELECTED, 
            function (event :RadioEvent) :void {
                setupUi(event.value);
            });
        var buttons :Array = [ _ui.brushtool, _ui.linetool, _ui.rectangletool, _ui.elipsetool, 
                               _ui.canvastool, _ui.pickertool ]
        var tools :Array = [ BRUSH_TOOL, LINE_TOOL, RECTANGLE_TOOL, ELIPSE_TOOL, CANVAS_TOOL,
                             PICKER_TOOL ];
        for (var ii :int = 0; ii < buttons.length; ii++) {
            _toolButtonSet.addButton(
                new ToggleButton(buttons[ii] as SimpleButton, tools[ii]), ii == 0);
        }

        _canvas.addEventListener(MouseEvent.MOUSE_MOVE, canvasMouseMove);
        _canvas.addEventListener(MouseEvent.MOUSE_OUT, canvasMouseOut);
        _canvas.addEventListener(MouseEvent.CLICK, canvasClick);
    }

    protected function indicatorForTool (tool :int) :DisplayObject
    {
        switch (tool) {
        case BRUSH_TOOL:
            // TODO
            return null;

        case LINE_TOOL:
            return new LINETOOL();

        case PICKER_TOOL:
            return new EYEDROPPER();
            
        case ELIPSE_TOOL: 
            return new ELIPSETOOL();

        case RECTANGLE_TOOL:
            return new RECTANGLETOOL();

        case CANVAS_TOOL:
            // nothing to show
            return null;

        default:
            log.warning("asked for indicator for unknown tool! [" + tool + "]");
            return null;
        }
    }

    protected function canvasMouseMove (event :MouseEvent) :void
    {
        // the player must mouse out to change tool settings at which point the indicator is set
        // to null, so we don't need to do anything fancy to get updates for tool changes.
        if (_toolIndicator == null || _toolIndicator.parent != this) {
            _toolIndicator = indicatorForTool(_currentTool);
            if (_toolIndicator == null) {
                return;
            }
            addChild(_toolIndicator);
        }

        var local :Point = globalToLocal(new Point(event.stageX, event.stageY));
        _toolIndicator.x = local.x;
        _toolIndicator.y = local.y - _toolIndicator.height;

        if (_currentTool == PICKER_TOOL) {
            showHoveredColor(event);
        }
    }

    protected function canvasMouseOut (event :MouseEvent) :void
    {
        if (_toolIndicator != null && _toolIndicator.parent == this) {
            removeChild(_toolIndicator);
            _toolIndicator = null;
        }
    }

    protected function canvasClick (event :MouseEvent) :void
    {
        if (_currentTool == PICKER_TOOL) {
            // this is the one case where the tool changes out from under us, so grab a new one.
            canvasMouseOut(event);
            pickClickedColor(event);
            _toolButtonSet.buttonClicked(_currentDrawingTool - 1);
            canvasMouseMove(event);
        }
    }

    private static const log :Log = Log.getLog(ToolBox);

    [Embed(source="../../../../../rsrc/graffiti_UI.swf", mimeType="application/octet-stream")]
    protected static const TOOLBOX_UI :Class;

    [Embed(source="../../../../../rsrc/eyedropper.png")]
    protected static const EYEDROPPER :Class;
    [Embed(source="../../../../../rsrc/elipsetool.png")]
    protected static const ELIPSETOOL :Class;
    [Embed(source="../../../../../rsrc/linetool.png")]
    protected static const LINETOOL :Class;
    [Embed(source="../../../../../rsrc/rectangletool.png")]
    protected static const RECTANGLETOOL :Class;

    // values for the tools RadioButtonSet
    protected static const BRUSH_TOOL :int = 1;
    protected static const LINE_TOOL :int = 2;
    protected static const RECTANGLE_TOOL :int = 3;
    protected static const ELIPSE_TOOL :int = 4;
    protected static const CANVAS_TOOL :int = 5;
    protected static const PICKER_TOOL :int = 10;

    protected static const NO_TOOLSET :int = -1;
    protected static const BASIC_TOOLSET :int = 0;
    protected static const MEDIUM_TOOLSET :int = 1;
    protected static const FULL_TOOLSET :int = 2;

    // values for the swatches RadioButtonSet
    protected static const PRIMARY_COLOR :int = 0;
    protected static const SECONDARY_COLOR :int = 1;

    protected static const TOOLBAR_WIDTH :int = 80;
    protected static const FLA_WIDTH :int = 485;
    protected static const BRUSH_PREVIEW_X_OFFSET :int = 445;
    protected static const BRUSH_PREVIEW_Y_OFFSET :int = 154;

    protected static const MIN_BRUSH_SIZE :int = 2;
    protected static const MAX_BRUSH_SIZE :int = 40;

    protected var _canvas :Canvas;
    protected var _ui :MovieClip;
    protected var _initialBackgroundColor :uint;
    protected var _initialBackgroundTransparent :Boolean;
    protected var _initialFillPercent :Number;
    protected var _sizeSlider :Slider;
    protected var _alphaSlider :Slider;
    protected var _swatches :Array = [];
    protected var _currentSwatch :int;
    protected var _swatchButtonSet :RadioButtonSet;
    protected var _toolButtonSet :RadioButtonSet;
    protected var _undoButton :MovieClipButton;
    protected var _currentTool :int;
    protected var _currentDrawingTool :int;
    protected var _eyeDropper :DisplayObject;
    protected var _sizeLimit :MovieClip;
    protected var _brushPreview :Shape;
    protected var _toolIndicator :DisplayObject;

    // settings for each tool set - arranged in the order of the tool set constants above
    protected var _sizes :Array = [ 2, 10, 5];
    protected var _alphas :Array = [ 0, 1, 1 ];
    protected var _colorEnableds :Array = [
        // primary
        [ true, true, true],
        // secondary
        [ false, false, false] ];
    protected var _colors :Array = [
        // primary
        [ 0, 0, 0 ],
        // secondary
        [ 0, 0, 0 ] ];
}
}
