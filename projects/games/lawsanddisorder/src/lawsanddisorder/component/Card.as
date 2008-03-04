package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;
import flash.filters.ColorMatrixFilter;

import lawsanddisorder.Context;
import lawsanddisorder.Content;

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
     * Draw the card sprite
     */
    override protected function initDisplay () :void
    {
        var color :uint = getColor();
        var red :int = (color >> 16) & 0xFF;
        var green :int = (color >> 8) & 0xFF;
        var blue :int = (color >> 0) & 0xFF;
		
        var background :Sprite = new CARD_BACKGROUND();
        background.mouseEnabled = false;
		var resultColorTransform:ColorTransform = new ColorTransform();
		resultColorTransform.redOffset = red;
		resultColorTransform.greenOffset = green;
		resultColorTransform.blueOffset = blue;
		background.transform.colorTransform = resultColorTransform;
        addChild(background);

        var symbol :Sprite = getSymbol();
        if (symbol != null) {
            symbol.width = symbol.width / 4;
            symbol.height = symbol.height / 4;
            symbol.x = 26;
            symbol.y = 40;
            var colorTransform :ColorTransform = new ColorTransform();
            colorTransform.color = color;
            symbol.transform.colorTransform = colorTransform;
            symbol.alpha = 0.5;
            symbol.mouseEnabled = false;
            addChild(symbol);
        }
		
        cardText = Content.defaultTextField();
        cardText.text = text;
        cardText.width = 45;
        cardText.height = 60;
        cardText.y = 5;
        cardText.x = 3;
        addChild(cardText);
		
		// create the highlight object but do not add it as a child
		highlightSprite = new Sprite();
		highlightSprite.graphics.lineStyle(5, 0xFFFF00);
		highlightSprite.graphics.drawRect(5, 5, 40, 55);
    }
    
    /**
     * Return the rgb hex color (eg 0xFF0000) for this card type
     */
    protected function getColor () :uint
    {
        if (_group == SUBJECT) {
            //return 0x0000FF;
			return 0x004080;
        }
        else if (_group == VERB) {
			return 0xFF3333;
            //return 0xFF0000;
        }
        else if (_group == OBJECT) {
			return 0xFFC600;
            //return 0xFFFF00;
        }
        else {
            //return 0xFF00FF;
			return 0xA800A8;
        }
    }
    
    /**
     * Generate and return a new sprite containing the symbol for this card, or null
     * if there is no symbol for this card.
     * TODO make these MovieClips instead?
     */
	protected function getSymbol () :Sprite
	{
	    switch (group) {
	        case SUBJECT:
	            switch (type) {
	                case Job.JUDGE:
	                    return new Job.SYMBOL_JUDGE();
	                case Job.THIEF:
	                    return new Job.SYMBOL_THIEF();
	                case Job.BANKER:
	                    return new Job.SYMBOL_BANKER();
	                case Job.TRADER:
	                    return new Job.SYMBOL_TRADER();
	                case Job.PRIEST:
	                    return new Job.SYMBOL_PRIEST();
	                case Job.SCIENTIST:
	                    return new Job.SYMBOL_SCIENTIST();
	            }
                break;
            case VERB:
                switch (type) {
                    case GETS:
                        return new SYMBOL_GETS();
                    case GIVES:
                        return new SYMBOL_GIVES();
                    case LOSES:
                        return new SYMBOL_LOSES();
                }
                break;
	        case OBJECT:
	            switch (type) {
	                case CARD:
	                    return new SYMBOL_CARD();
	                case MONIE:
	                    return new SYMBOL_MONIE();
	            }
                break;
	    }
	    return null;
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
                        return "The Judge";
                    case Job.THIEF:
                        return "The Thief";
                    case Job.BANKER:
                        return "The Banker";
                    case Job.TRADER:
                        return "The Trader";
                    case Job.PRIEST:
                        return "The Priest";
                    case Job.SCIENTIST:
                        return "The Scientist";
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
     * Return whether this card is currently being dragged.
     */
    public function get dragging () :Boolean {
        return _dragging;
    }
    
    /**
     * Return whether this card is currently being dragged.
     */
    public function set dragging (value :Boolean) :void {
        _dragging = value;
    }
    
    /**
     * Is the card displaying that it is selected?
     */
    public function get highlighted () :Boolean {
        return _highlighted;
    }
    
    /**
     * Change whether the card appears selected
     */
    public function set highlighted (value :Boolean) :void {
        _highlighted = value;
        //updateDisplay();
		//graphics.clear();
        if (_highlighted) {
			if (!contains(highlightSprite)) {
				addChild(highlightSprite);
			}
        //    graphics.lineStyle(5, 0xFFFF00);
        //    graphics.drawRect(5, 5, 40, 55);
        }
		else {
			if (contains(highlightSprite)) {
				removeChild(highlightSprite);
			}
		}
    }
    
	/** Display a box around the card when highlighted */
	protected var highlightSprite :Sprite;
	
    /** Text on the card */
    protected var cardText :TextField;
    
    /** Is the card highlighted? */
    protected var _highlighted :Boolean = false;
    
    /** Is this card being dragged? */
    protected var _dragging :Boolean = false;

    /** Parent CardContainer object */
    protected var _cardContainer :CardContainer;
    
    /** Identifier for this card in the sorted global deck */
    protected var _id :int;
    
    /** Supergroup of card SUBJECT/VERB/OBJECT/WHEN */
    protected var _group :int; 
    
    /** Subtype JUDGE/PRIEST/GETS/GIVES/CARD/MONIE/START_TURN etc */
    protected var _type :int; 
    
    /** 0/1/2 etc for card types with values eg CARD, MONIE */
    protected var _value :int;
    
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
	
	[Embed(source="../../../rsrc/symbols.swf#card")]
	public static const SYMBOL_CARD :Class;
	
	[Embed(source="../../../rsrc/symbols.swf#monie")]
	public static const SYMBOL_MONIE :Class;
    
    [Embed(source="../../../rsrc/symbols.swf#gets")]
    protected static const SYMBOL_GETS :Class;
    
    [Embed(source="../../../rsrc/symbols.swf#gives")]
    protected static const SYMBOL_GIVES :Class;
    
    [Embed(source="../../../rsrc/symbols.swf#loses")]
    protected static const SYMBOL_LOSES :Class;
    
    [Embed(source="../../../rsrc/components.swf#card")]
    protected static const CARD_BACKGROUND :Class;
}
}