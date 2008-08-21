package {

import flash.media.Sound;
import flash.media.SoundTransform;
import flash.events.Event;
import flash.display.MovieClip;

public class RhinoShipType extends ShipType
{
    public var warpSound :Sound;
    public var superShotAnim :Class, superShotExplode :Class;

    public function RhinoShipType () :void
    {
        name = "Rhino";
        forwardAccel = 6.0;
        backwardAccel = -2;
        friction = 0.1;
        turnAccel = 90.0;
        turnFriction = 0.03;

        hitPower = 0.18;
        primaryShotCost = 0.2;
        primaryShotRecharge = 0.4;
        primaryPowerRecharge = 4;
        primaryShotSpeed = 30;
        primaryShotLife = 2;
        primaryShotSize = 0.1;

        secondaryShotCost = 0.5;
        secondaryShotRecharge = 3;
        secondaryPowerRecharge = 20;

        armor = 1.5;
        size = 1.2;
    }

    override public function primaryShot (sf :StarFight, val :Array) :void
    {
        var left :Number = val[6] + Math.PI/2;
        var right :Number = val[6] - Math.PI/2;
        var leftOffsetX :Number = Math.cos(left) * 0.5;
        var leftOffsetY :Number = Math.sin(left) * 0.5;
        var rightOffsetX :Number = Math.cos(right) * 0.5;
        var rightOffsetY :Number = Math.sin(right) * 0.5;
        var damage :Number = hitPower;
        var shotClip :Class = null;
        var explodeClip :Class = null;

        if (val[2] == ShotSprite.SUPER) {
            damage *= 1.5;
            shotClip = superShotAnim;
            explodeClip = superShotExplode;
        }

        sf.addShot(new MissileShotSprite(val[3] + leftOffsetX, val[4] + leftOffsetY, val[5],
                val[6], val[0], damage, primaryShotLife, val[1], sf, shotClip, explodeClip));
        sf.addShot(new MissileShotSprite(val[3] + rightOffsetX, val[4] + rightOffsetY, val[5],
                val[6], val[0], damage, primaryShotLife, val[1], sf, shotClip, explodeClip));

        super.primaryShot(sf, val);
    }

    override public function secondaryShotMessage (ship :ShipSprite, sf :StarFight) :Boolean
    {
        var args :Array = new Array(5);
        args[0] = ship.shipId;
        args[1] = ship.shipType;
        args[2] = ship.boardX;
        args[3] = ship.boardY;
        args[4] = ship.ship.rotation;

        warpNow(ship, sf, args);
        return true;
    }

    override public function secondaryShot (sf :StarFight, val :Array) :void
    {
        var ship :ShipSprite = sf.getShip(val[0]);
        if (ship == null || ship.isOwnShip) {
            return;
        }
        warpNow(ship, sf, val);
    }

    protected function warpNow (ship :ShipSprite, sf :StarFight, val :Array) :void
    {
        var endWarp :Function = function (event:Event) :void
        {
            ship.removeEventListener(Event.COMPLETE, endWarp);
            ship.setAnimMode(ShipSprite.IDLE, true);
        };
        var warp :Function = function (event :Event) :void
        {
            clip.removeEventListener(Event.COMPLETE, warp);
            if (ship.isOwnShip) {
                sf.sendMessage("secondary", val);
            }
            var startX :Number = val[2];
            var startY :Number = val[3];
            var rads :Number = val[4] * Codes.DEGS_TO_RADS;
            var endX :Number = startX + Math.cos(rads) * JUMP;
            var endY :Number = startY + Math.sin(rads) * JUMP;

            ship.resolveMove(startX, startY, endX, endY, 1);
            ship.setAnimMode(ShipSprite.WARP_END, true).addEventListener(Event.COMPLETE, endWarp);
            sf.playSoundAt(warpSound, endX, endY);
        };
        var clip :MovieClip = ship.setAnimMode(ShipSprite.WARP_BEGIN, true);
        clip.addEventListener(Event.COMPLETE, warp);
    }

    override protected function swfAsset () :Class
    {
        return SHIP;
    }

    override protected function successHandler (event :Event) :void
    {
        super.successHandler(event);
        warpSound = Sound(new (_loader.getClass("warp.wav"))());
        superShotAnim = _loader.getClass("missile");
        superShotExplode = _loader.getClass("missile_explosion");
    }

    [Embed(source="../rsrc/ships/rhino.swf", mimeType="application/octet-stream")]
    protected static const SHIP :Class;

    protected static const JUMP :int = 15;
}
}
