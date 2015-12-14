package client
{
    import flash.display.Sprite;
    import flash.text.TextField;
    
    import sprites.SpriteUtil;

    public class LevelEndReward extends Sprite
    {
        public function LevelEndReward(levelNumber:int)
        {
            super();
            SpriteUtil.addBackground(this, 500, 200, SpriteUtil.RED, alpha=0.4);
                                                
            _heading = new TextField();
            _heading.htmlText = 
                  "<p align='center'><font color='#ffffff' size='40' face='Helvetica, Arial, _sans'>Yay! Level "
                  +levelNumber+" complete.</font></p>";
            _heading.width = 500;
            addChild(_heading);
            _heading.y = 50;
            
            _instructions = new TextField();
            _instructions.htmlText =
                "<p align='center'><font color='#ffffff' size='20' face='Helvetica, Arial, _sans'>Click for more fun on level "
                 +(levelNumber+1)+"</font></p>";
            _instructions.width = 500;                  
            addChild(_instructions);
            _instructions.y = 150;            
        }
        
        protected var _heading:TextField;
        protected var _instructions:TextField;            
    }
}