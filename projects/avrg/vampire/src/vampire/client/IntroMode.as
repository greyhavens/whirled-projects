package vampire.client
{
    import com.threerings.flash.TextFieldUtil;
    import com.threerings.util.Command;
    import com.whirled.contrib.simplegame.AppMode;
    
    import flash.events.MouseEvent;
    import flash.text.TextField;

    public class IntroMode extends AppMode
    {
        public function IntroMode()
        {
            super();
        }
        
        override protected function enter() :void
        {
            super.enter();
            modeSprite.graphics.beginFill(0xffffff);
            modeSprite.graphics.drawRect(200, 200, 300, 300);
            modeSprite.graphics.endFill();
            
            modeSprite.graphics.lineStyle(1, 1);
            
            var welcometext :TextField = TextFieldUtil.createField("Welcome to Vampire", {selectable:false}); 
            modeSprite.addChild( welcometext );
            
            Command.bind( modeSprite, MouseEvent.CLICK, VampireController.HIDE_INTRO );
        }
        
        override protected function exit() :void
        {
            super.exit();
        }
        
    }
}