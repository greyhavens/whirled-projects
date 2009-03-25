package vampire.client
{
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Command;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.avrg.DraggableSceneObject;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextLineMetrics;

public class PopupQuery extends DraggableSceneObject
{
    public function PopupQuery (ctrl :AVRGameControl, name :String, message :String,
        buttonNames :Array = null, commandsOrFunctions :Array = null, extraArgs :Array = null)
    {

        super(ctrl, name);
        _popupPanel = ClientContext.instantiateMovieClip("HUD", "popup", false);
        _popupPanel.mouseEnabled = true;
        _popupPanel.mouseChildren = true;
        _displaySprite.addChild(_popupPanel);


        _popupTop = _popupPanel["top"] as MovieClip;
        _popupMiddle = _popupPanel["middle"] as MovieClip;
        _popupBottom = _popupPanel["bottom"] as MovieClip;

        _popupText = _popupPanel["popup_text"] as TextField;
        _popupText.multiline = true;
        _popupText.wordWrap = true;
        _displaySprite.addChild(_popupText);

        _buttonHeight = SimpleButton(_popupPanel["button_01"]).height;

        setupText(message);

        if (buttonNames != null) {
            setupCommands(buttonNames, commandsOrFunctions, extraArgs);
        }
        else {
            setupCommands(["Ok"], [null], null);
        }


//        init( new Rectangle(-_popupPanel.width/2, _popupPanel.height/2, _popupPanel.width, _popupPanel.height), 0, 0, 0, 0);


    }

    override protected function addedToDB () :void
    {
        ClientContext.animateEnlargeFromMouseClick(this);
    }

    protected function setupText (message :String): void
    {
        _popupText.text = message;
        var lines :int = _popupText.numLines;
        var lineMetrics :TextLineMetrics = _popupText.getLineMetrics(0);
        _popupText.height = lineMetrics.height * lines + 6 ;//+ _buttonHeight + 10;//4 is the top and bottom gutters
        _popupText.y = -_popupText.height / 2 - 10;
        //See http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/text/TextLineMetrics.html

        //Make the middle panel big enough for the text and buttons, and a little more.
        var entireMiddleHeight :Number = _popupText.height
                                        + _buttonHeight
                                        + GAP_ABOVE_AND_BELOW_TEXT * 2
                                        + GAP_BETWEEN_BUTTON_AND_PANEL_BOTTOM;

        _popupMiddle.scaleY = entireMiddleHeight / _popupMiddle.height;
        _popupMiddle.y = _popupMiddle.height / 2;

        _popupTop.y = _popupMiddle.y - _popupMiddle.height + _popupTop.height;
        _popupBottom.y = _popupMiddle.y;

        init( new Rectangle(-_popupMiddle.width / 2,
                            -_popupMiddle.height / 2,
                            _popupMiddle.width,
                            _popupMiddle.height), 0, 0, 0, 0);
        centerOnViewableRoom();
    }

    protected function setupCommands (buttonNames :Array,
        commandsOrFunctions :Array, extraArgs :Array): void
    {

        if (buttonNames == null || buttonNames.length == 0) {
            buttonNames = ["Ok"];
        }
        var b1 :SimpleButton = _popupPanel["button_01"] as SimpleButton;
        var b2 :SimpleButton = _popupPanel["button_02"] as SimpleButton;
        b1.parent.removeChild(b1);
        b2.parent.removeChild(b2);
        if( buttonNames == null) {
            return;
        }



        for (var i :int = 0; i < buttonNames.length && i < 2; i++) {

            var b :SimpleButton = _popupPanel["button_0" + (i + 1)] as SimpleButton;
            if (b == null) {
                continue;
            }
            _popupPanel.addChild(b);
            //If there is only one button, position it in between the two buttons.
            if (i == 0 && buttonNames.length == 1) {
                b.x = b1.x + (b2.x - b1.x) / 2;
            }

            b.y = _popupMiddle.height / 2 - b.height / 2 - GAP_BETWEEN_BUTTON_AND_PANEL_BOTTOM;

            //Create and add the button text.
            var buttonText :TextField = buttonTextField(buttonNames[i], b.width - 15);
            buttonText.x = b.x - buttonText.width / 2;
            buttonText.y = b.y - buttonText.textHeight / 2;
            b.parent.addChild(buttonText);

            registerListener(b, MouseEvent.ROLL_OVER, function(...ignored) :void {
                buttonText.textColor = 0x990000;
            });
            registerListener(b, MouseEvent.ROLL_OUT, function(...ignored) :void {
                buttonText.textColor = 0xFF0000;
            });
            registerListener(b, MouseEvent.MOUSE_DOWN, function(...ignored) :void {
                buttonText.y += 1;
            });


            if (commandsOrFunctions[i] != null) {
                if (commandsOrFunctions[i] is Function) {
                    registerListener( b, MouseEvent.CLICK, commandsOrFunctions[i]);
                }
                else {
                    if( extraArgs != null &&  i < extraArgs.length) {
                        Command.bind( b, MouseEvent.CLICK, commandsOrFunctions[i], extraArgs[i]);
                    }
                    else {
                        Command.bind( b, MouseEvent.CLICK, commandsOrFunctions[i]);
                    }
                }
            }

            //Also make the buttons shut the popup
            registerListener( b, MouseEvent.CLICK, function(e :MouseEvent) :void {
                destroySelf();
            });
        }
    }

    protected function buttonTextField( buttonText :String, buttonWidth :int ) :TextField
    {
        var buttonTextField :TextField = TextFieldUtil.createField(buttonText);
        buttonTextField.mouseEnabled = false;
        buttonTextField.selectable = false;
        buttonTextField.tabEnabled = false;
        buttonTextField.embedFonts = true;
        var format :TextFormat = getJuiceFormat();

        buttonTextField.antiAliasType = AntiAliasType.ADVANCED;
        buttonTextField.width = buttonWidth - 4;
        buttonTextField.height = 35;
        buttonTextField.setTextFormat( format );

        //Poor mans bold font
        var filter :GlowFilter = new GlowFilter(0xFF0000, 1.0, 1.3, 1.1, 4);
        buttonTextField.filters = [filter];
        return buttonTextField;
    }

    protected function getJuiceFormat () :TextFormat
    {
        var format :TextFormat = new TextFormat();
        format.font = "JuiceEmbedded";
        format.size = 26;
        format.color = 0xFF0000;
        format.align = TextFormatAlign.CENTER;
        format.bold = true;
        return format;
    }





    protected var _popupPanel :MovieClip;

    protected var _popupTop :MovieClip;
    protected var _popupMiddle :MovieClip;
    protected var _popupBottom :MovieClip;

    protected var _popupText :TextField;
    protected var _buttonHeight :Number;
    protected static const GAP_BETWEEN_BUTTON_AND_PANEL_BOTTOM :int = 8;
    protected static const GAP_ABOVE_AND_BELOW_TEXT :int = 15;

}
}