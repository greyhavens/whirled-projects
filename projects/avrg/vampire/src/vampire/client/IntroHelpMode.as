package vampire.client
{
    import com.threerings.flash.TextFieldUtil;
    import com.threerings.util.Command;
    import com.whirled.contrib.simplegame.AppMode;
    
    import flash.events.MouseEvent;
    import flash.text.TextField;

    public class IntroHelpMode extends AppMode
    {
        public function IntroHelpMode()
        {
            super();
        }
        
        override protected function setup() :void
        {
            modeSprite.graphics.beginFill(0xcc0000);
            modeSprite.graphics.drawRect(100, 100, 400, 200);
            modeSprite.graphics.endFill();
            
            modeSprite.graphics.lineStyle(0x000000, 1);
            
            var welcometext :TextField = TextFieldUtil.createField("Welcome to Vampire, click to remove", {selectable:false, x:120, y:120, width:200}); 
            modeSprite.addChild( welcometext );
            
            Command.bind( modeSprite, MouseEvent.CLICK, VampireController.HIDE_INTRO );
        }
        
        
    }
}