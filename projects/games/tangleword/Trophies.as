package {

import com.whirled.game.GameControl;
import com.whirled.game.PlayerSubControl;

import com.whirled.contrib.Scoreboard;

/** Handles trophy awards. */
public class Trophies {

    public static const pointTrophyMin :int = 5;
    public static const pointTrophyMax :int = 9;
    public static const pointTrophySuffix :String = "_letter";

    public static const roundsBoundaries :Array = [ 10, 50, 100 ];
    public static const roundsTrophyPrefix :String = "played_";

    public static const totalRoundsBoundaries :Array = [ 25, 100, 500 ];
    public static const totalRoundsTrophyPrefix :String = "total_";

    public static const pointsBoundaries :Array = [ 100, 150, 200 ];
    public static const pointsTrophySuffix :String = "_points";

    public static const multiplayerWinsBoundaries :Array = [ 5, 10, 25 ];
    public static const multiplayerWinsTrophyPrefix :String = "multi_";

    
    public function Trophies (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;
        _player = gameCtrl.player;

        _player.getUserCookie(_gameCtrl.game.getMyId(), function (cookie :Object) :void {
                _cookie = cookie;
                if (_cookie == null) {
                    _cookie = { totalRounds: 0 };
                }
            });
    }

    public function handleAddWord (word :String, wordscore :int, scoreboard :Scoreboard) :void
    {
        // see if we need to award a word length trophy
        if (word.length >= pointTrophyMin) {
            var len :int = Math.min(word.length, pointTrophyMax); // clamp, just in case
            var trophy :String = String(len) + pointTrophySuffix; // make award name
            if (! _player.holdsTrophy(trophy)) {
                _player.awardTrophy(trophy);
            }
        }

        // how about a score-based trophy?
        var oldscore :int = scoreboard.getScore(_gameCtrl.game.getMyId());
        var newscore :int = oldscore + wordscore;
        for each (var boundary :int in pointsBoundaries) {
            trophy = String(boundary) + pointsTrophySuffix;
            if (oldscore < boundary && newscore >= boundary && // check if score is high enough
                ! _player.holdsTrophy(trophy))               // ...and if it's a new award
            {
                _player.awardTrophy(trophy);
            }
        }                    
    }

    public function handleRoundEnded (scoreboard :Scoreboard) :void
    {
        var score :int = scoreboard.getScore(_gameCtrl.game.getMyId());
        if (score > 0) { // only count rounds where the player was doing something

            // see if we need to grant a per-session round award
            _sessionRoundsEnded++;
            for each (var round :int in roundsBoundaries) {
                var trophy :String = roundsTrophyPrefix + String(round);
                if (_sessionRoundsEnded == round && ! _player.holdsTrophy(trophy)) {
                    _player.awardTrophy(trophy);
                }
            }

            // if the player won this round, count those up as well, but only for multiplayer
            if (scoreboard.getPlayerIds().length > 1) {
                var winners :Array = scoreboard.getWinnerIds();
                if (winners.indexOf(_gameCtrl.game.getMyId()) != -1) {
                    _multiplayerWins++;
                    for each (var boundary :int in multiplayerWinsBoundaries) {
                        trophy = multiplayerWinsTrophyPrefix + String(boundary);
                        if (_multiplayerWins == boundary && ! _player.holdsTrophy(trophy)) {
                            _player.awardTrophy(trophy);
                        }
                    }
                }
            }
            
            // now check the total number of rounds played
            if (_cookie != null) {
                _cookie.totalRounds++;
                _player.setUserCookie(_cookie);
                for each (round in totalRoundsBoundaries) {
                    trophy = totalRoundsTrophyPrefix + String(round);
                    if (_cookie.totalRounds == round && ! _player.holdsTrophy(trophy)) {
                        _player.awardTrophy(trophy);
                    }
                }
            }
        }
    }

    private var _sessionRoundsEnded :int = 0; // round count for this instance of the game
    private var _multiplayerWins :int = 0;    // multiplayer win count for this instance as well
    
    private var _gameCtrl :GameControl;
    private var _player :PlayerSubControl;
    
    private var _cookie :Object;
}

}
