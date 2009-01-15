package flashmob.client {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.geom.Rectangle;
import flash.text.TextField;

import flashmob.*;
import flashmob.client.view.*;
import flashmob.data.*;

public class WaitingMode extends GameDataMode
{
    override protected function setup () :void
    {
        super.setup();

        var bounds :Rectangle = ClientContext.roomDisplayBounds;
        var g :Graphics = _modeSprite.graphics;
        g.beginFill(0, 0.5);
        g.drawRect(bounds.left, bounds.top, bounds.width, bounds.height);
        g.endFill();

        var window :MovieClip = SwfResource.instantiateMovieClip("Spectacle_UI", "errorWindow");
        window.x = bounds.width * 0.5;
        window.y = bounds.height * 0.5;
        _modeSprite.addChild(window);

        // make the UI draggable
        addObject(new Dragger(window["dragger"], window));

        var tf :TextField = window["text"];
        tf.text = "Waiting for the rest of the party to enter the game...";
    }

    protected static var log :Log = Log.getLog(WaitingMode);
}

}
