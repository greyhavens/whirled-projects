package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.threerings.util.StringBuilder;
import com.whirled.contrib.EventHandlers;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.utils.Timer;

import vampire.client.events.ClosestPlayerChangedEvent;
import vampire.data.Constants;
import vampire.data.SharedPlayerStateClient;
import vampire.data.SharedPlayerStateServer;

/**
 * The main game HUD, showing e.g. blood, game notifications, and buttons to select the subgame to
 * play.
 */
public class HUD extends SceneObject
{
    public function HUD()
    {
//        super(ClientContext.gameCtrl, "HUD");
        
        setupUI();
        
//        EventHandlers.registerListener(ClientContext.model, PlayerStateChangedEvent.NAME, playerUpdated );
//        EventHandlers.registerListener( ClientContext.gameCtrl.player, AVRGamePlayerEvent.ENTERED_ROOM, updateOurPlayerState );
        
        
//        EventHandlers.registerListener( ClientContext.gameCtrl.room.props, PropertyChangedEvent.PROPERTY_CHANGED, propChanged );
        registerListener( ClientContext.gameCtrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        registerListener( ClientContext.model, ClosestPlayerChangedEvent.CLOSEST_PLAYER_CHANGED, closestPlayerChanged);
        
        log.debug("Initializing HUD");
        
        trace("Player stats: " + SharedPlayerStateClient.toStringForPlayer( ClientContext.ourPlayerId));
        
//        updateOurPlayerState();
//        if( ClientContext.model.isState ) {
//            log.debug("    there is our state in the room props.");
//            updatePlayerState( ClientContext.model.state );
//        }
//        else {
//            log.debug("    our state is not in the room props.");
//        }

        // now that we know our dimensions, initialize DraggableSprite
        
//        init( new Rectangle(0, 0, 100, 100), 10, 10, 10, 10);
        
        updateOurPlayerState();
           
        
        _checkRoomProps2ShowStatsTimer = new Timer(300, 0);
        EventHandlers.registerListener( _checkRoomProps2ShowStatsTimer, TimerEvent.TIMER, checkPlayerRoomProps);    
        _checkRoomProps2ShowStatsTimer.start();     
    }
    
    override protected function destroyed () :void
    {
        trace("HUD destroyed");
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _hud;
    }
    
    override public function get objectName () :String
    {
        return "HUD";
    }
    
//    public function destroy() :void
//    {
//        EventHandlers.
//    }
    
    protected function closestPlayerChanged( e :ClosestPlayerChangedEvent ) :void
    {
        _target.text = "Target: " + ClientContext.gameCtrl.room.getAvatarInfo( e.closestPlayerId ).name;
    }
    
    protected function propChanged (e :PropertyChangedEvent) :void
    {
        //Check if it is non-player properties changed??
        log.debug("propChanged", "e", e);
        trace("Player stats: " + SharedPlayerStateClient.toStringForPlayer( ClientContext.ourPlayerId));
        //Otherwise check for player updates
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );
        if( !isNaN(playerIdUpdated) && playerIdUpdated == ClientContext.ourPlayerId) {
            updateOurPlayerState();
        }
        else {
//            log.warning("  Failed to update PropertyChangedEvent" + e);
        }
        
    }
    
    protected function elementChanged (e :ElementChangedEvent) :void
    {
        //Check if it is non-player properties changed??
        log.debug("elementChanged", "e", e);
        trace("Player stats: " + SharedPlayerStateClient.toStringForPlayer( ClientContext.ourPlayerId));
        //Otherwise check for player updates
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );
        
        
        if( !isNaN( playerIdUpdated ) && playerIdUpdated == ClientContext.ourPlayerId) {
            
            if( e.index == SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD) {
                showBlood( ClientContext.ourPlayerId );
            }
            else if( e.index == SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_LEVEL) {
                showLevel( ClientContext.ourPlayerId );
                
            }
            else if( e.index == SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {
                showBloodBonds( ClientContext.ourPlayerId );
            }
            else if( e.index == SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION) {
                showAction( ClientContext.ourPlayerId );
            }
            else if( e.index == SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE) {
                showTime( ClientContext.ourPlayerId );
            }
        
        }
        else {
//            log.warning("  Failed to update ElementChangedEvent" + e);
        }
        
    }
    
    
    protected function checkPlayerRoomProps( ...ignored) :void
    {
//        trace("checkPlayerRoomProps"    );
//        trace("Player stats: " + SharedPlayerStateClient.toStringForPlayer( ClientContext.ourPlayerId));
        if( !SharedPlayerStateClient.isProps( ClientContext.ourPlayerId )) {
//            log.debug("checkPlayerRoomProps, but no props found");
        }
        else {
            updateOurPlayerState();
            EventHandlers.unregisterListener( _checkRoomProps2ShowStatsTimer, TimerEvent.TIMER, checkPlayerRoomProps);
            _checkRoomProps2ShowStatsTimer.stop();
        }
    }
    

    
    
//    override public function hitTestPoint (
//        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
//    {
//        return _hud != null && _hud.hitTestPoint(x, y, shapeFlag);
//    }
    
