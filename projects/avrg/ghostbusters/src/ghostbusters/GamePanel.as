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

public class GamePanel extends Sprite
{
    public function GamePanel (model :GameModel)
    {
        _model = model;

        _splash.addEventListener(MouseEvent.CLICK, handleClick);

        _hud = new HUD();
        _hud.visible = false;
        this.addChild(_hud);

        this.addEventListener(Event.ADDED_TO_STAGE, handleAdded);
    }

    public function shutdown () :void
    {
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        if (_hud.visible) {
            var hit :Boolean = _hud.hitTestPoint(x, y, shapeFlag);
            return hit;
        }
        return _box && _box.hitTestPoint(x, y, shapeFlag);
    }

    public function exportMobSprite (id :String, ctrl :MobControl) :DisplayObject
    {
        _ghost = new SpawnedGhost(ctrl);
        return _ghost;
    }

    public function enterState (state :String) :void
    {
        if (state == GameModel.STATE_SEEKING) {
            // TODO: somehow we need to have received a reference to SeekPanel here
        }
    }

    public function ghostHealthUpdated (health :Number) :void
    {
        _ghost.updateHealth(health);
    }

    protected function handleAdded (evt :Event) :void
    {
        showSplash();
    }

    protected function handleUnload (event :Event) :void
    {
        _hud.shutdown();
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

    [Embed(source="../../rsrc/splash01.swf")]
    protected static const SPLASH :Class;
}
}
