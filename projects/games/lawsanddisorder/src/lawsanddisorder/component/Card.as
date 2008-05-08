package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
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

        addEventListener(MouseEvent.MOUSE_DOWN, ctx.state.mouseEventHandler.cardMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, ctx.state.mouseEventHandler.cardMouseUp);
        addEventListener(MouseEvent.CLICK, ctx.state.mouseEventHandler.cardClick);

        super(ctx);
    }

    /**
     * Build the card sprite, the text-only version of the card sprite, and the highlight sprite.
     */
    override protected function initDisplay () :void
    {
        // full version of the card
        cardDisplay = buildCardDisplay();

        // text version of the card for displaying in laws
        textDisplay = buildTextDisplay();

        // create the highlight object but do not add it as a child
        highlightSprite = new Sprite();
        highlightSprite.graphics.lineStyle(5, 0xFFFF00);
        highlightSprite.graphics.drawRect(5, 5, 40, 55);
    }

    /**
     * Create the sprite to display when this card is in a player's hand or in a new law.
     */
    protected function buildCardDisplay () :Sprite
    {
        var cardSprite :Sprite = new Sprite();

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
        cardSprite.addChild(background);

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
            cardSprite.addChild(symbol);
        }

        var cardText :TextField = Content.defaultTextField();
        cardText.text = text;
        cardText.width = 50;
        cardText.height = 60;
        cardText.y = 5;
        cardText.x = 0;
        cardSprite.addChild(cardText);

        return cardSprite;
    }

    /**
     * Create and return the sprite to display when this card is in a law.
     */
    protected function buildTextDisplay () :Sprite
    {
        var textSprite :Sprite = new Sprite();

        // set width to 300 to prevent wrapping, then back to textWidth + padding to fix hitmap
        // TODO seriously?  would setting nowrap or autosize work instead?
        var cardText :TextField = Content.defaultTextField(1.0, "left");
        cardText.width = 300;
        cardText.text = text;
        cardText.width = cardText.textWidth + 5;
        cardText.height = 30;
        textSprite.addChild(cardText);
        textDisplayWidth = cardText.textWidth;

        // create the highlight text object but do not add it as a child
        highlightSpriteText = new Sprite();
        var cardTextHightlight :TextField = Content.defaultTextField(1.0, "left");
        var cardTextFormat :TextFormat =  cardTextHightlight.defaultTextFormat;
        cardTextFormat.color = 0xFFFF00;
        cardTextHightlight.defaultTextFormat = cardTextFormat;
        cardTextHightlight.width = 300;
        cardTextHightlight.text = text;
        cardTextHightlight.width = cardText.textWidth + 5;
        cardTextHightlight.height = 30;
        highlightSpriteText.addChild(cardTextHightlight);

        return textSprite;
    }

    /**
     * Width differs depending on the parent container
     */
    override public function get width () :Number
    {
        if (_cardContainer is Law) {
            return textDisplayWidth;
        }
        else {
            return super.width;
        }
    }

    /**
     * Determine what to display based on our cardContainer.  In laws, display a text element.
     * Anywhere else, display the card proper.
     */
    override protected function updateDisplay () :void
    {
        if (_cardContainer is Law) {
            if (contains(cardDisplay)) {
                removeChild(cardDisplay);
            }
            if (!contains(textDisplay)) {
                addChild(textDisplay);
            }
            buttonMode = false;
        }
        else {
            if (contains(textDisplay)) {
                removeChild(textDisplay);
            }
            if (!contains(cardDisplay)) {
                addChild(cardDisplay);
            }
            buttonMode = true;
        }
    }

    /**
     * Return the rgb hex color (eg 0xFF0000) for this card type
     */
    protected function getColor () :uint
    {
        if (_group == SUBJECT) {
            return 0x004080;
        }
        else if (_group == VERB) {
            return 0xFF3333;
        }
        else if (_group == OBJECT) {
            return 0xFFC600;
        }
        else {
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
                    case Job.DOCTOR:
                        return new Job.SYMBOL_DOCTOR();
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
                    case Job.DOCTOR:
                        return "The Doctor";
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
                        return getEnglishValue(value, "Card");
                    case MONIE:
                        return getEnglishValue(value, "Monie");
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
     * Writes the value out in english, and appends an "s" to the name when
     * plural.  Returns a string such as "One Card" or "Three Monies".
     */
    protected function getEnglishValue (value :int, name :String) :String
    {
        if (value == 1) {
            return "One " + name;
        }
        else if (value == 2) {
            return "Two " + name + "s";
        }
        else if (value == 3) {
            return "Three " + name + "s";
        }
        else if (value == 4) {
            return "Four " + name + "s";
        }
        else if (value == 5) {
            return "Five " + name + "s";
        }
        else {
            return value + name + "s";
        }

    }

    /**
     * Display contents of card for debugging purposes
     */
    override public function toString () :String
    {
        return "card[" + text + " id:"+ id +"]";
    }

    /**
     * Return the parent container of this card.  May not be the display parent if card is
     * being dragged on the board.
     */
    public function get cardContainer () :CardContainer {
        return _cardContainer;
    }

    /**
     * Also change the display mode depending on the type of card container
     */
    public function set cardContainer (cardContainer :CardContainer) :void {
        _cardContainer = cardContainer;
        updateDisplay();
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
        if (_highlighted) {
            if (!cardDisplay.contains(highlightSprite)) {
                cardDisplay.addChild(highlightSprite);
            }

            if (!textDisplay.contains(highlightSpriteText)) {
                textDisplay.addChild(highlightSpriteText)
            }
        }
        else {
            if (cardDisplay.contains(highlightSprite)) {
                cardDisplay.removeChild(highlightSprite);
            }
            if (textDisplay.contains(highlightSpriteText)) {
                textDisplay.removeChild(highlightSpriteText);
            }
        }
    }

    /** Contains card back, symbol, text */
    protected var cardDisplay :Sprite;

    /** Contains text-only version of this card */
    protected var textDisplay :Sprite;

    /** Text width is different from the card display width, and different from textDisplay.width */
    protected var textDisplayWidth :Number;

    /** Display a box around the card when highlighted */
    protected var highlightSprite :Sprite;

    /** Display a box around the card when highlighted and in text form */
    protected var highlightSpriteText :Sprite;

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