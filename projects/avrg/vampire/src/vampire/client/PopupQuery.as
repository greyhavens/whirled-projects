package vampire.client
{
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Command;
import com.whirled.contrib.avrg.RoomDragger;
import com.whirled.contrib.simplegame.objects.DraggableObject;
import com.whirled.contrib.simplegame.objects.Dragger;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class PopupQuery extends DraggableObject
{
    public function PopupQuery (name :String, message :String,
        buttonNames :Array = null, commandsOrFunctions :Array = null)
    {
        super();
        _name = name;
        _popupPanel = ClientContext.instantiateMovieClip("HUD", "popup", false);
        _popupPanel.mouseEnabled = true;
        _popupPanel.mouseChildren = true;
        _displaySprite.addChild(_popupPanel);

        _popupTop = _popupPanel["top"] as MovieClip;
        _popupMiddle = _popupPanel["middle"] as MovieClip;
        _popupBottom = _popupPanel["bottom"] as MovieClip;
        _closeButton = _popupPanel["button_close"] as SimpleButton;

        _buttonPanelSprite.addChild(_closeButton);


        //Close button shuts the popup
        registerListener(_closeButton, MouseEvent.CLICK, function (e :MouseEvent) :void {
            destroySelf();
        });

        _popupText = _popupPanel["popup_text"] as TextField;
        _initialTextHeight = _popupText.height;
        _popupText.multiline = true;
        _popupText.wordWrap = true;
        _displaySprite.addChild(_popupText);

        _buttonHeight = SimpleButton(_popupPanel["button_01"]).height;

        _isBottomButtons = buttonNames != null && buttonNames.length > 0;

        setText(message);

        if (_isBottomButtons) {
            setupCommands(buttonNames, commandsOrFunctions);
            _popupTop = _popupPanel["top"] as MovieClip;
//            _closeButton.parent.removeChild(_closeButton);
        }
        else {
            //If there are no button names, but there IS a function, bind it to the close button
            if (commandsOrFunctions != null && commandsOrFunctions.length > 0) {
                registerListener(_closeButton, MouseEvent.CLICK, function (e :MouseEvent) :void {
                    commandsOrFunctions[0]();
                });
            }

            //Remove the other buttons below the text
            var b1 :SimpleButton = _popupPanel["button_01"] as SimpleButton;
            var b2 :SimpleButton = _popupPanel["button_02"] as SimpleButton;
            b1.parent.removeChild(b1);
            b2.parent.removeChild(b2);

        }

        //Set up the size of the _draggableSprite
        _draggableSprite.graphics.clear();
//        _displaySprite.addChildAt(_draggableSprite, 0);
        _displaySprite.addChild(_draggableSprite);
        _draggableSprite.graphics.beginFill(0,0);
        _draggableSprite.graphics.drawRect(-_displaySprite.width / 2,
                                           -_displaySprite.height / 2 + _popupTop.height * 2,
                                           _displaySprite.width,
                                           _displaySprite.height
//                                                - GAP_BETWEEN_BUTTON_AND_PANEL_BOTTOM
//                                                - _buttonHeight
                                               );
        _draggableSprite.graphics.endFill();
        _displaySprite.addChildAt(_buttonPanelSprite, _displaySprite.numChildren);
    }

    override protected function update(dt:Number) :void
    {
        //Make sure the popup is always on top.
        var parent :DisplayObjectContainer = _displaySprite.parent;
        if (parent != null) {
            if (parent.getChildIndex(_displaySprite) != parent.numChildren - 1) {
                 parent.setChildIndex(_displaySprite, parent.numChildren - 1);
            }
        }
    }

    override public function get objectName () :String
    {
        return _name;
    }

    override protected function createDragger () :Dragger
    {
        return new RoomDragger(ClientContext.ctrl, this.draggableObject, this.displayObject);
    }

    override protected function get draggableObject () :InteractiveObject
    {
        return _draggableSprite;
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
//        ClientContext.animateEnlargeFromMouseClick(this);
    }

    public function setText (message :String): void
    {
//        var m :String;
//        m = "aasfd f asdf asdf asdf sag asg asdg asdg sadg asdg asdf asd fa sdf asdf asd fas dgasd gasd gAAAAAA:"
//        +"sdfljasd f gldf gldf g  sdfg jsdlfg slfdj g slfdgj sldf sldf gl XXXXXXX";
//        m  = "aasfd f asdf asdf asdf sag asg asdg asdg sadg asdg asdf asd fa sdf asdf asd fas dgasd gasd gAAAAAA:";
//        m = "aasfd f asdf asdf asdf ";
        _popupText.height = _initialTextHeight;
        _popupText.text = message;
        _popupText.multiline = true;
        _popupText.wordWrap = true;
        var lines :int = _popupText.numLines;
        var totalLineHeight :Number = 4;
        for (var line :int = 0; line < lines; line++) {
            totalLineHeight += _popupText.getLineMetrics(line).height + 2;
        }
//        var lineMetrics :TextLineMetrics = _popupText.getLineMetrics(0);
        _popupText.height = totalLineHeight;//+ _buttonHeight + 10;//4 is the top and bottom gutters
        //See http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/text/TextLineMetrics.html

        //Make the middle panel big enough for the text and buttons, and a little more.
        var entireMiddleHeight :Number = totalLineHeight
                                        + (_isBottomButtons ? _buttonHeight : 0)
                                        + GAP_ABOVE_AND_BELOW_TEXT * 2
                                        + GAP_BETWEEN_BUTTON_AND_PANEL_BOTTOM;

//        _popupMiddle.scaleY = entireMiddleHeight / _popupMiddle.height;
        _popupMiddle.height = entireMiddleHeight;
        _popupText.y = _popupMiddle.y
                       -_popupMiddle.height
//                       - _popupText.height / 2
                       + GAP_ABOVE_AND_BELOW_TEXT// - 20;
                       + lines / 2;
//        _popupMiddle.y = _popupMiddle.height / 2;

        _popupTop.y = _popupMiddle.y - _popupMiddle.height + 1;// + _popupTop.height;
        _popupBottom.y = _popupMiddle.y;

        //Position the close button
//        _popupText.parent.addChild(_closeButton);
        _closeButton.y = _popupMiddle.getBounds(_popupMiddle.parent).top + 3;
    }

    protected function setupCommands (buttonNames :Array, commandsOrFunctions :Array): void
    {

        if (buttonNames == null || buttonNames.length == 0) {
            buttonNames = ["Ok"];
        }
        var b1 :SimpleButton = _popupPanel["button_01"] as SimpleButton;
        var b2 :SimpleButton = _popupPanel["button_02"] as SimpleButton;
        b1.parent.removeChild(b1);
        b2.parent.removeChild(b2);
        if(buttonNames == null) {
            return;
        }



        for (var i :int = 0; i < buttonNames.length && i < 2; i++) {

            var b :SimpleButton = _popupPanel["button_0" + (i + 1)] as SimpleButton;
            if (b == null) {
                continue;
            }
            _buttonPanelSprite.addChild(b);
//            _popupPanel.addChild(b);
            //If there is only one button, position it in between the two buttons.
            if (i == 0 && buttonNames.length == 1) {
                b.x = b1.x + (b2.x - b1.x) / 2;
            }

            b.y = _popupMiddle.height / 2;//  - b.height / 2 - GAP_BETWEEN_BUTTON_AND_PANEL_BOTTOM;
            b.y = _popupMiddle.y - b.height / 2 - GAP_BETWEEN_BUTTON_AND_PANEL_BOTTOM;

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

            //Bind a command or function to the button
            if (commandsOrFunctions[i] != null) {
                if (commandsOrFunctions[i] is Function) {
                    registerListener(b, MouseEvent.CLICK, commandsOrFunctions[i]);
                }
                else {
                    Command.bind(b, MouseEvent.CLICK, commandsOrFunctions[i]);
                }
            }

            //Also make the buttons shut the popup
            registerListener(b, MouseEvent.CLICK, function(e :MouseEvent) :void {
                destroySelf();
            });
        }
    }

    protected function buttonTextField(buttonText :String, buttonWidth :int) :TextField
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
        buttonTextField.setTextFormat(format);

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

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }



    protected var _name :String;

    protected var _initialTextHeight :Number;
//    protected var _ctrl :AVRGameControl;
    protected var _popupPanel :MovieClip;

    protected var _popupTop :MovieClip;
    protected var _popupMiddle :MovieClip;
    protected var _popupBottom :MovieClip;
    protected var _closeButton :SimpleButton;

    protected var _popupText :TextField;
    protected var _buttonHeight :Number;
    protected var _isBottomButtons :Boolean;

    protected var _displaySprite :Sprite = new Sprite();
    protected var _draggableSprite :Sprite = new Sprite();
    protected var _buttonPanelSprite :Sprite = new Sprite();
    protected static const GAP_BETWEEN_BUTTON_AND_PANEL_BOTTOM :int = 4;
    protected static const GAP_ABOVE_AND_BELOW_TEXT :int = 18;//15;

}
}