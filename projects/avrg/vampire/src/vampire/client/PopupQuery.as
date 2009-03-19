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
        commands :Array, commandArgs :Array = null)
    {

        trace("con, commands=" + commands);
        trace("con, message=" + message);
        trace("con, name=" + name);
        super(ctrl, name);
        _popupPanel = ClientContext.instantiateMovieClip("HUD", "popup", false);
        _popupPanel.mouseEnabled = true;
        _popupPanel.mouseChildren = true;
        _displaySprite.addChild( _popupPanel );

        registerListener( _popupPanel["popup_close"], MouseEvent.CLICK,
            function( e :MouseEvent ) :void {
                destroySelf();
            });

        commands = ["asdsf", "sdfadsf"]

        trace("con, commandArgs=" + commandArgs);
        setupText(message);
        setupCommands(commands, commandArgs);

//        init( new Rectangle(-_popupPanel.width/2, _popupPanel.height/2, _popupPanel.width, _popupPanel.height), 0, 0, 0, 0);
        init( new Rectangle(-10, -10, 20, 20), 0, 0, 0, 0);
        centerOnViewableRoom();

    }

    protected function setupText (message :String): void
    {
        var tf :TextField = TextFieldUtil.createField( message );
        tf.multiline = true;
        tf.wordWrap = true;
        var format :TextFormat = new TextFormat();
        format.align = TextFormatAlign.CENTER;
        format.size = 20;
        format.color = 0xffffff;
        tf.setTextFormat(format);
        tf.antiAliasType = AntiAliasType.ADVANCED;
        tf.width = _popupPanel.width - 40;
        tf.height = _popupPanel.height - 30;
        tf.x = -tf.width / 2;
        tf.selectable = false;
        tf.mouseEnabled = false;
        _popupPanel.addChild( tf );
    }

    protected function setupCommands (commands :Array, commandArgs :Array = null): void
    {
        trace("setup, commands" + commands);
        if( commands == null) {
            trace("nu;;");
            return;
        }
//        var startX :int = -_popupPanel.width / 2;
        var startY :int = _popupPanel.height / 2 - 50;

        for( var i :int = 0; i < commands.length; i++){
            var command :String = commands[i] as String;
            trace("command="+command);
            //Add this object to the arguments
            var commandArg :Array = [this];
            if( commandArgs != null && i < commandArgs.length) {
                if( commandArgs[i] is Array) {
                    commandArg.concat(commandArgs[i]);
                }
                else {
                    commandArg.push( commandArgs[i] );
                }
            }
            trace("!!!!!!!!adding button");
            var b :SimpleTextButton = new SimpleTextButton(command);
            Command.bind( b, MouseEvent.CLICK, command,  commandArg );
            _popupPanel.addChild( b );
//            b.x = startX;
            b.y = startY;
            startY += 30;
        }
    }





    protected var _popupPanel :MovieClip;

    }
}