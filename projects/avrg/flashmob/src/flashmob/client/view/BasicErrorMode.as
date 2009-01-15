package flashmob.client.view {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

import flashmob.client.*;

public class BasicErrorMode extends AppMode
{
    public function BasicErrorMode (err :String, playSound :Boolean, okHandler :Function = null)
    {
        _err = err;
        _playSound = playSound;
        _okHandler = (okHandler != null ? okHandler : ClientContext.mainLoop.popMode);
    }

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
        tf.text = _err;

        var okButton :GameButton = new GameButton("ok_button");
        okButton.width = BUTTON_SIZE.x;
        okButton.height = BUTTON_SIZE.y;
        okButton.x = BUTTON_LOC.x;
        okButton.y = BUTTON_LOC.y;
        window.addChild(okButton);
        registerOneShotCallback(okButton, MouseEvent.CLICK, _okHandler);
    }

    override protected function enter () :void
    {
        super.enter();
        if (!_playedSound && _playSound) {
            AudioManager.instance.playSoundNamed("fail");
            _playedSound = true;
        }
    }

    protected var _err :String;
    protected var _playSound :Boolean;
    protected var _okHandler :Function;
    protected var _playedSound :Boolean;

    protected static const BUTTON_LOC :Point = new Point(0, 47);
    protected static const BUTTON_SIZE :Point = new Point(83, 27);
}

}
