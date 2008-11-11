package joingame.view
{
    import flash.display.Sprite;
    import flash.text.TextField;
    
    import joingame.UserCookieDataSourcePlayer;

    public class GameStatsSinglePlayerSprite extends Sprite
    {
        public function GameStatsSinglePlayerSprite(oldCookie :UserCookieDataSourcePlayer, newCookie :UserCookieDataSourcePlayer)
        {
            graphics.beginFill(0xffffff);
            graphics.drawRect(0, 0, 200, 100)
            graphics.endFill();
            
            addChild( createText("Level: " + newCookie.highestRobotLevelDefeated + ", old level: " + oldCookie.highestRobotLevelDefeated, 0, 10));
            x = 200;
            
            //Somewhere else
            
        }
        
        protected function createText( txt :String, xPos :int, yPos :int) :TextField 
        {
            var text :TextField = new TextField();
            text.selectable = false;
            text.textColor = 0x000000;
            text.width = 200;
            text.scaleX = 1;
            text.scaleY = 1;
            text.x = xPos;
            text.y = yPos;
            text.text = txt;
            return text;
        }
        
    }
}