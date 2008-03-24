//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.ByteArray;

import mx.controls.Button;
import mx.events.FlexEvent;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;
import com.whirled.MobControl;

import com.threerings.flash.AnimationManager;

import com.threerings.util.ArrayUtil;
import com.threerings.util.CommandEvent;

public class GamePanel extends Sprite
{
    public var hud :HUD;

    public function GamePanel ()
    {
        hud = new HUD();
        this.addChild(hud);

        _splash.addEventListener(MouseEvent.CLICK, handleClick);

        Game.control.state.addEventListener(
            AVRGameControlEvent.ROOM_PROPERTY_CHANGED, roomPropertyChanged);

        Game.control.addEventListener(AVRGameControlEvent.COINS_AWARDED, coinsAwarded);
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

    public function get seeking () :Boolean
    {
        return _seeking;
    }

    public function set seeking (seeking :Boolean) :void
    {
        _seeking = seeking;
        updateState();
    }

    public function reloadView () :void
    {
        hud.reloadView();
        updateState();
    }

    protected function coinsAwarded (evt :AVRGameControlEvent) :void
    {
        var panel :GamePanel = this;
        var flourish :CoinFlourish = new CoinFlourish(evt.value as int, function () :void {
            Game.log.debug("Stopping Flourish!");
            AnimationManager.stop(flourish);
            panel.removeChild(flourish);
        });
        flourish.x = (Game.stageSize.width - flourish.width) / 2;
        flourish.y = 20;
        this.addChild(flourish);
        AnimationManager.start(flourish);
        Game.log.debug("Added and started flourish: " + flourish);
    }

    protected function roomPropertyChanged (evt :AVRGameControlEvent) :void
    {
        if (evt.name == Codes.PROP_STATE) {
            _seeking = false;
            updateState();
        }
    }

    protected function updateState () :void
    {
        var avatarState :String = Codes.ST_PLAYER_DEFAULT;
        var fightPanel :Boolean = false;
        var seekPanel :Boolean = false;

        Game.log.debug("Main Panel entering state: " + Game.model.state);

        if (Game.model.state == GameModel.STATE_SEEKING) {
            if (_seeking) {
                avatarState = Codes.ST_PLAYER_FIGHT;
                seekPanel = true;

            } else {
                avatarState = Codes.ST_PLAYER_DEFAULT;
            }

        } else if (Game.model.state == GameModel.STATE_APPEARING) {
            seekPanel = true;

        } else if (Game.model.state == GameModel.STATE_FIGHTING) {
            fightPanel = true;
            avatarState = Codes.ST_PLAYER_FIGHT;

        } else if (Game.model.state == GameModel.STATE_GHOST_TRIUMPH ||
                   Game.model.state == GameModel.STATE_GHOST_DEFEAT) {
            fightPanel = true;
            // don't mess with the avatar's state here

        } else {
            Game.log.warning("Unknown state requested [state=" + Game.model.state + "]");
        }

        fixPanel(seekPanel, Game.seekController.panel);
        fixPanel(fightPanel, Game.fightController.panel);

        Game.gameController.setAvatarState(avatarState);
    }

    protected function fixPanel (show :Boolean, panel :DisplayObject) :void
    {
        if (show) {
            if (panel.parent != this) {
                this.addChildAt(panel, 0);
            }
        } else if (panel.parent == this) {
            this.removeChild(panel);
        }
    }

    protected function showHelp () :void
    {
        if (_box) {
            this.removeChild(_box);
        }
        var bits :TextBits = new TextBits("HELP HELP HELP HELP");
        bits.addButton("Whatever", true, function () :void {
            showSplash();
        });
        _box = new Box(bits);
        _box.x = 100;
        _box.y = 100;
        _box.scaleX = _box.scaleY = 0.5;
        this.addChild(_box);
    }

    protected function showSplash () :void
    {
        if (_box) {
            this.removeChild(_box);
        }
        _box = new Box(_splash);
        _box.x = 100;
        _box.y = 100;
        _box.scaleX = _box.scaleY = 0.5;
        this.addChild(_box);
    }

    protected function handleClick (evt :MouseEvent) :void
    {
        if (evt.target.name == "help") {
            CommandEvent.dispatch(this, GameController.HELP);

        } else if (evt.target.name == "playNow") {
            _box.hide();
            CommandEvent.dispatch(this, GameController.PLAY);
            hud.visible = true;

        } else {
            Game.log.debug("Clicked on: " + evt.target + "/" + (evt.target as DisplayObject).name);
        }
    }

    protected var _seeking :Boolean = false;
    protected var _box :Box;

    protected var _splash :MovieClip = MovieClip(new Content.SPLASH());
}
}
