//
// $Id$

package ghostbusters.client {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

import ghostbusters.client.fight.FightPanel;
import ghostbusters.client.seek.SeekPanel;
import ghostbusters.client.util.GhostModel;
import ghostbusters.data.Codes;

public class GamePanel extends Sprite
{
    // ghost states
    public static const ST_GHOST_HIDDEN :String = "hidden";
    public static const ST_GHOST_APPEAR :String = "appear_to_fighting";
    public static const ST_GHOST_FIGHT :String = "fighting";
    public static const ST_GHOST_REEL :String = "reel";
    public static const ST_GHOST_RETALIATE :String = "retaliate";
    public static const ST_GHOST_DEFEAT :String = "defeat_disappear";
    public static const ST_GHOST_TRIUMPH :String = "triumph_chase";

    public var hud :HUD;

    public function GamePanel ()
    {
        hud = new HUD();
        this.addChild(hud);

        new GameFrame(function (frame :GameFrame) :void {
            _frame = frame;
        });

        Game.control.player.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        Game.control.player.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, playerPropertyChanged);
        Game.control.player.addEventListener(
            AVRGamePlayerEvent.TASK_COMPLETED, taskCompleted);
        Game.control.player.addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);

        Game.control.room.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, roomPropertyChanged);

        //SKIN 
        if (Game.control.player.props.get(Codes.PROP_AVATAR_TYPE) == null) {
            trace("no avatar=we are new at the game");
            showSplash(SplashWidget.STATE_BEGIN);

        } else if (!Game.control.player.props.get(Codes.PROP_IS_PLAYING)) {
            showSplash(SplashWidget.STATE_BEGIN);
            trace("have avatar=we are NOT new at the game");

        } else {
            _seeking = true;
        }
        
