package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import lawsanddisorder.Context;
import lawsanddisorder.Content;

/**
 * Base for the three buttons on the left side of the player interface.
 * TODO should this be a fl.controls.Button?
 */
public class Button extends Component
{
    /**
     * Constructor
     */
    public function Button (ctx :Context)
    {
        super(ctx);
    }

    /**
     * Draw the button and initialize the label
     */
    override protected function initDisplay () :void
    {
        var background :Sprite = new BUTTON_BACKGROUND();
        addChild(background);

        textLabel = Content.defaultTextField(1.5);
        textLabel.height = 20;
        textLabel.width = 130;
        textLabel.y = 3;
        addChild(textLabel);

        buttonMode = true;
    }

    /**
     * Set the text of the label for this button
     */
    public function set text (value :String) :void
    {
        textLabel.text = value;
    }

    /**
     * Get the text of this button
     */
    public function get text () :String
    {
        return textLabel.text;
    }

    /**
     * Enable / disable this button
     * TODO does not work - how to correctly prevent click events from firing?
     */
    public function set enabled (value :Boolean) :void
    {
        if (value) {
            textLabel.textColor = 0x000000;
            buttonMode = true;
            mouseEnabled = true;
            _enabled = true;
        }
        else {
            textLabel.textColor = 0x666666;
            buttonMode = false;
            mouseEnabled = false;
            _enabled = false;
        }
    }

    /**
     * Is this button enabled?
     */
    public function get enabled () :Boolean
    {
        return _enabled;
    }

    /** Is this button enabled? */
    protected var _enabled :Boolean;

    /** Text to display for this button */
    protected var textLabel :TextField;

    /** Background image for a button */
    [Embed(source="../../../rsrc/components.swf#button")]
    protected static const BUTTON_BACKGROUND :Class;
}
}