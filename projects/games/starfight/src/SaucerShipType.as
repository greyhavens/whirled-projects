package {

public class SaucerShipType extends ShipType
{
    public static const SECONDARY_HIT_POWER :Number = 0.3;
    public static const SUPER_SHOT_COST :Number = 0.1;

    public function SaucerShipType () :void
    {
        name = "Saucer";

        forwardAccel = 60.0;
        backwardAccel = 0.0;
        friction = 0.5;
        velThreshold = 5;
        turnRate = 180;
        turnAccel = 38;
        turnFriction = 0.02;
        turnThreshold = 180;

        hitPower = 0.09;

        primaryShotCost = 0.2;
        primaryPowerRecharge = 6.0;
        primaryShotRecharge = 0.1;
        primaryShotSpeed = 10;
        primaryShotLife = 0.1;
        primaryShotSize = 0.4;

        secondaryShotCost = 0.4;
        secondaryShotRecharge = 3;
        secondaryPowerRecharge = 30;
        secondaryShotLife = 90;
        secondaryShotSize = 0.3;

        armor = 0.8;
        size = 0.9;
    }

    override public function getPrimaryShotCost (ship :Ship) :Number
    {
        return (ship.hasPowerup(Powerup.SPREAD) ? SUPER_SHOT_COST : primaryShotCost);
    }

    override public function doPrimaryShot (args :Array) :void
    {
        var ship :Ship = AppContext.game.getShip(args[0]);
        if (ship == null) {
            return;
        }

        var ships :Array = AppContext.game.findShips(ship.boardX, ship.boardY, RANGE);

        // no one in range so shoot straight
        if (ships.length <= 1) {
            AppContext.game.createLaserShot(ship.boardX, ship.boardY, ship.rotation, RANGE,
                args[0], hitPower, primaryShotLife, args[1], -1);
        } else {

            for each (var tShip :Ship in ships) {
                if (tShip.shipId == ship.shipId) {
                    continue;
                }
                var dist :Number = Math.sqrt((tShip.boardX - ship.boardX)*(tShip.boardX-ship.boardX) +
                        (tShip.boardY-ship.boardY)*(tShip.boardY-ship.boardY));
                dist = Math.min(RANGE, dist);
                var angle :Number = Constants.RADS_TO_DEGS *
                        Math.atan2(tShip.boardY - ship.boardY, tShip.boardX - ship.boardX);
                AppContext.game.createLaserShot(ship.boardX, ship.boardY, angle, dist, args[0],
                    hitPower, primaryShotLife, args[1], tShip.shipId);
            }
        }

        dispatchEvent(new ShotCreatedEvent(ShipType.PRIMARY_SHOT_CREATED, args));
    }

    override public function sendPrimaryShotMessage (ship :Ship) :void
    {
        var type :int = (ship.hasPowerup(Powerup.SPREAD) ? Shot.SUPER : Shot.NORMAL);

        var args :Array = new Array(3);
        args[0] = ship.shipId;
        args[1] = ship.shipTypeId;
        args[2] = type;
        AppContext.game.sendShotMessage(args);

        dispatchEvent(new ShotMessageSentEvent(ShipType.PRIMARY_SHOT_SENT, ship));
    }

    override public function sendSecondaryShotMessage (ship :Ship) :Boolean
    {
        var args :Array = new Array(5);
        args[0] = ship.shipId;
        args[1] = ship.shipTypeId;
        args[2] = Math.round(ship.boardX);
        args[3] = Math.round(ship.boardY);
        args[4] = SECONDARY_HIT_POWER;

        AppContext.game.sendMessage(Constants.MSG_SECONDARY, args);

        dispatchEvent(new ShotMessageSentEvent(ShipType.SECONDARY_SHOT_SENT, ship));

        return true;
    }

    override public function doSecondaryShot (args :Array) :void
    {
        AppContext.game.addMine(args[0], args[2], args[3], args[4]);

        dispatchEvent(new ShotCreatedEvent(ShipType.SECONDARY_SHOT_CREATED, args));
    }

    protected static var RANGE :Number = 7;
    protected static var TARGET :Number = 12;
}
}
