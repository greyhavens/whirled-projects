package vampire.client
{
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Command;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.avrg.DraggableSceneObject;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class PopupQuery extends DraggableSceneObject
{
    public function PopupQuery (ctrl :AVRGameControl, name :String, message :String,
        buttonNames :Array = null, commandsOrFunctions :Array = null, extraArgs :Array = null)
    {

//        trace("con, commands=" + commands);
//        trace("con, message=" + message);
//        trace("con, name=" + name);
        super(ctrl, name);
        _popupPanel = ClientContext.instantiateMovieClip("HUD", "popup", false);
        _popupPanel.mouseEnabled = true;
        _popupPanel.mouseChildren = true;
        _displaySprite.addChild( _popupPanel );

        _popupText = _popupPanel["popup_text"] as TextField;


        registerListener( _popupPanel["popup_close"], MouseEvent.CLICK,
            function( e :MouseEvent ) :void {
                destroySelf();
            });

//        commands = ["asdsf", "sdfadsf"]

//        trace("con, commandArgs=" + commandArgs);
        setupText(message);
        if (buttonNames != null) {
            setupCommands(buttonNames, commandsOrFunctions, extraArgs);
        }
        else {
            setupCommands(["Ok"], [null], null);
        }


//        init( new Rectangle(-_popupPanel.width/2, _popupPanel.height/2, _popupPanel.width, _popupPanel.height), 0, 0, 0, 0);
        init( new Rectangle(-10, -10, 20, 20), 0, 0, 0, 0);
        centerOnViewableRoom();

    }

    override protected function addedToDB () :void
    {
        ClientContext.animateEnlargeFromMouseClick(this);
    }

    protected function setupText (message :String): void
    {
        _popupText.text = message;
        _popupText.y = -_popupText.textHeight/2;
    }

    protected function setupCommands (buttonNames :Array,
        commandsOrFunctions :Array, extraArgs :Array): void
    {

        if (buttonNames == null || buttonNames.length == 0) {
            buttonNames = ["Ok"];
        }
        var b1 :SimpleButton = _popupPanel["button_01"] as SimpleButton;
        var b2 :SimpleButton = _popupPanel["button_02"] as SimpleButton;
        trace("b1=" + b1);
        b1.parent.removeChild(b1);
        b2.parent.removeChild(b2);
//        trace("setup, commands" + commands);
        if( buttonNames == null) {
//            trace("nu;;");
            return;
        }



        for (var i :int = 0; i < buttonNames.length && i < 2; i++) {

            var b :SimpleButton = _popupPanel["button_0" + (i + 1)] as SimpleButton;
            if (b == null) {
                continue;
            }
//            b.gotoAndStop(1);

            trace("adding button");
            _popupPanel.addChild(b);
            if (i == 0 && buttonNames.length == 1) {
                b.x = b1.x + (b2.x - b1.x) / 2;
            }

            var buttonText :TextField = buttonTextField(buttonNames[i]);
            buttonText.x = b.x - buttonText.width / 2;
            buttonText.y = b.y - buttonText.textHeight / 2;
            b.parent.addChild(buttonText);


//            trace("b[button_text]=" + b.g["button_text"]);
//            TextField(b["button_text"]).text = buttonNames[i];
//            TextField(b["button_text"]).selectable = false;

//            registerListener(b, MouseEvent.ROLL_OVER, function(...ignored) :void {
//                b.gotoAndStop(2);
//            });
//            registerListener(b, MouseEvent.ROLL_OUT, function(...ignored) :void {
//                trace("mouse out");
//                b.gotoAndStop(1);
//            });
//            registerListener(b, MouseEvent.CLICK, function(...ignored) :void {
//                b.gotoAndStop(1);
//            });

            //buttonNames[i] as String

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

//            Command.bind( b, MouseEvent.CLICK, command,  commandArg );

            //Also make the buttons shut the popup
            registerListener( b, MouseEvent.CLICK, function(e :MouseEvent) :void {
                destroySelf();
            });

//            b.x = startX;
//            b.y = startY;
//            startY += 30;
        }
    }

    protected function buttonTextField( buttonText :String ) :TextField
    {
        var buttonTextField :TextField = TextFieldUtil.createField(buttonText);
        buttonTextField.mouseEnabled = false;
        buttonTextField.selectable = false;
        buttonTextField.tabEnabled = false;
        buttonTextField.textColor = 0x000000;
        buttonTextField.embedFonts = true;
        var format :TextFormat = getJuiceFormat();
        format.align = TextFormatAlign.CENTER;
        buttonTextField.setTextFormat( format );

        buttonTextField.antiAliasType = AntiAliasType.ADVANCED;
        buttonTextField.width = 100;
        buttonTextField.height = 35;
        return buttonTextField;
    }

    protected function getJuiceFormat () :TextFormat
    {
        var format :TextFormat = new TextFormat();
        format.font = "JuiceEmbedded";
        format.size = 26;
        format.color = 0x000000;
        format.align = TextFormatAlign.CENTER;
        format.bold = true;
        return format;
    }





    protected var _popupPanel :MovieClip;
    protected var _popupText :TextField;

    }
}