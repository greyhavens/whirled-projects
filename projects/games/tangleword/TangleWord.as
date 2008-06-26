package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import flash.text.TextField;

import mx.core.BitmapAsset;

import com.threerings.util.Assert;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.MessageReceivedEvent;

import com.whirled.contrib.Scoreboard;

import com.whirled.game.OccupantChangedEvent;
/**
 * Main game takes care of initializing network connections,
 * maintaining distributed data representation, and responding to events.
 */

[SWF(width="700", height="500")]
public class TangleWord extends Sprite
{
    //
    //
    // PUBLIC METHODS

    // Constructor creates the board, and registers itself for events and other startup
    // information.
    public function TangleWord () :void
    {
        // Register unloader
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // Initialize game data
        _gameCtrl = new GameControl(this);
        
        if (!_gameCtrl.net.isConnected()) {
            // Initialize the background bitmap
            var background :DisplayObject = new Resources.logo();
            Assert.isNotNull(background, "Background bitmap failed to initialize!");
            addChild(background);
            // Error message
            var label :TextField = new TextField();
            label.x = 100;
            label.y = 400;
            label.width = 500;
            label.multiline = true;
            label.htmlText = "<center><p align=\"center\"><font size=\"+2\">TangleWord</font>" +
                "<br/>This game can only be played in <a href=\"http://www.whirled.com\">" +
                "<u>Whirled</u></a>.</p>";
            addChild(label);
            return;
        }

        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        _gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);

        // Create MVC elements
        _controller = new Controller(_gameCtrl, null); // we'll set the model later...
        _display = new Display(_gameCtrl, _controller, "Tangleword v. 1.4.1");
        _model = new Model(_gameCtrl, _display);
        _trophies = new Trophies(_gameCtrl);

        _controller.setModel(_model); // ... as in, right here :)
        addChild(_display);

        _scoreboard = new Scoreboard(_gameCtrl);

        // If the game's already going, do what you have to do to catch up
        if (_gameCtrl.game.isInPlay()) {
            gameDidStart(null);
            if (! _gameCtrl.game.amInControl()) {
                _model.updateFromExistingGame();
            }
        }
    }

    /** Clean up and shut down. */
    public function handleUnload (event :Event) :void
    {
        _display.handleUnload(event);
        _model.handleUnload(event);
    }

    protected function gameDidStart (event :StateChangedEvent) :void
    {
        _gameCtrl.doBatch(function () :void {
            _model.roundStarted();
            _controller.roundStarted();
        });

        // TODO: if the game is already in progress, deduct the start time from the round length;
        // also we need the board to be in the game object
        _display.roundStarted(Properties.ROUND_LENGTH);
    }

    protected function nextRound () :void
    {
        _gameCtrl.game.restartGameIn(1);
        _gameCtrl.services.stopTicker(Server.RESTART);
    }

    protected function handleElementChanged (event :ElementChangedEvent) :void
    {
        if (event.name == Server.SCOREBOARD && event.key == _gameCtrl.game.getMyId()) {
            // Notify the trophy manager to award points-based trophies
            _trophies.handleScoreUpdate(Number(event.oldValue), Number(event.newValue));
        }
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (Server.RESULT_SUCCESS == event.name) {
            var word :String = event.value.word as String;
            var score :Number = event.value.score as Number;
            var points :Array = event.value.points as Array;
            var first :Boolean = event.value.first as Boolean;

            _display.logSuccess(word, score, first ? 1 : 0, points);

            // TODO: Move trophy handling to agent
            _trophies.handleAddWord(word, score);
        } else if (Server.BONUS == event.name) {
            _display.logBonus(event.value as Number);

        } else if (Server.RESULT_UNRECOGNIZED == event.name) {
            _display.logInvalidWord(event.value as String);

        } else if (Server.RESULT_DUPLICATE == event.name) {
            _display.logAlreadyClaimed(event.value as String);

        } else if (Server.COUNTDOWN == event.name) {
            var elapsed :int = int(event.value);
            _display.setTimer(Properties.ROUND_LENGTH - elapsed);

        } else if (Server.RESTART == event.name) {
            // we're in a paused state between games
            elapsed = int(event.value);
            _display.setTimer(Properties.PAUSE_LENGTH - elapsed);
        }
    }

    protected function gameDidEnd (event :StateChangedEvent) :void
    {
        _controller.roundEnded();
        _display.roundEnded(_model, _scoreboard);
        _trophies.handleRoundEnded(_scoreboard);
    }

    /**
       Sets up the game information. This needs to happen after all of the
       MVC objects have been initialized.
    */
    private function startGame () :void
    {
    }

    protected var _scoreboard :Scoreboard;

    /** Game control object */
    private var _gameCtrl :GameControl;

    /** Data interface */
    private var _model :Model;

    /** Data display */
    private var _display :Display;

    /** Data validation */
    private var _controller :Controller;

    /** Trophy manager. */
    private var _trophies :Trophies;

    // PRIVATE CONSTANTS

    /** Key name: shared letter set */
    private static const SHARED_LETTER_SET :String = "Shared Letter Set";

    /** Key name: shared scoreboard */
    private static const SHARED_SCOREBOARD :String = "Shared Scoreboard";
}



}
