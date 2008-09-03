package {

import com.threerings.util.Log;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class RhinoShipType extends ShipType
{
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

    override public function doPrimaryShot (args :Array) :void
    {
        var left :Number = args[6] + Math.PI/2;
        var right :Number = args[6] - Math.PI/2;
        var leftOffsetX :Number = Math.cos(left) * 0.5;
        var leftOffsetY :Number = Math.sin(left) * 0.5;
        var rightOffsetX :Number = Math.cos(right) * 0.5;
        var rightOffsetY :Number = Math.sin(right) * 0.5;
        var damage :Number = hitPower;
        var shotClip :Class = null;
        var explodeClip :Class = null;

        if (args[2] == Shot.SUPER) {
            damage *= 1.5;
            // TODO
            shotClip = null;//superShotAnim;
            explodeClip = null;//superShotExplode;
        }

        AppContext.game.createMissileShot(args[3] + leftOffsetX, args[4] + leftOffsetY,
                args[5], args[6], args[0], damage, primaryShotLife, args[1], shotClip, explodeClip);
        AppContext.game.createMissileShot(args[3] + rightOffsetX, args[4] + rightOffsetY,
                args[5], args[6], args[0], damage, primaryShotLife, args[1], shotClip, explodeClip);

        super.doPrimaryShot(args);
    }

    override public function sendSecondaryShotMessage (ship :Ship) :Boolean
    {
        var args :Array = new Array(5);
        args[0] = ship.shipId;
        args[1] = ship.shipTypeId;
        args[2] = ship.boardX;
        args[3] = ship.boardY;
        args[4] = ship.rotation;

        warpNow(ship, args);

        dispatchEvent(new ShotMessageSentEvent(ShipType.SECONDARY_SHOT_SENT, ship));

        return true;
    }

    override public function doSecondaryShot (args :Array) :void
    {
        var ship :Ship = AppContext.game.getShip(args[0]);
        if (ship != null && !ship.isOwnShip) {
            warpNow(ship, args);
        }
    }

    protected function warpNow (ship :Ship, args :Array) :void
    {
        // TODO - change this horribly unsafe function.

        var endWarp :Function = function (event:Event) :void {
            ship.state = Ship.STATE_DEFAULT;
        };

        var warp :Function = function (event :Event) :void {
            if (ship.isOwnShip) {
                AppContext.game.sendMessage(Codes.MSG_SECONDARY, args);
                dispatchEvent(new ShotMessageSentEvent(ShipType.SECONDARY_SHOT_SENT, ship));
            } else {
                dispatchEvent(new ShotCreatedEvent(ShipType.SECONDARY_SHOT_CREATED, args));
            }

            var startX :Number = args[2];
            var startY :Number = args[3];
            var rads :Number = args[4] * Codes.DEGS_TO_RADS;
            var endX :Number = startX + Math.cos(rads) * JUMP;
            var endY :Number = startY + Math.sin(rads) * JUMP;

            ship.resolveMove(startX, startY, endX, endY, 1);
            ship.state = Ship.STATE_WARP_END;

            var endTimer :Timer = new Timer(WARP_IN_TIME, 1);
            endTimer.addEventListener(TimerEvent.TIMER, endWarp);
            endTimer.start();
        };

        ship.state = Ship.STATE_WARP_BEGIN;
        var timer :Timer = new Timer(WARP_OUT_TIME, 1);
        timer.addEventListener(TimerEvent.TIMER, warp);
        timer.start();
    }

    protected static const log :Log = Log.getLog(RhinoShipType);

    protected static const JUMP :int = 15;

    protected static const WARP_OUT_TIME :Number = 0.5 * 1000;
    protected static const WARP_IN_TIME :Number = 0.5 * 1000;
}
}
