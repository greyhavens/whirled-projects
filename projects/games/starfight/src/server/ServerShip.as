package server {

import net.ShipExplodedMessage;

public class ServerShip extends Ship
{
    /**
     * Registers that the ship was hit.
     */
    public function hit (shooterId :int, damage :Number) :void
    {
        // Already dead, don't bother.
        if (!isAlive) {
            return;
        }

        var hitPower :Number = damage / _shipType.armor;

        if (hasPowerup(Powerup.SHIELDS)) {
            // shields always have an armor of 0.5
            hitPower = damage * 2;
            _serverData.shieldHealth -= hitPower;
            if (_serverData.shieldHealth <= DEAD) {
                removePowerup(Powerup.SHIELDS);
            }
            return;
        }

        _serverData.health -= hitPower;
        if (_serverData.health <= DEAD) {
            AppContext.msgs.sendMessage(ShipExplodedMessage.create(shipId, shooterId, boardX,
                boardY, rotation));
            // TODO - move this to ClientShip
            //checkAwards();

            // Stop moving and firing.
            xVel = 0;
            yVel = 0;
            turnRate = 0;
            turnAccelRate = 0;
            accel = 0;
            _firing = false;
            _secondaryFiring = false;
            stopTurning();
            stopMoving();
            _deaths++;
        }
    }
}

}
