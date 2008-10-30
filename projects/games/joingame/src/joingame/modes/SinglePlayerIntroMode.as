package joingame.modes
{
    import com.threerings.util.*;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.audio.*;
    import com.whirled.contrib.simplegame.net.*;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
    import com.whirled.contrib.simplegame.resource.*;
    import com.whirled.contrib.simplegame.util.*;
    import com.whirled.game.*;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.AllPlayersReadyMessage;
    import joingame.net.PlayerReceivedGameStateMessage;
    import joingame.net.RegisterPlayerMessage;
    import joingame.net.StartPlayMessage;
    import joingame.view.*;

    public class SinglePlayerIntroMode extends AppMode
    {
        protected static var log :Log = AppContext.log;
        
        override protected function enter ():void
        {
            log.debug("SinglePlayerIntroMode...");
            
//            if( !AppContext.gameCtrl.isConnected() ) {
//                return;
//            }
            
            _allPlayersReady = false;
            _startClicked = false;
            
            _bg = ImageResource.instantiateBitmap("INSTRUCTIONS");
            if(_bg != null) {
                _modeSprite.addChild(_bg);
            }
            else {
                trace("!!!!!Background is null!!!");
            }
            
            var swfRoot :MovieClip = MovieClip(SwfResource.getSwfDisplayRoot("UI"));
            modeSprite.addChild(swfRoot);
            
            
            var swf :SwfResource = (ResourceManager.instance.getResource("UI") as SwfResource);
            var _intro_panel_Class :Class = swf.getClass("intro_panel");
            
            
            
            _intro_panel = new SimpleSceneObject( new _intro_panel_Class() );
            addObject( _intro_panel, modeSprite);
            
            _startButton = MovieClip(_intro_panel.displayObject["start"]);
            _startButton.mouseEnabled = true;
            _startButton.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
            _startButton.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
            _startButton.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            _startButton.addEventListener(MouseEvent.CLICK, mouseClicked);
            
            modeSprite.addChild(_startButton);
            
            var brightness :int = 25;
            var contrast :int = 50;
                 
            /* See http://www.adobetutorialz.com/articles/1987/1/Color-Matrix */                         
            var myElements_array:Array = [2,0,0,0,-13.5,0,2,0,0,-13.5,0,0,2,0,-13.5,0,0,0,1,0]
                                                                                    
            _myColorMatrix_filter = new ColorMatrixFilter(myElements_array);
            AppContext.messageManager.addEventListener( AllPlayersReadyMessage.NAME, handleAllPlayersReady);
            AppContext.messageManager.addEventListener( StartPlayMessage.NAME, handleStartPlay);
//            AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            AppContext.messageManager.sendMessage(new RegisterPlayerMessage( AppContext.playerId));
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
            
            AppContext.messageManager.sendMessage(new RegisterPlayerMessage( AppContext.playerId));
        }
        
        /** Respond to messages from other clients. */
        protected function handleAllPlayersReady (event :AllPlayersReadyMessage) :void
        {
            GameContext.gameModel = new JoinGameModel( AppContext.gameCtrl);
            GameContext.gameModel.setModelMemento( event.model );
            
//            log.debug(ClassUtil.shortClassName(SinglePlayerIntroMode) + " sending " + ClassUtil.shortClassName(PlayerReceivedGameStateMessage));
            AppContext.messageManager.sendMessage(new PlayerReceivedGameStateMessage(AppContext.playerId));
                
        }
        
        /** Respond to messages from other clients. */
        public function handleStartPlay (event :StartPlayMessage) :void
        {
            GameContext.mainLoop.unwindToMode(new PlayPuzzleMode());
        }
        
        override protected function exit () :void
        {
            AppContext.messageManager.removeEventListener( AllPlayersReadyMessage.NAME, handleAllPlayersReady);
            AppContext.messageManager.removeEventListener( StartPlayMessage.NAME, handleStartPlay);
            _startButton.removeEventListener(MouseEvent.CLICK, mouseClicked);
            super.exit();
        }
        
        override protected function destroy () :void
        {
            AppContext.messageManager.removeEventListener( AllPlayersReadyMessage.NAME, handleAllPlayersReady);
            AppContext.messageManager.removeEventListener( StartPlayMessage.NAME, handleStartPlay);
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