﻿package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.events.MouseEvent;
import flash.events.Event;

import lawsanddisorder.*;

/**
 * Contains display and logic for game players including all opponents
 */
public class Players extends Component
{
    /**
     * Constructor.  Create players
     */
    public function Players (ctx :Context)
    {
        super(ctx);
        
        // lists player ids and names by seating position
        var playerServerIds :Array = _ctx.control.game.seating.getPlayerIds();
        var playerNames :Array = _ctx.control.game.seating.getPlayerNames();
        numHumanPlayers = playerServerIds.length;

        // get the player's position; -1 means the player is a watcher
        var myPosition :int = _ctx.control.game.seating.getMyPosition();
        var isWatcher :Boolean;
        if (myPosition == -1) {
            isWatcher = true;
        }

        /*
        // for testing, pretend as a watcher
        numHumanPlayers = playerServerIds.length - 1;
        playerServerIds.length = numHumanPlayers;
        playerNames.length = numHumanPlayers;
        if (myPosition == numHumanPlayers) {
            isWatcher = true;
        }
        */

        // watchers don't get a job, hand, etc.
        if (isWatcher) {
            player = new Player(_ctx, -1, -1, "watcher");
        }
        else {
            player = new Player(_ctx, myPosition, playerServerIds[myPosition], playerNames[myPosition]);
            playerObjects[myPosition] = player;
        }
        addChild(player);

        opponents = new Opponents(_ctx);

        // watchers see all players as opponents
        if (isWatcher) {
            for (var j :int = 0; j < numHumanPlayers; j++) {
                var playerOpponent :Opponent = new Opponent(_ctx, j, playerServerIds[j], playerNames[j]);
                opponents.addOpponent(playerOpponent);
                playerObjects[j] = playerOpponent;
            }
        }

        // players create the opponents in order, starting with the opponent whose turn is next
        else {
            var i :int = myPosition;
            while (numHumanPlayers > 1) {
                // increment i and wrap around once the last seat is reached
                i = (i + 1) % numHumanPlayers;
                var opponent :Opponent = new Opponent(_ctx, i, playerServerIds[i], playerNames[i]);
                opponents.addOpponent(opponent);
                playerObjects[i] = opponent;
                if ((i + 1) % numHumanPlayers == myPosition) {
                    break;
                }
            }
        }
        
        // add ai players after all the opponents to fill the seats up to NUM_PLAYERS
        for (var k :int = numHumanPlayers; k < LawsAndDisorder.NUM_PLAYERS; k++) {
            var aiPlayer :AIPlayer = new AIPlayer(_ctx, k);
            opponents.addOpponent(aiPlayer);
            playerObjects[k] = aiPlayer;
            // last player controls all ais that are added after them
            if (player.id == numHumanPlayers - 1) {
                aiPlayer.isController = true;
            }
        }

        // add opponents as child after player so they'll be displayed over top
        opponents.x = 590;
        opponents.y = 10;
        addChild(opponents);
    }
    
    /**
     * Setup is only performed by the player who is in control at the start of the game.
     * Called by the controller player; add cards to deck, deal hands, assign jobs to players.
     */
    public function setup () :void
    {
        // setup the player hands and jobs
        for (var i :int = 0; i < playerObjects.length; i++) {
            var player :Player = playerObjects[i];
            player.setup();
        }
    }

    /**
     * For watchers who join partway through the game, fetch the existing board data
     */
    public function refreshData () :void
    {
        for each (var player :Player in playerObjects) {
            player.refreshData();
        }
    }

    /**
     * Return the player with the given id.
     */
    public function getPlayer (playerId :int) :Player
    {
        if (playerId < 0 || playerId > playerObjects.length) {
            _ctx.log("WTF playerId is " + playerId + " in getPlayer");
            return null;
        }
        return playerObjects[playerId];
    }
    
    /**
     * Called as soon as turn starts before the TURN_STARTED message goes out.  If a player is
     * provided, use that player as the new turn holder
     */
    public function calculateTurnHolder (player :Player = null) :void
    {
        if (player != null) {
            turnHolder = player;
            return;
        }
        var serverId :int = _ctx.control.game.getTurnHolderId();
        for (var i :int = 0; i < playerObjects.length; i++) {
            var player :Player = playerObjects[i];
            if (player.serverId == serverId) {
                turnHolder = player;
            }
        }
    }

    /**
     * Return true if it is this player's turn
     */
    public function isMyTurn () :Boolean
    {
        if (player != null && turnHolder == player) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Return true if it is currently an AI's turn and this player is controlling that AI.
     */
    public function amControllingAI () :Boolean
    {
        if (turnHolder is AIPlayer && AIPlayer(turnHolder).isController) {
            return true;
            /*
            _ctx.log("turnholder is an ai.  turnholder.id is " + turnHolder.id + " and player.id is " + player.id);
            if (turnHolder.id == 0 && player.id == numPlayers - 1) {
                _ctx.log("turnholder.id is 0 and player.id is numPlayers-1");
                return true;
            } else if (turnHolder.id - 1 == player.id) {
                _ctx.log("turnholder.id comes directly after player.id");
                return true;
            }
            _ctx.log("not controlling ai turnholder"); 
            */
        }
        return false;
    }

    /**
     * Return the player whose turn it is next, including AI players
     */
    public function get nextPlayer () :Player
    {
        return playerObjects[((turnHolder.id+1) % playerObjects.length)];
    }

    /**
     * Called when a player leaves the game.  Remove them from the visible opponents and
     * the list of player objects, and make their job available, but don't change player.ids or
     * remove them from distributed data arrays.
     */
    public function playerLeft (playerServerId :int) :void
    {
        if (playerServerId == player.serverId) {
            _ctx.log("WTF I'm the player who left?");
            return;
        }

        // find and unload the opponent object
        var opponent :Opponent;
        for each (var tempPlayer :Player in playerObjects) {
            if (tempPlayer.serverId == playerServerId) {
                opponent = tempPlayer as Opponent;
                break;
            }
        }

        // return the player's job to the pile
        if (_ctx.control.game.amInControl()) {
            _ctx.eventHandler.setData(Deck.JOBS_DATA, -1, opponent.id);
        }

        // if anything was happening with any player, stop it now
        // TODO only stop things that were waiting on the player who left
        _ctx.notice("Cancelling all events and actions because a player left.");
        _ctx.state.cancelMode();
        _ctx.board.laws.cancelTriggering();

        // remove the player object
        opponents.removeOpponent(opponent);
        var index :int = playerObjects.indexOf(opponent);
        playerObjects.splice(index, 1);

        // control player may be unset, so have the player in seating position 0 control for now
        if (turnHolder == null && playerObjects.indexOf(player) == 0) {
            _ctx.broadcast("Moving on to next player's turn.");
            _ctx.control.game.startNextTurn();
        }

        // unload the opponent object
        opponent.unload();
    }
    
    /**
     * Return the number of players (including AIs) in the game right now.
     */
    public function get numPlayers () :int
    {
        return playerObjects.length;
    }

    /** All player objects in the game, indexed by id */
    public var playerObjects :Array = new Array();

    /** All the other players */
    public var opponents :Opponents;

    /** Current player */
    public var player :Player;
    
    /** The player (including AIs) whose turn it is now */
    public var turnHolder :Player;
    
    /** How many of the players are human? 1-6 */
    public var numHumanPlayers :int;
}
}