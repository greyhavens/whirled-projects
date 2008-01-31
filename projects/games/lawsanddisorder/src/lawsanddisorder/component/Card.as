package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import lawsanddisorder.Context;

/**
 * A single card element
 */
public class Card extends Component
{
    /**
     * Constructor for a new card object.
     * @param id Identifer for the card in the global sorted deck
     * @param group Supertype of card (SUBJECT, VERB, OBJECT)
     * @param type Depends on type of card (which SUBJECT, what VERB, what kind of OBJECT)
     * @param value Only for OBJECT, how many cards/monies
     */
    public function Card (ctx :Context, id :int, group :int, type :int, value :int)
    {
        _id = id;
        _group = group;
        _type = type;
        _value = value;

        buttonMode = true;
        mouseEnabled = true;
        addEventListener(MouseEvent.MOUSE_DOWN, ctx.state.cardMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, ctx.state.cardMouseUp);
        addEventListener(MouseEvent.CLICK, ctx.state.cardClick);
        
        super(ctx);
    }
    
    /**
     * Return the text for the card face
     */
    public function get text () :String
    {
        switch (group) {
            case SUBJECT:
                switch (type) {
                    case Job.JUDGE:
                        return "Judge";
                    case Job.THIEF:
                        return "Thief";
                    case Job.BANKER:
                        return "Banker";
                    case Job.TRADER:
                        return "Trader";
                    case Job.PRIEST:
                        return "Priest";
                    case Job.SCIENTIST:
                        return "Scientist";
                }
                break;
            case VERB:
                switch (type) {
                    case GETS:
                        return "Gets";
                    case GIVES:
                        return "Gives";
                    case LOSES:
                        return "Loses";
                }
                break;
            case OBJECT:
                switch (type) {
                    case CARD:
                        if (value == 1) {
                            return "1 Card";
                        }
                        else {
                            return value + " Cards";
                        }
                    case MONIE:
                        if (value == 1) {
                            return "1 Monie";
                        }
                        else {
                            return value + " Monies";
                        }
                }
                break;
            case WHEN:
                switch (type) {
                    case START_TURN:
                       return "When their turn starts";
                    case CREATE_LAW:
                       return "When a law is created";
                    case USE_ABILITY:
                       return "When they use an ability";
                }
                break;
        }
        return "UNKNOWN";
    }
    
    /**
     * Draw the card sprite
     */
    override protected function initDisplay () :void
    {
        graphics.clear();
        graphics.beginFill(0x4499EE);
        graphics.drawRect(0, 0, 40, 60);
        graphics.endFill();
        
        title.text = text + " [" + id + "]";
        title.width = 40;
        title.height = 60;
        
        if (_group == SUBJECT) {
            graphics.lineStyle(2, 0x0000FF, 0.5);
        }
        else if (_group == VERB) {
            graphics.lineStyle(2, 0xFF0000, 0.5);
        }
        else if (_group == OBJECT) {
        	graphics.lineStyle(2, 0xFFFF00, 0.5);
        }
        else {
        	graphics.lineStyle(2, 0xFF00FF, 0.5);
        }
        graphics.drawRect(0, 0, 40, 60);
    }
    
    /**
     * Draw a border in one of two colours.
     */
    override protected function updateDisplay () :void
    {
        if (_highlighted) {
            graphics.lineStyle(5, 0xFFFF00);
        }
        else {
            graphics.lineStyle(5, 0x4499EE);
        }
        graphics.drawRect(5, 5, 30, 50);
    }
    
    /**
     * Display contents of card for debugging purposes
     */
    override public function toString() :String
    {
        return "card[" + text + " id:"+ id +"]";
    }
    
    public function get cardContainer () :CardContainer {
        return _cardContainer;
    }
    public function set cardContainer (cardContainer :CardContainer) :void {
        _cardContainer = cardContainer;
    }
    public function get id () :int {
        return _id;
    }
    public function get group () :int {
        return _group;
    }
    public function get type () :int {
        return _type;
    }
    public function get value () :int {
        return _value;
    }
    
    /**
     * Override the startDrag function to record that we are dragging.
     * TODO isn't there some better way to determine if a DisplayObject is being dragged?
     */
    override public function startDrag (lockCenter :Boolean = false, bounds: Rectangle = null) :void
    {
        super.startDrag(lockCenter, bounds);
        _dragging = true;
    }
    
    /**
     * Override the stopDrag function to record that we are no longer dragging.
     */
    override public function stopDrag () :void
    {
        super.stopDrag();
        _dragging = false;
    }
    
    /**
     * Return whether this card is currently being dragged.
     */
    public function get dragging () :Boolean {
        return _dragging;
    }
    
    /**
     * Is the card displaying that it is selected?     */
    public function get highlighted () :Boolean {
        return _highlighted;
    }
    
    /**
     * Change whether the card appears selected     */
    public function set highlighted (value :Boolean) :void {
        _highlighted = value;
        updateDisplay();
    }
    
    /** Is the card highlighted? */
    private var _highlighted :Boolean = false;
    
    /** Is this card being dragged? */
    private var _dragging :Boolean = false;

    /** Parent CardContainer object */
    private var _cardContainer :CardContainer;
    
    /** Identifier for this card in the sorted global deck */
    private var _id :int;
    
    /** Supergroup of card SUBJECT/VERB/OBJECT/WHEN */
    private var _group :int; 
    
    /** Subtype JUDGE/PRIEST/GETS/GIVES/CARD/MONIE/START_TURN etc */
    private var _type :int; 
    
    /** 0/1/2 etc for card types with values eg CARD, MONIE */
    private var _value :int;
    
    /** card groups */
    public static const SUBJECT :int = 0;
    public static const VERB :int = 1;
    public static const OBJECT :int = 2;
    public static const WHEN :int = 3;
    
    /** subject types are stored in Job */
    
    /** verb types */
    public static const GETS :int = 0;
    public static const GIVES :int = 1;
    public static const LOSES :int = 2;
    
    /** object types */
    public static const CARD :int = 0;
    public static const MONIE :int = 1;
    
    /** when types */
    public static const START_TURN :int = 0;
    public static const CREATE_LAW :int = 1;
    public static const USE_ABILITY :int = 2;
    
}
}