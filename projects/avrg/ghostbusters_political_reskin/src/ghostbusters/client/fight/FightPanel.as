//
// $Id$

package ghostbusters.client.fight {

import com.threerings.flash.FrameSprite;
import com.threerings.util.ArrayUtil;
import com.threerings.util.CommandEvent;
import com.threerings.util.Log;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import ghostbusters.client.ClipHandler;
import ghostbusters.client.Dimness;
import ghostbusters.client.Game;
import ghostbusters.client.GameController;
import ghostbusters.client.Ghost;
import ghostbusters.data.Codes;

public class FightPanel extends FrameSprite
{
    public function FightPanel (ghost :Ghost)
    {
        graphics.clear();
        
        _ghost = ghost;

        _dimness = new Dimness(0.8, true);
        
        this.addChild(_dimness);

        this.addChild(_ghost);
        _ghost.mask = null;
        _ghost.x = 400;
        _ghost.y = 60;//100
        _ghost.visible = true

        // listen for notification messages from the server on the room control
        Game.control.room.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);

        Game.control.room.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, roomPropertyChanged);
        Game.control.player.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, playerPropertyChanged);

        _ghost.fighting();

        checkForSpecialStates();

        //SKIN
        if( _ghostDying) {
            return;
        }
        
        var clipClass :Class = Game.panel.getClipClass();
        if (clipClass == null) {
            log.debug("Urk, failed to find a ghost clip class");
            return;
        }
        var handler :ClipHandler;
        handler = new ClipHandler(ByteArray(new clipClass()), function () :void {
            var gameContext :MicrogameContext = new MicrogameContext();
            gameContext.ghostMovie = handler.clip;
            _player = new MicrogamePlayer(gameContext);
            maybeStartMinigame();
        });

        _playing = Boolean(Game.control.player.props.get(Codes.PROP_IS_PLAYING));
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return (_player && _player.hitTestPoint(x, y, shapeFlag)) ||
            _ghost.hitTestPoint(x, y, shapeFlag);
    }

    public function weaponUpdated () :void
    {
        if (_player == null){// || _selectedWeapon == Game.panel.hud.getWeaponType()) {
            var index :int = ArrayUtil.indexOf(WeaponType.WEAPONS, _player.weaponType.name);
            if( index == Game.panel.hud.getWeaponType())
            {
                log.debug("Weapon unchanged...");
                return;
            }
        }
        if (_player.currentGame != null) {
            log.debug("Cancelling current game...");
            _player.cancelCurrentGame();
        }
        log.debug("Starting new minigame.");
        maybeStartMinigame();
    }

    public function toggleGame () :void
    {
        if (_player == null) {
            // this is either a miracle of timing, or an irrecoverable error condition
            log.warning("No minigame container in toggleGame()");
            return;
        }

        if (_player.root == null) {
            maybeStartMinigame();

        } else {
            endMinigame();
        }
    }

    protected function maybeStartMinigame () :void
    {
        if (!_playing || Game.amDead()) {
            return;
        }

        if( _ghost != null) {
            _ghost.visible = true;
        }
        if (_player.root == null) {
            Game.panel.frameContent(_player);
        }
        
        //SKIN
        _ghostDying = false;
        
        _selectedWeapon = Game.panel.hud.getWeaponType();

        switch(_selectedWeapon) {
        case Codes.WPN_QUOTE:
            _player.weaponType = new WeaponType(WeaponType.NAME_QUOTE, 1);
            break;

        case Codes.WPN_IRAQ:
            _player.weaponType = new WeaponType(WeaponType.NAME_IRAQ, 2);
            break;

        case Codes.WPN_VOTE:
            _player.weaponType = new WeaponType(WeaponType.NAME_VOTE, 1);
            break;

        case Codes.WPN_PRESS:
            _player.weaponType = new WeaponType(WeaponType.NAME_PRESS, 0);
            break;
        default:
            log.warning("Eek, unknown weapon", "weapon", _selectedWeapon);
            return;
        }

        trace("starting a new minigame, type 3!!");
        _player.beginNextGame();
    }

    protected function endMinigame () :void
    {
        if (_player != null ){//&& _player.root != null) {
//            if (_player.currentGame != null) {
                
                _player.cancelCurrentGame();
                _player.shutdown();
                trace("cancelling minigame");
                Game.panel.unframeContent();
//            }
            
        }
        
    }

    override protected function handleAdded (... ignored) :void
    {
        if( _ghost != null) {
            _ghost.visible = true;
        }
        super.handleAdded();
        //_battleLoop = Sound(new Content.BATTLE_LOOP_AUDIO()).play();
    }

    override protected function handleRemoved (... ignored) :void
    {
        super.handleRemoved();
        //_battleLoop.stop();

        if (_player != null) {
            _player.shutdown();
        }
    }

    override protected function handleFrame (... ignored) :void
    {
        //SKIN white flash hackery
        if( _isWhite && getTimer() > _startTimeForWhiteFlash + _durationWhiteFlash) {
            _isWhite = false;
            graphics.clear();    
        }
        
        
        // TODO: when we have real teams, we have a fixed order of players, but for now we
        // TODO: just grab the first six in the order the client exports them
        
//        updateSpotlights();

        // if we've got the minigame player up, do some extra checks
        if (_player != null && _player.root != null && !_ghostDying) {
            if (_player.currentGame == null) {
                // if we've no current game, start a new one
                trace("starting a new minigame!!");
                _player.beginNextGame();

            } else if (_player.currentGame.isDone) {
                // else if we finished a game, announce it to the world & start the next one
                CommandEvent.dispatch(this, GameController.GHOST_ATTACKED,
                                      [ _selectedWeapon, _player.currentGame.gameResult ]);
                if (_player != null) {
                    trace("starting a new minigame, type 2!!");
                    _player.beginNextGame(true);
                }
            }
        }
    }

    protected function updateSpotlights () :void
    {
//        var team :Array = PlayerModel.getTeam(false);
//
//        // TODO: maintain our own list, calling this 30 times a second is rather silly
//        for (var ii :int = 0; ii < team.length; ii ++) {
//            var playerId :int = team[ii] as int;
//
//            var info :AVRGameAvatar = Game.control.room.getAvatarInfo(playerId);
//            if (info == null) {
//                log.warning("Can't get avatar info", "player", playerId);
//                continue;
//            }
//            var topLeft :Point = this.globalToLocal(info.bounds.topLeft);
//            var bottomRight :Point = this.globalToLocal(info.bounds.bottomRight);
//
//            var height :Number = bottomRight.y - topLeft.y;
//            var width :Number = bottomRight.x - topLeft.x;
//
//            var spotlight :Spotlight = _spotlights[playerId];
//            if (spotlight == null) {
//                spotlight = new Spotlight(playerId);
//                _spotlights[playerId] = spotlight;
//
//                _dimness.addChild(spotlight.hole);
//            }
//            spotlight.redraw(topLeft.x + width/2, topLeft.y + height/2, width, height);
//        }

        // TODO: remove spotlights when people leave
    }

    protected function messageReceived (event: MessageReceivedEvent) :void
    {
        if (event.name == Codes.SMSG_GHOST_ATTACKED) {
            //SKIN this is borked.
//            var bits :Array = (event.value as Array);
//            if (bits != null && bits[2] > 0) {
//                log.debug("showing ghost damage.  we should see a reel...");
                showGhostDamage();
//            }

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

        } else if (evt.name == Codes.PROP_IS_PLAYING) {
            _playing = Boolean(evt.newValue);
            maybeStartMinigame();
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
        _ghostDying = true;
        // cancel minigame
        trace("cancelling minigame, should expect no more updates.");
        endMinigame();

        _ghost.die();
        
        endMinigame();
    }

    protected function handleGhostTriumph () :void
    {
        log.debug("calling _ghost.triumph()");
        if( _player != null ) {
            _player.shutdown();
            _player.cancelCurrentGame();
        }
        log.debug("Should not be playing minigame code from now on");
        _ghost.triumph(whitenPanelOnDeath);
    }

    protected function whitenPanelOnDeath() :void
    {
        if( contains( _dimness )) {
            removeChild( _dimness);
        }
        _ghost.visible = false;
        graphics.beginFill(0xffffff);
        graphics.drawRect(-700, -500, 3000, 2000);//HACK, I want it to cover the entire screen
        graphics.endFill();
        
        _isWhite = true;
        _startTimeForWhiteFlash = getTimer();
        
        
    }
    
    protected function showGhostDamage () :void
    {
        _ghost.damaged();
    }

    //Some hackery for a flash of white after the ghost dies
    protected var _isWhite :Boolean = false;
    protected var _startTimeForWhiteFlash :int;
    protected var _durationWhiteFlash :int = 1000; 
    protected var _ghostDying :Boolean; //UTTER HACKERY, but why doesn't the minigame panel stop when the ghost dies?


    protected var _ghost :Ghost;

    protected var _dimness :Dimness;

    //protected var _battleLoop :SoundChannel;

    protected var _playing :Boolean;

    protected var _spotlights :Dictionary = new Dictionary();

    protected var _player: MicrogamePlayer;

    protected var _selectedWeapon :int;

    protected var _gameContext :MicrogameContext;

    protected static const log :Log = Log.getLog(FightPanel);
}
}