//        if (Game.control.player.props.get(Codes.PROP_AVATAR_TYPE) == null) {
//            showSplash(SplashWidget.STATE_WELCOME);
//
//        } else if (!Game.control.player.props.get(Codes.PROP_IS_PLAYING)) {
//            showSplash(SplashWidget.STATE_BEGIN);
//
//        } else {
//            _seeking = true;
//        }
        
        
        checkForDeath();
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        for (var ii :int = 0; ii < this.numChildren; ii ++) {
            if (this.getChildAt(ii).hitTestPoint(x, y, shapeFlag)) {
                return true;
            }
        }
        return false;
    }

    public function get ghost () :Ghost
    {
        return _ghost;
    }

    public function get subPanel () :DisplayObject
    {
        return _panel;
    }

    public function get seeking () :Boolean
    {
        return _seeking;
    }

    public function set seeking (seeking :Boolean) :void
    {
        if (_seeking != seeking) {
            _seeking = seeking;
            _seeking = false;//SKIN
            updateState(true);
        }
    }

    public function showSplash (state :String) :void
    {
        if (_splash != null) {
            _splash.gotoState(state);
            return;
        }
        _splash = new SplashWidget(state);
        
        this.addChild(_splash);
//        _splash.gotoState( SplashWidget.STATE_BEGIN);
        _splash.x = 100;
        _splash.y = 0;

        // when we show a splash screen, turn off the seek mode
        seeking = false;
    }

    public function hideSplash () :void
    {
        this.removeChild(_splash);
        _splash = null;
    }

    public function unframeContent () :void
    {
        if (_frame != null && _frame.root != null) {
            _frame.frameContent(null);
            this.removeChild(_frame);
        }
    }

    public function frameContent (content :DisplayObject) :void
    {
        if (_frame == null) {
            log.warning("Can't frame content; frame clip not yet loaded.");
            return;
        }

        var paintable :Rectangle = Game.control.local.getPaintableArea(true);
        if (paintable == null) {
            log.warning("Can't frame content; we have no dimensions!");
            return;
        }

        _frame.frameContent(content);
        this.addChild(_frame);

        _frame.x = (paintable.width - 100 - _frame.width) / 2;
        _frame.y = (paintable.height - _frame.height) / 2 - FRAME_DISPLACEMENT_Y;
        _frame.x = 20;
        trace("paintable=" + paintable);
        trace("_frame.width=" + _frame.width);
        trace("_frame coords=" + _frame.x + ", " + _frame.y);
    }

    public function getClipClass () :Class
    {
        var id :String = GhostModel.getId();
        if (id != null) {
            var clip :Class = GHOST_CLIPS[id]
            if (clip != null) {
                return clip;
            }
            log.debug("Erk, cannot find clip", "id", id);
        }
        return null;
    }

    protected function newGhost () :void
    {
        _ghost = null;
        var clip :Class = getClipClass();
        if (clip != null) {
            // TODO: ghost positioning needs to be generalized
            new Ghost(clip, new Point(0, 0), function (g :Ghost) :void {
                _ghost = g;
                updateState(true);
            });
        }
    }

    protected function taskCompleted (evt :AVRGamePlayerEvent) :void
    {
        if (evt.name != Codes.TASK_GHOST_DEFEATED) {
            log.warning("Unknown task completed", "task", evt.name);
            return;
        }

        _triumph = new TriumphWidget(int(evt.value), function () :void {
            popdown(_triumph);
            _triumph = null;
        });
        popup(_triumph);
    }

    protected function checkForDeath () :void
    {
        if (!Game.amDead()) {
            if (_revive != null) {
                log.debug("Popping DOWN the revive widget!");
                popdown(_revive);
                _revive = null;
                updateState(false);
            }
            return;
        }

        if (_revive == null) {
            log.debug("Popping UP the revive widget!");
            _revive = new ReviveWidget();
            popup(_revive);
            updateState(false);
        }
    }

    protected function popup (clip :DisplayObject) :void
    {
        if (clip.parent != null) {
            log.warning("Popup candidate already has a parent", "popup", clip,
                        "parent", clip.parent);
            return;
        }
        this.addChild(clip);

        // TODO: center?
        clip.x = 50;
        clip.y = 50;

        updateState(false);
    }

    protected function popdown (clip :DisplayObject) :void
    {
        if (clip.parent != this) {
            log.warning("We're not displaying popdown candidate", "clip", clip);
            return;
        }
        this.removeChild(clip);

        updateState(false);
    }

    protected function messageReceived (evt: MessageReceivedEvent) :void
    {
        if (evt.name == Codes.SMSG_DEBUG_RESPONSE && evt.value == Codes.DBG_GIMME_PANEL) {
            if (_debugPanel != null) {
                this.removeChild(_debugPanel);
                _debugPanel = null;
                return;
            }
            _debugPanel = new DebugPanel();
            _debugPanel.x = _debugPanel.y = 20;
            this.addChild(_debugPanel);
        }
    }

    protected function playerPropertyChanged (evt :PropertyChangedEvent) :void
    {
        if (evt.name == Codes.PROP_MY_HEALTH) {
            checkForDeath();

        } else if (evt.name == Codes.PROP_AVATAR_TYPE) {
            // if we 
            if (_splash != null && _splash.state == SplashWidget.STATE_AVATARS) {
                _splash.gotoState(SplashWidget.STATE_BEGIN);
            }

        } else if (evt.name == Codes.PROP_IS_PLAYING) {
            if (Boolean(evt.newValue) && _splash != null &&
                _splash.state == SplashWidget.STATE_BEGIN) {
                hideSplash();
                _seeking = true;
                updateState(true);
            }
        }
    }

    protected function roomPropertyChanged (evt :PropertyChangedEvent) :void
    {
        if (evt.name == Codes.PROP_STATE) {
            updateState(false);

        } else if (evt.name == Codes.DICT_GHOST) {
            newGhost();
        }
    }

    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {
        newGhost();
    }

    protected function updateState (forced :Boolean) :void
    {
        var pClass :Class = null;

        if (_triumph == null && _revive == null) {
            switch(Game.state) {
            case Codes.STATE_SEEKING:
                if (_seeking == false) {
                    break;
                }
                // fall through
            case Codes.STATE_APPEARING:
                pClass = SeekPanel;
                break;
            case Codes.STATE_FIGHTING:
            case Codes.STATE_GHOST_TRIUMPH:
            case Codes.STATE_GHOST_DEFEAT:
                pClass = FightPanel;
                break;
            default:
                log.warning("Aii, updateState() doesn't know what to do", "state", Game.state);
                return;
            }
        }

        if (!forced && pClass != null && _panel is pClass) {
            return;
        }

        if (_panel != null) {
            unframeContent();
            this.removeChild(_panel);
            _panel = null;
        }
        if (pClass != null) {
            _panel = new pClass(_ghost);
            this.addChildAt(_panel, 0);
        }
    }

    protected var _seeking :Boolean;

    protected var _panel :DisplayObject;

    protected var _ghost :Ghost;

    protected var _frame :GameFrame;

    protected var _splash :SplashWidget;

    protected var _revive :ClipHandler;
    protected var _triumph :ClipHandler;

    protected var _debugPanel :DebugPanel;

    // maps ghost id to model
    protected static const GHOST_CLIPS :Object = {//SKIN
//      pinchy: Content.GHOST_PINCHER,
      mccain: Content.GHOST_MCCAIN,
      palin: Content.GHOST_PALIN,
      mutant: Content.GHOST_MUTANT
    };

    protected static const FRAME_DISPLACEMENT_Y :int = 20;

    protected static const log :Log = Log.getLog(GamePanel);
}
}
