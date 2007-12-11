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

import ghostbusters.fight.SpawnedGhost;
import ghostbusters.seek.SeekPanel;

public class GamePanel extends Sprite
{
    public function GamePanel (model :GameModel, seekPanel :SeekPanel)
    {
        _model = model;
        _seekPanel = seekPanel;

        _hud = new HUD();

        _splash.addEventListener(MouseEvent.CLICK, handleClick);
    }

    public function shutdown () :void
    {
        _hud.shutdown();
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        var hit :Boolean = false;

        if (_hud.parent != null) {
            hit ||= _hud.hitTestPoint(x, y, shapeFlag);
        }
        if (_box.parent != null) {
            hit ||= _box.hitTestPoint(x, y, shapeFlag);
        }

        return hit;
    }

    public function exportMobSprite (id :String, ctrl :MobControl) :DisplayObject
    {
        _ghost = new SpawnedGhost(ctrl);
        return _ghost;
    }

    public function enterState (state :String) :void
    {
        if (state == GameModel.STATE_IDLE) {
            showSplash();

        } else if (state == GameModel.STATE_SEEKING) {
            showPanels(_hud);

        } else if (state == GameModel.STATE_SEEKING) {
            showPanels(_seekPanel, _hud);

        } else if (state == GameModel.STATE_FIGHTING) {
            showPanels(_hud);
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

    protected var _splash :MovieClip = MovieClip(new SPLASH());

    protected var _seekPanel :SeekPanel;

    [Embed(source="../../rsrc/splash01.swf")]
    protected static const SPLASH :Class;
}
}
