package {

import flash.events.Event;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.utils.Timer;

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

    override public function primaryShot (val :Array) :void
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

        if (val[2] == Shot.SUPER) {
            damage *= 1.5;
            shotClip = superShotAnim;
            explodeClip = superShotExplode;
        }

        AppContext.game.createMissileShot(val[3] + leftOffsetX, val[4] + leftOffsetY,
                val[5], val[6], val[0], damage, primaryShotLife, val[1], shotClip, explodeClip);
        AppContext.game.createMissileShot(val[3] + rightOffsetX, val[4] + rightOffsetY,
                val[5], val[6], val[0], damage, primaryShotLife, val[1], shotClip, explodeClip);

        super.primaryShot(val);
    }

    override public function secondaryShotMessage (ship :Ship) :Boolean
    {
        var args :Array = new Array(5);
        args[0] = ship.shipId;
        args[1] = ship.shipTypeId;
        args[2] = ship.boardX;
        args[3] = ship.boardY;
        args[4] = ship.rotation;

        warpNow(ship, args);
        return true;
    }

    override public function secondaryShot (val :Array) :void
    {
        var ship :Ship = AppContext.game.getShip(val[0]);
        if (ship == null || ship.isOwnShip) {
            return;
        }
        warpNow(ship, val);
    }

    protected function warpNow (ship :Ship, val :Array) :void
    {
        // TODO - change this horribly unsafe function.

        var endWarp :Function = function (event:Event) :void {
            ship.state = Ship.STATE_DEFAULT;
        };

        var warp :Function = function (event :Event) :void {
            if (ship.isOwnShip) {
                AppContext.game.sendMessage("secondary", val);
            }
            var startX :Number = val[2];
            var startY :Number = val[3];
            var rads :Number = val[4] * Codes.DEGS_TO_RADS;
            var endX :Number = startX + Math.cos(rads) * JUMP;
            var endY :Number = startY + Math.sin(rads) * JUMP;

            ship.resolveMove(startX, startY, endX, endY, 1);
            ship.state = Ship.STATE_WARP_END;
            AppContext.game.playSoundAt(warpSound, endX, endY);

            var timer :Timer = new Timer(WARP_IN_TIME, 1);
            timer.addEventListener(TimerEvent.TIMER, endWarp);
            timer.start();
        };

        ship.state = Ship.STATE_WARP_BEGIN;
        var timer :Timer = new Timer(WARP_OUT_TIME, 1);
        timer.addEventListener(TimerEvent.TIMER, warp);
        timer.start();
    }

    override protected function swfAsset () :Class
    {
        return SHIP;
    }

    override protected function successHandler () :void
    {
        super.successHandler();
        warpSound = Sound(new (getLoadedClass("warp.wav"))());
        superShotAnim = getLoadedClass("missile");
        superShotExplode = getLoadedClass("missile_explosion");
    }

    [Embed(source="../rsrc/ships/rhino.swf", mimeType="application/octet-stream")]
    protected static const SHIP :Class;

    protected static const JUMP :int = 15;

    protected static const WARP_OUT_TIME :Number = 0.5;
    protected static const WARP_IN_TIME :Number = 0.5;
}
}
