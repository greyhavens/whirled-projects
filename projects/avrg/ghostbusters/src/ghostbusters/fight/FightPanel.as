//
// $Id$

package ghostbusters.fight {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.media.Sound;
import flash.media.SoundChannel;

import flash.utils.setTimeout;

import com.threerings.util.CommandEvent;
import com.whirled.MobControl;

import ghostbusters.Content;
import ghostbusters.Dimness;
import ghostbusters.fight.FightController;

public class FightPanel extends Sprite
{
    public function FightPanel (model :FightModel)
    {
        _model = model;

        buildUI();

        _frame = new GameFrame();

        this.addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        this.addEventListener(Event.REMOVED_FROM_STAGE, handleRemoved);
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return _minigame && _minigame.hitTestPoint(x, y, shapeFlag);
    }

    public function getGhostSprite (ctrl :MobControl) :SpawnedGhost
    {
        _ghost = new SpawnedGhost(ctrl, _model.getGhostHealth(), _model.getGhostMaxHealth());
        setTimeout(startGame, 1000);
        return _ghost;
    }

    public function ghostHealthUpdated () :void
    {
        if (_ghost) {
            _ghost.updateHealth(_model.getGhostHealth(), _model.getGhostMaxHealth());
        }
    }

    public function startGame () :void
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

    public function endFight () :void
    {
        if (_minigame != null) {
            _frame.frameContent(null);
            this.removeChild(_frame);
            _minigame = null;
        }
    }

    protected function handleAdded (evt :Event) :void
    {
        _battleLoop = Sound(new Content.BATTLE_LOOP_AUDIO()).play();
    }

    protected function handleRemoved (evt :Event) :void
    {
        _battleLoop.stop();
    }

    protected function buildUI () :void
    {
        _dimness = new Dimness(0.6, true);
        this.addChild(_dimness);
    }

    protected function gamePerformance (score :Number, style :Number = 0) :void
    {
        CommandEvent.dispatch(this, FightController.GHOST_MELEE, score);
    }

    protected var _model :FightModel;

    protected var _ghost :SpawnedGhost;

    protected var _dimness :Sprite;

    protected var _battleLoop :SoundChannel;

    protected var _frame :GameFrame;
    protected var _minigame: DisplayObject;

}
}
