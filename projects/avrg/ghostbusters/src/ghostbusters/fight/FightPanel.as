//
// $Id$

package ghostbusters.fight {

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.media.Sound;
import flash.media.SoundChannel;

import flash.utils.Dictionary;
import flash.utils.setTimeout;

import com.threerings.flash.FrameSprite;
import com.threerings.util.CommandEvent;
import com.whirled.AVRGameAvatar;
import com.whirled.MobControl;

import ghostbusters.Content;
import ghostbusters.Dimness;
import ghostbusters.Game;
import ghostbusters.fight.FightController;

public class FightPanel extends FrameSprite
{
    public function FightPanel (model :FightModel)
    {
        _model = model;

        buildUI();

        _frame = new GameFrame();
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return _minigame && _minigame.hitTestPoint(x, y, shapeFlag);
    }

    public function getGhostSprite (ctrl :MobControl) :SpawnedGhost
    {
        _ghost = new SpawnedGhost(ctrl, _model.getGhostHealth(), _model.getGhostMaxHealth());
//        setTimeout(startGame, 1000);
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

    override protected function handleAdded (... ignored) :void
    {
        super.handleAdded();
        _battleLoop = Sound(new Content.BATTLE_LOOP_AUDIO()).play();

//        Game.control.addEventListener(AVRGameControlEvent.PLAYER_CHANGED, playerChanged);
    }

    override protected function handleRemoved (... ignored) :void
    {
        super.handleRemoved();
        _battleLoop.stop();
//        Game.control.removeEventListener(AVRGameControlEvent.PLAYER_CHANGED, playerChanged);
    }

    protected function buildUI () :void
    {
        _dimness = new Dimness(0.8, true);
        this.addChild(_dimness);
    }

    override protected function handleFrame (... ignored) :void
    {
        // TODO: maintain our own list, calling this 30 times a second is rather silly
        var players :Array = Game.control.getPlayerIds();
        for (var ii :int = 0; ii < players.length; ii ++) {
            var playerId :int = players[ii] as int;

            var info :AVRGameAvatar = Game.control.getAvatarInfo(playerId);
            if (info == null) {
                Game.log.warning("Can't get avatar info [player=" + playerId + "]");
                continue;
            }
            var topLeft :Point = this.globalToLocal(info.stageBounds.topLeft);
            var bottomRight :Point = this.globalToLocal(info.stageBounds.bottomRight);

            var height :Number = bottomRight.y - topLeft.y;
            var width :Number = bottomRight.x - topLeft.x;

            var spotlight :Spotlight = _spotlights[playerId];
            if (spotlight == null) {
                // a new spotlight just appears, no splines involved
                spotlight = new Spotlight(playerId);
                _spotlights[playerId] = spotlight;

//                _maskLayer.addChild(spotlight.mask);
//                _lightLayer.addChild(spotlight.light);
                _dimness.addChild(spotlight.hole);
            }
            spotlight.redraw(topLeft.x + width/2, topLeft.y + height/2, width, height);
        }
    }

    protected function gamePerformance (score :Number, style :Number = 0) :void
    {
        CommandEvent.dispatch(this, FightController.GHOST_MELEE, score);
    }

    protected var _model :FightModel;

    protected var _ghost :SpawnedGhost;

    protected var _dimness :Dimness;

    protected var _battleLoop :SoundChannel;

    protected var _spotlights :Dictionary = new Dictionary();

    protected var _frame :GameFrame;
    protected var _minigame: DisplayObject;

    protected var _stars :Array = [];

    protected static const STARS :int = 400;
}
}
