package server {

import flash.events.TimerEvent;
import flash.utils.Timer;

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
            return;
        }

        _serverData.health -= hitPower;
        if (_serverData.health <= DEAD) {
            AppContext.msgs.sendMessage(ShipExplodedMessage.create(this, shooterId));
        }
    }

    public function enableShield (shieldHealth :Number, timeoutMs :int) :void
    {
        _serverData.shieldHealth = shieldHealth;

        if (timeoutMs > 0) {
            var shieldTimer :Timer = new Timer(timeoutMs, 1);
            shieldTimer.addEventListener(TimerEvent.TIMER, function (event :TimerEvent) :void {
                shieldTimer.removeEventListener(TimerEvent.TIMER, arguments.callee);
                _serverData.shieldHealth = 0;
            });
            shieldTimer.start();
        }
    }

    public function awardHealth (healthIncrement :Number) :void
    {
        _serverData.health = Math.min(1, _serverData.health + healthIncrement);
    }
}

}
