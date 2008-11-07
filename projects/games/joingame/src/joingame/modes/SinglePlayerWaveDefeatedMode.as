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

    public class SinglePlayerWaveDefeatedMode extends AppMode
    {
        private static const log :Log = Log.getLog(SinglePlayerWaveDefeatedMode);
        
        protected var _nextWaveButton :SimpleTextButton;
        
        override protected function setup () :void
        {
            log.debug("SinglePlayerWaveDefeatedMode...");
//            _text = new TextField();
//            _text.selectable = false;
//            _text.textColor = 0xFFFFFF;
//            _text.width = 300;
//            _text.scaleX = 2;
//            _text.scaleY = 2;
//            _text.x = 50;
//            _text.y = 50;
//            _text.text = "SinglePlayerWaveDefeatedMode";
    
//            this.modeSprite.addChild(_text);
            
            
            _nextWaveButton  = new SimpleTextButton("Next wave");
            _nextWaveButton.x = 50;
            _nextWaveButton.y = 200;
            modeSprite.addChild( _nextWaveButton );
            
            var mainMenuButton :SimpleTextButton = new SimpleTextButton("Main Menu");
            mainMenuButton.x = 50;
            mainMenuButton.y = _nextWaveButton.y + 50;
            mainMenuButton.addEventListener(MouseEvent.CLICK, doMainMenuButtonClick);
            modeSprite.addChild( mainMenuButton );
    
        }
        
        protected function doMainMenuButtonClick (event :MouseEvent) :void
        {
            GameContext.mainLoop.unwindToMode( new SinglePlayerIntroMode());
        }
        
        protected function doNextWave( ...ignored) :void
        {
            log.debug("Sending " + ClassUtil.shortClassName(StartSinglePlayerWaveMessage));
            AppContext.messageManager.sendMessage( new StartSinglePlayerWaveMessage( AppContext.playerId, true));
        }
        
        protected function handleReplayConfirm( event :ReplayConfirmMessage) :void
        {
            log.debug("handleReplayConfirm(), popping mode");
            GameContext.gameModel.setModelMemento( event.modelMemento );
            GameContext.mainLoop.popMode();
        }
        
        override protected function enter () :void
        {
            AppContext.messageManager.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
//            AppContext.messageManager.addEventListener(ReplayConfirmMessage.NAME, handleReplayConfirm);
            _nextWaveButton.addEventListener(MouseEvent.CLICK, doNextWave);
            
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