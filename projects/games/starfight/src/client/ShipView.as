package client {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

public class ShipView extends Sprite
{
    public function ShipView (ship :Ship)
    {
        _ship = ship;
        setupGraphics();

        if (_ship.isOwnShip) {
            _shieldSound = new SoundLoop(Resources.getSound("shields.wav"));
            _thrusterForwardSound = new SoundLoop(Resources.getSound("thruster.wav"));
            _thrusterReverseSound = new SoundLoop(Resources.getSound("thruster_retro2.wav"));
            _engineSound = new SoundLoop(_ship.shipType.engineSound);
        }
    }

    protected function setupGraphics () :void
    {
        _shipParent = new Sprite();
        addChild(_shipParent);

        var shipType :ShipType = _ship.shipType;

        // Set up our animation.
        _shipMovie = MovieClip(new shipType.shipAnim());
        _shieldMovie = MovieClip(new shipType.shieldAnim());

        setAnimMode(IDLE, true);
        _shipMovie.x = _shipMovie.width/2;
        _shipMovie.y = -_shipMovie.height/2;
        _shipMovie.rotation = 90;
        _shipParent.addChild(_shipMovie);

        _shieldMovie.gotoAndStop(1);
        _shieldMovie.rotation = 90;
        _shipParent.addChild(_shieldMovie);

        _shipParent.scaleX = shipType.size + 0.1;
        _shipParent.scaleY = shipType.size + 0.1;

        // Add our name as a textfield
        if (_ship.playerName != null) {
            var nameText :TextField = new TextField();
            nameText.autoSize = TextFieldAutoSize.CENTER;
            nameText.selectable = false;
            nameText.x = 0;
            nameText.y = TEXT_OFFSET;

            var format:TextFormat = new TextFormat();
            format.font = GameView.gameFont.fontName;
            format.color = (_ship.isOwnShip || _ship.shipId < 0) ? Codes.CYAN : Codes.RED;
            format.size = 10;
            format.rightMargin = 3;
            nameText.defaultTextFormat = format;
            nameText.embedFonts = true;
            nameText.antiAliasType = AntiAliasType.ADVANCED;
            nameText.text = _ship.playerName;
            addChild(nameText);
        }
    }

    public function keyPressed (event :KeyboardEvent) :void
    {
        // Can't do squat while dead.
        if (!_ship.isAlive()) {
            return;
        }

        if (event.keyCode == KV_LEFT || event.keyCode == KV_A) {
            //_ship.turnAccelRate = -_ship.shipType.turnAccel;
            _ship.turnLeft();
        } else if (event.keyCode == KV_RIGHT || event.keyCode == KV_D) {
            _ship.turnRight();
        } else if (event.keyCode == KV_UP || event.keyCode == KV_W) {
            _ship.moveForward();

        } else if (event.keyCode == KV_DOWN || event.keyCode == KV_S) {
            _ship.moveBackward();

        } else if (event.keyCode == KV_SPACE) {
            _ship.firing = true;
        } else if (event.keyCode == KV_B || event.keyCode == KV_SHIFT) {
            _ship.secondaryFiring = true;
        }
    }

    public function keyReleased (event :KeyboardEvent) :void
    {
        // Can't do squat while dead.
        if (!_ship.isAlive()) {
            return;
        }

        if (event.keyCode == KV_LEFT || event.keyCode == KV_A) {
            _ship.stopTurning();
        } else if (event.keyCode == KV_RIGHT || event.keyCode == KV_D) {
            _ship.stopTurning();
        } else if (event.keyCode == KV_UP || event.keyCode == KV_W) {
            _ship.stopMoving();
        } else if (event.keyCode == KV_DOWN || event.keyCode == KV_S) {
            _ship.stopMoving();
        } else if (event.keyCode == KV_SPACE) {
            _ship.firing = false;
        } else if (event.keyCode == KV_B || event.keyCode == KV_SHIFT) {
            _ship.secondaryFiring = false;
        } /*else if (event.keyCode == KV_X) {
            hit(shipId, 5.0);
        }*/
    }

    public function updateDisplayState (boardCenterX :Number, boardCenterY: Number) :void
    {
        var shipState :int = _ship.state;
        visible = (shipState != Ship.STATE_DEAD);

        if (shipState == Ship.STATE_DEAD) {
            stopSounds();

        } else {
            // position on the screen
            x = ((_ship.boardX - boardCenterX) * Codes.PIXELS_PER_TILE) + (Codes.GAME_WIDTH * 0.5);
            y = ((_ship.boardY - boardCenterY) * Codes.PIXELS_PER_TILE) + (Codes.GAME_HEIGHT * 0.5);

            _shipParent.rotation = _ship.rotation;

            _shieldMovie.visible = _ship.hasPowerup(Powerup.SHIELDS);

            // determine animation state
            var newAnimMode :int;
            switch (shipState) {
            case Ship.STATE_SPAWN:
                if (shipState != _lastShipState) {
                    playSpawnMovie();
                }
                newAnimMode = IDLE;
                break;

            case Ship.STATE_WARP_BEGIN:
                newAnimMode = WARP_BEGIN;
                break;

            case Ship.STATE_WARP_END:
                newAnimMode = WARP_END;
                break;

            default:
                var accel :Number = _ship.accel;
                var hasSpeed :Boolean = _ship.hasPowerup(Powerup.SPEED);
                if (accel > 0.0) {
                    newAnimMode = hasSpeed ? FORWARD_FAST : FORWARD;
                } else if (accel < 0.0) {
                    newAnimMode = hasSpeed ? REVERSE_FAST : REVERSE;
                } else {
                    newAnimMode = IDLE;
                }
                break;
            }

            setAnimMode(newAnimMode, false);

            if (_ship.isOwnShip) {
                _engineSound.play(true);
                _shieldSound.play(_ship.hasPowerup(Powerup.SHIELDS));
                _thrusterForwardSound.play(_ship.accel > 0);
                _thrusterReverseSound.play(_ship.accel < 0);
            }
        }

        _lastShipState = shipState;
    }

    protected function setAnimMode (mode :int, force :Boolean) :void
    {
        if (force || _animMode != mode) {
            _shipMovie.gotoAndPlay(ANIM_MODES[mode]);
            _animMode = mode;
        }
    }

    protected function playSpawnMovie () :void
    {
        //var sound :Sound = _ship.shipType.spawnSound;
        //AppContext.game.playSoundAt(sound, _ship.boardX, _ship.boardY);
        var spawnClip :MovieClip = MovieClip(new (Resources.getClass("ship_spawn"))());
        addChild(spawnClip);
        spawnClip.addEventListener(Event.COMPLETE, function complete (event :Event) :void {
            spawnClip.removeEventListener(Event.COMPLETE, arguments.callee);
            removeChild(event.target as MovieClip);
        });
    }

    protected function stopSounds () :void
    {
        // Turn off sound loops.
        if (_thrusterForwardSound != null) {
            _thrusterForwardSound.stop();
        }
        if (_thrusterReverseSound != null) {
            _thrusterReverseSound.stop();
        }

        if (_shieldSound != null) {
            _shieldSound.stop();
        }

        if (_engineSound != null) {
            _engineSound.stop();
        }

    }

    protected var _ship :Ship;

    /** The sprite with our ship graphics in it. */
    protected var _shipParent :Sprite;

    /** Animations. */
    protected var _shipMovie :MovieClip;
    protected var _shieldMovie :MovieClip;

    protected var _animMode :int;

    protected var _lastShipState :int = -1;

    /** Sounds currently being played - only play sounds for ownship. Note
     * that due to stupid looping behavior these need to be MovieClips to keep
     * from getting gaps between loops. */
    protected var _engineSound :SoundLoop;
    protected var _thrusterForwardSound :SoundLoop;
    protected var _thrusterReverseSound :SoundLoop;
    protected var _shieldSound :SoundLoop;

    /** "frames" within the actionscript for movement animations. */
    protected static const IDLE :int = 0;
    protected static const FORWARD :int = 2;
    protected static const REVERSE :int = 1;
    protected static const FORWARD_FAST :int = 3;
    protected static const REVERSE_FAST :int = 4;
    protected static const SELECT :int = 5;
    protected static const WARP_BEGIN :int = 6;
    protected static const WARP_END :int = 7;

    /** Some useful key codes. */
    protected static const KV_LEFT :uint = 37;
    protected static const KV_UP :uint = 38;
    protected static const KV_RIGHT :uint = 39;
    protected static const KV_DOWN :uint = 40;
    protected static const KV_SPACE :uint = 32;
    protected static const KV_ENTER :uint = 13;
    protected static const KV_A :uint = 65;
    protected static const KV_B :uint = 66;
    protected static const KV_D :uint = 68;
    protected static const KV_S :uint = 83;
    protected static const KV_W :uint = 87;
    protected static const KV_X :uint = 88;
    protected static const KV_SHIFT :uint = 16;

    protected static const TEXT_OFFSET :int = 25;

    protected static const ANIM_MODES :Array = [
        "ship", "retro", "thrust", "super_thrust", "super_retro", "select", "warp_begin", "warp_end"
    ];
}

}
