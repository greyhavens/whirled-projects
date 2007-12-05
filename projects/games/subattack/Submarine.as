package {

import flash.display.MovieClip;

import flash.filters.BitmapFilter;
import flash.filters.GlowFilter;

import flash.media.Sound;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import com.threerings.util.Log;

import com.threerings.flash.FilterUtil;

import com.whirled.WhirledGameControl;

public class Submarine extends BaseSprite
{
    /** The amount we shift hue for each truck. */
    //public static const SHIFTS :Array = [ 40, -80, 120, -160 -40, 80, -120, 160 ];
    public static const SHIFTS :Array = [ -136, 21, -106, 77, -38, 143, 0, 180 ];

    /** How often can we build? */
    public static const TICKS_PER_BUILD :int = 50; // about every 5 seconds

    public function Submarine (
        playerId :int, playerIdx :int, playerName :String, startx :int, starty :int,
        board :Board, gameCtrl :WhirledGameControl)
    {
        super(playerIdx, board);

        _gameCtrl = gameCtrl;

        _isMe = (_gameCtrl.getMyId() == playerId);
        _playerId = playerId;
        _playerName = playerName;
        _x = startx;
        _y = starty;
        _orient = (_x == 0) ? Action.RIGHT : Action.LEFT;

        configureVisual(playerIdx, playerName);

        if (_isMe && !(this is GhostSubmarine)) {
            _ghost = new GhostSubmarine(playerId, playerIdx, playerName, startx, starty,
                board, gameCtrl);
            _ghostActions = [];
        }

        updateVisual();
        updateLocation();
    }

    public function getGhost () :GhostSubmarine
    {
        return _ghost;
    }

    public function canQueueActions () :Boolean
    {
        // don't let us get more than 10 actions behind
        return (_futureActions.length < 20); // since there are 2 values stored for each action
    }

    public function queueAction (now :Number, action :int) :void
    {
        _futureActions.push(now, action);

        if (_ghost != null) {
            // and apply them immediately
            _ghost.queueAction(now, action);
        }
    }

    public function getHueShift () :BitmapFilter
    {
        return _hueShift;
    }

    public function getPlayerId () :int
    {
        return _playerId;
    }

    public function getPlayerName () :String
    {
        return _playerName;
    }

    public function getKills () :int
    {
        return _kills;
    }

    public function getDeaths () :int
    {
        return _deaths;
    }

    /**
     * Is this sub dead?
     */
    public function isDead () :Boolean
    {
        return _dead;
    }

    public function gotPlayerCookie (cookie :Object) :void
    {
        var array :Array = (cookie as Array);
        if (array != null) {
            _totalKills += int(array[0]);
            _totalDeaths += int(array[1]);
            updateVisual();
        }
    }

    public function getNewCookie () :Object
    {
        return [ _totalKills, _totalDeaths ];
    }

    /**
     * Called to respawn this sub at the coordinates specified.
     */
    public function respawn (xx :int, yy :int) :void
    {
        if (_dead) {
            _dead = false;
            _x = xx;
            _y = yy;
            updateDeath();
            updateLocation();
            updateVisual();

            if (_ghost != null) {
                _ghost.respawn(xx, yy);
            }
        }
    }

    /**
     * Perform the action specified, or return false if unable.
     */
    public function performAction (action :int) :Boolean
    {
        _queuedActions.push(action);
        return true;
    }

    /**
     * Set up the visual of this submarine.
     */
    protected function configureVisual (playerIdx :int, playerName :String) :void
    {
        _hueShift = FilterUtil.createHueShift(SHIFTS[playerIdx]);

        _avatar = MovieClip(new AVATAR());
        //_shootSound = Sound(new SHOOT_SOUND());
        if (_isMe) {
            _cantShootSound = Sound(new CANT_SHOOT_SOUND());
        }

        _avatar.filters = [ _hueShift ];
        addChild(_avatar);

        _nameLabel = new TextField();
        var tf :TextFormat = new TextFormat();
        tf.size = 16;
        tf.bold = true;
        _nameLabel.defaultTextFormat = tf;
        _nameLabel.autoSize = TextFieldAutoSize.CENTER;
        _nameLabel.selectable = false;
        _nameLabel.text = playerName;
        _nameLabel.textColor = 0x000000;
        _nameLabel.filters = [ new GlowFilter(0xFFFFFF, 1, 2, 2, 255) ];
        // center the label above us
        _nameLabel.y = -1 * (_nameLabel.textHeight + NAME_PADDING);
        _nameLabel.x = (SeaDisplay.TILE_SIZE - _nameLabel.textWidth) / 2;
        addChild(_nameLabel);
    }

    protected static const OK :int = 0;
    protected static const CANT :int = 1;
    protected static const DROP :int = 2;

    protected function performActionInternal (action :int) :int
    {
        if (_dead || action == Action.RESPAWN) {
            if (_dead && action == Action.RESPAWN) {
                _board.respawn(this);
                return OK;
            }
            return DROP;
        }

        if (_movedOrShot) {
            return CANT;
        }

        if (action == Action.BUILD) {
            if (_tickCanBuild > _tickCount) {
                return DROP;
            }
            _movedOrShot = true;
            if (++_buildingStep == 3) {
                _board.buildBarrier(_playerIdx, _x, _y);
                _buildingStep = 0;
                _tickCanBuild = _tickCount + TICKS_PER_BUILD;
                return OK;
            }
            return CANT; // it takes 3 ticks for the build to go through...
        }

        if (action == Action.SHOOT) {
            _movedOrShot = true;
            if (_torpedos.length == MAX_TORPEDOS) {
                // shoot once per tick, max 2 in-flight
                if (_cantShootSound != null) {
                    _cantShootSound.play();
                }
                return DROP;

            } else {
                _torpedos.push(new Torpedo(this, _board));
//                _shootSound.play();
                updateVisual();
                return OK;
            }
        }

        // we can always re-orient
        var reoriented :Boolean = false;
        if (_orient != action) {
            _orient = action;
            updateVisual();
            reoriented = true;
        }
        if (!advanceLocation() && !reoriented) {
//            return DROP;
            // maybe we can shoot?
            if (_board.isDestructable(_playerIdx, advancedX(), advancedY()) &&
                    (OK == performActionInternal(Action.SHOOT))) {
                // we auto-shot, so save the move for next tick
                return CANT;
            } else {
                return DROP;
            }
        }

        // we did it!
        _movedOrShot = true;
        return OK;
    }

    /**
     * Called by the board to notify us that time has passed.
     */
    public function tick () :void
    {
        _tickCount++;
        // reset our move counter
        _movedOrShot = false;

        while (_queuedActions.length > 0) {
            var action :int = int(_queuedActions[0]);
            if (CANT == performActionInternal(action)) {
                return;
            }
            _queuedActions.shift();

            if (_isMe) {
                // ensure that this is the top action in _ghostActions
                var futureAction :int = int(_futureActions.splice(0, 2)[1]);
                if (futureAction != action) {
                    // if this happens, we need to debug some stuff.
                    trace("====OMG!");
                    Log.dumpStack();
                }
                if (_ghost != null) {
                    // update stuff with our ghost
                    _ghost.updateQueuedActions(_x, _y, _orient, _futureActions);
                }
            }
        }

        if (_dead) {
            if (--_respawnTicks == 0) {
                performActionInternal(Action.RESPAWN);
            }
        }
    }

    /**
     * Called by our torpedo to let us know that it's gone.
     */
    public function torpedoExploded (torp :Torpedo, kills :int) :void
    {
        var idx :int = _torpedos.indexOf(torp);
        if (idx == -1) {
            trace("OMG: missing torp!");
            return;
        }

        // remove it
        _torpedos.splice(idx, 1);

        // track the kills
        _kills += kills;
        _totalKills += kills;
        updateVisual();
        updateDisplayedScore();
    }

    /**
     * Called to indicate that this sub was hit with a torpedo.
     */
    public function wasKilled () :void
    {
        _dead = true;
        _deaths++;
        _totalDeaths++;
        _buildingStep = 0;
        _queuedActions.length = 0; // drop any queued actions
        updateVisual();
        updateDeath();
        _respawnTicks = AUTO_RESPAWN_TICKS;

        if (_ghost != null) {
            _ghostActions = [];
            _ghost.updateQueuedActions(_x, _y, _orient, _ghostActions);
            _ghost.wasKilled();
        }
    }

    override protected function updateLocation () :void
    {
        super.updateLocation();

        if (parent != null) {
            (parent as SeaDisplay).subUpdated(this, _x, _y);
        }
    }

    protected function updateDeath () :void
    {
        if (parent != null) {
            (parent as SeaDisplay).deathUpdated(this);
        }
    }

    protected function updateVisual () :void
    {
        alpha = _dead ? 0 : 1;
        // fucking label doesn't alpha out.. so we need to add or remove it
        if (_dead != (_nameLabel.parent == null)) {
            if (_dead) {
                removeChild(_nameLabel);
            } else {
                addChild(_nameLabel);
            }
        }
        var add :int = (_torpedos.length == MAX_TORPEDOS) ? 0 : 4;
        _avatar.gotoAndStop(orientToFrame() + add);

        updateDisplayedScore();
    }

    protected function updateDisplayedScore () :void
    {
        var score :Object = {};
        score[_playerId] = [_kills + " kills, " + _deaths + " deaths.", (_kills - _deaths)];
        if (_gameCtrl != null) {
            _gameCtrl.setMappedScores(score);
        }
    }

    protected function orientToFrame () :int
    {
        switch (_orient) {
        case Action.DOWN:
        default:
            return 1;

        case Action.LEFT:
            return 2;

        case Action.UP:
            return 3;

        case Action.RIGHT:
            return 4;
        }
    }

    protected var _ghost :GhostSubmarine;

    protected var _ghostActions :Array;

    /** Actions received from the server that we're waiting to execute. */
    protected var _queuedActions :Array = [];

    /** Actions we've sent to the server but haven't applied yet. */
    protected var _futureActions :Array = [];

    protected var _dead :Boolean;

    /** The game control. */
    protected var _gameCtrl :WhirledGameControl;

    /** Is this submarine ours? */
    protected var _isMe :Boolean;

    /** The id of this player. */
    protected var _playerId :int;

    /** The name of the player controlling this sub. */
    protected var _playerName :String;

    /** The filter we use to color the truck. */
    protected var _hueShift :BitmapFilter;

    /** Have we moved or shot this tick yet? */
    protected var _movedOrShot :Boolean;

    /** How many steps have we done to do a 'build'. */
    protected var _buildingStep :int = 0;

    protected var _tickCount :int = 0;

    protected var _tickCanBuild :int = TICKS_PER_BUILD;

    /** Our currently in-flight torpedos. */
    protected var _torpedos :Array = [];

    /** The number of kills we've had. */
    protected var _kills :int;

    /** The number of times we've been killed. */
    protected var _deaths :int;

    protected var _totalKills :int;
    protected var _totalDeaths :int;

    /** A count of how long until we respawn. */
    protected var _respawnTicks :int;

    /** The movie clip that represents us. */
    protected var _avatar :MovieClip;

    /** Our shooty-shoot sound. */
    protected var _shootSound :Sound;

    protected var _cantShootSound :Sound;

    protected var _nameLabel :TextField;

    /** The maximum number of torpedos that may be in-flight at once. */
    protected static const MAX_TORPEDOS :int = 2;

    /** The number of pixels to raise the name above the sprite. */
    protected static const NAME_PADDING :int = 3;

    /** The number of ticks that may elapse before we're auto-respawned. */
    protected static const AUTO_RESPAWN_TICKS :int = 100;

    [Embed(source="trucks_drill.swf#animations")]
    protected static const AVATAR :Class;

    //[Embed(source="shooting.wav", mimeType="audio/wav")]

    [Embed(source="Error.mp3")]
    protected static const CANT_SHOOT_SOUND :Class;
}
}
