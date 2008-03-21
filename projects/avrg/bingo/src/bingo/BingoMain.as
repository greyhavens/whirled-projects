//
// $Id$

package bingo {

import com.threerings.util.Log;
import com.threerings.util.MultiLoader;
import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.ApplicationDomain;

[SWF(width="700", height="500")]
public class BingoMain extends Sprite
{
    public static var log :Log = Log.getLog(BingoMain);

    public static var control :AVRGameControl;
    public static var model :Model;
    public static var controller :Controller;
    public static var resourcesDomain :ApplicationDomain;

    public static var ourPlayerId :int;

    public static var sprite :Sprite;

    public function BingoMain ()
    {
        log.info("Bingo version " + Constants.VERSION);

        sprite = this;

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        control = new AVRGameControl(this);

        control.addEventListener(AVRGameControlEvent.LEFT_ROOM, leftRoom);

        control.addEventListener(AVRGameControlEvent.GOT_CONTROL, gotControl);

        resourcesDomain = new ApplicationDomain();
        MultiLoader.getLoaders(Resources.SWF_UI, handleResourcesLoaded, false, resourcesDomain);
    }

    public static function quit () :void
    {
        if (control.isConnected()) {
            control.deactivateGame();
        }
    }

    public static function getPlayerName (playerId :int) :String
    {
        if (control.isConnected()) {
            var avatar :AVRGameAvatar = control.getAvatarInfo(playerId);
            if (null != avatar) {
                return avatar.name;
            }
        }

        return "player " + playerId.toString();
    }

    protected function maybeBeginGame () :void
    {
        if (_addedToStage && _resourcesLoaded) {
            new BingoItemManager(); // init singleton

            _introView = new BingoIntroView();
            _introView.addEventListener(MouseEvent.CLICK, play, false, 0, true);
            this.addChild(_introView);

            model.setup();
        }
    }

    protected function play (...ignored) :void
    {
        _introView.removeEventListener(MouseEvent.CLICK, play);
        this.removeChild(_introView);
        _introView = null;

        controller.beginGame();
    }

    protected function handleResourcesLoaded (results :Object) :void
    {
        _resourcesLoaded = true;
        this.maybeBeginGame();
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");

        log.info(control.isConnected() ? "playing online game" : "playing offline game");

        model = (control.isConnected() && !Constants.FORCE_SINGLEPLAYER ? new OnlineModel() : new OfflineModel());
        controller = new Controller(this, model);

        ourPlayerId = (control.isConnected() ? control.getPlayerId() : 666);

        _addedToStage = true;

        this.maybeBeginGame();
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

        controller.destroy();
        model.destroy();
    }

    protected function leftRoom (e :Event) :void
    {
        log.debug("leftRoom");
        if (control.isConnected()) {
            log.debug("deactivating game");
            control.deactivateGame();
        }
    }

    protected function gotControl (evt :AVRGameControlEvent) :void
    {
        log.debug("gotControl(): " + evt);
    }

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;
    protected var _introView :BingoIntroView;
}
}
