package client {

public class ClientLocalUtility
    implements LocalUtility
{
    public function resetScores () :void
    {
        AppContext.gameCtrl.local.clearScores(0);
    }

    public function setScore (playerId :int, score :int) :void
    {
        var scoreObj :Object = {};
        scoreObj[playerId] = score;

        AppContext.gameCtrl.local.setMappedScores(scoreObj);
    }

    public function incrementScore (playerId :int, delta :int) :void
    {

        // TODO
        /*if (shipId == myId) {
        //AppContext.gameView.status.addScore(score);
            _ownShip.addScore(score);
            var scores :Object = {};
            scores[_ownShip.shipId] = _ownShip.score;
            _gameCtrl.local.setMappedScores(scores);
        } else {
            if (_otherScores[shipId] === undefined) {
                _otherScores[shipId] = score;
            } else {
                _otherScores[shipId] = int(_otherScores[shipId]) + score;
            }
        }*/
    }

    public function feedback (msg :String) :void
    {
        AppContext.gameCtrl.local.feedback(msg);
    }
}

}
