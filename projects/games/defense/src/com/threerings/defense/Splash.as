package com.threerings.defense {

import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.net.URLRequest;

import flash.net.navigateToURL; // function import

import mx.containers.Canvas;
import mx.controls.Button;
import mx.controls.Image;

public class Splash extends Canvas
{
    public static const HELP_URL :String = "http://whirled.threerings.net/";
    
    public function Splash (playCallback :Function)
    {
        _playCallback = playCallback;
    }
       
    // from Canvas
    override protected function createChildren () :void
    {
        super.createChildren();
        
        var bg :Image = new Image();
        addChild(bg);
        bg.source = new _splash();
        
        var play :Button = new Button();
        play.styleName = "playButton";
        play.x = 220;
        play.y = 267;
        play.addEventListener(MouseEvent.CLICK, playClicked);
        addChild(play);

        var help :Button = new Button();
        help.styleName = "helpButton";
        help.x = 339;
        help.y = 382;
        help.addEventListener(MouseEvent.CLICK, helpClicked);
        addChild(help);
    }
        
    protected function helpClicked (event :MouseEvent) :void
    {
        var url :URLRequest = new URLRequest(HELP_URL);
        navigateToURL(url, "_blank");
    }

    protected function playClicked (event :MouseEvent) :void
    {
        _playCallback();
    }
    
    [Embed(source="../../../../rsrc/splash/splash.swf")]
    private static const _splash :Class;

    protected var _playCallback :Function;
}
}
