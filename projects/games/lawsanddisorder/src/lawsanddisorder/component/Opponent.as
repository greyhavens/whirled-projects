package lawsanddisorder.component {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.text.TextField;

import lawsanddisorder.*;

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
        _ctx.eventHandler.addEventListener(EventHandler.TURN_CHANGED, turnChanged);
    }

    /**
     * Opponent jobs are not displayed; override and instead of making job a child, make
     * a new symbol child.
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
        
        var colorTransform :ColorTransform = new ColorTransform();
        colorTransform.color = 0x660033;
        jobSymbol.transform.colorTransform = colorTransform;
        jobSymbol.alpha = 0.15;
        addChild(jobSymbol);

        updateDisplay();
    }

    /**
     * Initialize the static display
     */
    override protected function initDisplay () :void
    {
        // position hand for theif stealing events but do not display it
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

        var cardIcon :Sprite = new Content.CARD_BACK();
        cardIcon.width = cardIcon.width / 4;
        cardIcon.height = cardIcon.height / 4;
        cardIcon.x = 68;
        cardIcon.y = 40;
        addChild(cardIcon);

        // create the highlight object but do not add it as a child
        highlightSprite = new Sprite();
        highlightSprite.graphics.lineStyle(5, 0xFFFF00);
        highlightSprite.graphics.drawRect(5, 5, 80, 45);
        highlightSprite.x = 5;
        highlightSprite.y = 5;
    }

    /**
     * Update the changing display
     */
    override protected function updateDisplay () :void
    {
        infoText.text = job + "\n" + _name;
        numMoniesText.text = String(monies);
        numCardsText.text = String(hand.numCards);
    }

    /** Is this opponent selected?
     * TODO rename to selected, find out where this is called that state can't be polled
     */
    public function get highlighted () :Boolean {
        return _highlighted;
    }

    /**
     * Indicate that the opponent is selected
     */
    public function set highlighted (value :Boolean) :void {
        _highlighted = value;
    }

    /**
     * Display the player's / opponent's hand
     */
    public function set showHand (value :Boolean) :void
    {
        if (value && !contains(hand)) {
            addChild(hand);
        }
        else if (!value && contains(hand)) {
            removeChild(hand);
        }
    }
    
    public function getGlobalHandLocation () :Point
    {
        return localToGlobal(new Point(0, 0));
    }

    /**
     * The turn just changed.  Display whether it is this opponent's turn.
     */
    protected function turnChanged (event :Event) :void
    {       
        if (_ctx.board.players.turnHolder == this) {
            infoText.textColor = 0x990000;
            if (!contains(highlightSprite)) {
                addChildAt(highlightSprite, 1);
            }
        } else {
            infoText.textColor = 0x000000;
            if (contains(highlightSprite)) {
                removeChild(highlightSprite);
            }
        }
    }

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

    /** Display a box around the card when highlighted */
    protected var highlightSprite :Sprite;

    /** Background image for an opponent */
    [Embed(source="../../../rsrc/components.swf#opponent")]
    protected static const OPPONENT_BACKGROUND :Class;
}
}