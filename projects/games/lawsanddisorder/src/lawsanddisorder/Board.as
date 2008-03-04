package lawsanddisorder {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.events.MouseEvent;
import flash.events.Event;

import com.threerings.util.HashMap;
import com.whirled.game.StateChangedEvent;

import lawsanddisorder.component.*;

/**
 * Layout of the game board.  Components such as Player can be publicly accessed through here.
 */
public class Board extends Sprite
{
    /**
     * Constructor
     */
    public function Board (ctx :Context)
    {
        _ctx = ctx;
    }

    /**
     * Create the board components and initialize them 
     */
    public function init () :void
    {
        // display background
        initDisplay();
        
        _ctx.eventHandler.addEventListener(EventHandler.PLAYER_TURN_ENDED, turnEnded);
        _ctx.eventHandler.addEventListener(EventHandler.PLAYER_TURN_STARTED, turnStarted);
                        
        // create law button
        createLawButton = new CreateLawButton(_ctx);
        createLawButton.x = 12;
        createLawButton.y = 250;
        addChild(createLawButton);
        
        endTurnButton = new EndTurnButton(_ctx);
        endTurnButton.x = 12;
        endTurnButton.y = 290;
        addChild(endTurnButton);
        
        deck = new Deck(_ctx);
        deck.x = 15;
        deck.y = 330;
        addChild(deck);
        
        newLaw = new NewLaw(_ctx);
        newLaw.x = 170;
        newLaw.y = 200;
        
        laws = new Laws(_ctx);
        laws.x = 170;
        laws.y = 30;
        addChild(laws);
                
        opponents = new Opponents(_ctx);
        
        // create the players
        // lists player ids and names by seating position
        var playerIds :Array = _ctx.control.game.seating.getPlayerIds();
        var playerNames :Array = _ctx.control.game.seating.getPlayerNames();
        for (var i :int = 0; i < playerIds.length; i++) {
            var player :Player;
            if (_ctx.control.game.seating.getMyPosition() == i) {
                player = new Player(_ctx, i, playerIds[i], playerNames[i]);
                player.x = 0;
                player.y = 0;
                addChild(player);
                this.player = player;
            }
            else {
                player = new Opponent(_ctx, i, playerIds[i], playerNames[i]);
                opponents.addOpponent(Opponent(player));
            }
            playerObjects[i] = player;
        }
        
        // add opponents as child after player so they'll be displayed over top
        opponents.x = 590;
        opponents.y = 10;
        addChild(opponents);
        
        // notices display above everything else
        notices = new Notices(_ctx);
        notices.x = 0;
        notices.y = 380;
        //addChild(notices);
        
        // displayed during the player's turn
        turnHighlight = new Sprite();
        turnHighlight.graphics.lineStyle(5, 0xFFFF00);
        turnHighlight.graphics.drawRect(2, 2, 695, 495);
    }
    
    /**
     * Setup is only performed by the player who is in control at the start of the game.
     * Called by the controller player; add cards to deck, deal hands, assign jobs to players.
     */
    public function setup () :void
    {
    	deck.setup();
    	// setup the player hands and jobs
        for (var i :int = 0; i < playerObjects.length; i++) {
            var player :Player = playerObjects[i];
            player.setup();
        }
    }
    
    /**
     * Initialize the table; draw the background
     */
    protected function initDisplay () :void
    {
    	var background :Sprite = new BOARD_BACKGROUND();
		// TODO this mask seems to have a shorter y in whirled - fix or adjust
    	var bgMask :Sprite = new Sprite();
    	bgMask.graphics.beginFill(0x000000);
    	bgMask.graphics.drawRect(0, 0, 700, 500);
    	bgMask.graphics.endFill();
    	background.mask = bgMask;
		background.mouseEnabled = false;
        addChild(background);
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
     * Remove a card from the board layer
     */
    public function removeCard (card :Card) :void
    {
        if (contains(card)) {
            try {
                removeChild(card);
            }
            catch (error :ArgumentError) {
                return;
            }
        }
    }
    
    /**
     * Return the player whose turn it is.
     * TODO could be more efficient?  Listen for turn changed event?  Does turn changed event 
     *      include turnholder id?  Should be here?  Should player array be moved?
     */
    public function getTurnHolder () :Player
    {
    	// getTurnHolder returns a serverId, not their seating position
    	var serverId :int = _ctx.control.game.getTurnHolderId();
    	for (var i :int = 0; i < playerObjects.length; i++) {
    		var player :Player = playerObjects[i];
    		if (player.serverId == serverId) {
    			return player;
    		}
    	}
    	return null;
    }
    
    /**
     * Return true if it is this player's turn
     * TODO not the place for this either     */
    public function isMyTurn () :Boolean
    {
    	var turnHolder :Player = getTurnHolder();
    	if (turnHolder != null && turnHolder == player) {
        	return true;
        }
        return false;
    }
    
    /**
     * Return the array of players in order of seating.
     */
    public function get players () :Array {
    	return playerObjects;
    }
    
    /**
     * The turn just changed.  Indicate if it is the player's turn
     */
    protected function turnStarted (event :Event) :void
    {
    	if (!contains(turnHighlight)){
    		addChild(turnHighlight);
    	}
    }
    
    /**
     * Handler for end turn event - remove newlaw and turn highlight
     */
    protected function turnEnded (event :Event) :void
    {
        if (contains(newLaw)) {
            removeChild(newLaw);
        }
        if (contains(turnHighlight)){
            removeChild(turnHighlight);
        }
    }
    
    /** Game context */
    protected var _ctx :Context;
    
    /** TODO make components readonly using getters */
    
    /** Displays in-game messages to the player */
    public var notices :Notices;
    
    /** Press this to show the create law box */
    public var createLawButton :CreateLawButton;
    
    /** Press this to end the turn */
    public var endTurnButton :EndTurnButton;
    
    /** Deck of cards */
    public var deck :Deck;
    
    /** Play area for creating a new law */
    public var newLaw :NewLaw;
    
    /** List of finished laws */
    public var laws :Laws;
    
    /** All the other players */
    public var opponents :Opponents;
    
    /** Current player */
    public var player :Player;
    
    /** All player objects in the game, indexed by id */
    protected var playerObjects :Array = new Array();
    
    /** Displays to indicate it is the player's turn */
    protected var turnHighlight :Sprite;
    
    /** Background image for the entire board */
    [Embed(source="../../rsrc/components.swf#bg")]
    protected static const BOARD_BACKGROUND :Class;
}
}