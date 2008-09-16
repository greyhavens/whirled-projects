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
            AVRGamePlayerEvent.TASK_COMPLETED, taskCompleted);
        Game.control.player.addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);

        Game.control.room.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, roomPropertyChanged);

        checkForDeath();
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

    protected function taskCompleted (evt :AVRGamePlayerEvent) :void
    {
        if (evt.name != Codes.TASK_GHOST_DEFEATED) {
            Game.log.warning("Unknown task completed: " + evt.name);
            return;
        }

        popup(new TriumphWidget(int(evt.value), function (widget :TriumphWidget) :void {
            popdown(widget);
        }));
    }

    protected function checkForDeath () :void
    {
        var health :Object = Game.control.player.props.get(Codes.PROP_MY_HEALTH);
        if (health > 0) {
            if (_revive != null) {
                Game.log.debug("Popping UP the revive widget!");
                popdown(_revive);
            }
            return;
        }

        if (_revive == null) {
            Game.log.debug("Popping DOWN the revive widget!");
            _revive = new ReviveWidget();
            popup(_revive);
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

        // TODO: center?
        clip.x = 50;
        clip.y = 50;
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