    protected function setupUI() :void
    {
        _hud = new DraggableSprite(ClientContext.gameCtrl, "HUD");
        _hud.init( new Rectangle(0, 0, 100, 100), 10, 10, 10, 10);
        _hud.graphics.beginFill(0xffffff);
        _hud.graphics.drawRect(0, 0, 500, 50);
        _hud.graphics.drawRect(290, 50, 210, 100);
        _hud.graphics.endFill();
        
        var startX :int = 30;
        var startY :int = 0;
            
        for each ( var mode :String in Constants.GAME_MODES) {
            var button :SimpleTextButton = new SimpleTextButton( mode );
            button.x = startX;
            button.y = startY;
            startX += 90;
            Command.bind( button, MouseEvent.CLICK, VampireController.SWITCH_MODE, mode);
            _hud.addChild( button );
        }
        
        _blood = new Sprite();
        _hud.addChild( _blood );
        _blood.x = 180;
        _blood.y = 35; 
        
        _bloodText = TextFieldUtil.createField("", {mouseEnabled:false, selectable:false});
        _bloodText.x = 50;
        _blood.addChild( _bloodText );
        
        var quitButton :SimpleTextButton = new SimpleTextButton( "Quit" );
        quitButton.x = startX;
        button.y = startY;
        startX += 90;
        Command.bind( quitButton, MouseEvent.CLICK, VampireController.QUIT);
        _hud.addChild( quitButton );
        
        
        _action = TextFieldUtil.createField("Action: ", {mouseEnabled:false, selectable:false, x:300, y:35});
        _hud.addChild( _action );
        
        _level = TextFieldUtil.createField("Level: ", {mouseEnabled:false, selectable:false, x:300, y:55});
        _hud.addChild( _level );
        
        _target = TextFieldUtil.createField("Target: ", {mouseEnabled:false, selectable:false, x:300, y:75, width:400});
        _hud.addChild( _target );
        
        _bloodbonds = TextFieldUtil.createField("Bloodbonds: ", {mouseEnabled:false, selectable:false, x:300, y:95, width:300});
        _hud.addChild( _bloodbonds );
        
        _time = TextFieldUtil.createField("Time: ", {mouseEnabled:false, selectable:false, x:300, y:115, width:400});
        _hud.addChild( _time );
        
        _myName = TextFieldUtil.createField("Me: Testing locally", {mouseEnabled:false, selectable:false, x:20, y:35, width:150});
        if( !Constants.LOCAL_DEBUG_MODE) {
            _myName = TextFieldUtil.createField("Me: " + ClientContext.gameCtrl.room.getAvatarInfo( ClientContext.ourPlayerId).name, {mouseEnabled:false, selectable:false, x:20, y:35, width:150});
        }
            
        _hud.addChild( _myName );
    }
    
    
    protected function playerUpdated( e :PlayerStateChangedEvent ) :void
    {
        if( e.playerId == ClientContext.ourPlayerId) {
            updateOurPlayerState();
        }
    }
    
    public function updateOurPlayerState( ...ignored ) :void
    {
        if( !SharedPlayerStateClient.isProps( ClientContext.ourPlayerId )) {
            log.debug("updatePlayerState, but no props found");
            return;
        }
        
        
        showBlood( ClientContext.ourPlayerId );
        showLevel( ClientContext.ourPlayerId );
        showBloodBonds( ClientContext.ourPlayerId );
        showAction( ClientContext.ourPlayerId );
        showTime( ClientContext.ourPlayerId );
        
    }
    
    protected function showBlood( playerId :int ) :void
    {
        log.debug("Showing player blood=" + SharedPlayerStateClient.getBlood( playerId ) + "/" + SharedPlayerStateClient.getMaxBlood( playerId ));
        _blood.graphics.clear();
        _blood.graphics.lineStyle(1, 0xcc0000);
        _blood.graphics.drawRect(0, 0, 100, 10);
        _blood.graphics.beginFill( 0xcc0000 );
        if( SharedPlayerStateClient.getMaxBlood( playerId ) > 0) {
            _blood.graphics.drawRect(0, 0, (SharedPlayerStateClient.getBlood( playerId ) * 100.0) / SharedPlayerStateClient.getMaxBlood( playerId ), 10);
        }
        _blood.graphics.endFill();
        
        var bloodtext :String = "" + SharedPlayerStateClient.getBlood( playerId );
        if( bloodtext.indexOf(".") >= 0) {
            bloodtext = bloodtext.slice(0, bloodtext.indexOf(".") + 3);
        }
        _bloodText.text = bloodtext;
        
    }
    
    protected function showBloodBonds( playerId :int ) :void
    {
        var bloodbondedArray :Array = SharedPlayerStateClient.getBloodBonded(ClientContext.ourPlayerId);
        if( bloodbondedArray == null) {
            _bloodbonds.text = "Bloodbonds: null" ;
            return;
        }
        var sb :StringBuilder = new StringBuilder();
        
        for( var i :int = 0; i < bloodbondedArray.length; i += 2) {
            sb.append(bloodbondedArray[ i + 1] + " ");
        }
        _bloodbonds.text = "Bloodbonds: " + sb.toString( );
    }
    
    protected function showLevel( playerId :int ) :void
    {
        _level.text = "Level: " + SharedPlayerStateClient.getLevel( ClientContext.ourPlayerId );
    }
    
    protected function showAction( playerId :int ) :void
    {
        _action.text = "Action: " + SharedPlayerStateClient.getCurrentAction( ClientContext.ourPlayerId );
    }
    
    protected function showTime( playerId :int ) :void
    {
        var date :Date = new Date( SharedPlayerStateClient.getTime( ClientContext.ourPlayerId ) );
        _time.text = "Time: " + date.toTimeString();
    }

    
    protected var _hud :DraggableSprite;
    
    protected var _blood :Sprite;
    protected var _bloodText :TextField;
    protected var _action :TextField;
    protected var _level :TextField;
    protected var _target :TextField;
    protected var _myName :TextField;
    protected var _bloodbonds :TextField;
    protected var _time :TextField;
    
    protected var _checkRoomProps2ShowStatsTimer :Timer;//Stupid hack, the first time a player enters a room, the 
    
    protected static const log :Log = Log.getLog( HUD );
}

}