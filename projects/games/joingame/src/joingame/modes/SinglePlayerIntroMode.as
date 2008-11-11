package joingame.modes
{
    import com.threerings.flash.SimpleTextButton;
    import com.threerings.util.*;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.audio.*;
    import com.whirled.contrib.simplegame.net.*;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
    import com.whirled.contrib.simplegame.resource.*;
    import com.whirled.contrib.simplegame.util.*;
    import com.whirled.game.*;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.AllPlayersReadyMessage;
    import joingame.net.JoinGameMessage;
    import joingame.net.StartPlayMessage;
    import joingame.net.StartSinglePlayerGameMessage;
    import joingame.view.*;

    public class SinglePlayerIntroMode extends JoinGameMode
    {
        private static const log :Log = Log.getLog(SinglePlayerIntroMode);
        
        override protected function setup ():void
        {
            super.setup();
            fadeIn();
        }
        override protected function enter ():void
        {
            log.debug("SinglePlayerIntroMode...");
            
            _allPlayersReady = false;
            _startClicked = false;

            AppContext.messageManager.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            _bg = ImageResource.instantiateBitmap("INSTRUCTIONS");
            if(_bg != null) {
                _modeLayer.addChild(_bg);
            }
            else {
                trace("!!!!!Background is null!!!");
            }
            
            var swfRoot :MovieClip = MovieClip(SwfResource.getSwfDisplayRoot("UI"));
            _modeLayer.addChild(swfRoot);
            
            
            var swf :SwfResource = (ResourceManager.instance.getResource("UI") as SwfResource);
            var _intro_panel_Class :Class = swf.getClass("intro_panel");
            
            
            
            _intro_panel = new SimpleSceneObject( new _intro_panel_Class() );
            addObject( _intro_panel, _modeLayer);
            
            _startButton = MovieClip(_intro_panel.displayObject["start"]);
            _startButton.mouseEnabled = true;
            _startButton.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
            _startButton.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
            _startButton.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            _startButton.addEventListener(MouseEvent.CLICK, mouseClicked);
            _modeLayer.addChild(_startButton);
            
            /* See http://www.adobetutorialz.com/articles/1987/1/Color-Matrix */                         
            var myElements_array:Array = [2,0,0,0,-13.5,0,2,0,0,-13.5,0,0,2,0,-13.5,0,0,0,1,0]
            _myColorMatrix_filter = new ColorMatrixFilter(myElements_array);
            
            var startWavesButton :SimpleTextButton = new SimpleTextButton("Start waves");
            startWavesButton.x = 50;
            startWavesButton.y = 50;
            startWavesButton.addEventListener(MouseEvent.CLICK, doStartWavesButtonClick);
            _modeLayer.addChild( startWavesButton );
            
            
            var startWithXOpponentsButton :SimpleTextButton = new SimpleTextButton("Start 10 opponents");
            startWithXOpponentsButton.x = startWavesButton.x;
            startWithXOpponentsButton.y = startWavesButton.y + 50;
            startWithXOpponentsButton.addEventListener(MouseEvent.CLICK, doStartXOpponentsButtonClick);
            _modeLayer.addChild( startWithXOpponentsButton );
            
            
            
        }
        
        protected function doStartWavesButtonClick( event:MouseEvent ) :void 
        {
            var msg :StartSinglePlayerGameMessage = new StartSinglePlayerGameMessage( AppContext.playerId, Constants.SINGLE_PLAYER_GAME_TYPE_WAVES, GameContext.playerCookieData.clone());
            log.debug("Client sending " + msg);
            AppContext.messageManager.sendMessage(msg);
        }
        
        protected function doStartXOpponentsButtonClick( event:MouseEvent ) :void 
        {
            var msg :StartSinglePlayerGameMessage = new StartSinglePlayerGameMessage( AppContext.playerId, Constants.SINGLE_PLAYER_GAME_TYPE_CHOOSE_OPPONENTS, GameContext.playerCookieData.clone());
            log.debug("Client sending " + msg);
            AppContext.messageManager.sendMessage(msg);
        }
        
        
        private function mouseDown( event:MouseEvent ) :void 
        {
            _startButton.y += 4;
        }
        
        
        private function mouseOver( event:MouseEvent ) :void
        {
            _startButton.filters = [_myColorMatrix_filter];
        }
        
        private function mouseOut( event:MouseEvent ) :void 
        {
            _startButton.filters = [];
        }
        
        private function mouseClicked( event:MouseEvent ) :void
        {
            _startButton.y -= 4;
            _startClicked = true;
            log.debug("Client sending " + StartSinglePlayerGameMessage.NAME);
            AppContext.messageManager.sendMessage(new StartSinglePlayerGameMessage( AppContext.playerId, Constants.SINGLE_PLAYER_GAME_TYPE_WAVES));
        }
        
        protected function messageReceived (event :MessageReceivedEvent) :void
        {
            log.debug(event.name);
            if (event.value is AllPlayersReadyMessage) {
                handleAllPlayersReady( AllPlayersReadyMessage(event.value) );
            }
            else if (event.value is StartPlayMessage) {
                handleStartPlay( StartPlayMessage(event.value) );
            }
            else {
                log.debug("ignored message: " + event.name);
            }
        }
        
        protected function handleAllPlayersReady (event :AllPlayersReadyMessage) :void
        {
            GameContext.gameModel = new JoinGameModel( AppContext.gameCtrl);
            GameContext.gameModel.setModelMemento( event.model );
            GameContext.gameModel._initialSeatedPlayerIds = GameContext.gameModel.currentSeatingOrder.slice();
            
            fadeOutToMode( new PlayPuzzleMode() );
//            GameContext.mainLoop.unwindToMode( new PlayPuzzleMode());
//            log.debug(ClassUtil.shortClassName(SinglePlayerIntroMode) + " sending " + ClassUtil.shortClassName(PlayerReceivedGameStateMessage));
//            AppContext.messageManager.sendMessage(new PlayerReceivedGameStateMessage(AppContext.playerId));
                
        }
        
        protected function handleStartPlay (event :StartPlayMessage) :void
        {
            fadeOutToMode( new PlayPuzzleMode() );
//            GameContext.mainLoop.unwindToMode(new PlayPuzzleMode());
        }
        
        override protected function exit () :void
        {
            AppContext.messageManager.removeEventListener( MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
//            AppContext.messageManager.removeEventListener( AllPlayersReadyMessage.NAME, handleAllPlayersReady);
//            AppContext.messageManager.removeEventListener( StartPlayMessage.NAME, handleStartPlay);
            _startButton.removeEventListener(MouseEvent.CLICK, mouseClicked);
            super.exit();
        }
        
        override protected function destroy () :void
        {
//            AppContext.messageManager.removeEventListener( AllPlayersReadyMessage.NAME, handleAllPlayersReady);
//            AppContext.messageManager.removeEventListener( StartPlayMessage.NAME, handleStartPlay);
            _startButton.removeEventListener(MouseEvent.CLICK, mouseClicked);
            super.destroy();
        }
        
        protected var _intro_panel :SceneObject;
        protected var _startButton :MovieClip;
        protected var _myColorMatrix_filter :ColorMatrixFilter;
        protected var _allPlayersReady :Boolean;
        protected var _startClicked :Boolean;
        
        protected var _bg :DisplayObject;
        
    }
}