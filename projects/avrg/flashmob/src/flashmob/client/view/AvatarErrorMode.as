package flashmob.client.view {

import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.MovieClip;
import flash.geom.Rectangle;
import flash.text.TextField;

import flashmob.*;
import flashmob.client.*;

public class AvatarErrorMode extends GameDataMode
{
    public function AvatarErrorMode (requiredAvatarId :int)
    {
        _requiredAvatarId = requiredAvatarId;
    }

    override protected function setup () :void
    {
        super.setup();

        var roomBounds :Rectangle = SpaceUtil.roomDisplayBounds;
        var window :MovieClip = SwfResource.instantiateMovieClip(ClientCtx.rsrcs, "Spectacle_UI", "errorWindow");
        window.x = roomBounds.width * 0.5;
        window.y = roomBounds.height * 0.5;
        _modeSprite.addChild(window);

        // make the UI draggable
        addObject(new Dragger(window["dragger"], window));

        var tf :TextField = window["text"];
        tf.text = "The Spectacle will continue when everyone is wearing the correct Avatar!";

        _dataBindings.bindProp(Constants.PROP_PLAYERS,
            function () :void {
                if (ClientCtx.players.allWearingAvatar(_requiredAvatarId)) {
                    ClientCtx.mainLoop.popMode();
                }
            });
    }

    override protected function enter () :void
    {
        super.enter();
        if (!_playedSound) {
            ClientCtx.audio.playSoundNamed("fail");
            _playedSound = true;
        }
    }

    protected var _requiredAvatarId :int;
    protected var _playedSound :Boolean;
}

}
