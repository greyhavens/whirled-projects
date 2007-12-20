package {

import com.whirled.WhirledGameControl;

/** Handles trophy awards. */
public class Trophies {

    public static const pointTrophyMin :int = 5;
    public static const pointTrophyMax :int = 9;
    public static const pointTrophySuffix :String = "_letter";

    public static const roundsBoundaries :Array = [ 10, 50, 100 ];
    public static const roundsTrophyPrefix :String = "played_";

    public static const pointsBoundaries :Array = [ 100, 150, 200 ];
    public static const pointsTrophySuffix :String = "_points";
        
    
    public function Trophies (gameCtrl :WhirledGameControl)
    {
        _gameCtrl = gameCtrl;
    }

    public function handleAddWord (word :String, wordscore :int, scoreboard :Scoreboard) :void
    {
        // see if we need to award a word length trophy
        if (word.length >= pointTrophyMin) {
            var len :int = Math.min(word.length, pointTrophyMax); // clamp, just in case
            var trophy :String = String(len) + pointTrophySuffix; // make award name
            if (! _gameCtrl.holdsTrophy(trophy)) {
                _gameCtrl.awardTrophy(trophy);
            }
        }

        // how about a score-based trophy?
        var oldscore :int = scoreboard.getRoundScore(_gameCtrl.getMyId());
        var newscore :int = oldscore + wordscore;
        for each (var boundary :int in pointsBoundaries) {
                trophy = String(boundary) + pointsTrophySuffix;
                if (oldscore < boundary && newscore >= boundary && // check if score is high enough
                    ! _gameCtrl.holdsTrophy(trophy))               // ...and if it's a new award
                {
                    _gameCtrl.awardTrophy(trophy);
                }
            }                    
    }

    public function handleRoundEnded (scoreboard :Scoreboard) :void
    {
        var score :int = scoreboard.getRoundScore(_gameCtrl.getMyId());
        if (score > 0) { // only count rounds where the player was doing something
            _roundsEnded++;
            for each (var round :int in roundsBoundaries) {
                    var trophy :String = roundsTrophyPrefix + String(round);
                    if (_roundsEnded == int(round) &&
                        ! _gameCtrl.holdsTrophy(trophy))
                    {
                        _gameCtrl.awardTrophy(trophy);
                    }
                }
        }
    }
    

    private var _roundsEnded :int = 0; // round count for this instance of the game
    private var _gameCtrl :WhirledGameControl;
}

}
