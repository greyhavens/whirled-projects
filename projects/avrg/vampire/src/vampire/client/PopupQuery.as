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
import flash.text.TextField;

public class PopupQuery extends DraggableSceneObject
{
    public function PopupQuery(ctrl :AVRGameControl, name :String, message :String,
        commands :Array, commandArgs :Array = null)
    {

        super(ctrl, name);
        _popupPanel = ClientContext.instantiateMovieClip("HUD", "popup", false);
        _popupPanel.mouseEnabled = true;
        _popupPanel.mouseChildren = true;
        _displaySprite.addChild( _popupPanel );

        registerListener( _popupPanel["popup_close"], MouseEvent.CLICK,
            function( e :MouseEvent ) :void {
                destroySelf();
            });

        setupText( message );
        setupCommands( commands, commandArgs );

//        init( new Rectangle(-_popupPanel.width/2, _popupPanel.height/2, _popupPanel.width, _popupPanel.height), 0, 0, 0, 0);
        init( new Rectangle(-10, -10, 20, 20), 0, 0, 0, 0);
        centerOnViewableRoom();

    }

    protected function setupText( message :String): void
    {
        var tf :TextField = TextFieldUtil.createField( message );
        _popupPanel.addChild( tf );
    }

    protected function setupCommands( commands :Array, commandArgs :Array = null): void
    {

        var startX :int = _popupPanel.width / 2;
        var startY :int = _popupPanel.height / 2 - 30;

        for( var i :int = 0; i < commands.length; i++){
            var command :String = commands[i] as String;
            var commandArg :Object = null;
            if( commandArgs != null && i < commandArgs.length) {
                commandArg = commandArgs[i] as Object;
            }
            var b :SimpleTextButton = new SimpleTextButton(command);
            Command.bind( b, MouseEvent.CLICK, command, commandArg );
            _popupPanel.addChild( b );
            b.x = startX;
            b.y = startY;
            startX += 50;
        }
    }





    protected var _popupPanel :MovieClip;

    }
}