package vampire.client.modes
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Command;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.MainLoop;

import flash.events.MouseEvent;

import vampire.client.VampireController;
[RemoteClass(alias="vampire.client.modes.BaseVampireMode")]
public class BaseVampireMode extends AppMode
{
    override protected function enter() :void
    {
        setupUI();
    }
    
    protected function setupUI() :void
    {
        modeSprite.x = 100;
        modeSprite.y = 100;
        modeSprite.graphics.beginFill(0xd0d0e3);
        modeSprite.graphics.drawRect(0, 0, 200, 200);
        modeSprite.graphics.endFill();
        modeSprite.addChild( TextFieldUtil.createField( ClassUtil.shortClassName( this ), {selectable :false}));
        
        var closeButton :SimpleTextButton = new SimpleTextButton( "Close" );
        closeButton.x = modeSprite.width - 50;
        closeButton.y = 0;
        Command.bind( closeButton, MouseEvent.CLICK, VampireController.CLOSE_MODE, MainLoop.instance);
        modeSprite.addChild( closeButton );
    }
    
}
}