package lawsanddisorder {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.Timer;

import lawsanddisorder.component.*;

/**
 * Layout of the game board.  Components such as Player can be publicly accessed through here.
 */
public class Board extends Sprite
{
    /**
     * Constructor.  Create board components and display them, but don't fill them with
     * distributed data (eg cards in hands) just yet.
     */
    public function Board (ctx :Context)
    {
        _ctx = ctx;
        _ctx.eventHandler.addEventListener(EventHandler.MY_TURN_ENDED, myTurnEnded);
        _ctx.eventHandler.addEventListener(EventHandler.MY_TURN_STARTED, myTurnStarted);

        // display background
        var background :Sprite = new BOARD_BACKGROUND();
        background.mouseEnabled = false;
        addChild(background);

        // help button in bottom right corner displays help screen
        var helpButton :Sprite = new Sprite();
        var helpButtonText :TextField = Content.defaultTextField(2.0);
        var helpButtonFormat :TextFormat =  helpButtonText.defaultTextFormat;
        helpButtonFormat.color = 0xFFFFFF;
        helpButtonText.defaultTextFormat = helpButtonFormat;
        helpButtonText.width = 20;
        helpButtonText.height = 30;
        helpButtonText.text = "?";
        helpButton.addChild(helpButtonText);
        helpButton.x = 670;
        helpButton.y = 465;
        helpButton.buttonMode = true;
        helpButton.addEventListener(MouseEvent.CLICK, helpButtonClicked);
        addChild(helpButton);

        deck = new Deck(_ctx);
        deck.x = 30;
        deck.y = 320;
        addChild(deck);

        newLaw = new NewLaw(_ctx);
        newLaw.x = 160;
        newLaw.y = 200;

        // list of laws
        laws = new Laws(_ctx);
        laws.x = 160;
        laws.y = 15;
        addChild(laws);
        
        notices = new Notices(_ctx);
        notices.x = 170;
        notices.y = 350;
        addChild(notices);
        
        // current player and opponents
        players = new Players(_ctx);
        addChild(players);

        // use power / cancel button
        usePowerButton = new UsePowerButton(_ctx);
        usePowerButton.x = 9;
        usePowerButton.y = 180;
        addChild(usePowerButton);

        createLawButton = new CreateLawButton(_ctx);
        createLawButton.x = 9;
        createLawButton.y = 225;
        addChild(createLawButton);

        endTurnButton = new EndTurnButton(_ctx, this);
        endTurnButton.x = 9;
        endTurnButton.y = 270;
        addChild(endTurnButton);

        // show the splash screen over the entire board
        helpScreen = new SPLASH_SCREEN();
        helpScreen.addEventListener(MouseEvent.CLICK, helpScreenClicked);
        helpScreen.buttonMode = true;
        addChild(helpScreen);
        
        // version
        var version :TextField = new TextField();
        version.text = "v " + LawsAndDisorder.VERSION;
        version.height = 20;
        version.y = 485;
        addChild(version);

        // displayed during the player's turn
        turnHighlight = new Sprite();
        turnHighlight.graphics.lineStyle(8, 0xFFFF00);
        turnHighlight.graphics.drawRect(3, 3, 694, 494);
    }
    
    /**
     * Setup is only performed by the player who is in control at the start of the game.
     * Called by the controller player; add cards to deck, deal hands, assign jobs to players.
     */
    public function setup () :void
    {
        deck.setup();
        laws.setup();
        players.setup();
        _setupComplete = true;
    }

    /**
     * Player clicked the splash screen; remove it and signal game start
     */
    protected function helpScreenClicked (event :MouseEvent) :void
    {
        if (contains(helpScreen)) {
           removeChild(helpScreen);
        }
    }

    /**
     * Player clicked the help button, display the help screen
     */
    protected function helpButtonClicked (event :MouseEvent) :void
    {
        if (!contains(helpScreen)) {
           addChild(helpScreen);
        }
    }

    /**
     * For watchers who join partway through the game, fetch the existing board data
     */
    public function refreshData () :void
    {
        laws.refreshData();
        players.refreshData();
        deck.refreshData();
    }

    /**
     * Remove a card from the board layer
     */
    public function removeCard (card :Card) :void
    {
        if (contains(card)) {
            try {
                removeChild(card);
            } catch (error :ArgumentError) {
                return;
            }
        }
    }

    /**
     * Indicate that it is now the player's turn
     */
    protected function myTurnStarted (event :Event) :void
    {
        if (!contains(turnHighlight)){
            addChild(turnHighlight);
        }
    }

    /**
     * Handler for end turn event - remove newlaw and turn highlight
     */
    protected function myTurnEnded (event :Event) :void
    {
        if (contains(newLaw)) {
            removeChild(newLaw);
        }
        if (contains(turnHighlight)){
            removeChild(turnHighlight);
        }
    }

    /** Displays a help screen overlay */
    protected var helpScreen :Sprite;

    /** Displays in-game messages to the player */
    public var notices :Notices;

    /** Button for using power */
    public var usePowerButton :UsePowerButton;

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
    
    /** Current player */
    public var players :Players;

    /** Indicates that the game may start */
    protected var _setupComplete :Boolean = false;

    /** Game context */
    protected var _ctx :Context;

    /** Displays to indicate it is the player's turn */
    protected var turnHighlight :Sprite;

    /** Background image for the entire board */
    [Embed(source="../../rsrc/components.swf#bg")]
    protected static const BOARD_BACKGROUND :Class;

    /** Background image for the entire board */
    [Embed(source="../../rsrc/components.swf#splash")]
    protected static const SPLASH_SCREEN :Class;
}
}