// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id: MainLoop.as 6718 2008-11-18 05:13:37Z jamie $

package flashmob.server {

import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class ServerModeStack
{
    /**
     * Returns the top mode on the mode stack, or null
     * if the stack is empty.
     */
    public function get topMode () :ServerMode
    {
        if (_modeStack.length == 0) {
            return null;
        } else {
            return ((_modeStack[_modeStack.length - 1]) as ServerMode);
        }
    }

    /**
     * Initializes structures required by the framework.
     */
    public function setup () :void
    {
        if (_hasSetup) {
            return;
        }

        _hasSetup = true;
    }

    /**
     * Call this function before the application shuts down to release
     * memory and disconnect event handlers.
     *
     * Most applications will want to install an Event.REMOVED_FROM_STAGE
     * handler on the main sprite, and call shutdown from there.
     */
    public function shutdown () :void
    {
        stop();

        popAllModes();
        handleModeTransitions();
    }

    /**
     * Kicks off the MainLoop. Game updates will start happening after this
     * function is called.
     */
    public function run () :void
    {
        if (_running) {
            return;
        }

        // ensure that proper setup has completed
        setup();

        _running = true;
        _timer.addEventListener(TimerEvent.TIMER, update);
        _timer.reset();
        _timer.start();
    }

    public function stop () :void
    {
        if (_running) {
            _timer.removeEventListener(TimerEvent.TIMER, update);
            _timer.stop();
            _running = false;
        }
    }

    /**
     * Inserts a mode into the stack at the specified index. All modes
     * at and above the specified index will move up in the stack.
     * (Mode changes take effect between game updates.)
     *
     * @param mode the ServerMode to add
     * @param index the stack position to add the mode at.
     * You can use a negative integer to specify a position relative
     * to the top of the stack (for example, -1 is the top of the stack).
     */
    public function insertMode (mode :ServerMode, index :int) :void
    {
        if (null == mode) {
            throw new ArgumentError("mode must be non-null");
        }

        createModeTransition(mode, TRANSITION_INSERT, index);
    }

    /**
     * Removes a mode from the stack at the specified index. All
     * modes above the specified index will move down in the stack.
     * (Mode changes take effect between game updates.)
     *
     * @param index the stack position to add the mode at.
     * You can use a negative integer to specify a position relative
     * to the top of the stack (for example, -1 is the top of the stack).
     */
    public function removeMode (index :int) :void
    {
        createModeTransition(null, TRANSITION_REMOVE, index);
    }

    /**
     * Pops the top mode from the stack, if the modestack is not empty, and pushes
     * a new mode in its place.
     * (Mode changes take effect between game updates.)
     */
    public function changeMode (mode :ServerMode) :void
    {
        if (null == mode) {
            throw new ArgumentError("mode must be non-null");
        }

        createModeTransition(mode, TRANSITION_CHANGE);
    }

    /**
     * Pushes a mode to the mode stack.
     * (Mode changes take effect between game updates.)
     */
    public function pushMode (mode :ServerMode) :void
    {
        createModeTransition(mode, TRANSITION_PUSH);
    }

    /**
     * Pops the top mode from the mode stack.
     * (Mode changes take effect between game updates.)
     */
    public function popMode () :void
    {
        removeMode(-1);
    }

    /**
     * Pops all modes from the mode stack.
     * Mode changes take effect before game updates.
     */
    public function popAllModes () :void
    {
        createModeTransition(null, TRANSITION_UNWIND);
    }

    /**
     * Pops modes from the stack until the specified mode is reached.
     * If the specified mode is not reached, it will be pushed to the top
     * of the mode stack.
     * Mode changes take effect before game updates.
     */
    public function unwindToMode (mode :ServerMode) :void
    {
        if (null == mode) {
            throw new ArgumentError("mode must be non-null");
        }

        createModeTransition(mode, TRANSITION_UNWIND);
    }

    protected function createModeTransition (mode :ServerMode, transitionType :uint, index :int = 0) :void
    {
        var transition :ModeTransition = new ModeTransition();
        transition.mode = mode;
        transition.type = transitionType;
        transition.index = index;
        _pendingModeTransitionQueue.push(transition);
    }

    protected function handleModeTransitions () :void
    {
        if (_pendingModeTransitionQueue.length <= 0) {
            return;
        }

        var initialTopMode :ServerMode = this.topMode;

        function doPushMode (newMode :ServerMode) :void {
            if (null == newMode) {
                throw new Error("Can't push a null mode to the mode stack");
            }

            _modeStack.push(newMode);
            newMode.setupInternal();
        }

        function doInsertMode (newMode :ServerMode, index :int) :void {
            if (null == newMode) {
                throw new Error("Can't insert a null mode in the mode stack");
            }

            if (index < 0) {
                index = _modeStack.length + index;
            }
            index = Math.max(index, 0);
            index = Math.min(index, _modeStack.length);

            _modeStack.splice(index, 0, newMode);
            newMode.setupInternal();
        }

        function doRemoveMode (index :int) :void {
            if (_modeStack.length == 0) {
                throw new Error("Can't remove a mode from an empty stack");
            }

            if (index < 0) {
                index = _modeStack.length + index;
            }

            index = Math.max(index, 0);
            index = Math.min(index, _modeStack.length - 1);

            // if the top mode is removed, make sure it's exited first
            var mode :ServerMode = _modeStack[index];
            if (mode == initialTopMode) {
                //initialTopMode.exitInternal();
                initialTopMode = null;
            }

            mode.destroyInternal();
            _modeStack.splice(index, 1);
        }

        // create a new _pendingModeTransitionQueue right now
        // so that we can properly handle mode transition requests
        // that occur during the processing of the current queue
        var transitionQueue :Array = _pendingModeTransitionQueue;
        _pendingModeTransitionQueue = [];

        for each (var transition :ModeTransition in transitionQueue) {
            var mode :ServerMode = transition.mode;
            switch (transition.type) {
            case TRANSITION_PUSH:
                doPushMode(mode);
                break;

            case TRANSITION_INSERT:
                doInsertMode(mode, transition.index);
                break;

            case TRANSITION_REMOVE:
                doRemoveMode(transition.index);
                break;

            case TRANSITION_CHANGE:
                // a pop followed by a push
                if (null != this.topMode) {
                    doRemoveMode(-1);
                }
                doPushMode(mode);
                break;

            case TRANSITION_UNWIND:
                // pop modes until we find the one we're looking for
                while (_modeStack.length > 0 && this.topMode != mode) {
                    doRemoveMode(-1);
                }

                Assert.isTrue(this.topMode == mode || _modeStack.length == 0);

                if (_modeStack.length == 0 && null != mode) {
                    doPushMode(mode);
                }
                break;
            }
        }

        /*var topMode :ServerMode = this.topMode;
        if (topMode != initialTopMode) {
            if (null != initialTopMode) {
                initialTopMode.exitInternal();
            }

            if (null != topMode) {
                topMode.enterInternal();
            }
        }*/
    }

    protected function update (e :Event) :void
    {
        handleModeTransitions();
    }

    protected var _timer :Timer = new Timer(1000 / 20, 0);
    protected var _hasSetup :Boolean = false;
    protected var _running :Boolean = false;
    protected var _lastTime :Number;
    protected var _modeStack :Array = [];
    protected var _pendingModeTransitionQueue :Array = [];
    protected var _updatables :Array = [];

    protected var _fps :Number = 0;

    // mode transition constants
    internal static const TRANSITION_PUSH :int = 0;
    internal static const TRANSITION_UNWIND :int = 1;
    internal static const TRANSITION_INSERT :int = 2;
    internal static const TRANSITION_REMOVE :int = 3;
    internal static const TRANSITION_CHANGE :int = 4;
}

}

import flashmob.server.ServerMode;

class ModeTransition
{
    public var mode :ServerMode;
    public var type :int;
    public var index :int;
}
