// $Id$

package com.threerings.graffiti.tools {

import fl.core.UIComponent;

import fl.controls.ComboBox;
import fl.controls.Slider;

import fl.skins.DefaultComboBoxSkins;
import fl.skins.DefaultListSkins;

import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;

import flash.system.ApplicationDomain;

import com.threerings.util.Log;
import com.threerings.util.MultiLoader;

import com.threerings.graffiti.Canvas;

[Event(name="colorPicked", type="ToolEvent")];
[Event(name="brushPicked", type="ToolEvent")];
[Event(name="backgroundColor", type="ToolEvent")];
[Event(name="clearCanvas", type="ToolEvent")];

public class ToolBox extends Sprite 
{
    public static const POPUP_WIDTH :int = 485;
    public static const POPUP_HEIGHT :int = 465;

    public function ToolBox (canvas :Canvas) 
    {
        addChild(_canvas = canvas);
        MultiLoader.getLoaders(TOOLBOX_UI, handleUILoaded, false, ApplicationDomain.currentDomain); 
    }

    public function pickColor (color :uint) :void
    {
        dispatchEvent(new ToolEvent(ToolEvent.COLOR_PICKED, color));
    }

    public function brushPicked (brush :Brush) :void
    {
        dispatchEvent(new ToolEvent(ToolEvent.BRUSH_PICKED, brush.clone()));
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
    
    protected function handleUILoaded (loader :Loader) :void
    {
        var ui :MovieClip = loader.content as MovieClip;
        addChild(ui);
        var alphaSlider :Slider = ui.alpha_slider;
        var fontSizeCombo :ComboBox = ui.font_size;

        // force the compiler to include
        DefaultComboBoxSkins;
        DefaultListSkins;
        UIComponent;
    }

    [Embed(source="../../../../../rsrc/graffiti_UI.swf", mimeType="application/octet-stream")]
    protected static const TOOLBOX_UI :Class;

    private static const log :Log = Log.getLog(ToolBox);

    protected var _canvas :Canvas;
}
}
