package joingame.view
{
    import com.threerings.util.Controller;
    
    import flash.display.DisplayObject;
    import flash.events.IEventDispatcher;
    import flash.filters.ColorMatrixFilter;
    
    import joingame.AppContext;
    import joingame.Constants;
    import joingame.GameContext;
    import joingame.modes.SinglePlayerIntroMode;
    import joingame.net.GameOverMessage;
    import joingame.net.StartSinglePlayerGameMessage;

    public class GameController extends Controller
    {
        public static const START_CAMPAIGN_LEVEL :String = "StartCampainLevel";
        public static const START_WAVES :String = "StartWaves";
        public static const MOUSE_DOWN :String = "MouseDown";
        public static const MOUSE_OVER :String = "MouseOver";
        public static const MOUSE_OUT :String = "MouseOut";
        public static const MAIN_MENU :String = "GoToMainMenu";
        
        /* See http://www.adobetutorialz.com/articles/1987/1/Color-Matrix */                         
        protected var myElements_array:Array = [2,0,0,0,-13.5,0,2,0,0,-13.5,0,0,2,0,-13.5,0,0,0,1,0];
        protected var _myColorMatrix_filter :ColorMatrixFilter = new ColorMatrixFilter(myElements_array);
        
        public function GameController(controlledPanel :IEventDispatcher)
        {
            setControlledPanel(controlledPanel);
        }
        
        public function handleStartCampainLevel( level :int, button :DisplayObject ) :void
        {
            button.y -= 4;
            var msg :StartSinglePlayerGameMessage = new StartSinglePlayerGameMessage( AppContext.playerId, Constants.SINGLE_PLAYER_GAME_TYPE_CHOOSE_OPPONENTS, GameContext.playerCookieData.clone(), level);
            GameContext.requestedSinglePlayerLevel = level;
            AppContext.messageManager.sendMessage(msg);
        }
        
        public function handleStartWaves( level :int, button :DisplayObject ) :void
        {
            button.y -= 4;
            var msg :StartSinglePlayerGameMessage = new StartSinglePlayerGameMessage( AppContext.playerId, Constants.SINGLE_PLAYER_GAME_TYPE_WAVES, GameContext.playerCookieData.clone(), level);
            GameContext.requestedSinglePlayerLevel = level;
            AppContext.messageManager.sendMessage(msg);
        }
        
        public function handleMouseDown( button :DisplayObject ) :void 
        {
            button.y += 4;
        }
        
        
        public function handleMouseOver( button :DisplayObject ) :void
        {
            button.filters = [_myColorMatrix_filter];
        }
        
        public function handleMouseOut( button :DisplayObject ) :void 
        {
            button.filters = [];
        }
    
        public function handleGoToMainMenu() :void 
        {
            var msg :GameOverMessage = new GameOverMessage();
            AppContext.messageManager.sendMessage(msg);
            GameContext.mainLoop.unwindToMode( new SinglePlayerIntroMode());
        }
    
    }
}