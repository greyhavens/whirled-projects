// $Id$

package com.threerings.graffiti.tools {

import fl.controls.ComboBox;
import fl.controls.Slider;

import fl.events.SliderEvent;

import fl.data.DataProvider;

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

[Event(name="colorPicked", type="ToolEvent")];
[Event(name="brushPicked", type="ToolEvent")];
[Event(name="backgroundColor", type="ToolEvent")];
[Event(name="clearCanvas", type="ToolEvent")];

public class ToolBox extends Sprite 
{
    public static const POPUP_WIDTH :int = Canvas.CANVAS_WIDTH + TOOLBAR_WIDTH;
    public static const POPUP_HEIGHT :int = 465;

    public function ToolBox (canvas :Canvas, backgroundColor :uint) 
    {
        addChild(_canvas = canvas);
        _initialBackgroundColor = backgroundColor;
        MultiLoader.getContents(TOOLBOX_UI, handleUILoaded, false, ApplicationDomain.currentDomain);
    }

    public function pickColor (color :uint) :void
    {
        fillSwatch(_currentSwatch.swatchShape, color);

        switch (_currentSwatch.type) {
        case Swatch.BRUSH:
            _brush.color = color;
            dispatchEvent(new ToolEvent(ToolEvent.BRUSH_PICKED, _brush.clone()));
            break;

        case Swatch.BACKGROUND:
            dispatchEvent(new ToolEvent(ToolEvent.BACKGROUND_COLOR, color));
            break;

        default:
            log.debug("Unknown swatch type [" + _currentSwatch.type + "]");
        }
    }
    
    public function hoverColor (color :uint) :void
    {
        // TODO
    }

    public function setBackgroundColor (color :uint) :void
    {
        dispatchEvent(new ToolEvent(ToolEvent.BACKGROUND_COLOR, color));
    }

    public function clearCanvas () :void
    {
        dispatchEvent(new ToolEvent(ToolEvent.CLEAR_CANVAS));
    }

    public function displayFillPercent (percent :Number) :void
    {
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
    
    protected function handleUILoaded (ui :MovieClip) :void
    {
        ui.x = POPUP_WIDTH - FLA_WIDTH;
        addChild(ui);
        
        // initialize the swatches
        var buttonSet :RadioButtonSet = new RadioButtonSet();
        buttonSet.addEventListener(RadioEvent.BUTTON_SELECTED, function (event :RadioEvent) :void {
            _currentSwatch = event.value as Swatch;
        });
        var swatches :Array = 
            [ ui.brushcolor_swatch, ui.bgcolor_swatch, ui.fillcolor_swatch, ui.linecolor_swatch ];
        var buttons :Array = [ ui.brush_color, ui.bg_color, ui.fill_color, ui.line_color ];
        var types :Array = [ Swatch.BRUSH, Swatch.BACKGROUND, Swatch.FILL, Swatch.LINE ];
        for (var ii :int = 0; ii < swatches.length; ii++) {
            swatches[ii].mouseEnabled = false;
            var swatch :Swatch = new Swatch(swatches[ii].getChildAt(0) as Shape, types[ii]);
            buttonSet.addButton(new RadioButton(buttons[ii] as SimpleButton, swatch), ii == 0);
        }
        
        // fill in the current background color on the background swatch
        fillSwatch(ui.bgcolor_swatch.getChildAt(0) as Shape, _initialBackgroundColor);

        var palette :Palette = new Palette(this, 0xFF0000);
        palette.x = ui.x + PALETTE_X_OFFSET;
        palette.y = ui.y + PALETTE_Y_OFFSET;
        addChild(palette);

        var thicknessSlider :Slider = ui.size_slider;
        thicknessSlider.liveDragging = true;
        thicknessSlider.minimum = MIN_BRUSH_SIZE;
        thicknessSlider.maximum = MAX_BRUSH_SIZE;
        thicknessSlider.value = _brush.thickness;
        thicknessSlider.snapInterval = 1;
        thicknessSlider.addEventListener(SliderEvent.CHANGE, function (event :SliderEvent) :void {
            _brush.thickness = thicknessSlider.value;
            dispatchEvent(new ToolEvent(ToolEvent.BRUSH_PICKED, _brush.clone()));
        });

        var alphaSlider :Slider = ui.alpha_slider;
        alphaSlider.liveDragging = true;
        alphaSlider.maximum = 1;
        alphaSlider.minimum = 0;
        alphaSlider.value = _brush.alpha;
        alphaSlider.snapInterval = 0.05;
        alphaSlider.addEventListener(SliderEvent.CHANGE, function (event :SliderEvent) :void {
            _brush.alpha = alphaSlider.value;
            dispatchEvent(new ToolEvent(ToolEvent.BRUSH_PICKED, _brush.clone()));
        });

        var fontSizeCombo :ComboBox = ui.font_size;
        fontSizeCombo.dataProvider = new DataProvider(["TODO"]);

        var doneButton :SimpleButton = ui.done_button;
        doneButton.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            dispatchEvent(new ToolEvent(ToolEvent.DONE_EDITING));
        });
    }

    [Embed(source="../../../../../rsrc/graffiti_UI.swf", mimeType="application/octet-stream")]
    protected static const TOOLBOX_UI :Class;

    protected static const TOOLBAR_WIDTH :int = 80;
    protected static const FLA_WIDTH :int = 485;
    protected static const PALETTE_X_OFFSET :int = 445;
    protected static const PALETTE_Y_OFFSET :int = 65;

    protected var MIN_BRUSH_SIZE :int = 2;
    protected var MAX_BRUSH_SIZE :int = 60;

    private static const log :Log = Log.getLog(ToolBox);

    protected var _canvas :Canvas;
    protected var _brush :Brush = new Brush();
    protected var _currentSwatch :Swatch;
    protected var _initialBackgroundColor :uint;
}
}

import flash.display.Shape;

class Swatch 
{
    public static const BRUSH :int = 1;
    public static const BACKGROUND :int = 2;
    public static const LINE :int = 3;
    public static const FILL :int = 4;

    public var swatchShape :Shape;
    public var type :int;

    public function Swatch (swatchShape :Shape, type :int) 
    {
        this.swatchShape = swatchShape;
        this.type = type;
    }
}
