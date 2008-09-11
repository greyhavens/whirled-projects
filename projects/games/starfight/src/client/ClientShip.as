package client {

public class ClientShip extends Ship
{
    public static const LEFT_TURN :int = -1;
    public static const RIGHT_TURN :int = 1;
    public static const NO_TURN :int = 0;

    public static const REVERSE :int = -1;
    public static const FORWARD :int = 1;
    public static const NO_MOVE :int = 0;

    public var firing :Boolean;
    public var secondaryFiring :Boolean;
    public var turning :int;
    public var moving :int;

    public function set serverData (shipData :ShipData) :void
    {
        _serverData = shipData;

        if (_serverData.shieldHealth < DEAD && hasPowerup(Powerup.SHIELDS)) {
            removePowerup(Powerup.SHIELDS);
        }
    }

    public function set shipView (view :ShipView) :void
    {
        _shipView = view;
    }

    override public function roundEnded () :void
    {
        super.roundEnded();
        checkAwards(true);
    }

    override public function update (time :int) :void
    {
        // update move and turn acceleration if this ship is under our control
        if (isAlive && state != STATE_WARP_BEGIN && state != STATE_WARP_END && _isOwnShip) {
            if (turning < 0) {
                turnAccelRate = -_shipType.turnAccel;
            } else if (turning > 0) {
                turnAccelRate = _shipType.turnAccel;
            } else {
                turnAccelRate = 0;
            }

            if (moving < 0) {
                accel = _shipType.backwardAccel;
            } else if (moving > 0) {
                accel = _shipType.forwardAccel;
            } else {
                accel = 0;
            }

            if (hasPowerup(Powerup.SPEED)) {
                accel *= SPEED_BOOST_FACTOR;
            }
        }

        super.update(time);

        // handle SPEED powerup
        if (_isOwnShip && accel != 0 && hasPowerup(Powerup.SPEED)) {
            engineBonusPower -= time / 30000;
            if (engineBonusPower <= 0) {
                removePowerup(Powerup.SPEED);
                accel = Math.min(accel, _shipType.forwardAccel);
                accel = Math.max(accel, _shipType.backwardAccel);
            }
        }

        // handle firing
        if (_ticksToFire > 0) {
            _ticksToFire -= time;
        }
        if (firing && (_ticksToFire <= 0) &&
                (primaryShotPower >= _shipType.getPrimaryShotCost(this))) {
            handleFire();
        }

        if (_ticksToSecondary > 0) {
            _ticksToSecondary -= time;
        }
        if (secondaryFiring && (_ticksToSecondary <= 0) &&
                (secondaryShotPower >= _shipType.secondaryShotCost)) {
            handleSecondaryFire();
        }
    }

    protected function handleFire () :void
    {
        _shipType.sendPrimaryShotMessage(this);
        if (hasPowerup(Powerup.SPREAD)) {
            weaponBonusPower -= 0.03;
            if (weaponBonusPower <= 0.0) {
                removePowerup(Powerup.SPREAD);
            }
        }

        _ticksToFire = _shipType.primaryShotRecharge * 1000;
        primaryShotPower -= _shipType.getPrimaryShotCost(this);
    }

    protected function handleSecondaryFire () :void
    {
        if (_shipType.sendSecondaryShotMessage(this)) {
            _ticksToSecondary = _shipType.secondaryShotRecharge * 1000;
            secondaryShotPower -= _shipType.secondaryShotCost;
        }
    }

    protected function checkAwards (gameOver :Boolean = false) :void
    {
        if (!isOwnShip) {
            return;
        }

        if (_killsThisLife >= 10 && !_powerupsThisLife) {
            AppContext.game.awardTrophy("fly_by_wire");
        }
        if (_killsThisLife3 >= 10) {
            AppContext.game.awardTrophy(_shipType.name + "_pilot");
        }

        // see if we've killed 7 other poeple currently playing
        var bogey :int = 0;
        for (var id :String in _enemiesKilled) {
            if (AppContext.game.getShip(int(_enemiesKilled[id])) != null) {
                bogey++;
            }
        }
        if (bogey >= 7) {
            AppContext.game.awardTrophy("bogey_hunter");
        }

        if (gameOver && AppContext.game.numShips() >= 8 && _kills / _deaths >= 4) {
            AppContext.game.awardTrophy("space_ace");
        }

        if (AppContext.game.numShips() < 3) {
            return;
        }

        var myScore :int = this.score;
        if (myScore >= 500) {
            AppContext.game.awardTrophy("score1");
        }
        if (myScore >= 1000) {
            AppContext.game.awardTrophy("score2");
        }
        if (myScore >= 1500) {
            AppContext.game.awardTrophy("score3");
        }
    }

    public function awardPowerup (powerup :Powerup) :void
    {
        _powerupsThisLife = true;
        AppContext.scores.addToScore(shipId, POWERUP_PTS);
        powerup.consume();
        if (powerup.type == Powerup.HEALTH) {
            _serverData.health = Math.min(1.0, _serverData.health + 0.5);
            return;
        }
        _powerups |= (1 << powerup.type);
        switch (powerup.type) {
        case Powerup.SHIELDS:
            _serverData.shieldHealth = 1.0;
            break;
        case Powerup.SPEED:
            engineBonusPower = 1.0;
            break;
        case Powerup.SPREAD:
            weaponBonusPower = 1.0;
            break;
        }
    }

    public function removePowerup (type :int) :void
    {
        _powerups &= ~(1 << type);
    }

    protected var _shipView :ShipView;
    protected var _ticksToFire :int = 0;
    protected var _ticksToSecondary :int = 0;
}

}
