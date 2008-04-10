//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.ByteArray;

import mx.controls.Button;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.flash.AnimationManager;
import com.threerings.flash.DisplayUtil;

import com.threerings.util.ArrayUtil;
import com.threerings.util.CommandEvent;

import ghostbusters.fight.FightPanel;
import ghostbusters.seek.SeekPanel;

public class GamePanel extends Sprite
{
    public var hud :HUD;

    public function GamePanel ()
    {
        hud = new HUD();
        this.addChild(hud);

        new GameFrame(function (frame :GameFrame) :void {
            _frame = frame;
        });

        Game.control.state.addEventListener(
            AVRGameControlEvent.ROOM_PROPERTY_CHANGED, roomPropertyChanged);

        Game.control.addEventListener(AVRGameControlEvent.COINS_AWARDED, coinsAwarded);

        _ppp = new PerPlayerProperties(handlePlayerPropertyUpdate);

        var panel :GamePanel = this;
        new ClipHandler(ByteArray(new Content.PLAYER_DIED()), function (clip :MovieClip) :void {
            _revivePopup = clip;
            _revivePopup.x = 100;
            _revivePopup.y = 200;

            var button :SimpleButton =
                SimpleButton(DisplayUtil.findInHierarchy(clip, "revivebutton"));
            if (button == null) {
                Game.log.debug("Urk, cannot find revivebutton...");
                return;
            }
            button.addEventListener(MouseEvent.CLICK, function (event :Event) :void {
                CommandEvent.dispatch(panel, GameController.REVIVE);
            });

            checkPlayerHealth();
        });

        new ClipHandler(ByteArray(new Content.GHOST_DEFEATED()), function (clip :MovieClip) :void {
            _ghostDefeated = clip;
            _ghostDefeated.x = 300;
            _ghostDefeated.y = 200;

            var button :SimpleButton =
                SimpleButton(DisplayUtil.findInHierarchy(clip, "continuebutton"));
            if (button == null) {
                Game.log.debug("Urk, cannot find continuebutton...");
                return;
            }
            button.addEventListener(MouseEvent.CLICK, function (event :Event) :void {
                popdown(_ghostDefeated);
            });

        });
    }

    public function shutdown () :void
    {
        hud.shutdown();
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
        _seeking = seeking;
        updateState();
    }

    public function unframeContent () :void
    {
        _frame.frameContent(null);
        this.removeChild(_frame);
    }

    public function frameContent (content :DisplayObject) :void
    {
        _frame.frameContent(content);

        this.addChild(_frame);

        _frame.x = (Game.stageSize.width - 100 - _frame.width) / 2;
        _frame.y = (Game.stageSize.height - _frame.height) / 2 - FRAME_DISPLACEMENT_Y;
    }

    public function reloadView () :void
    {
        hud.reloadView();
        checkPlayerHealth();
    }

    public function getClipClass () :Class
    {
        var data: Object = Game.model.ghostId;
        if (data != null) {
            var clip :Class = GHOST_CLIPS[data.id];
            if (clip != null) {
                return clip;
            }
            Game.log.debug("Erk, cannot find clip for ghostId=" + data);
        }
        return null;
    }

    public function newGhost () :void
    {
        hud.newGhost();

        _ghost = null;
        var clip :Class = getClipClass();
        if (clip != null) {
            new Ghost(clip, function (g :Ghost) :void {
                _ghost = g;
                updateState();
            });
        }
    }

    protected function coinsAwarded (evt :AVRGameControlEvent) :void
    {
        var panel :GamePanel = this;
        var flourish :CoinFlourish = new CoinFlourish(evt.value as int, function () :void {
            AnimationManager.stop(flourish);
            panel.removeChild(flourish);
        });

        flourish.x = (Game.stageSize.width - flourish.width) / 2;
        flourish.y = 20;
        this.addChild(flourish);

        AnimationManager.start(flourish);
    }

    protected function handlePlayerPropertyUpdate (playerId :int, name :String, value :Object) :void
    {
        if (name == Codes.PROP_PLAYER_CUR_HEALTH) {
            if (playerId == Game.ourPlayerId) {
                checkPlayerHealth();
                updateAvatarState();
            }
        }
    }

    public function updateAvatarState () :void
    {
        var avatarState :String;

        if (Game.model.isPlayerDead(Game.ourPlayerId)) {
            avatarState = Codes.ST_PLAYER_DEFEAT;

        } else if (Game.model.state == GameModel.STATE_SEEKING ||
                   Game.model.state == GameModel.STATE_APPEARING) {
                avatarState = Codes.ST_PLAYER_DEFAULT;

        } else {
            avatarState = Codes.ST_PLAYER_FIGHT;

        }

        Game.setAvatarState(avatarState);
    }

    protected function checkPlayerHealth () :void
    {
        if (_revivePopup == null) {
            // still loading; there will be another callback when it's done
            return;
        }

        if (!Game.model.isPlayerDead(Game.ourPlayerId)) {
            // possibly we were just revived, let's see
            if (_revivePopup.parent == this) {
                this.removeChild(_revivePopup);
            }
            // we're not dead
            return;
        }
        Game.log.debug("We seem to be quite dead.");
        popup(_revivePopup);
    }

    protected function popup (clip :MovieClip) :void
    {
        if (clip.parent != null) {
            Game.log.warning("Popup candidate already has a parent [popup=" + clip + "]");
            return;
        }
        this.addChild(clip);
    }

    protected function popdown (clip :MovieClip) :void
    {
        if (clip.parent != null) {
            Game.log.warning("Popup candidate already has a parent [popup=" + clip + "]");
            return;
        }
        this.addChild(clip);
    }

    protected function roomPropertyChanged (evt :AVRGameControlEvent) :void
    {
        if (evt.name == Codes.PROP_STATE) {
            _seeking = false;
            updateState();

            if (evt.value == GameModel.STATE_GHOST_TRIUMPH) {
                popup(_ghostDefeated);
            }

        } else if (evt.name == Codes.PROP_GHOST_ID) {
            newGhost();
        }
    }

    protected function updateState () :void
    {
        var seekPanel :Boolean =
            ((Game.model.state == GameModel.STATE_SEEKING && _seeking) ||
             Game.model.state == GameModel.STATE_APPEARING);

        var fightPanel :Boolean =
            (Game.model.state == GameModel.STATE_FIGHTING ||
             Game.model.state == GameModel.STATE_GHOST_TRIUMPH ||
             Game.model.state == GameModel.STATE_GHOST_DEFEAT);

        setPanel(seekPanel ? SeekPanel : (fightPanel ? FightPanel : null));

        updateAvatarState();
    }

    protected function setPanel (pClass :Class) :void
    {
        if (pClass != null && _panel is pClass) {
            return;
        }
        if (_panel != null) {
            this.removeChild(_panel);
            _panel = null;
        }
        if (pClass != null) {
            _panel = new pClass(_ghost);
            this.addChildAt(_panel, 0);
        }
    }

    protected var _ppp :PerPlayerProperties;

    protected var _seeking :Boolean = false;

    protected var _panel :DisplayObject;

    protected var _ghost :Ghost;

    protected var _frame :GameFrame;

    protected var _revivePopup :MovieClip;

    protected var _ghostDefeated :MovieClip;

    // maps ghost id to model
    protected static const GHOST_CLIPS :Object = {
      pinchy: Content.GHOST_PINCHER,
      duchess: Content.GHOST_DUCHESS,
      widow: Content.GHOST_WIDOW,
      demon: Content.GHOST_DEMON
    };

    protected static const FRAME_DISPLACEMENT_Y :int = 20;
}
}
