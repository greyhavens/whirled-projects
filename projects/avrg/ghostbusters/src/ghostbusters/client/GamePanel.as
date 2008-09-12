//
// $Id$

package ghostbusters.client {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.ByteArray;
import flash.utils.setTimeout;

import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.net.PropertyChangedEvent;

import com.threerings.flash.AnimationManager;
import com.threerings.flash.DisplayUtil;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Command;

import ghostbusters.client.fight.FightPanel;
import ghostbusters.data.Codes;
import ghostbusters.client.util.GhostModel;
import ghostbusters.client.seek.SeekPanel;

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

        Game.control.player.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, playerPropertyChanged);
        Game.control.player.addEventListener(
            AVRGamePlayerEvent.COINS_AWARDED, coinsAwarded);
        Game.control.player.addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);

        Game.control.room.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, roomPropertyChanged);

        _revive = new ClipHandler(ByteArray(new Content.PLAYER_DIED()), function () :void {
            Game.log.debug("revive bounds: " + _revive.getBounds(_revive));
            _revive.x = 100;
            _revive.y = 200;

            setTimeout(function () :void {
                var button :SimpleButton =
                    SimpleButton(DisplayUtil.findInHierarchy(_revive, "revivebutton"));
                if (button == null) {
                    Game.log.debug("Urk, cannot find revivebutton...");
//                    return;
                }
                // TODO: when Bill fixes the art, change 'clip' to 'button'
                Command.bind(_revive, MouseEvent.CLICK, GameController.REVIVE);
                checkForDeath();
            }, 1);
        });

        _triumph = new ClipHandler(ByteArray(new Content.GHOST_DEFEATED()), function () :void {
            _triumph.x = 300;
            _triumph.y = 200;

            var button :SimpleButton =
                SimpleButton(DisplayUtil.findInHierarchy(_triumph, "continuebutton"));
            if (button == null) {
                Game.log.debug("Urk, cannot find continuebutton...");
//                return;
            }
            // TODO: when Bill fixes the art, change 'clip' to 'button'
            _triumph.addEventListener(MouseEvent.CLICK, function (event :Event) :void {
                popdown(_triumph);
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
        if (_frame != null) {
            _frame.frameContent(null);
            this.removeChild(_frame);
        }
    }

    public function frameContent (content :DisplayObject) :void
    {
        if (_frame == null) {
            Game.log.warning("Can't frame content; frame clip not yet loaded.");
            return;
        }
        _frame.frameContent(content);

        this.addChild(_frame);

        _frame.x = (Game.stageSize.width - 100 - _frame.width) / 2;
        _frame.y = (Game.stageSize.height - _frame.height) / 2 - FRAME_DISPLACEMENT_Y;
    }

    public function reloadView () :void
    {
        hud.reloadView();

        // TODO: is this really needed?
        checkForDeath();
    }

    public function getClipClass () :Class
    {
        var id :String = GhostModel.getId();
        if (id != null) {
            var clip :Class = GHOST_CLIPS[id]
            if (clip != null) {
                return clip;
            }
            Game.log.debug("Erk, cannot find clip for id=" + id);
        }
        return null;
    }

    protected function newGhost () :void
    {
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

    protected function checkForDeath () :void
    {
        if (_revive.clip == null) {
            Game.log.debug("Revival popup still loading; there will be another callback");
            return;
        }

        var health :Object = Game.control.player.props.get(Codes.PROP_MY_HEALTH);
        if (health > 0) {
            Game.log.debug("We're alive [health=" + health + "]");
            // possibly we were just revived, let's see
            if (_revive.parent == this) {
                this.removeChild(_revive);
            }
            // we're not dead
        } else if (health === 0) {
           Game.log.debug("We're dead!!"); 
            popup(_revive);
        } else {
            Game.log.debug("We're neither dead nor alive. Scary.");
        }
    }

    protected function popup (clip :DisplayObject) :void
    {
        if (clip.parent != null) {
            Game.log.warning("Popup candidate already has a parent [popup=" + clip +
                             ", parent=" + clip.parent + "]");
            return;
        }
        this.addChild(clip);
    }

    protected function popdown (clip :DisplayObject) :void
    {
        if (clip.parent != this) {
            Game.log.warning("We're not displaying popdown candidate [clip=" + clip + "]");
            return;
        }
        this.removeChild(clip);
    }

    protected function playerPropertyChanged (evt :PropertyChangedEvent) :void
    {
        if (evt.name == Codes.PROP_MY_HEALTH) {
            checkForDeath();
        }
    }

    protected function roomPropertyChanged (evt :PropertyChangedEvent) :void
    {
        if (evt.name == Codes.PROP_STATE) {
            _seeking = false;
            updateState();

            if (evt.newValue == Codes.STATE_GHOST_DEFEAT) {
                popup(_triumph);
            }

        } else if (evt.name == Codes.DICT_GHOST) {
            newGhost();
        }
    }

    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {
        _seeking = false;
        newGhost();
    }

    protected function updateState () :void
    {
        var seekPanel :Boolean =
            ((Game.state == Codes.STATE_SEEKING && _seeking) ||
              Game.state == Codes.STATE_APPEARING);

        var fightPanel :Boolean =
            (Game.state == Codes.STATE_FIGHTING ||
             Game.state == Codes.STATE_GHOST_TRIUMPH ||
             Game.state == Codes.STATE_GHOST_DEFEAT);

        setPanel(seekPanel ? SeekPanel : (fightPanel ? FightPanel : null));
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

    protected var _seeking :Boolean = false;

    protected var _panel :DisplayObject;

    protected var _ghost :Ghost;

    protected var _frame :GameFrame;

    protected var _revive :ClipHandler;

    protected var _triumph :ClipHandler

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
