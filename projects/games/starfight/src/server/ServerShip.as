package server {

import net.ShipExplodedMessage;

public class ServerShip extends Ship
{
    public function ServerShip (shipId :int, playerName :String)
    {
        super(shipId, playerName);
    }

    /**
     * Registers that the ship was hit.
     */
    public function hit (shooterId :int, damage :Number) :Boolean
    {
        // Already dead, don't bother.
        if (!isAlive) {
            return false;
        }

        var hitPower :Number = damage / _shipType.armor;

        if (_serverData.shieldHealth > 0) {
            // shields always have an armor of 0.5
            hitPower = damage * 2;
            _serverData.shieldHealth = Math.max(_serverData.shieldHealth - hitPower, 0);

        } else {
            _serverData.health -= hitPower;
            if (_serverData.health <= DEAD) {
                AppContext.msgs.sendMessage(ShipExplodedMessage.create(this, shooterId));
            }
        }

        return true;
    }

    public function enableShield (shieldHealth :Number, timeoutMs :int) :void
    {
        _serverData.shieldHealth = shieldHealth;

        if (timeoutMs > 0) {
            _timers.runOnce(timeoutMs, function (...ignored) :void {
                _serverData.shieldHealth = 0;
            });
        }
    }

    public function awardHealth (healthIncrement :Number) :void
    {
        _serverData.health = Math.min(1, _serverData.health + healthIncrement);
    }
}

}
