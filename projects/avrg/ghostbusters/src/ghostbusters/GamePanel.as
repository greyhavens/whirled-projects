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

import com.threerings.util.CommandEvent;
import com.threerings.util.EmbeddedSwfLoader;

import ghostbusters.fight.GameFrame;
import ghostbusters.fight.SpawnedGhost;
import ghostbusters.seek.SeekPanel;

import ghostbusters.fight.Match3;

public class GamePanel extends Sprite
{
    public function GamePanel (model :GameModel, seekPanel :SeekPanel)
    {
        _model = model;
        _seekPanel = seekPanel;

        _hud = new HUD();

        _frame = new GameFrame();

        _splash.addEventListener(MouseEvent.CLICK, handleClick);
    }

    public function shutdown () :void
    {
        _hud.shutdown();
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

    public function exportMobSprite (id :String, ctrl :MobControl) :DisplayObject
    {
        _ghost = new SpawnedGhost(ctrl);
        _ghost.addEventListener(MouseEvent.CLICK, handleGhostClick);
        return _ghost;
    }

    protected function handleGhostClick (evt :MouseEvent) :void
    {
        if (_minigame == null) {
            var gameHolder :Sprite = new Sprite();

            _minigame = new Match3(gamePerformance);
            gameHolder.addChild(_minigame);

            _frame.frameContent(gameHolder);

            this.addChild(_frame);
            _frame.x = 100;
            _frame.y = 350;
        }
    }

    protected function gamePerformance (score :Number, style :Number = 0) :void
    {
        CommandEvent.dispatch(this, GameController.GHOST_MELEE, score);
    }

    public function enterState (state :String) :void
    {
        if (_model.getState() == GameModel.STATE_FIGHTING && state != GameModel.STATE_FIGHTING) {
            if (_minigame != null) {
                _frame.frameContent(null);
                this.removeChild(_frame);
                _minigame = null;
            }
        }

        if (state == GameModel.STATE_INTRO) {
            showSplash();

        } else if (state == GameModel.STATE_IDLE) {
            showPanels(_hud);

        } else if (state == GameModel.STATE_SEEKING) {
            showPanels(_seekPanel, _hud);

        } else if (state == GameModel.STATE_FIGHTING) {
            showPanels(_hud);

        } else {
            Game.log.warning("Unknown state requested [state=" + state + "]");
        }
    }

    public function ghostHealthUpdated (health :Number) :void
    {
        _ghost.updateHealth(health);
    }

    protected function showPanels (... panels) :void
    {
        while (this.numChildren > 0) {
            this.removeChildAt(0);
        }
        for (var ii :int = 0; ii < panels.length; ii ++) {
            this.addChild(panels[ii]);
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
        _box.show();
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
        _box.show();
    }

    protected function handleClick (evt :MouseEvent) :void
    {
        if (evt.target.name == "close") {
            _box.hide();
            // TODO: only do this when box finishes hiding
            CommandEvent.dispatch(this, GameController.END_GAME);
//            _control.deactivateGame();

        } else if (evt.target.name == "help") {
            CommandEvent.dispatch(this, GameController.HELP);

        } else if (evt.target.name == "playnow") {
            _box.hide();
            CommandEvent.dispatch(this, GameController.PLAY);
            _hud.visible = true;

        } else {
            Game.log.debug("Clicked on: " + evt.target + "/" + (evt.target as DisplayObject).name);
        }
    }

    protected var _model :GameModel;

    protected var _hud :HUD;
    protected var _box :Box;

    protected var _ghost :SpawnedGhost;

    protected var _splash :MovieClip = MovieClip(new Content.SPLASH());

    protected var _frame :GameFrame;
    protected var _minigame: DisplayObject;

    protected var _seekPanel :SeekPanel;
}
}
