package lawsanddisorder {

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.events.Event;

import com.whirled.game.GameControl;
import com.whirled.game.FlowAwardedEvent;
import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.StateChangedEvent;

import lawsanddisorder.component.*

/**
 * Handles game setup / game start / game end logic.
 *
 * TODO gameplay:
 * ai to fill games up to 6 players?
 * timers for auto-selection for afk players (?)
 * detecting afk players
 * handling players leaving
 * handle watchers
 * handle premature game ending
 * handle rematch
 * unloader?
 * grab fresh job data before using it on opponent's turn eg during enact law after switch job
 * same with hand data eg after being stolen from, before losing card
 * can the above cases happen, eg can a message get lost?
 * don't send change data events to turn holder, or use set immediate?
 * propagate events for end turn, other events?
 * 
 * 
 * TODO inerface:
 * improve highlighting with delays/events for unhighlighting
 * bring law to front on mouseover
 * improve notice & broadcast messages esp when waiting for opponent
 * animations when drawing cards, stealing cards, playing law, gain/lose/give monies
 * card mouseover tooltips, esp job powers?
 * figure out wtf to do with laws
 * figure out whether/how to display notices
 * get a better font
 * 
 */
[SWF(width="1000", height="550")]
public class LawsAndDisorder extends Sprite
{
    /** Message that game is ending */
    public static const GAME_ENDING :String = "gameEnding";

    /**
     * Constructor
     */
    public function LawsAndDisorder ()
    {
        // create context and game controller
        var control :GameControl = new GameControl(this, false);
        _ctx = new Context(control);
		
		// if we're not connected, stop here
        if (!_ctx.control.isConnected()) {
            return;
        }
		
        _ctx.control.game.addEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        _ctx.control.game.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);
        _ctx.control.player.addEventListener(FlowAwardedEvent.FLOW_AWARDED, flowAwarded);
        
        // first player sets up distributed data and waits to hear about it from the server
        // before continuing to fill properties with actual data
        if (_ctx.control.game.amInControl()) {
            _ctx.control.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, initPropertyChanged);
            _ctx.control.net.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);
            var playerCount :int = _ctx.control.game.seating.getPlayerIds().length;
            _ctx.control.net.set(Player.MONIES_DATA, new Array(playerCount).map(function (): int { return Player.STARTING_MONIES; }));
            _ctx.control.net.set(Hand.HAND_DATA, new Array(playerCount).map(function (): Array { return new Array(); }));
            _ctx.control.net.set(Deck.JOBS_DATA, new Array(playerCount).map(function (): int { return -1; }));
            //_ctx.control.net.set(Laws.LAWS_DATA, new Array());
            _ctx.control.net.set(Laws.LAWS_DATA, null);
        }
        // other players just set up the board now and wait to receive the actual data
        else {
            finishInit();
        }
    }
    
    /**
     * Implementation of PropertyChangedListener method; fires when a property changes on
     * the server.  Only the control player will perform this.
     */
    public function initPropertyChanged (event :PropertyChangedEvent) :void
    {
        if ((event.name == Hand.HAND_DATA)
            || (event.name == Deck.JOBS_DATA)
            || (event.name == Laws.LAWS_DATA)
            || (event.name == Player.MONIES_DATA)) {

               // one step closer to being done initialization
               if (++_initComplete == INIT_GOAL) {
                _ctx.control.net.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, initPropertyChanged);
                finishInit();
             }
        }
    }
    
    /**
     * Verify that all the init pieces are complete, then setup and start the game
     */
    protected function finishInit () :void
    {
        if (!_ctx.control.isConnected()) {
            _ctx.log("WTF not connected??!?");
            return;
        }

        // create our state and our board, and initialize them
        var state :State = new State(_ctx)
        var board :Board = new Board(_ctx)
        var eventHandler :EventHandler = new EventHandler(_ctx);
        _ctx.init(state, board, eventHandler);
        _ctx.board.init();
        addChild(_ctx.board);

        // notify the game that we're ready to start
        _ctx.control.game.playerReady();
    }
    
    /** 
     * Fires when all players have called playerReady().  Have the control player set
     * up the board data then start the first turn.
     * 
     * TODO listen for the board data before starting the first turn?
     */     
    protected function gameDidStart (event :StateChangedEvent) :void
    {
        _ctx.notice("Welcome to Laws & Disorder!");
        if (_ctx.control.game.amInControl()) {
            _ctx.board.setup();
            // start the first turn
            _ctx.control.game.startNextTurn();
        }
    }

    /**
     * Handler for receiving flow awarded events
     * TODO move to Notices?
     */
    protected function flowAwarded (event :FlowAwardedEvent) :void
    {
        _ctx.notice("You got: " + event.amount + " flow for playing.  That's " + event.percentile + "%");
    }
    
    /**
     * Handler for recieving game end events
     * TODO move to Notices?
     */
    protected function gameDidEnd (event :StateChangedEvent) :void
    {
        _ctx.notice("Game over - thanks for playing!");
    }
    
    /** Context */
    protected var _ctx :Context;
    
    /** How far are we towards INIT_GOAL? */
    protected var _initComplete :int = 0;
    
    /** How many things must be done before init is complete? */
    protected static const INIT_GOAL :int = 4;
}
}