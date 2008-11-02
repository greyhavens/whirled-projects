package lawsanddisorder {

import com.whirled.game.GameControl;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.StateChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

import lawsanddisorder.component.*;

/**
 * Main game class handles game setup and players joining/leaving.
 * 
 * TODO logic & bugs:
 * move config options from the game lobby to inside the game for single player
 * improve ai handling of job powers
 * 
 * TODO interface:
 * make splash screen a 3 screen click through
 * card mouseover tooltips, esp job powers?
 * better explanation of each ability (in help?  tooltips?  with pictures?)
 * handling long names / special characters in names
 * twinkle on opponents when they use an ability
 * cards appearing after the draw animation (may not fix, it's a pain)
 * 
 */
[SWF(width="1000", height="550")]
public class LawsAndDisorder extends Sprite
{
    /** Message that game is ending */
    public static const GAME_ENDING :String = "gameEnding";
    
    /** Game version for testing/debugging purposes */
    public static const VERSION :String = "0.516";

    /**
     * Constructor.  Set up game control, context, and board.  Add listeners for game events, and
     * begin data initilization.
     */
    public function LawsAndDisorder ()
    {
        // create context and game controller
        var control :GameControl = new GameControl(this, false);
        if (!control.isConnected()) {
            var version :TextField = new TextField();
            var format :TextFormat = new TextFormat();
            format.size = 1000;
            version.defaultTextFormat = format;
            version.width = 600;
            version.height = 150;
            version.text = "v " + VERSION;
            version.textColor = 0xFFFFFF;
            version.x = 20;
            version.y = 20;
            addChild(version);
            return;
        }
        _ctx = new Context(control);

        // connect game state listeners
        _ctx.control.game.addEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _ctx.control.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, occupantEntered);
        _ctx.control.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);
        _ctx.control.game.addEventListener(StateChangedEvent.CONTROL_CHANGED, controlChanged);
        addEventListener(Event.REMOVED_FROM_STAGE, unload);

        // if we're a watcher, assume the game has already started and fetch data
        if (_ctx.control.game.seating.getMyPosition() == -1) {
            gameStarted();
            _ctx.board.refreshData();
        }

        _ctx.control.game.playerReady();
    }

    /**
     * Game is no longer being displayed; stop the timers.
     */
    protected function unload (event :Event = null) :void
    {
        if (_ctx.state != null) {
            _ctx.state.unload();
        }
        if (_ctx.eventHandler != null) {
            _ctx.eventHandler.unload();
        }
        if (_ctx.board != null) {
            removeChild(_ctx.board);
        }
    }

    /**
     * Fires when all players have called playerReady(), whether for the first time during the
     * constructor or automatically after a rematch has been called.  Have the control player
     * set up the board data then start the first turn.
     */
    protected function gameStarted (event :StateChangedEvent = null) :void
    {
        if (_ctx.board != null) {
            // clear the board and handlers and start fresh during a rematch
            unload();
        }
        
        // create our state, event, and trophy handlers
        _ctx.state = new State(_ctx);
        _ctx.eventHandler = new EventHandler(_ctx);
        _ctx.trophyHandler = new TrophyHandler(_ctx);
        _ctx.board = new Board(_ctx);
        addChild(_ctx.board);
        
        if (_ctx.control.game.amInControl()) {
            beginInit();
        }

        _ctx.notice("Welcome to Laws & Disorder!");
        _ctx.gameStarted = true;
        //_ctx.log("in l&d, turn holder: " + _ctx.control.game.getTurnHolderId());
    }

    /**
     * Have the control player set the distributed data objects to blank arrays.
     * Control player will then wait to hear about it
     * from the server before contiinuing to fill properties with actual data.
     * Also reset deck, hands, and scores for all players.
     */
    protected function beginInit () :void
    {
        if (_ctx.control.game.amInControl()) {
            _ctx.log("I am the controller");
            _ctx.control.net.addEventListener(
                PropertyChangedEvent.PROPERTY_CHANGED, initPropertyChanged);
            var playerCount :int = _ctx.control.game.seating.getPlayerIds().length;

            _ctx.eventHandler.setData(Player.MONIES_DATA, new Array(_ctx.numPlayers).map(
                function () :int { return Player.STARTING_MONIES; }));
            _ctx.eventHandler.setData(Hand.HAND_DATA, new Array(_ctx.numPlayers).map(
                function () :Array { return new Array(); }));
            _ctx.eventHandler.setData(Deck.JOBS_DATA, new Array(_ctx.numPlayers).map(
                function () :int { return -1; }));
        }
    }

    /**
     * Fires when a data event occurs during control player init.  Control player must receive
     * these data initialization messages before they can send the player, hand and deck data in
     * Board.setup().  Other players skip this step.
     */
    protected function initPropertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == Player.MONIES_DATA) {
            _initMoniesData = true;
        }
        else if (event.name == Hand.HAND_DATA) {
            _initHandsData = true;
        }
        else if (event.name == Deck.JOBS_DATA) {
            _initJobsData = true;
        }

        // once all data messages are recieved, disconnect this listener and finish setup
        if (_initMoniesData && _initHandsData && _initJobsData) {
            _initMoniesData = false;
            _initHandsData = false;
            _initJobsData = false;
            
            _ctx.control.net.removeEventListener(
                PropertyChangedEvent.PROPERTY_CHANGED, initPropertyChanged);
            // delay this so that other objects have a chance to clear data
            EventHandler.startTimer(30, 
                function (): void { 
                    _ctx.board.setup();
                    // control player starts the first turn
                    if (_ctx.control.game.amInControl()) {
                        //_ctx.control.game.startNextTurn();
                        if (_ctx.player.isController) {
                            _ctx.sendMessage(EventHandler.TURN_CHANGED);
                        }
                    }
                });
        }
    }

    /**
     * Handler for dealing with players / watchers joining.
     * Players can't join this game on the fly, sorry
     */
    protected function occupantEntered (event :OccupantChangedEvent) :void
    {
        if (event.player && _ctx != null && _ctx.gameStarted) {
            _ctx.error("player joined the game partway through - impossible!");
        }
    }

    /**
     * Handler for dealing with players / watchers leaving
     */
    protected function occupantLeft (event :OccupantChangedEvent) :void
    {
        // player left before game started; start game over and hope that works
        /*if (!_ctx.gameStarted && event.player) {
            if (_ctx != null) {
                _ctx.notice("Player left before the game started.  Attempting to start over.");
            }
            if (_ctx.control.game.amInControl()) {
                gameStarted();
            }
        }
        else */if (event.player) {
            _ctx.board.players.playerLeft(event.occupantId);
        }
    }

    /**
     * Handler for dealing with control switching to another player
     */
    protected function controlChanged (event :StateChangedEvent) :void
    {
        _ctx.notice("Control changed when player left.");
    }

    /** Context */
    protected var _ctx :Context;

    /** Indicates data objects have been setup on the server */
    protected var _initMoniesData :Boolean = false;
    protected var _initHandsData :Boolean = false;
    protected var _initJobsData :Boolean = false;
}
}