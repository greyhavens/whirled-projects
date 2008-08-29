package view {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.media.Sound;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

public class ShipView extends Sprite
{
    public function ShipView (ship :ShipSprite)
    {
        _ship = ship;
        setupGraphics();
    }

    public function setupGraphics () :void
    {
        _shipContainer = new Sprite();
        addChild(_shipContainer);

        var shipType :ShipType = Codes.getShipType(_ship.shipType);

        // Set up our animation.
        _shipMovie = MovieClip(new shipType.shipAnim());
        _shieldMovie = MovieClip(new shipType.shieldAnim());

        setAnimMode(IDLE, true);
        _shipMovie.x = _shipMovie.width/2;
        _shipMovie.y = -_shipMovie.height/2;
        _shipMovie.rotation = 90;
        _shipContainer.addChild(_shipMovie);

        _shieldMovie.gotoAndStop(1);
        _shieldMovie.rotation = 90;
        _shipContainer.addChild(_shieldMovie);

        if (_ship.isOwnShip) {
            // Start the engine sound...
            if (_engineSound != null) {
                _engineSound.stop();
            }

            // Play the engine sound forever til we stop.
            _engineSound = new SoundLoop(shipType.engineSound);
            _engineSound.loop();
        }

        _shipContainer.scaleX = shipType.size + 0.1;
        _shipContainer.scaleY = shipType.size + 0.1;

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

    public function updateDisplayState (boardCenterX :Number, boardCenterY: Number) :void
    {
        if (visible) {
            // position on the screen
            x = ((_ship.boardX - boardCenterX) * Codes.PIXELS_PER_TILE) + (Codes.GAME_WIDTH * 0.5);
            y = ((_ship.boardY - boardCenterY) * Codes.PIXELS_PER_TILE) + (Codes.GAME_HEIGHT * 0.5);

            _shipContainer.rotation = _ship.rotation;

            _shieldMovie.visible = _ship.hasPowerup(Powerup.SHIELDS);

            // determine animation state
            var shipState :int = _ship.state;
            var newAnimMode :int;
            switch (shipState) {
            case ShipSprite.STATE_SPAWN:
                if (shipState != _lastShipState) {
                    playSpawnMovie();
                }
                newAnimMode = IDLE;
                break;

            case ShipSprite.STATE_WARP_BEGIN:
                newAnimMode = WARP_BEGIN;
                break;

            case ShipSprite.STATE_WARP_END:
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
            _lastShipState = shipState;
        }
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
        if (_thrusterForward != null) {
            _thrusterForward.stop();
        }
        if (_thrusterReverse != null) {
            _thrusterReverse.stop();
        }

        if (_shieldSound != null) {
            _shieldSound.stop();
        }

        if (_engineSound != null) {
            _engineSound.stop();
        }

    }

    protected var _ship :ShipSprite;

    /** The sprite with our ship graphics in it. */
    protected var _shipContainer :Sprite;

    /** Animations. */
    protected var _shipMovie :MovieClip;
    protected var _shieldMovie :MovieClip;

    protected var _animMode :int;

    protected var _lastShipState :int = -1;

    /** Sounds currently being played - only play sounds for ownship. Note
     * that due to stupid looping behavior these need to be MovieClips to keep
     * from getting gaps between loops. */
    protected var _engineSound :SoundLoop;
    protected var _thrusterForward :SoundLoop;
    protected var _thrusterReverse :SoundLoop;
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

    protected static const TEXT_OFFSET :int = 25;

    protected static const ANIM_MODES :Array = [
        "ship", "retro", "thrust", "super_thrust", "super_retro", "select", "warp_begin", "warp_end"
    ];
}

}
