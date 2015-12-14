// $Id$

package com.threerings.graffiti {

import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.system.ApplicationDomain;

import com.threerings.util.MultiLoader;

public class ClearCanvasDialog extends Sprite
{
    public static const POPUP_WIDTH :int = 300;
    public static const POPUP_HEIGHT :int = 100;

    public function ClearCanvasDialog (yesfunc :Function, nofunc :Function) 
    {
        _yesfunc = yesfunc;
        _nofunc = nofunc;
        MultiLoader.getContents(
            CLEAR_CANVAS, handleUILoaded, false, ApplicationDomain.currentDomain);
    }

    protected function handleUILoaded (ui :MovieClip) :void
    {
        addChild(ui);
        ui.yesbutton.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _yesfunc();
        });
        ui.nobutton.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _nofunc();
        });
    }

    [Embed(source="../../../../rsrc/clearcanvas.swf", mimeType="application/octet-stream")]
    protected static const CLEAR_CANVAS :Class;

    protected var _yesfunc :Function;
    protected var _nofunc :Function;
}
}
