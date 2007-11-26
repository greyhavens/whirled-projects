package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.geom.Matrix;

import flash.media.Sound;

import com.threerings.util.Log;

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

import com.whirled.contrib.EntityStatePublisher;

[SWF(width="128", height="128")]
public class Switch extends Sprite
{
    public static const KEY :String = "circuit01";

    public function Switch ()
    {
        _imageHolder = new Sprite();
        this.addChild(_imageHolder);

        _imageHolder.addChild(_onImage);

        _control = new FurniControl(this);
        if (_control.isConnected()) {
            _publisher = new EntityStatePublisher(_control, KEY, false, stateChanged);

            _imageHolder.addEventListener(MouseEvent.CLICK, handleClick);
            _imageHolder.addChild(_offImage);
            updateImage();
        }
    }

    protected function handleClick (event :MouseEvent) :void
    {
        _publisher.setState(!_publisher.state);
    }

    protected function stateChanged (key :String, state :Object) :void
    {
        _switchSnd.play();
        updateImage();
    }

    protected function updateImage () :void
    {
        _onImage.visible = _publisher.state;
        _offImage.visible = !_publisher.state;
    }

    protected var _control :FurniControl;
    protected var _publisher :EntityStatePublisher;
    protected var _imageHolder :Sprite;

    protected var _onImage :DisplayObject = new SWITCH_IMG_ON();
    protected var _offImage :DisplayObject = new SWITCH_IMG_OFF();
    protected var _switchSnd :Sound = new SWITCH_SND();

    [Embed(source="switch-on.png")]
        protected static const SWITCH_IMG_ON :Class;
    [Embed(source="switch-off.png")]
        protected static const SWITCH_IMG_OFF :Class;
    [Embed(source="switch.mp3")]
        protected static const SWITCH_SND :Class;

}
}
