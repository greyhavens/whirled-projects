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

import com.threerings.ezgame.util.GameModeStack;
import com.threerings.util.Assert;

public class Splash extends GameModeCanvas
{
    public static const HELP_URL :String = "http://wiki.whirled.com/Tree_House_Defense";
    
    public function Splash (modes :GameModeStack)
    {
        super(modes);
    }

    // from interface GameMode
    override public function pushed () :void
    {
        // start playing
    }
    
    // from interface GameMode
    override public function popped () :void
    {
        Assert.fail("Splash screen should never be popped!");
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
        getGameModeStack().push(new SelectBoard(_modes));
    }
    
    [Embed(source="../../rsrc/splash/splash.swf")]
    private static const _splash :Class;
}
}
