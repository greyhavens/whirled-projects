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
import com.threerings.util.ArrayUtil;
import com.threerings.util.CommandEvent;

import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControlEvent;
import com.whirled.MobControl;

import ghostbusters.Codes;
import ghostbusters.Content;
import ghostbusters.Dimness;
import ghostbusters.Game;
import ghostbusters.GameController;
import ghostbusters.HUD;

public class FightPanel extends FrameSprite
{
    public function FightPanel ()
    {
        buildUI();

        _frame = new GameFrame();

        Game.control.state.addEventListener(
            AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);

        Game.control.state.addEventListener(
            AVRGameControlEvent.ROOM_PROPERTY_CHANGED, roomPropertyChanged);
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return (_minigame && _minigame.hitTestPoint(x, y, shapeFlag)) ||
            (_ghost && _ghost.hitTestPoint(x, y, shapeFlag));
    }

    public function startGame () :void
    {
        if (_minigame == null) {
            _minigame = new MicrogamePlayer( { } );
            _frame.frameContent(_minigame);

            this.addChild(_frame);
            _frame.x = (Game.stageSize.width - 100 - _frame.width) / 2;
            _frame.y = (Game.stageSize.height - _frame.height) / 2 - FRAME_DISPLACEMENT_Y;
        }

        var selectedWeapon :int = Game.gameController.panel.hud.getWeaponType();

        if (selectedWeapon == HUD.LOOT_LANTERN) {
            _minigame.weaponType = new WeaponType(WeaponType.NAME_LANTERN, 1);

        } else if (selectedWeapon == HUD.LOOT_BLASTER) {
            _minigame.weaponType = new WeaponType(WeaponType.NAME_PLASMA, 2);

        } else if (selectedWeapon == HUD.LOOT_OUIJA) {
            _minigame.weaponType = new WeaponType(WeaponType.NAME_OUIJA, 1);

        } else if (selectedWeapon == HUD.LOOT_POTIONS) {
            _minigame.weaponType = new WeaponType(WeaponType.NAME_POTIONS, 0);

        } else {
            Game.log.warning("Eek, unknown weapon: " + selectedWeapon);
            return;
        }

        _minigame.beginNextGame();
    }

    public function endFight () :void
    {
        if (_minigame != null) {
            _frame.frameContent(null);
            this.removeChild(_frame);
            _minigame = null;
        }
    }

    public function showGhostDeath () :void
    {
        // cancel minigame
        endFight();

        var panel :DisplayObject = this;
        _ghost.die(function () :void {
            CommandEvent.dispatch(panel, GameController.END_FIGHT);
        });
    }

    public function showPlayerDeath (playerId :int) :void
    {
        // at the moment, there is no visible effect other than the avatar state change
        if (playerId == Game.ourPlayerId) {
            Game.gameController.setAvatarState("Defeat");

            // cancel minigame
            endFight();
        }
    }

    public function showGhostTriumph () :void
    {
        if (_ghost != null && _ghost.parent != null) {
            var panel :DisplayObject = this;
            _ghost.triumph(function () :void {
                CommandEvent.dispatch(panel, GameController.END_FIGHT);
            });
        }
    }

    public function showGhostDamage () :void
    {
        if (_ghost != null && _ghost.parent != null) {
            _ghost.damaged();
        }
    }

    public function showGhostAttack (playerId :int) :void
    {
        if (_ghost != null && _ghost.parent != null) {
            _ghost.attack();
        }
        if (playerId == Game.ourPlayerId) {
            Game.gameController.setAvatarState("Reel");
        }
    }

    public function newRoom () :void
    {
        _battleLoop = Sound(new Content.BATTLE_LOOP_AUDIO()).play();
        maybeNewGhost();
    }

    override protected function handleAdded (... ignored) :void
    {
        super.handleAdded();
//        Game.control.addEventListener(AVRGameControlEvent.PLAYER_CHANGED, playerChanged);
    }

    override protected function handleRemoved (... ignored) :void
    {
        super.handleRemoved();
        if (_ghost != null) {
            _ghost.handler.stop();
        }
        _battleLoop.stop();
//        Game.control.removeEventListener(AVRGameControlEvent.PLAYER_CHANGED, playerChanged);
    }

    protected function buildUI () :void
    {
        _dimness = new Dimness(0.8, true);
        this.addChild(_dimness);
    }

    protected var counter :int;

    override protected function handleFrame (... ignored) :void
    {
        // TODO: when we have real teams, we have a fixed order of players, but for now we
        // TODO: just grab the first six in the order the client exports them

        if (--counter < 0) {
            counter = Game.FRAMES_PER_REPORT;
            Game.log.debug("Frame handler running: " + this);
        }

        updateSpotlights(Game.getTeam());

        if (_minigame != null) {
            if (_minigame.currentGame == null) {
                _minigame.beginNextGame();

            } else if (_minigame.currentGame.isDone) {
                if (_minigame.currentGame.gameResult.success == MicrogameResult.SUCCESS) {
                    CommandEvent.dispatch(this, FightController.GHOST_ATTACKED,
                                          _minigame.currentGame.gameResult);
                }
                if (_minigame != null) {
                    _minigame.beginNextGame();
                }
            }
        }
    }

    protected function updateSpotlights (team :Array) :void
    {
        // TODO: maintain our own list, calling this 30 times a second is rather silly
        for (var ii :int = 0; ii < team.length; ii ++) {
            var playerId :int = team[ii] as int;

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
                spotlight = new Spotlight(playerId);
                _spotlights[playerId] = spotlight;

                _dimness.addChild(spotlight.hole);
            }
            spotlight.redraw(topLeft.x + width/2, topLeft.y + height/2, width, height);
        }

        // TODO: remove spotlights when people leave
    }

    protected function maybeNewGhost () :void
    {
        if (_ghost != null) {
            this.removeChild(_ghost);
            _ghost = null;
        }
        if (Game.model.ghostId != null) {
            _ghost = new SpawnedGhost();
            _ghost.x = Game.stageSize.width - 250;
            _ghost.y = 100;
            this.addChild(_ghost);
            _ghost.fighting();        
        }
    }

    protected function messageReceived (event: AVRGameControlEvent) :void
    {
        if (event.name == Codes.MSG_GHOST_ATTACKED) {
            showGhostDamage();

        } else if (event.name == Codes.MSG_PLAYER_ATTACKED) {
            showGhostAttack(event.value as int);

        } else if (event.name == Codes.MSG_GHOST_DEATH) {
            showGhostDeath();

        } else if (event.name == Codes.MSG_GHOST_TRIUMPH) {
            showGhostTriumph();

        } else if (event.name == Codes.MSG_PLAYER_DEATH) {
            showPlayerDeath(event.value as int);
        }
    }

    protected function roomPropertyChanged (evt :AVRGameControlEvent) :void
    {
        if (evt.name == Codes.PROP_GHOST_ID) {
            maybeNewGhost();
        }
    }

    protected var _ghost :SpawnedGhost;

    protected var _dimness :Dimness;

    protected var _battleLoop :SoundChannel;

    protected var _spotlights :Dictionary = new Dictionary();

    protected var _frame :GameFrame;
    protected var _minigame: MicrogamePlayer;

    protected static const FRAME_DISPLACEMENT_Y :int = 20;
}
}
