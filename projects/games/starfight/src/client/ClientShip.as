package client {

public class ClientShip extends Ship
{
    public function set serverData (shipData :ShipData) :void
    {
        _serverData = shipData;
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

    protected var _shipView :ShipView;
}

}
