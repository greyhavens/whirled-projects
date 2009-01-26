package vampire.client
{
    import com.threerings.util.ClassUtil;
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.AppMode;
    import com.whirled.contrib.simplegame.Config;
    import com.whirled.contrib.simplegame.SimpleGame;
    
    import vampire.client.events.ChangeActionEvent;
    import vampire.client.modes.NothingMode;

    public class MainGameMode extends AppMode
    {
        public function MainGameMode()
        {
            super();
        }
        
        override protected function enter() :void
        {
            super.enter();
            log.debug("Starting " + ClassUtil.tinyClassName( this ));
            var subgameconfig :Config = new Config();
            subgameconfig.hostSprite = modeSprite;
            subgame = new SimpleGame( subgameconfig );
            subgame.run();
            subgame.ctx.mainLoop.pushMode( new NothingMode() );
            
            modeSprite.addChild( ClientContext.hud );
            ClientContext.model.addEventListener( ChangeActionEvent.CHANGE_ACTION, changeAction );
        }
        
        override protected function exit() :void
        {
            super.exit();
            subgame.shutdown();
            ClientContext.model.removeEventListener( ChangeActionEvent.CHANGE_ACTION, changeAction );
        }
        
        protected function changeAction( e :ChangeActionEvent ) :void
        {
            var action :String = e.action;
            
            var modeClass :Class = ClientContext.GAME_MODES2AppMode.get(action);
            
            log.debug("Changing to action=" + action);
            var m :AppMode;
            
            if( modeClass == null) {
                log.error("no mode class found, going to nothing mode");
                m = new NothingMode();
            }
            else {
                m = new modeClass() as AppMode;
            }
                
    //        var m :AppMode = new modeClass() as AppMode;
            log.debug("new mode=" + ClassUtil.getClassName( m ) );
            log.debug("current mode=" + ClassUtil.getClassName( subgame.ctx.mainLoop.topMode ) );
            if( m !== subgame.ctx.mainLoop.topMode) {
                subgame.ctx.mainLoop.changeMode( m );
            }
            else{
                log.debug("Not changing mode because the mode is already on top, m=" + m);
            }
        }
        
        protected var subgame :SimpleGame;
        
        protected static const log :Log = Log.getLog( MainGameMode );
    }
}