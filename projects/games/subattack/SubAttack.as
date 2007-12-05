package {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;

import flash.text.TextField;

import flash.ui.Keyboard;

import flash.utils.getTimer; // function import
import flash.utils.ByteArray;
import flash.utils.Timer;

import com.threerings.util.StringUtil;

import com.threerings.flash.KeyRepeatLimiter;

import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;

import com.whirled.WhirledGameControl;

[SWF(width="700", height="500")]
public class SubAttack extends Sprite
{
    /** How many tiles does our vision extend past our tile? */
    public static const VISION_TILES :int = 8;

    /** How many total tiles are in one direction in the view? */
    public static const VIEW_TILES :int = (VISION_TILES * 2) + 1;

    public function SubAttack ()
    {
        _seaHolder = new Sprite();
//        var scale :Number = 500 / (VIEW_TILES * SeaDisplay.TILE_SIZE);
//        trace("Tile scaled size is " + (scale * SeaDisplay.TILE_SIZE));
//        _seaHolder.scaleX = scale;
//        _seaHolder.scaleY = scale;
        _seaHolder.x = 200;
        addChild(_seaHolder);

        _seaHolder.addChild(_seaDisplay = new SeaDisplay());

        addChild(new SIDEBAR() as DisplayObject);

        var maskSize :int = VIEW_TILES * SeaDisplay.TILE_SIZE;
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0xFFFFFF);
        masker.graphics.drawRect(0, 0, maskSize, maskSize);
        masker.graphics.endFill();
        //masker.x = 200;
        _seaHolder.mask = masker;
        _seaHolder.addChild(masker); // the mask must be added to the display
        // set up a fake starting sea
        _seaDisplay.setupSea(VIEW_TILES, VIEW_TILES);

        _gameCtrl = new WhirledGameControl(this, false);
        if (!_gameCtrl.isConnected()) {
            // just show a demo-mode display
            _seaDisplay.setStatus(
                "<P align=\"center\"><font size=\"+2\">Truckyard Shootout</font>" +
                "<br>A fast-action maze-building and shooting game for " +
                "2-8 players.<br>Must be played inside Whirled.</P>");
            var sub :Submarine = new Submarine(0, 0, "Player 1", 3, 3, null, null);
            _seaDisplay.addChild(sub);
            return;
        }

        _splash = new Loader();
        addChild(_splash);
        _splash.loadBytes(ByteArray(new SPLASH_SCREEN()));
        _splash.addEventListener(MouseEvent.CLICK, handleRemoveSplash);
        _splashTimer.addEventListener(TimerEvent.TIMER, handleRemoveSplash);
        _splashTimer.start();

        _myIndex = _gameCtrl.seating.getMyPosition();

        if (_myIndex != -1) {
            _keyLimiter = new KeyRepeatLimiter(_gameCtrl, 100);
            _keyLimiter.addEventListener(KeyboardEvent.KEY_DOWN, keyEvent);

            addEventListener(Event.ENTER_FRAME, enterFrame);
        }

        _gameCtrl.addEventListener(PropertyChangedEvent.TYPE, handlePropertyChanged);
        _gameCtrl.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);

        this.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // check everyone's current readyness states
        recheckReadyness();
    }

    /**
     * Update the score display to display readyness of all players.
     */
    protected function recheckReadyness () :void
    {
        _gameCtrl.setPlayerScores(
            _gameCtrl.seating.getPlayerIds().map(function (id :int, ... ig) :String {
                return (null == _gameCtrl.get("ready:" + id)) ? "Waiting..." : "Ready!";
            }));
    }

    protected function handleRemoveSplash (event :Event) :void
    {
        removeChild(_splash);
        _splashTimer.stop();
        _splashTimer = null;
        _gameCtrl.set("ready:" + _gameCtrl.getMyId(), true);
        _gameCtrl.playerReady();
    }

    /**
     * Clean up the game when unloaded.
     */
    protected function handleUnload (evt :Event) :void
    {
        if (_splashTimer != null) {
            _splashTimer.stop();
        }
        _keyLimiter.shutdown();
        removeEventListener(Event.ENTER_FRAME, enterFrame);
    }

    /**
     */
    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        if (StringUtil.startsWith(event.name, "ready:")) {
            recheckReadyness();
        }
    }

    /**
     * React to a successful rematch and remove the rematch button.
     */
    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        // stop listening for ready events
        _gameCtrl.removeEventListener(PropertyChangedEvent.TYPE, recheckReadyness);

        _seaDisplay.clearStatus();
        _seaHolder.removeChild(_seaDisplay);
        _seaHolder.addChildAt(_seaDisplay = new SeaDisplay(), 0);
        _board = new Board(_gameCtrl, _seaDisplay);
    }

    /**
     * Handles KEY_DOWN.
     */
    protected function keyEvent (event :KeyboardEvent) :void
    {
        if (!_seaDisplay.canQueueActions()) {
            trace("Can't queue: waiting on serer.");
            // ignore it, we're still waiting on too much to return from the server
            return;
        }

        var action :int = getActionForKey(event);
        if (action == Action.NONE) {
            return;
        }

        var now :int = getTimer();
        if (_queued != null) {
            _queued.push(action);

        } else {
            if ((now - _lastSent) < SEND_THROTTLE) {
                _queued = [ action ];

            } else {
                _gameCtrl.sendMessage("sub" + _myIndex, [ action ]);
                _lastSent = now;
            }
        }

        _seaDisplay.queueAction(now, action);
    }

    protected function enterFrame (event :Event) :void
    {
        if (_queued != null) {
            var now :int = getTimer();
            if ((now - _lastSent) >= SEND_THROTTLE) {
                _gameCtrl.sendMessage("sub" + _myIndex, _queued);
                _lastSent = now;
                _queued = null;
            }
        }
    }

    /**
     * Get the action that corresponds to the specified key.
     */
    protected function getActionForKey (event :KeyboardEvent) :int
    {
        switch (event.keyCode) {
        case Keyboard.DOWN:
            return Action.DOWN;

        case Keyboard.UP:
            return Action.UP;

        case Keyboard.RIGHT:
            return Action.RIGHT;

        case Keyboard.LEFT:
            return Action.LEFT;

        case Keyboard.SPACE:
            return Action.SHOOT;

        case Keyboard.ENTER:
            return Action.RESPAWN;

        case Keyboard.CONTROL:
            return Action.BUILD;

        default:
            if (event.charCode == 90 || event.charCode == 122) { // 'Z' and 'z'
                return Action.BUILD;
            }
            return Action.NONE;
        }
    }

    /** The game control. */
    protected var _gameCtrl :WhirledGameControl;

    /** Represents our board. */
    protected var _board :Board;

    /** Holds the splash screen. */
    protected var _splash :Loader;

    /** A timer that automatically removes the splash screen. */
    protected var _splashTimer :Timer = new Timer(20000, 1);

    protected var _seaHolder :Sprite;

    /** The visual display of the game. */
    protected var _seaDisplay :SeaDisplay;

    /** Limits key repeats. */
    protected var _keyLimiter :KeyRepeatLimiter;

    /** Our player index, or -1 if we're not a player. */
    protected var _myIndex :int;

    /** The time at which we last sent our actions. */
    protected var _lastSent :int = 0;

    /** The actions we have queued to be sent. */
    protected var _queued :Array;

    [Embed(source="title_screen.swf", mimeType="application/octet-stream")]
    protected static const SPLASH_SCREEN :Class;

    [Embed(source="sidebar.png")]
    protected static const SIDEBAR :Class;

    protected static const SEND_THROTTLE :int = 105;
}
}
