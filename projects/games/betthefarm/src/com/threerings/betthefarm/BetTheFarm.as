//
// $Id$

package com.threerings.betthefarm {

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;

import com.whirled.WhirledGameControl;

import com.threerings.ezgame.StateChangedEvent;
import com.threerings.util.Random;

[SWF(width="900", height="500")]
public class BetTheFarm extends Sprite
{
    public static const DEBUG :Boolean = true;

    public static var random :Random = new Random();

    /**
     * Creates and initializes our game.
     */
    public function BetTheFarm ()
    {
        // wire up our unloader
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // create and wire ourselves into our multiplayer game control
        _control = new WhirledControl(this);
        _control.addEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        _control.addEventListener(StateChangedEvent.ROUND_STARTED, roundDidStart);
        _control.addEventListener(StateChangedEvent.ROUND_ENDED, roundDidEnd);
        _control.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);
        _control.addEventListener(StateChangedEvent.CONTROL_CHANGED, controlChanged);

        // create our server, our model and our view, and initialize them
        _model = new Model(_control);
        if (_control.amInControl()) {
            _server = new Server(_control, _model);
            _control.startTicker(Model.MSG_TICK, 1000);
        }
        _view = new View(_control, _model);
        addChild(_view);
    }

    protected function controlChanged (event :StateChangedEvent) :void
    {
        if (_control.amInControl()) {
            _server = new Server(_control, _model);
        }
    }

    protected function gameDidStart (event :StateChangedEvent) :void
    {
        _model.gameDidStart();
        if (_server != null) {
            _server.gameDidStart();
        }
        _view.gameDidStart();
    }

    protected function roundDidStart (event :StateChangedEvent) :void
    {
        _model.roundDidStart();
        if (_server != null) {
            _server.roundDidStart();
        }
        _view.roundDidStart();
    }

    protected function roundDidEnd (event :StateChangedEvent) :void
    {
        _model.roundDidEnd();
        if (_server != null) {
            _server.roundDidEnd();
        }
        _view.roundDidEnd();
    }

    protected function gameDidEnd (event :StateChangedEvent) :void
    {
        _model.gameDidEnd();
        if (_server != null) {
            _server.gameDidEnd();
        }
        _view.gameDidEnd();
    }

    protected function handleUnload (event :Event) :void
    {
        _model.shutdown();
        if (_server != null) {
            _server.shutdown();
        }
        _view.shutdown();
    }

    protected var _control :WhirledGameControl;
    protected var _server :Server;
    protected var _model :Model;
    protected var _view :View;
}

}
