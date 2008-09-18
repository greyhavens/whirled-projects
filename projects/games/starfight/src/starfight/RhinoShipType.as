package starfight {

import com.threerings.util.Log;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import starfight.net.DefaultShotMessage;
import starfight.net.ShipShotMessage;
import starfight.net.WarpMessage;

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

    override public function doShot (message :ShipShotMessage) :void
    {
        if (message is DefaultShotMessage) {
            doPrimaryShot(message);
        } else if (message is WarpMessage) {
            doSecondaryShot(message);
        }
    }

    override protected function doPrimaryShot (message :ShipShotMessage) :void
    {
        var msg :DefaultShotMessage = DefaultShotMessage(message);

        var left :Number = msg.rotationRads + Math.PI/2;
        var right :Number = msg.rotationRads - Math.PI/2;
        var leftOffsetX :Number = Math.cos(left) * 0.5;
        var leftOffsetY :Number = Math.sin(left) * 0.5;
        var rightOffsetX :Number = Math.cos(right) * 0.5;
        var rightOffsetY :Number = Math.sin(right) * 0.5;
        var damage :Number = hitPower;
        var shotClip :Class = null;
        var explodeClip :Class = null;

        if (msg.isSuper) {
            damage *= 1.5;
            // TODO
            shotClip = null;//superShotAnim;
            explodeClip = null;//superShotExplode;
        }

        AppContext.game.createMissileShot(msg.x + leftOffsetX, msg.y + leftOffsetY, msg.velocity,
            msg.rotationRads, msg.shipId, damage, primaryShotLife, msg.shipTypeId, shotClip,
            explodeClip);

        AppContext.game.createMissileShot(msg.x + rightOffsetX, msg.y + rightOffsetY, msg.velocity,
            msg.rotationRads, msg.shipId, damage, primaryShotLife, msg.shipTypeId, shotClip,
            explodeClip);

        super.doPrimaryShot(msg);
    }

    override public function sendSecondaryShotMessage (ship :Ship) :Boolean
    {
        warpNow(ship, WarpMessage.create(ship));
        dispatchEvent(new ShotMessageSentEvent(ShipType.SECONDARY_SHOT_SENT, ship));
        return true;
    }

    override protected function doSecondaryShot (msg :ShipShotMessage) :void
    {
        var ship :Ship = AppContext.game.getShip(msg.shipId);
        if (ship != null && !ship.isOwnShip) {
            warpNow(ship, WarpMessage(msg));
        }
    }

    protected function warpNow (ship :Ship, msg :WarpMessage) :void
    {
        var warp :Function = function (...ignored) :void {
            if (ship.isOwnShip) {
                AppContext.msgs.sendMessage(msg);
                dispatchEvent(new ShotMessageSentEvent(ShipType.SECONDARY_SHOT_SENT, ship));
            } else {
                dispatchEvent(new ShotCreatedEvent(ShipType.SECONDARY_SHOT_CREATED, msg));
            }

            var startX :Number = msg.boardX;
            var startY :Number = msg.boardY;
            var rads :Number = msg.rotation * Constants.DEGS_TO_RADS;
            var endX :Number = startX + Math.cos(rads) * JUMP;
            var endY :Number = startY + Math.sin(rads) * JUMP;

            ship.resolveMove(startX, startY, endX, endY, 1);
            ship.state = Ship.STATE_WARP_END;

            ship.runOnce(WARP_IN_TIME, endWarp);
        };

        var endWarp :Function = function (...ignored) :void {
            ship.state = Ship.STATE_DEFAULT;
        };

        ship.state = Ship.STATE_WARP_BEGIN;
        ship.runOnce(WARP_OUT_TIME, warp);
    }

    protected static const log :Log = Log.getLog(RhinoShipType);

    protected static const JUMP :int = 15;

    protected static const WARP_OUT_TIME :Number = 0.5 * 1000;
    protected static const WARP_IN_TIME :Number = 0.5 * 1000;
}
}
