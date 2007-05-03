package {

import flash.display.Sprite;
import flash.display.Loader;

import flash.events.TextEvent;

import flash.text.TextField;
import flash.text.TextFieldType;

import flash.net.URLRequest;

import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;


import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="600", height="450")]
public class SuperStealer extends Sprite
{
    public function SuperStealer ()
    {
        _ctrl = new AvatarControl(this);
        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleStateChanged);

        // Now that we're listening for state events, see if we are being controlled (by trying to set our state) by the same person
        // viewing us (our instanceId)
        var state :String = _ctrl.getState();
        if (state == null) { 
            _ctrl.setState("_" + String(_ctrl.getInstanceId()));
        } else {
            handleStateChanged();
        }
    }


    protected function addInputField () :void
    {
        if (_input == null) {
            _input = new TextField();
            _input.background = true;
            _input.width = 100;
            _input.height = 20;
            _input.type = TextFieldType.INPUT;
            _input.addEventListener(TextEvent.TEXT_INPUT, handleTextInput);
        }
        addChild(_input);
    }

    protected function handleStateChanged (... ignored) :void
    {
        var state :String = _ctrl.getState();
        var mode :String = state.charAt(0);
        state = state.substring(1);
        switch (mode) {
        case "_":
            if (state == String(_ctrl.getInstanceId())) {
                _inControl = true; // Yeah!! Launch our deeevious plan...
                addInputField();
            }
            break;

        case "#":
            loadUrl(state);
            break;
        }
    }

    protected function loadUrl (url :String) :void
    {
        if (_url == url) {
            return;
        }

        if (_loader != null) {
            _loader.unload();
            removeChild(_loader);
        }

        _loader = new Loader();
        _loader.load(new URLRequest(url),
            new LoaderContext(false, new ApplicationDomain(null), null));
        addChildAt(_loader, 0);


        if (_inControl) {
            var stateName :String = "#" + _url;
            if (-1 == _urls.indexOf(stateName)) {
                _urls.push(url);
                _ctrl.registerStates.apply(_ctrl, _urls);
            }
        }
    }

    protected function handleTextInput (... ignored) :void
    {
        _ctrl.setState("#" + _input.text);
    }

    protected var _ctrl :AvatarControl;

    protected var _inControl :Boolean;

    protected var _input :TextField;

    protected var _loader :Loader;

    protected var _url :String;

    protected var _urls :Array = [];
}
}
