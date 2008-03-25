//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;

import flash.geom.Rectangle;

import flash.utils.getTimer;

import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;
import com.whirled.MobControl;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Random;
import com.threerings.util.StringUtil;

[SWF(width="700", height="500")]
public class Game extends Sprite
{
    public static const DEBUG :Boolean = false;
    public static const FRAMES_PER_REPORT :int = 300;

    public static var log :Log = Log.getLog(Game);

    public static var control :AVRGameControl;

    public static var server :Server;

    public static var model :GameModel;
    public static var panel :GamePanel;

    public static var stageSize :Rectangle;
    public static var scrollSize :Rectangle;
    public static var roomBounds :Rectangle;

    public static var ourRoomId :int;
    public static var ourPlayerId :int;

    public static var random :Random;

    public function Game ()
    {
        random = new Random();

        control = new AVRGameControl(this);
        if (!control.isConnected()) {
            return;
        }
        ourPlayerId = control.getPlayerId();

        server = new Server();
        model = new GameModel();

        var gameController :GameController = new GameController();

        addChild(panel = gameController.panel);

        control.setHitPointTester(panel.hitTestPoint);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        control.addEventListener(
            AVRGameControlEvent.ENTERED_ROOM,
            function (... ignored) :void { newRoom(); });

        control.addEventListener(
            AVRGameControlEvent.SIZE_CHANGED,
            function (... ignored) :void { newSize(); reloadView(); });

        control.addEventListener(AVRGameControlEvent.GOT_CONTROL, gotControl);

        if (control.hasControl() && !control.state.getProperty(Codes.PROP_TICKER_RUNNING)) {
            control.state.setProperty(Codes.PROP_TICKER_RUNNING, true, false);
            control.startTicker(Codes.MSG_TICK, 1000);
        }
    }

    public static function profile (f :Function) :void
    {
        var t :Number = getTimer();
        f();
        log.debug("Profiling(" + f + ") = " + (getTimer() - t));
    }

    public static function setAvatarState (state :String) :void
    {
        var info :AVRGameAvatar = control.getAvatarInfo(Game.ourPlayerId);
        if (info != null && info.state != state) {
            control.setAvatarState(state);
        }
    }

    public static function getTeam (excludeDead :Boolean = false) :Array
    {
        var players :Array = Game.control.getPlayerIds();
        if (players == null) {
            // disconnected
            return [ ];
        }
        var team :Array = new Array(players.length);
        var jj :int = 0;
        for (var ii :int = 0; ii < players.length; ii ++) {
            if (!Game.control.isPlayerHere(players[ii])) {
                continue;
            }
            if (excludeDead && model.isPlayerDead(players[ii])) {
                continue;
            }
            team[jj ++] = players[ii];
        }
        return team.slice(0, jj);
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");
        newSize();
        newRoom();
        reloadView();
//        gameController.panel.showSplash();
    }

    protected function newSize () :void
    {
        var resized :Boolean = false;

        var newSize :Rectangle = control.getStageSize();
        if (newSize != null) {
            stageSize = newSize;
            log.debug("Setting stage size: " + stageSize);
            resized = true;

        } else if (stageSize != null) {
            log.warning("Eek - null stage size -- keeping old data.");

        } else {
            log.warning("Eek - null stage size -- hard coding at 700x500");
            stageSize = new Rectangle(0, 0, 700, 500);
        }

        newSize = control.getStageSize(false);
        if (newSize != null) {
            scrollSize = newSize;
            log.debug("Setting scroll size: " + scrollSize);
            resized = true;

        } else if (scrollSize != null) {
            log.warning("Eek - null scroll size -- keeping old data.");

        } else {
            log.warning("Eek - null scroll size -- hard coding at 700x500");
            scrollSize = new Rectangle(0, 0, 700, 500);
        }
    }

    protected function newRoom () :void
    {
        ourRoomId = control.getRoomId();

        var newBounds :Rectangle = control.getRoomBounds();
        if (newBounds != null) {
            roomBounds = newBounds;
            log.debug("Setting room bounds: " + roomBounds);

        } else if (roomBounds != null) {
            log.warning("Eek - null room bounds -- keeping old data.");

        } else {
            log.warning("Eek - null room bounds -- hard coding at 700x500");
            roomBounds = new Rectangle(0, 0, 700, 500);
        }

        server.newRoom();

        panel.newGhost();
    }

    protected function reloadView () :void
    {
        panel.reloadView();
    }

    protected function gotControl (evt :AVRGameControlEvent) :void
    {
        log.debug("gotControl(): " + evt);
    }
}
}
