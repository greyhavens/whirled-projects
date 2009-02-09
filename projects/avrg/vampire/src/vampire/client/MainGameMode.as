package vampire.client
{
    import com.threerings.util.ClassUtil;
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.AppMode;
    import com.whirled.contrib.simplegame.Config;
    import com.whirled.contrib.simplegame.SimpleGame;
    
    import flash.display.Sprite;
    
    import vampire.client.actions.NothingMode;
    import vampire.client.actions.bloodbond.BloodBondMode;
    import vampire.client.actions.feed.EatMeMode;
    import vampire.client.actions.feed.FeedMode;
    import vampire.client.actions.fight.FightMode;
    import vampire.client.actions.hierarchy.HierarchyMode;
    import vampire.client.events.ChangeActionEvent;
    import vampire.data.Constants;

    public class MainGameMode extends AppMode
    {
        public function MainGameMode()
        {
            super();
        }
        
        override protected function enter() :void
        {
            log.debug("Starting " + ClassUtil.tinyClassName( this ));
            
        }
        
        override protected function setup() :void
        {
            super.setup();
            
            
//            push
//            ClientContext.hud = new HUD(); 
//            modeSprite.addChild( ClientContext.hud );
            
            _hud = new HUD();
            addObject( _hud, modeSprite );
            
            _subgameSprite = new Sprite();
            modeSprite.addChild( _subgameSprite );
            var subgameconfig :Config = new Config();
            subgameconfig.hostSprite = _subgameSprite;
            subgame = new SimpleGame( subgameconfig );
            subgame.run();
            subgame.ctx.mainLoop.pushMode( new NothingMode() );
            
            registerListener( ClientContext.model, ChangeActionEvent.CHANGE_ACTION, changeAction ); 
            
        }
        
        override protected function exit() :void
        {
            log.warning("!!! " + ClassUtil.tinyClassName(this) + "exiting.  Is this what we want??");
        }
        
        override protected function destroy() :void
        {
            subgame.shutdown();
        }
        
        protected function changeAction( e :ChangeActionEvent ) :void
        {
            var action :String = e.action;
            
            var m :AppMode;
            
            switch( action ) {
//                case Constants.GAME_MODE_BLOODBOND:
//                     m = new BloodBondMode();
//                     break;
                 
                 case Constants.GAME_MODE_FEED:
                     m = new FeedMode();
                     break;
                       
                 case Constants.GAME_MODE_EAT_ME:
                     m = new EatMeMode();
                     break;
                     
                 case Constants.GAME_MODE_FIGHT:
                     m = new FightMode();
                     break;
                     
                 case Constants.GAME_MODE_HIERARCHY_AND_BLOODBONDS:
                     m = new HierarchyMode();
                     break;
                     
                 default:
                     m = new NothingMode();
            }
            
            log.debug("current mode=" + ClassUtil.getClassName( subgame.ctx.mainLoop.topMode ) );
            log.debug("new mode=" + ClassUtil.getClassName( m ) );
            if( m !== subgame.ctx.mainLoop.topMode) {
                subgame.ctx.mainLoop.unwindToMode( m );
            }
            else{
                log.debug("Not changing mode because the mode is already on top, m=" + m);
            }
        }
        
        protected var subgame :SimpleGame;
        protected var _subgameSprite :Sprite;
        protected var _hud :HUD;
        
        protected static const log :Log = Log.getLog( MainGameMode );
    }
}