// $Id$

package com.threerings.graffiti.tools {

import fl.controls.CheckBox;
import fl.controls.ComboBox;
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

public class ToolBox2 extends Sprite 
{
    public static const POPUP_WIDTH :int = Canvas.CANVAS_WIDTH + TOOLBAR_WIDTH;
    public static const POPUP_HEIGHT :int = 465;

    public function ToolBox2 (canvas :Canvas, backgroundColor :uint, backgroundTransparent :Boolean,
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

    protected function selectUi (tool :int) :void
    {
        _ui.gotoAndStop(tool);
    }

    protected function handleUILoaded (ui :MovieClip) :void
    {
        _ui = ui;
        _ui.x = POPUP_WIDTH - FLA_WIDTH;
        selectUi(BRUSH_TOOL);
        addChild(_ui);

        _ui.brushtool.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            selectUi(BRUSH_TOOL);
        });
        _ui.linetool.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            selectUi(LINE_TOOL);
        });
        _ui.rectangletool.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            selectUi(RECTANGLE_TOOL);
        });
        _ui.elipsetool.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            selectUi(ELIPSE_TOOL);
        });
        _ui.canvastool.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            selectUi(CANVAS_TOOL);
        });
    }

    private static const log :Log = Log.getLog(ToolBox);

    [Embed(source="../../../../../rsrc/graffiti_UI2.swf", mimeType="application/octet-stream")]
    protected static const TOOLBOX_UI :Class;

    [Embed(source="../../../../../rsrc/eyedropper.png")]
    protected static const EYEDROPPER :Class;

    protected static const BRUSH_TOOL :int = 1;
    protected static const LINE_TOOL :int = 2;
    protected static const RECTANGLE_TOOL :int = 3;
    protected static const ELIPSE_TOOL :int = 4;
    protected static const CANVAS_TOOL :int = 5;

    protected static const TOOLBAR_WIDTH :int = 80;
    protected static const FLA_WIDTH :int = 485;
    protected static const PALETTE_X_OFFSET :int = 445;
    protected static const PALETTE_Y_OFFSET :int = 65;
    protected static const BRUSH_PREVIEW_X_OFFSET :int = 430;
    protected static const BRUSH_PREVIEW_Y_OFFSET :int = 122;

    protected static const MIN_BRUSH_SIZE :int = 2;
    protected static const MAX_BRUSH_SIZE :int = 40;

    protected var _canvas :Canvas;
    protected var _ui :MovieClip;
    protected var _currentSwatch :Swatch;
    protected var _backgroundColorSwatch :Swatch;
    protected var _initialBackgroundColor :uint;
    protected var _initialBackgroundTransparent :Boolean;
    protected var _initialFillPercent :Number;
    protected var _currentToolType :int = 0;
    protected var _brushColor :uint;
    protected var _outlineColor :uint = 0x000000;
    protected var _outlineClear :Boolean = true;
    protected var _fillColor :uint = 0x000000;
    protected var _fillClear :Boolean = false;
    protected var _thickness :int = 10;
    protected var _alpha :Number = 1.0;
    protected var _fillButton :ToggleButton;
    protected var _outlineButton :ToggleButton;
    protected var _brushPreview :Shape;
    protected var _sizeLimit :MovieClip;
    protected var _swatchSet :RadioButtonSet;
    protected var _colorPicker :Sprite;
    protected var _hoverColor :uint;
    protected var _eyeDropper :DisplayObject;
    protected var _undoButton :MovieClipButton;
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
