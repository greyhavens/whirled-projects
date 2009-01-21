package vampire.client {
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.EventHandlers;
import com.whirled.contrib.simplegame.MainLoop;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.registerClassAlias;

import vampire.client.modes.BloodBondMode;
import vampire.client.modes.FeedMode;
import vampire.client.modes.FightMode;
import vampire.client.modes.HierarchyMode;
import vampire.client.modes.NothingMode;

[SWF(width="700", height="500")]
public class VampireMain extends Sprite
{
    public function VampireMain()
    {
        Log.setLevel("", Log.DEBUG);
//        Log.setLevel("vampire", Log.DEBUG);
        
        trace("VampireMain()");
        /* Register mode classes so that they can be instatiated just by name*/
        registerClassAlias("vampire.client.modes.BloodBondMode", BloodBondMode);
        registerClassAlias("vampire.client.modes.FeedMode", FeedMode);
        registerClassAlias("vampire.client.modes.FightMode", FightMode);
        registerClassAlias("vampire.client.modes.HierarchyMode", HierarchyMode);
        
        trace("  registered classes");
        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);
        
        // instantiate MainLoop singleton
        var gameSprite :Sprite = new Sprite();
        addChild( gameSprite );
        var loop :MainLoop = new MainLoop(gameSprite);
        MainLoop.instance.setup();
        
        trace("  main loop");
        
        
        // load resources
//        ResourceManager.instance.queueResourceLoad("swf", "ui",     { embeddedClass: Resources.SWF_UI });
//        ResourceManager.instance.queueResourceLoad("swf", "board",  { embeddedClass: Resources.SWF_BOARD });
//        ResourceManager.instance.queueResourceLoad("swf", "intro",  { embeddedClass: Resources.SWF_INTRO });
//        ResourceManager.instance.queueResourceLoad("swf", "help",   { embeddedClass: Resources.SWF_HELP });
        
//        ResourceManager.instance.loadQueuedResources(handleResourcesLoaded, handleResourceLoadError);
        _resourcesLoaded = true;
    }
    
    
    protected function maybeShowIntro () :void
    {
        if (_addedToStage && _resourcesLoaded) {
            
            ClientContext.gameCtrl = new AVRGameControl( this );
        
            if( !ClientContext.gameCtrl.isConnected()) {
                return;
            }
            
            ClientContext.ourPlayerId = ClientContext.gameCtrl.player.getPlayerId();
            
            var controller :VampireController = new VampireController(this);
            
            ClientContext.model = new Model();
        
            var hud :HUD = new HUD();
            addChild( hud );
    
            ClientContext.model.setup();
            
            
//            Command.bind( ClientContext.model, VampireController.PLAYER_STATE_CHANGED, VampireController.PLAYER_STATE_CHANGED, [ClientContext.model, hud]);
            
    
            MainLoop.instance.run();
            
            MainLoop.instance.pushMode( new NothingMode() );
        
//            setupAvatarInfoCapture();
        
//            ClientContext.gameCtrl = new AVRGameControl(this);
//            ClientContext.gameCtrl.player.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);
//
//            ClientContext.ourPlayerId = (ClientContext.gameCtrl.isConnected()
//                ? ClientContext.gameCtrl.player.getPlayerId() : 666);
//
//            ClientContext.items = new BingoItemManager(ClientBingoItems.ITEMS);
//
//            ClientContext.model = new Model();
//            ClientContext.model.setup();

//            MainLoop.instance.pushMode(new IntroMode());
//            MainLoop.instance.run();
        }
    }

    protected function handleResourcesLoaded () :void
    {
        _resourcesLoaded = true;
        this.maybeShowIntro();
    }

    protected function handleResourceLoadError (err :String) :void
    {
        log.warning("Resource load error: " + err);
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");

        _addedToStage = true;
        this.maybeShowIntro();
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

//        ClientContext.model.destroy();

        MainLoop.instance.shutdown();
        
        removeEventListener( MouseEvent.MOUSE_MOVE, mouseMove);
        EventHandlers.freeAllHandlers();
    }

    protected function leftRoom (e :Event) :void
    {
        log.debug("leftRoom");
//        ClientContext.quit();
    }
    
    protected function setupAvatarInfoCapture() :void
    {
        graphics.clear();
        graphics.beginFill(0, 0);
        graphics.drawRect(0, 0, 700, 500);
        graphics.endFill();
        
        addEventListener( MouseEvent.MOUSE_MOVE, mouseMove);
    }
    
    protected function mouseMove( e :MouseEvent ) :void
    {
        for each (var playerId :int in ClientContext.gameCtrl.room.getPlayerIds()) {
            var avatar :AVRGameAvatar = ClientContext.gameCtrl.room.getAvatarInfo( playerId );
            if( avatar.bounds.contains( e.localX, e.localY ) ) {
                trace("mouse over avatar=" + playerId );
                return; 
            }
        }
    }
    

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;

    protected static var log :Log = Log.getLog(VampireMain);
    
}

}