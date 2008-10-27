package lawsanddisorder {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.utils.Timer;
import flash.events.TimerEvent;

import com.whirled.contrib.UserCookie;

import lawsanddisorder.component.*;

/**
 * Watches the game messages and awards Whirled trophies when applicable.  Trophies:
 * 
 * all 6 jobs held in one game
 * all 6 job powers used cumulative
 * 
 * won a single player game
 * won a multiplayer game
 * won a multiplayer game with five human opponents
 * won a game with at twice the coins as the runner-up
 * 
 * 5 laws in one game
 * 10 laws ever cumulative
 * 50 laws ever cumulative
 * 100 laws ever cumulative
 * 5 card law
 * 
 */
public class TrophyHandler
{
    /**
     * Constructor - fetch persistant data from the server cookie
     */
    public function TrophyHandler(ctx :Context)
    {
        _ctx = ctx;
        _ctx.eventHandler.addDataListener(Deck.JOBS_DATA, jobsChanged);
        _ctx.eventHandler.addEventListener(Laws.NEW_LAW, lawCreated);
        _ctx.eventHandler.addEventListener(Job.POWER_USED, powerUsed);
        _ctx.eventHandler.addEventListener(EventHandler.GAME_ENDED, gameEnded);
        
        // set up counters for this game
        _jobsHeld = new Array(6).map(function (): Boolean { return false; });
        
        // dummy array of the job powers this player has ever used
        var powersUsed :Array = [];
        for (var jobId :int = 0; jobId < 6; jobId++) {
            powersUsed.push(UserCookie.getIntParameter("", 0));
        }
        
        var cookieDef :Array = [
            // version 1
            UserCookie.getVersionParameter(),
            UserCookie.getIntParameter(NUM_LAWS_PLAYED, 0),
            UserCookie.getArrayParameter(POWERS_USED, powersUsed)
        ];
         
        UserCookie.getCookie(_ctx.control, function (cookie :UserCookie) :void {
                _cookie = cookie;
            }, cookieDef, true /* ENABLE DEBUG */);
    }

    /**
     * Called when the player jobs array changes on the server.  Also set the player for every
     * job at this time.
     * @event event.index is the player.id and event.newValue is the job.id
     */
    protected function jobsChanged (event :DataChangedEvent) :void
    {
        if (event.index == -1 || event.index != player.id) {
            return;
        }
        
        var job :Job = _ctx.board.deck.getJob(event.newValue);
        //_ctx.log("recording that you changed to " + job);
        
        _jobsHeld[job.id] = true;
        
        for (var jobId :int = 0; jobId < 6; jobId++) {
            if (_jobsHeld[jobId] == false) {
                return;
            }
        }
        // if you've been all six jobs, award trophy
        awardTrophy("allJobsInOneGame");
    }

    /**
     * Called when the player finishes using a job power.
     */
    protected function powerUsed (event :Event) :void
    {
        if (!_ctx.board.players.isMyTurn()) {
            return;
        }
        
        if (_cookie.get(POWERS_USED, player.job.id) > 0) {
            return;
        }
        
        //_ctx.log("recording that you used a new power");
        _cookie.set(POWERS_USED, 1, player.job.id);
        
        for (var jobId :int = 0; jobId < 6; jobId++) {
            if (_cookie.get(POWERS_USED, jobId) == 0) {
                return;
            }
        }
        // all six jobs have been used, award trophy
        awardTrophy("allPowersCumulative");
    }

    /**
     * Called when some player creates a new law
     * @param event event.value is the serialized cards of the new law
     */
    protected function lawCreated (event :Event) :void
    {
        if (!_ctx.board.players.isMyTurn()) {
            return;
        }
        
        // create a dummy law from the newlaw contents
        var law :Law = new Law(_ctx, -1);
        law.setSerializedCards(_ctx.board.newLaw.getSerializedCards());
        
        //_ctx.log("recording that you made a law: " + law);
        var newNumLaws :int = (_cookie.get(NUM_LAWS_PLAYED) as int) + 1;
        _cookie.set(NUM_LAWS_PLAYED, newNumLaws);
        
        _lawsCreated++;
        if (_lawsCreated == 5) {
            awardTrophy("5LawsOneGame");
        }
        
        if (newNumLaws == 10) {
            awardTrophy("10LawsCumulative");
        } else if (newNumLaws == 50) {
            awardTrophy("50LawsCumulative");
        } else if (newNumLaws == 100) {
            awardTrophy("100LawsCumulative");
        }
        
        if (law.numCards == 5) {
            awardTrophy("fiveCardLaw");
        }
    }

    /**
     * Called when the game is over and scores have been posted
     */
    protected function gameEnded (event :Event) :void
    {
        /*
        _ctx.log("game ended.  score percentiles are : ");
        for each (var pl :Player in _ctx.board.players.playerObjects) {
            _ctx.log(pl + " : " + pl.getWinningPercentile(false));
        }
        _ctx.log("yours is " + player + " : " + player.getWinningPercentile(false));
        */
            
        if (player.getWinningPercentile(false) < 100) {
            return;
        }
        _ctx.log("You came in first place!");
        
        if (_ctx.board.players.numHumanPlayers == 1) {
            awardTrophy("winnerVsBots");
        } else {
            awardTrophy("winnerVsHumans");
            if (_ctx.board.players.numHumanPlayers == 6) {
                awardTrophy("winnerVsFiveHumans");
            }
        }
        
        var nextHighestMonies :int = 0;
        for each (var otherPlayer :Player in _ctx.board.players.playerObjects) {
            if (otherPlayer != player && otherPlayer.monies > nextHighestMonies) {
                nextHighestMonies = otherPlayer.monies;
            }
        }
        if (player.monies >= 2 * nextHighestMonies) {
            awardTrophy("twiceTheMonies");
        }
    }
    
    /** Helper for giving trophies */
    protected function awardTrophy (trophy :String) :void
    {
        _ctx.log("You got a trophy: " + trophy);
        _ctx.control.player.awardTrophy(trophy);
    }
    
    /** Helper for getting the player object */
    protected function get player () :Player
    {
        return _ctx.board.players.player;
    }
    
    /** Context */
    protected var _ctx :Context;
    
    /** Persistant data across multiple games for the player */
    protected var _cookie :UserCookie;
    
    /** Array of jobs held in this game, each index is a jobId, values are boolean */
    protected var _jobsHeld :Array /* of Boolean */;
    
    /** Count of laws created in this game */
    protected var _lawsCreated :int = 0;
    
    /** Cookie Id for the array of jobs whose powers have been used across all games */
    protected static var POWERS_USED :String = "powersUsed";
    
    /** Cookie Id for the count of laws ever created by this player across all games */
    protected static var NUM_LAWS_PLAYED :String = "numLawsPlayed";
}
}