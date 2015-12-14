package flashmob.client.view {

import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flashmob.client.*;

public class GameButton extends Sprite
{
    public function GameButton (name :String)
    {
        _enabledState = SwfResource.instantiateButton(ClientCtx.rsrcs, "Spectacle_UI", name);
        _disabledState = SwfResource.instantiateMovieClip(ClientCtx.rsrcs, "Spectacle_UI", name + "_disabled");
        this.enabled = true;
    }

    public function get button () :SimpleButton
    {
        return _enabledState;
    }

    public function get enabled () :Boolean
    {
        return _enabled;
    }

    public function set enabled (val :Boolean) :void
    {
        if (_enabled != val) {
            _enabled = val;
            var enabled :DisplayObject = (_enabled ? _enabledState : _disabledState);
            var disabled :DisplayObject = (_enabled ? _disabledState : _enabledState);

            if (disabled != null && disabled.parent != null) {
                disabled.parent.removeChild(disabled);
            }

            if (enabled != null) {
                addChild(enabled);
            }
        }
    }

    protected var _enabledState :SimpleButton;
    protected var _disabledState :DisplayObject;
    protected var _enabled :Boolean;
}

}
