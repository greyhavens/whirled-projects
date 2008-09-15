package joingame.modes
{
    import com.whirled.contrib.simplegame.AppMode;

    public class SinglePlayerIntroMode extends AppMode
    {
        override protected function setup ():void
        {
            if( !AppContext.gameCtrl.isConnected() ) {
                return;
            }
            
            _allPlayersReady = false;
            _startClicked = false;
            
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
            
            _startButton.addEventListener(MouseEvent.CLICK, playerReady);
            
            var brightness :int = 25;
            var contrast :int = 50;
//            var myElements_array:Array = [1, 0, 0, 0, brightness,
//                                          0, 1, 0, 0, brightness,
//                                          0, 0, 1, 0, brightness,
//                                          0, 0, 0, 1, 0];
//                                          
                 
            /* See http://www.adobetutorialz.com/articles/1987/1/Color-Matrix */                         
            var myElements_array:Array = [2,0,0,0,-13.5,0,2,0,0,-13.5,0,0,2,0,-13.5,0,0,0,1,0]
                                                                                    
            _myColorMatrix_filter = new ColorMatrixFilter(myElements_array);
            
            
            
//            _playersReady = new Array();
//            _button = new SimpleTextButton("Waiting for player data!");
//            _modeSprite.addChild(_button);
//            _button.addEventListener(MouseEvent.CLICK, playerReady);
//            _button.x = 100;
//            _button.y = 100;
//            
            AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
//            _timer.addEventListener(TimerEvent.TIMER, timerListener);
//            _timer.start();
            
            playerReady(null);
            
        }
        
        private function mouseOver( event:MouseEvent ) :void
        {
            
            _startButton.filters = [_myColorMatrix_filter];
            
        }
        
        private function mouseOut( event:MouseEvent ) :void 
        {
            _startButton.filters = [];
        }
        
        private function playerReady( event:MouseEvent ) :void
        {
            _startClicked = true;
            if( _allPlayersReady ) {
                AppContext.gameCtrl.net.sendMessage(Server.PLAYER_READY, {}, NetSubControl.TO_SERVER_AGENT);
            }
        }
        
        /** Respond to messages from other clients. */
        public function messageReceived (event :MessageReceivedEvent) :void
        {
            
            if (event.name == Server.ALL_PLAYERS_READY)
            {
//                trace("WaitingForReadyPlayersMode Server.ALL_PLAYERS_READY for player " + AppContext.gameCtrl.game.getMyId());
                GameContext.gameState = new JoinGameModel( AppContext.gameCtrl);
                GameContext.gameState.setModelMemento( event.value[0] as Array );
                
                _allPlayersReady = true;
                if(_startClicked) {
                    playerReady(null);
                }
                
            }
            else if (event.name == Server.START_PLAY)
            {
//                trace("WaitingForReadyPlayersMode Server.START_PLAY for player " + AppContext.gameCtrl.game.getMyId());
                AppContext.mainLoop.unwindToMode(new PlayPuzzleMode());
            }
        }
        
//        protected function startPlay() :void 
//        {
//            AppContext.gameCtrl.net.sendMessage(Server.PLAYER_RECEIVED_START_GAME_STATE, {}, NetSubControl.TO_SERVER_AGENT);
//            
//        }
        
        override protected function destroy () :void
        {
//            _timer.removeEventListener(TimerEvent.TIMER, timerListener);
//            _timer.stop();
//            _button.removeEventListener(MouseEvent.CLICK, playerReady);
            AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            _startButton.removeEventListener(MouseEvent.CLICK, playerReady);
            super.destroy();
            
        }
        
        private function timerListener(e:TimerEvent):void
        {
            playerReady(null);
        }
        
//        private var _playersReady:Array;
//        private var _button: SimpleTextButton;
        
        protected var _intro_panel :SceneObject;
        protected var _startButton :MovieClip;
        protected var _myColorMatrix_filter :ColorMatrixFilter;
        protected var _allPlayersReady :Boolean;
        protected var _startClicked :Boolean;
        
//        private var _timer: Timer = new Timer(3000);//Ping the server every few seconds
        
    }
}