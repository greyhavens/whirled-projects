package {

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.media.Sound;
import flash.utils.ByteArray;

import com.threerings.util.EmbeddedSwfLoader;

public class ShipType
{
    /** The name of the ship type. */
    public var name :String;

    /** maneuverability statistics. */
    public var forwardAccel :Number;
    public var backwardAccel :Number;
    public var friction :Number;
    public var velThreshold :Number = 0.5;
    public var turnAccel :Number;
    public var turnFriction :Number;
    public var turnThreshold :Number = 35;
    public var turnRate :Number;

    /** armorment statistics. */
    public var hitPower :Number;
    public var primaryShotCost :Number;
    public var primaryPowerRecharge :Number;
    public var primaryShotRecharge :Number;
    public var primaryShotSpeed :Number;
    public var primaryShotLife :Number;
    public var primaryShotSize :Number;

    public var secondaryShotCost :Number;
    public var secondaryPowerRecharge :Number;
    public var secondaryShotRecharge :Number;
    public var secondaryShotSpeed :Number;
    public var secondaryShotLife :Number;
    public var secondaryShotSize :Number;

    public var armor :Number;
    public var size :Number;

    public var shipAnim :Class, shieldAnim :Class, explodeAnim :Class, shotAnim :Class, secondaryAnim :Class;
    public var shotSound :Sound, supShotSound :Sound, spawnSound :Sound, engineSound :Sound;

    /**
     * Called to have the ship perform their primary shot action.
     */
    public function primaryShot (sf :StarFight, val :Array) :void
    {
        // Shooting sound.
        var sound :Sound = (val[2] == ShotSprite.SUPER) ? supShotSound : shotSound;

        sf.playSoundAt(sound, val[3], val[4]);
    }

    /**
     * Called to have the ship perform their secondary shot action.
     */
    public function secondaryShot (sf :StarFight, val :Array) :void
    {
    }

    public function getPrimaryShotCost (ship :ShipSprite) :Number
    {
        return primaryShotCost;
    }

    /**
     * Sends a standard forward fire message.
     */
    public function primaryShotMessage (ship :ShipSprite, sf :StarFight) :void
    {
        var rads :Number = ship.ship.rotation*Codes.DEGS_TO_RADS;
        var cos :Number = Math.cos(rads);
        var sin :Number = Math.sin(rads);

        var shotX :Number = cos * primaryShotSpeed + ship.xVel;
        var shotY :Number = sin * primaryShotSpeed + ship.yVel;

        //var shotVel :Number = Math.sqrt(shotX*shotX + shotY*shotY);
        var shotVel :Number = primaryShotSpeed;
        var shotAngle :Number = Math.atan2(shotY, shotX);

        var type :int = (ship.powerups & ShipSprite.SPREAD_MASK) ?
                ShotSprite.SUPER : ShotSprite.NORMAL;

        var args :Array = new Array(7);
        args[0] = ship.shipId;
        args[1] = ship.shipType;
        args[2] = type;
        args[3] = ship.boardX + cos * size + 0.1 * ship.xVel;
        args[4] = ship.boardY + sin * size + 0.1 * ship.yVel;
        args[5] = shotVel;
        args[6] = rads;

        sf.fireShot(args);
    }

    /**
     * Secondary shot message generator.
     */
    public function secondaryShotMessage (ship :ShipSprite, sf :StarFight) :Boolean
    {
        return false;
    }

    public function loadAssets (callback :Function) :void
    {
        _callback = callback;
        _loader = new EmbeddedSwfLoader(true);
        _loader.addEventListener(Event.COMPLETE, successHandler);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, failureHandler);
        Logger.log("loading assets for " + name + " and class " + swfAsset());
        _loader.load(new (swfAsset())());
    }

    protected function swfAsset () :Class
    {
        return null;
    }

    protected function failureHandler (event :IOErrorEvent) :void
    {
        _callback(false);
        finish();
        _loader = null;
    }

    protected function successHandler (event :Event) :void
    {
        _callback(true);
        finish();
        shipAnim = _loader.getClass("ship");
        shieldAnim = _loader.getClass("ship_shield");
        explodeAnim = _loader.getClass("ship_explosion_big");
        shotAnim = _loader.getClass("beam");
        shotSound = Sound(new (_loader.getClass("beam.wav"))());
        supShotSound = Sound(new (_loader.getClass("beam_powerup.wav"))());
        spawnSound = Sound(new (_loader.getClass("spawn.wav"))());
        engineSound = Sound(new (_loader.getClass("engine_sound.wav"))());
    }

    protected function finish () :void
    {
        _loader.removeEventListener(Event.COMPLETE, successHandler);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, failureHandler);
    }

    protected var _loader :EmbeddedSwfLoader;
    protected var _callback :Function;

}
}
