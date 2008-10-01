//
// $Id$

package ghostbusters.client.fight {

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.geom.Point;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.media.Sound;
import flash.media.SoundChannel;

import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

import com.threerings.flash.FrameSprite;
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.CommandEvent;
import com.threerings.util.Log;
import com.threerings.util.StringUtil;

import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import ghostbusters.client.ClipHandler;
import ghostbusters.client.Content;
import ghostbusters.client.Dimness;
import ghostbusters.client.Game;
import ghostbusters.client.GameController;
import ghostbusters.client.Ghost;
import ghostbusters.client.HUD;
import ghostbusters.client.util.PlayerModel;
import ghostbusters.data.Codes;

public class FightPanel extends FrameSprite
{
    public function FightPanel (ghost :Ghost)
    {
        _ghost = ghost;

        _dimness = new Dimness(0.8, true);
        this.addChild(_dimness);

        this.addChild(_ghost);
        _ghost.mask = null;
        _ghost.x = Game.panel.hud.getRightEdge() - _ghost.bounds.width/2;
        _ghost.y = 100;

        // listen for notification messages from the server on the room control
        Game.control.room.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);

        Game.control.room.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, roomPropertyChanged);
        Game.control.player.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, playerPropertyChanged);

        _ghost.fighting();

        checkForSpecialStates();

        var clipClass :Class = Game.panel.getClipClass();
        if (clipClass == null) {
            _log.debug("Urk, failed to find a ghost clip class");
            return;
        }
        var handler :ClipHandler;
        handler = new ClipHandler(ByteArray(new clipClass()), function () :void {
            var gameContext :MicrogameContext = new MicrogameContext();
            gameContext.ghostMovie = handler.clip;
            _player = new MicrogamePlayer(gameContext);
            startMinigame();
        });
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return (_player && _player.hitTestPoint(x, y, shapeFlag)) ||
            _ghost.hitTestPoint(x, y, shapeFlag);
    }

    public function weaponUpdated () :void
    {
        if (_player == null || _selectedWeapon == Game.panel.hud.getWeaponType()) {
            _log.debug("Weapon unchanged...");
            return;
        }
        if (_player.currentGame != null) {
            _log.debug("Cancelling current game...");
            _player.cancelCurrentGame();
        }
        _log.debug("Starting new minigame.");
        startMinigame();
    }

    public function toggleGame () :void
    {
        if (_player == null) {
            // this is either a miracle of timing, or an irrecoverable error condition
            _log.warning("No minigame container in toggleGame()");
            return;
        }

        if (_player.root == null) {
            startMinigame();

        } else {
            endMinigame();
        }
    }

    protected function startMinigame () :void
    {
        if (_player.root == null) {
            Game.panel.frameContent(_player);
        }

        _selectedWeapon = Game.panel.hud.getWeaponType();

        switch(_selectedWeapon) {
        case HUD.LOOT_LANTERN:
            _player.weaponType = new WeaponType(WeaponType.NAME_LANTERN, 1);
            break;

        case HUD.LOOT_BLASTER:
            _player.weaponType = new WeaponType(WeaponType.NAME_PLASMA, 2);
            break;

        case HUD.LOOT_OUIJA:
            _player.weaponType = new WeaponType(WeaponType.NAME_OUIJA, 1);
            break;

        case HUD.LOOT_POTIONS:
            _player.weaponType = new WeaponType(WeaponType.NAME_POTIONS, 0);
            break;
        default:
            _log.warning("Eek, unknown weapon: " + _selectedWeapon);
            return;
        }

        _player.beginNextGame();
    }

    protected function endMinigame () :void
    {
        if (_player.root != null) {
            if (_player.currentGame != null) {
                _player.cancelCurrentGame();
            }
            Game.panel.unframeContent();
        }
    }

    override protected function handleAdded (... ignored) :void
    {
        super.handleAdded();
        _battleLoop = Sound(new Content.BATTLE_LOOP_AUDIO()).play();
    }

    override protected function handleRemoved (... ignored) :void
    {
        super.handleRemoved();
        _battleLoop.stop();

        _player.shutdown();
    }

    override protected function handleFrame (... ignored) :void
    {
        // TODO: when we have real teams, we have a fixed order of players, but for now we
        // TODO: just grab the first six in the order the client exports them

        updateSpotlights();

        // if we've got the minigame player up, do some extra checks
        if (_player != null && _player.root != null) {
            if (_player.currentGame == null) {
                // if we've no current game, start a new one
                _player.beginNextGame();

            } else if (_player.currentGame.isDone) {
                // else if we finished a game, announce it to the world & start the next one
                CommandEvent.dispatch(this, GameController.GHOST_ATTACKED,
                                      _player.currentGame.gameResult);
                if (_player != null) {
                    _player.beginNextGame();
                }
            }
        }
    }

    protected function updateSpotlights () :void
    {
        var team :Array = PlayerModel.getTeam(false);

        // TODO: maintain our own list, calling this 30 times a second is rather silly
        for (var ii :int = 0; ii < team.length; ii ++) {
            var playerId :int = team[ii] as int;

            var info :AVRGameAvatar = Game.control.room.getAvatarInfo(playerId);
            if (info == null) {
                _log.warning("Can't get avatar info [player=" + playerId + "]");
                continue;
            }
            var topLeft :Point = this.globalToLocal(info.bounds.topLeft);
            var bottomRight :Point = this.globalToLocal(info.bounds.bottomRight);

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

    protected function messageReceived (event: MessageReceivedEvent) :void
    {
        if (event.name == Codes.SMSG_GHOST_ATTACKED) {
            var bits :Array = (event.value as Array);
            if (bits != null && bits[2] > 0) {
                showGhostDamage();
            }

        } else if (event.name == Codes.SMSG_PLAYER_ATTACKED) {
            _ghost.attack();

        }
    }

    protected function roomPropertyChanged (evt :PropertyChangedEvent) :void
    {
        if (evt.name == Codes.PROP_STATE) {
            checkForSpecialStates();
        }
    }

    protected function playerPropertyChanged (evt :PropertyChangedEvent) :void
    {
        if (evt.name == Codes.PROP_MY_HEALTH) {
            if (Game.amDead()) {
                // if we just died, cancel minigame
                endMinigame();
            }
        }
    }

    protected function checkForSpecialStates () :void
    {
        if (Game.state == Codes.STATE_GHOST_TRIUMPH) {
            handleGhostTriumph();

        } else if (Game.state == Codes.STATE_GHOST_DEFEAT) {
            showGhostDeath();
        }
    }

    protected function showGhostDeath () :void
    {
        // cancel minigame
        endMinigame();

        _ghost.die();
    }

    protected function handleGhostTriumph () :void
    {
        _ghost.triumph();
    }

    protected function showGhostDamage () :void
    {
        _ghost.damaged();
    }

    protected var _ghost :Ghost;

    protected var _dimness :Dimness;

    protected var _battleLoop :SoundChannel;

    protected var _spotlights :Dictionary = new Dictionary();

    protected var _player: MicrogamePlayer;

    protected var _selectedWeapon :int;

    protected var _gameContext :MicrogameContext;

    protected static const _log :Log = Log.getLog(FightPanel);
}
}
