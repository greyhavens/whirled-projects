package flashmob.client.view {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;

import flashmob.client.*;

public class BasicErrorMode extends AppMode
{
    public function BasicErrorMode (err :String, okHandler :Function = null)
    {
        _err = err;
        _okHandler = (okHandler != null ? okHandler : ClientContext.mainLoop.popMode);
    }

    override protected function setup () :void
    {
        super.setup();

        var bounds :Rectangle = ClientContext.fullDisplayBounds;
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
        tf.text = _err;

        var okButton :GameButton = new GameButton("ok_button");
        okButton.x = 0;
        okButton.y = 47;
        window.addChild(okButton);
        registerOneShotCallback(okButton, MouseEvent.CLICK, _okHandler);
    }

    override protected function enter () :void
    {
        super.enter();
        if (!_playedSound) {
            AudioManager.instance.playSoundNamed("clown_horn");
            _playedSound = true;
        }
    }

    protected var _err :String;
    protected var _okHandler :Function;
    protected var _playedSound :Boolean;
}

}
