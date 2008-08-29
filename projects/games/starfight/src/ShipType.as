package {

import com.threerings.util.MultiLoader;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.media.Sound;
import flash.system.ApplicationDomain;

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
    public function primaryShot (val :Array) :void
    {
        // Shooting sound.
        var sound :Sound = (val[2] == ShotSprite.SUPER) ? supShotSound : shotSound;

        AppContext.game.playSoundAt(sound, val[3], val[4]);
    }

    /**
     * Called to have the ship perform their secondary shot action.
     */
    public function secondaryShot (val :Array) :void
    {
    }

    public function getPrimaryShotCost (ship :Ship) :Number
    {
        return primaryShotCost;
    }

    /**
     * Sends a standard forward fire message.
     */
    public function primaryShotMessage (ship :Ship) :void
    {
        var rads :Number = ship.rotation*Codes.DEGS_TO_RADS;
        var cos :Number = Math.cos(rads);
        var sin :Number = Math.sin(rads);

        var shotX :Number = cos * primaryShotSpeed + ship.xVel;
        var shotY :Number = sin * primaryShotSpeed + ship.yVel;

        //var shotVel :Number = Math.sqrt(shotX*shotX + shotY*shotY);
        var shotVel :Number = primaryShotSpeed;
        var shotAngle :Number = Math.atan2(shotY, shotX);

        var type :int = ship.hasPowerup(Powerup.SPREAD) ? ShotSprite.SUPER : ShotSprite.NORMAL;

        var args :Array = new Array(7);
        args[0] = ship.shipId;
        args[1] = ship.shipTypeId;
        args[2] = type;
        args[3] = ship.boardX + cos * size + 0.1 * ship.xVel;
        args[4] = ship.boardY + sin * size + 0.1 * ship.yVel;
        args[5] = shotVel;
        args[6] = rads;

        AppContext.game.fireShot(args);
    }

    /**
     * Secondary shot message generator.
     */
    public function secondaryShotMessage (ship :Ship) :Boolean
    {
        return false;
    }

    public function loadAssets (callback :Function) :void
    {
        _callback = callback;
        _resourcesDomain = new ApplicationDomain();
        MultiLoader.getLoaders(swfAsset(), loadComplete, false, _resourcesDomain);
    }

    protected function swfAsset () :Class
    {
        return null;
    }

    protected function loadComplete (result :Object) :void
    {
        if (result is Error) {
            _callback(false);
        } else {
            _callback(true);
            successHandler();
        }
    }

    protected function successHandler () :void
    {
        shipAnim = getLoadedClass("ship");
        shieldAnim = getLoadedClass("ship_shield");
        explodeAnim = getLoadedClass("ship_explosion_big");
        shotAnim = getLoadedClass("beam");
        shotSound = Sound(new (getLoadedClass("beam.wav"))());
        supShotSound = Sound(new (getLoadedClass("beam_powerup.wav"))());
        spawnSound = Sound(new (getLoadedClass("spawn.wav"))());
        engineSound = Sound(new (getLoadedClass("engine_sound.wav"))());
    }

    protected function getLoadedClass (name :String) :Class
    {
        return _resourcesDomain.getDefinition(name) as Class;
    }

    protected var _resourcesDomain :ApplicationDomain;
    protected var _callback :Function;

}
}
