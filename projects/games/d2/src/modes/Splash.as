package modes {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.URLRequest;

import flash.net.navigateToURL; // function import

import mx.containers.Canvas;
import mx.controls.Button;
import mx.controls.Image;

import com.threerings.util.Assert;

import com.whirled.contrib.GameModeStack;

import select.SelectBoard;

public class Splash extends GameModeCanvas
{
    public static const HELP_URL :String = "http://wiki.whirled.com/Tree_House_Defense";
    
    public function Splash (main :Main)
    {
        super(main);
    }

    // from GameModeCanvas
    override public function pushed () :void
    {
        // start playing
    }
    
    // from GameModeCanvas
    override public function popped () :void
    {
        // note: splash screen should only be popped when shutting down!
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
        _main.modes.push(new SelectBoard(_main));
    }
    
    [Embed(source="../../rsrc/splash/splash.swf")]
    private static const _splash :Class;
}
}
