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
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.ColorMatrixFilter;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.view.*;

    public class SinglePlayerIntroMode extends AppMode
    {
        override protected function setup ():void
        {
            if( !AppContext.gameCtrl.isConnected() ) {
                return;
            }
            
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
            
            var brightness :int = 25;
            var contrast :int = 50;
                 
            /* See http://www.adobetutorialz.com/articles/1987/1/Color-Matrix */                         
            var myElements_array:Array = [2,0,0,0,-13.5,0,2,0,0,-13.5,0,0,2,0,-13.5,0,0,0,1,0]
                                                                                    
            _myColorMatrix_filter = new ColorMatrixFilter(myElements_array);
            AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            
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
            AppContext.gameCtrl.net.sendMessage(Server.REGISTER_PLAYER, {}, NetSubControl.TO_SERVER_AGENT);
        }
        
        /** Respond to messages from other clients. */
        public function messageReceived (event :MessageReceivedEvent) :void
        {
            if (event.name == Server.ALL_PLAYERS_READY)
            {
                GameContext.gameModel = new JoinGameModel( AppContext.gameCtrl);
                GameContext.gameModel.setModelMemento( event.value[0] as Array );
                
                AppContext.gameCtrl.net.sendMessage(Server.PLAYER_RECEIVED_START_GAME_STATE, {}, NetSubControl.TO_SERVER_AGENT);
                
            }
            else if (event.name == Server.START_PLAY)
            {
                AppContext.mainLoop.unwindToMode(new PlayPuzzleMode());
            }
        }
        
        
        override protected function destroy () :void
        {
            AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
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