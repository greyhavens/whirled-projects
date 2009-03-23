package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Command;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.avrg.DraggableSceneObject;

import flash.display.MovieClip;
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
//        trace("setup, commands" + commands);
        if( buttonNames == null) {
//            trace("nu;;");
            return;
        }
//        var startX :int = -_popupPanel.width / 2;
        var startY :int = _popupPanel.height / 2 - 50;

        for (var i :int = 0; i < buttonNames.length; i++) {

            var b :SimpleTextButton = new SimpleTextButton(buttonNames[i] as String);

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

            _popupPanel.addChild( b );
//            b.x = startX;
            b.y = startY;
            startY += 30;
        }
    }





    protected var _popupPanel :MovieClip;
    protected var _popupText :TextField;

    }
}