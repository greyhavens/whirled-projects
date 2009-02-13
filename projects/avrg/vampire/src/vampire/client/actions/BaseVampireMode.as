package vampire.client.actions
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Command;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.MainLoop;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import vampire.client.ClientContext;
import vampire.client.DraggableSprite;
import vampire.client.VampireController;
import vampire.data.Constants;


[RemoteClass(alias="vampire.client.modes.BaseVampireMode")]
public class BaseVampireMode extends AppMode
{
    
    public function BaseVampireMode()
    {
        super();
        _modeSprite = new DraggableSprite( ClientContext.gameCtrl, "actionwindow");
        _modeSprite.y = 60;
        (DraggableSprite(_modeSprite)).init( new Rectangle(0, 0, 100, 100), 10, 10, 10, 10);
//        this.modeSprite.mouseEnabled = false;
//        this.modeSprite.mouseChildren = false;
    }
    override protected function setup() :void
    {
        setupUI();
    }
    
    protected function setupUI() :void
    {
//        var s :Sprite = new Sprite();
//        s.graphics.beginFill(0xd0d0e3);
//        s.graphics.drawRect(0, 0, 200, 200);
//        s.graphics.endFill();
//        modeSprite.addChild( s );
        
//        modeSprite.x = 100;
//        modeSprite.y = 100;
        modeSprite.graphics.beginFill(0xd0d0e3);
        modeSprite.graphics.drawRect(0, 0, 200, 200);
        modeSprite.graphics.endFill();
        modeSprite.addChild( TextFieldUtil.createField( ClassUtil.shortClassName( this ), {selectable :false}));
        
        var closeButton :SimpleTextButton = new SimpleTextButton( "Close" );
        closeButton.x = modeSprite.width - 50;
        closeButton.y = 0;
//        _events.registerListener( closeButton, MouseEvent.CLICK, function(...ignored) :void {
//            ctx.mainLoop.popMode();    
//        });
        Command.bind( closeButton, MouseEvent.CLICK, VampireController.CLOSE_MODE, this);
//        Command.bind( closeButton, MouseEvent.CLICK, VampireController.SWITCH_MODE, Constants.GAME_MODE_NOTHING);
        modeSprite.addChild( closeButton );
        
    }
    
    
    
}
}