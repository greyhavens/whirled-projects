package
{

import com.whirled.game.GameControl;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Point;


/** The Controller class holds game logic, and updates game state in the model. */
    
public class Controller 
{
    // PUBLIC METHODS
    
    public function Controller (gameCtrl :GameControl, model :Model) :void
    {
        _gameCtrl = gameCtrl;
        _model = model;
    }

    /** Called when the round starts - enables user input, randomizes data. */
    public function roundStarted () :void
    {
        initializeLetterSet();
        enabled = true;
    }

    /** Called when the round ends - disables user input. */
    public function roundEnded () :void
    {
        enabled = false;
    }

    /** Update model that's being controlled. */
    public function setModel (model :Model) :void
    {
        _model = model;
    }

    /** Returns true if the controller should accept player inputs, false otherwise */
    public function get enabled () :Boolean
    {
        return _enabled;
    }

    /** Sets the value specifying whether the controller should accept player inputs */
    public function set enabled (value :Boolean) :void
    {
        _enabled = value;
    }
    
    /** 
     * Signals that the currently selected word is a candidate for scoring.
     * It will be matched against the dictionary, and added to the model.
     * @throws TangleWordError if choice is completely bogus.
     */
    public function tryScoreWord (word :String) :void
    {
        // Normalize the word
        word = word.toLowerCase();

        _model.validate(word);

        _gameCtrl.net.agent.sendMessage(Server.SUBMIT, word);
    }

    // PRIVATE METHODS

    /** If this client is the host, initializes a new letter set. */
    private function initializeLetterSet () :void
    {
        if (_gameCtrl.game.amInControl()) {
            _gameCtrl.services.getDictionaryLetterSet(
                Properties.LOCALE, null, Properties.LETTER_COUNT, _model.sendNewLetterSet);
        }
    }

    // PRIVATE VARIABLES

    /** Game helper */
    private var _gameCtrl :GameControl;
    
    /** Game data interface */
    private var _model :Model;

    /** Does the controller accept user input? */
    private var _enabled :Boolean;
}
}
