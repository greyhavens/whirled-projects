package core {

import com.threerings.util.Assert;
import com.threerings.util.ArrayUtil;

import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

import core.util.Rand;
import flash.display.Sprite;

public class MainLoop
{
    public static function get instance () :MainLoop
    {
        return g_instance;
    }

    public function MainLoop (applicationSprite :Sprite)
    {
        Assert.isNull(g_instance);
        g_instance = this;

        Assert.isNotNull(applicationSprite);
        _applicationSprite = applicationSprite;
    }

    public function addUpdatable (obj :Updatable) :void
    {
        _updatables.push(obj);
    }

    public function removeUpdatable (obj :Updatable) :void
    {
        ArrayUtil.removeFirst(_updatables, obj);
    }

    public function get topMode () :AppMode
    {
        if (_modeStack.length == 0) {
            return null;
        } else {
            return ((_modeStack[_modeStack.length - 1]) as AppMode);
        }
    }

    public function setup () :void
    {
        if (_hasSetup) {
            return;
        }

        _hasSetup = true;

        Rand.setup();

        addUpdatable(ResourceManager.instance);
    }

    public function run () :void
    {
        // ensure that proper setup has completed
        setup();

        // it's an error to call run() multiple times
        Assert.isFalse(_running);
        _running = true;

        var appSettings :CoreAppSettings = this.applicationSettings;

        // convert fps to update interval
        var updateInterval :Number = 1000.0 / Number(appSettings.frameRate);

        _mainTimer = new Timer(updateInterval, 0);
        _mainTimer.addEventListener(TimerEvent.TIMER, update);
        _mainTimer.start();

        _lastTime = this.elapsedSeconds;
    }

    public function pushMode (mode :AppMode) :void
    {
        Assert.isTrue(null != mode);
        createModeTransition(mode, TRANSITION_PUSH);
    }

    public function popMode () :void
    {
        createModeTransition(null, TRANSITION_POP);
    }

    public function changeMode (mode :AppMode) :void
    {
        Assert.isTrue(null != mode);
        createModeTransition(mode, TRANSITION_CHANGE);
    }

    public function unwindToMode (mode :AppMode) :void
    {
        Assert.isTrue(null != mode);
        createModeTransition(mode, TRANSITION_UNWIND);
    }

    protected function createModeTransition (mode :AppMode, transitionType :uint) :void
    {
        var modeTransition :Object = new Object();
        modeTransition.mode = mode;
        modeTransition.transitionType = transitionType;
        _pendingModeTransitionQueue.push(modeTransition);
    }

    public function get applicationSettings () :CoreAppSettings
    {
        if (null == _defaultAppSettings) {
            _defaultAppSettings = new CoreAppSettings();
        }

        return _defaultAppSettings;
    }

    protected function update (e :TimerEvent) :void
    {
        var initialTopMode :AppMode = this.topMode;

        function doPopMode () :void {
            var topMode :AppMode = this.topMode;
            Assert.isNotNull(mode);

            _modeStack.pop();
            _applicationSprite.removeChild(topMode);

            // if the top mode is popped, make sure it's exited first
            if (mode == initialTopMode) {
                initialTopMode.exit();
                initialTopMode = null;
            }

            mode.destroy();
        }

        function doPushMode (mode :AppMode) :void {
            Assert.isNotNull(mode);

            _modeStack.push(mode);
            _applicationSprite.addChild(mode);
            mode.setup();
        }

        for each (var transition :* in _pendingModeTransitionQueue) {
            var type :uint = transition.transitionType as uint;
            var mode :AppMode = transition.mode as AppMode;

            switch (type) {
            case TRANSITION_PUSH:
                doPushMode(mode);
                break;

            case TRANSITION_POP:
                doPopMode();
                break;

            case TRANSITION_CHANGE:
                // a pop followed by a push
                doPopMode();
                doPushMode(mode);
                break;

            case TRANSITION_UNWIND:
                // pop modes until we find the one we're looking for
                while (_modeStack.length > 0 && this.topMode != mode) {
                    doPopMode();
                }

                Assert.isTrue(this.topMode == mode || _modeStack.length == 0);

                if (_modeStack.length == 0) {
                    doPushMode();
                }
                break;
            }
        }

        var topMode :AppMode = this.topMode;
        if (topMode != initialTopMode) {
            if (null != initialTopMode) {
                initialTopMode.exit();
            }

            if (null != topMode) {
                topMode.enter();
            }
        }

        _pendingModeTransitionQueue = new Array();

        // how much time has elapsed since last frame?
        var newTime :Number = this.elapsedSeconds;
        var dt :Number = newTime - _lastTime;

        // update all our "updatables"
        for each (var updatable :Updatable in _updatables) {
            updatable.update(dt);
        }

        // update the top mode
        if (null != topMode) {
            topMode.update(dt);
        }

        _lastTime = newTime;
    }

    /** Returns the number of seconds that have elapsed since the application started. */
    public function get elapsedSeconds () :Number
    {
        return (getTimer() / 1000); // getTimer() returns a value in milliseconds
    }

    protected static var g_instance :MainLoop;

    protected var _defaultAppSettings :CoreAppSettings;

    protected var _applicationSprite :Sprite;
    protected var _hasSetup :Boolean = false;
    protected var _running :Boolean = false;
    protected var _mainTimer :Timer;
    protected var _lastTime :Number;
    protected var _modeStack :Array = new Array();
    protected var _pendingModeTransitionQueue :Array = new Array();
    protected var _updatables :Array = new Array();

    // mode transition constants
    internal static const TRANSITION_PUSH :uint = 0;
    internal static const TRANSITION_POP :uint = 1;
    internal static const TRANSITION_CHANGE :uint = 2;
    internal static const TRANSITION_UNWIND :uint = 3;
}

}
