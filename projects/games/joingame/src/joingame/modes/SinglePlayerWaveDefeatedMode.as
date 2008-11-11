package joingame.modes
{
    import com.threerings.flash.SimpleTextButton;
    import com.threerings.util.ClassUtil;
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.AppMode;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.events.MouseEvent;
    
    import joingame.AppContext;
    import joingame.GameContext;
    import joingame.net.ReplayConfirmMessage;
    import joingame.net.StartSinglePlayerWaveMessage;
    import joingame.view.GameStatsSinglePlayerSprite;

    public class SinglePlayerWaveDefeatedMode extends JoinGameMode
    {
        private static const log :Log = Log.getLog(SinglePlayerWaveDefeatedMode);
        
        protected var _nextWaveButton :SimpleTextButton;
        
        override protected function setup () :void
        {
            super.setup();
            log.debug("SinglePlayerWaveDefeatedMode...");
            trace("SinglePlayerWaveDefeatedMode...");
            _nextWaveButton  = new SimpleTextButton("Next wave");
            _nextWaveButton.x = 50;
            _nextWaveButton.y = 200;
            _modeLayer.addChild( _nextWaveButton );
            
            var mainMenuButton :SimpleTextButton = new SimpleTextButton("Main Menu");
            mainMenuButton.x = 50;
            mainMenuButton.y = _nextWaveButton.y + 50;
            mainMenuButton.addEventListener(MouseEvent.CLICK, doMainMenuButtonClick);
            _modeLayer.addChild( mainMenuButton );
    
            fadeIn();
        }
        
        protected function doMainMenuButtonClick (event :MouseEvent) :void
        {
            fadeOutToMode( new SinglePlayerIntroMode() );
//            GameContext.mainLoop.unwindToMode( new SinglePlayerIntroMode());
        }
        
        protected function doNextWave( ...ignored) :void
        {
            log.debug("Sending " + ClassUtil.shortClassName(StartSinglePlayerWaveMessage));
            AppContext.messageManager.sendMessage( new StartSinglePlayerWaveMessage( AppContext.playerId, true, GameContext.playerCookieData.clone()));
        }
        
        protected function handleReplayConfirm( event :ReplayConfirmMessage) :void
        {
            log.debug("handleReplayConfirm(), popping mode");
            GameContext.gameModel.setModelMemento( event.modelMemento );
            fadeOutToMode( new PlayPuzzleMode() );
//            GameContext.mainLoop.unwindToMode( new PlayPuzzleMode());
//            GameContext.mainLoop.popMode();
        }
        
        override protected function enter () :void
        {
            AppContext.messageManager.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
//            AppContext.messageManager.addEventListener(ReplayConfirmMessage.NAME, handleReplayConfirm);
            _nextWaveButton.addEventListener(MouseEvent.CLICK, doNextWave);
            
            _modeLayer.addChild( new GameStatsSinglePlayerSprite(GameContext.playerCookieData.clone(), GameContext.gameModel._tempNewPlayerCookie.clone()));
            GameContext.playerCookieData.setFrom( GameContext.gameModel._tempNewPlayerCookie );
            if( AppContext.isConnected ) {
                GameContext.cookieManager.needsUpdate();
            }
        }
        
        override protected function exit () :void
        {
            AppContext.messageManager.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
//            AppContext.messageManager.removeEventListener(ReplayConfirmMessage.NAME, handleReplayConfirm);
            _nextWaveButton.removeEventListener(MouseEvent.CLICK, doNextWave);
            
        }
        
        protected function messageReceived (event :MessageReceivedEvent) :void
        {
            if (event.value is ReplayConfirmMessage) {
                handleReplayConfirm( ReplayConfirmMessage(event.value) );
            }
        }
        
    }
}