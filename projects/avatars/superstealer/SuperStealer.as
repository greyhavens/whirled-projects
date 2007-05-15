package {

import flash.display.Sprite;
import flash.display.Loader;

import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;

import flash.text.TextField;
import flash.text.TextFieldType;

import flash.net.URLRequest;

import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;

import flash.ui.Keyboard;


import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="600", height="450")]
public class SuperStealer extends Sprite
{
    public static const NEW_URL_ACTION :String = "Enter new URL";

    public static const QUERY_URL_MSG :String = "qURL";

    public static const NOTIFY_URL_MSG :String = "URL";

    public function SuperStealer ()
    {
        _ctrl = new AvatarControl(this);
        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleStateChanged);
        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, handleActionTriggered);
        _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessageReceived);

        _ctrl.registerActions(NEW_URL_ACTION);

        // whenever we start up, we broadcast an "Oy! What's my URL?" message
        _ctrl.sendMessage(QUERY_URL_MSG);
    }

    protected function handleMessageReceived (event :ControlEvent) :void
    {
        switch (event.name) {
        case QUERY_URL_MSG:
            if (_ctrl.hasControl()) {
                if (_url != null) {
                    _ctrl.sendMessage(NOTIFY_URL_MSG, _url);

                } else {
                    showInputField();
                }
            }
            break;

        case NOTIFY_URL_MSG:
            loadUrl(event.value as String);
            break;
        }
    }

    protected function handleActionTriggered (event :ControlEvent) :void
    {
        switch (event.name) {
        case NEW_URL_ACTION:
            if (_ctrl.hasControl()) {
                showInputField();
            }
            break;
        }
    }

    protected function handleStateChanged (... ignored) :void
    {
        // nada, currently
    }

    protected function showInputField () :void
    {
        if (_input == null) {
            _input = new TextField();
            _input.background = true;
            _input.width = 600;
            _input.height = 20;
            _input.type = TextFieldType.INPUT;
            _input.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown)
            addChild(_input);
        }

        this.stage.focus = _input;
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
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
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

    protected function handleKeyDown (event :KeyboardEvent) :void
    {
        if (event.keyCode != Keyboard.ENTER) {
            return;
        }

        // dispatch with all haste
        _ctrl.sendMessage(NOTIFY_URL_MSG, _input.text);
        removeChild(_input);
        _input = null;
    }

    protected function loadError (event :IOErrorEvent) :void
    {
        trace("Got load error: " + event);
    }

    protected var _ctrl :AvatarControl;

    protected var _inControl :Boolean;

    protected var _input :TextField;

    protected var _loader :Loader;

    protected var _url :String;

    protected var _urls :Array = [];
}
}
