package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

import com.whirled.game.StateChangedEvent;

import lawsanddisorder.Context;
import lawsanddisorder.Content;

/**
 * Area containing details on a single player
 */
public class Opponent extends Player
{
    /**
     * Constructor
     * @param id Identifier for this player according to their position on the board
     * @param serverId Identifier for this player according to the game server
     */
    public function Opponent (ctx :Context, id :int, serverId :int, name :String)
    {
        addEventListener(MouseEvent.CLICK, ctx.state.mouseEventHandler.opponentClick);
        super(ctx, id, serverId, name);
        _ctx.control.game.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);
    }

    /**
     * Opponent jobs are not displayed; override and instead of making job a child, make
     * a new symbol child.
     * TODO use event to trigger this
     */
    override public function set job (job :Job) :void
    {
        _job = job;

        if (jobSymbol != null && contains(jobSymbol)) {
            removeChild(jobSymbol);
        }
        jobSymbol = job.getSymbol();
        jobSymbol.width = jobSymbol.width / 3.5;
        jobSymbol.height = jobSymbol.height / 3.5;
        jobSymbol.x = 65;
        jobSymbol.y = 30;
        //jobSymbol.alpha = 0.1;
        var colorTransform :ColorTransform = new ColorTransform();
        colorTransform.color = 0x660033;
        jobSymbol.transform.colorTransform = colorTransform;
        jobSymbol.alpha = 0.15;
        addChild(jobSymbol);

        updateDisplay();
    }

    /**
     * Initialize the static display
     * TODO cleaner way to instanciate/position all these display elements?
     */
    override protected function initDisplay () :void
    {
        // position hand but do not display it
        _hand.x = -550;
        _hand.y = 0;

        var background :Sprite = new OPPONENT_BACKGROUND();
        addChild(background);

        infoText = Content.defaultTextField(1.2, "left");
        infoText.x = 8;
        infoText.y = 5;
        infoText.height = 80;
        addChild(infoText);

        numMoniesText = Content.defaultTextField(1, "right");
        numMoniesText.x = 2;
        numMoniesText.y = 40;
        numMoniesText.width = 25;
        addChild(numMoniesText);

        //var monieIcon :Sprite = new Card.SYMBOL_MONIE();
        var monieIcon :Sprite = new Content.MONIE_BACK();
        monieIcon.width = monieIcon.width / 3.5;
        monieIcon.height = monieIcon.height / 3.5;
        monieIcon.x = 32;
        monieIcon.y = 42;
        addChild(monieIcon);

        numCardsText = Content.defaultTextField(1, "right");
        numCardsText.x = 37;
        numCardsText.y = 40;
        numCardsText.width = 25;
        addChild(numCardsText);

        //var cardIcon :Sprite = new Card.SYMBOL_CARD();
        var cardIcon :Sprite = new Content.CARD_BACK();
        cardIcon.width = cardIcon.width / 4;
        cardIcon.height = cardIcon.height / 4;
        cardIcon.x = 68;
        cardIcon.y = 40;
        addChild(cardIcon);

        // little icon will be displayed during this opponent's turn
        turnIndicator = new Sprite();
        turnIndicator.graphics.beginFill(0xFFFF00);
        turnIndicator.graphics.drawCircle(0, 0, 8);
        turnIndicator.graphics.endFill();
        turnIndicator.x = 90;
        turnIndicator.y = 20;
    }

    /**
     * Update the changing display
     */
    override protected function updateDisplay () :void
    {
        //title.text = playerName + "\nJob: " + job + "\nMonies: " + monies + "\nCards: " + hand.numCards;
        infoText.text = playerName + "\n" + job;
        numMoniesText.text = String(monies);
        numCardsText.text = String(hand.numCards);
    }

    /** Is this opponent selected?
     * TODO rename to selected, find out where this is called that state can't be polled
     */
    public function get highlighted () :Boolean {
        return _highlighted;
    }

    /** Indicate that the opponent is selected
     * TODO does state need to be stored?
     */
    public function set highlighted (value :Boolean) :void {
        _highlighted = value;
        /*
        // draw a border, highlighted or not
        if (value) {
            graphics.lineStyle(5, 0xFFFF00);
        }
        else {
            graphics.lineStyle(5, 0x8888FF);
        }
        graphics.drawRect(5, 5, 110, 50);
        */
    }

    /**
     * The turn just changed.  Display whether it is this opponent's turn.
     */
    protected function turnChanged (event :StateChangedEvent) :void
    {
        var turnHolder :Player = _ctx.board.getTurnHolder();
        if (turnHolder == this) {
            if (!contains(turnIndicator)) {
                addChild(turnIndicator);
            }
            //graphics.lineStyle(5, 0xFFFF00);
        }
        else {
            if (contains(turnIndicator)) {
                removeChild(turnIndicator);
            }
            //graphics.lineStyle(5, 0x8888FF);
        }
        //graphics.drawRect(0, 0, 120, 60);
    }

    /** Indicates if it is the opponent's turn
     * TODO better name that doesn't conflict with TurnIndicator class
     */
    protected var turnIndicator :Sprite;

    /** Displays the number of monies */
    protected var numMoniesText :TextField;

    /** Displays the number of cards */
    protected var numCardsText :TextField;

    /** Displays opponent's name, job, etc */
    protected var infoText :TextField;

    /** Is the opponent highlighted? */
    protected var _highlighted :Boolean = false;

    /** Symbol for the current job */
    protected var jobSymbol :Sprite;

    /** Background image for an opponent */
    [Embed(source="../../../rsrc/components.swf#opponent")]
    protected static const OPPONENT_BACKGROUND :Class;
}
}