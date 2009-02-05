package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.threerings.util.StringBuilder;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.contrib.EventHandlers;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.utils.Timer;

import vampire.client.events.ClosestPlayerChangedEvent;
import vampire.data.Codes;
import vampire.data.Constants;
import vampire.data.Logic;
import vampire.data.SharedPlayerStateClient;

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
        
        //Listen to events that might cause us to update ourselves
        registerListener(ClientContext.gameCtrl.player, AVRGamePlayerEvent.ENTERED_ROOM, updateOurPlayerState );
        registerListener( ClientContext.gameCtrl.room.props, PropertyChangedEvent.PROPERTY_CHANGED, propChanged );
        registerListener( ClientContext.gameCtrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        
//        registerListener( ClientContext.model, ClosestPlayerChangedEvent.CLOSEST_PLAYER_CHANGED, closestPlayerChanged);
        
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
           
        
//        _checkRoomProps2ShowStatsTimer = new Timer(300, 0);
//        EventHandlers.registerListener( _checkRoomProps2ShowStatsTimer, TimerEvent.TIMER, checkPlayerRoomProps);    
//        _checkRoomProps2ShowStatsTimer.start();   

          
    }
    
    override protected function destroyed () :void
    {
        trace("HUD destroyed");
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
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
        if( e.closestPlayerId > 0) {
            _target.text = "Target: " + ClientContext.gameCtrl.room.getAvatarInfo( e.closestPlayerId ).name;
        }
        else {
            _target.text = "Target: ";
        }
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
//        trace("Player stats: " + SharedPlayerStateClient.toStringForPlayer( ClientContext.ourPlayerId));
        //Otherwise check for player updates
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );
        
        
        if( !isNaN( playerIdUpdated ) ) { 
            if( playerIdUpdated == ClientContext.ourPlayerId) {
            
                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD) {
                    showBlood( ClientContext.ourPlayerId );
                }
                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP) {
                    showXP( ClientContext.ourPlayerId );
                }
                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_LEVEL) {
                    showLevel( ClientContext.ourPlayerId );
                }
                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {
                    showBloodBonds( ClientContext.ourPlayerId );
                }
                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION) {
                    showAction( ClientContext.ourPlayerId );
                }
                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE) {
                    showTime( ClientContext.ourPlayerId );
                }
                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_DISPLAY_VISIBLE
//                         || e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_NAME
//                         || e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_LOCATION
//                         || e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_BLOOD
//                         || e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_MAXBLOOD
                ) {
                    showTarget( ClientContext.ourPlayerId );
                }
            }
            else {
//                log.debug("  Failed to update ElementChangedEvent" + e);
            }
        }
        else {
            log.error("isNaN( " + playerIdUpdated + " ), failed to update ElementChangedEvent" + e);
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
        _sprite = new Sprite();
        _hud = new DraggableSprite(ClientContext.gameCtrl, "HUD");
        _sprite.addChild( _hud );
        _hud.init( new Rectangle(0, 0, 100, 100), 10, 10, 10, 10);
        _hud.graphics.beginFill(0xffffff);
        _hud.graphics.drawRect(0, 0, 600, 50);
        _hud.graphics.drawRect(290, 50, 260, 100);
        _hud.graphics.endFill();
        
        var startX :int = 30;
        var startY :int = 0;
            
        for each ( var mode :String in Constants.GAME_MODES) {
            var button :SimpleTextButton = new SimpleTextButton( mode );
            button.x = startX;
            button.y = startY;
            startX += 85;
            Command.bind( button, MouseEvent.CLICK, VampireController.SWITCH_MODE, mode);
            _hud.addChild( button );
        }
        
        
        //Help Button
        var help :SimpleTextButton = new SimpleTextButton( "Help" );
        help.x = startX;
        help.y = startY;
        startX += 90;
        Command.bind( help, MouseEvent.CLICK, VampireController.SHOW_INTRO);
        _hud.addChild( help );
        
        //Show blood as a horizontal bar
        _blood = new Sprite();
        _hud.addChild( _blood );
        _blood.x = 180;
        _blood.y = 35; 
        
        _bloodText = TextFieldUtil.createField("", {mouseEnabled:false, selectable:false});
        _bloodText.x = 50;
        _blood.addChild( _bloodText );
        
        //Show xp as a horizontal bar
        _xp = new Sprite();
        _hud.addChild( _xp );
        _xp.x = 320;
        _xp.y = 35; 
        
        _xpText = TextFieldUtil.createField("", {mouseEnabled:false, selectable:false});
        _xpText.x = 50;
        _xp.addChild( _xpText );
        
        
        //Quit button
        var quitButton :SimpleTextButton = new SimpleTextButton( "Quit" );
        quitButton.x = startX;
        button.y = startY;
        startX += 90;
        Command.bind( quitButton, MouseEvent.CLICK, VampireController.QUIT);
        _hud.addChild( quitButton );
        
        
        _action = TextFieldUtil.createField("Action: ", {mouseEnabled:false, selectable:false, x:300, y:45});
        _hud.addChild( _action );
        
        _level = TextFieldUtil.createField("Level: ", {mouseEnabled:false, selectable:false, x:300, y:65});
        _hud.addChild( _level );
        
        _target = TextFieldUtil.createField("Target: ", {mouseEnabled:false, selectable:false, x:300, y:85, width:400});
        _hud.addChild( _target );
        
        _bloodbonds = TextFieldUtil.createField("Bloodbonds: ", {mouseEnabled:false, selectable:false, x:300, y:105, width:300});
        _hud.addChild( _bloodbonds );
        
        _time = TextFieldUtil.createField("Time: ", {mouseEnabled:false, selectable:false, x:300, y:125, width:450});
        _hud.addChild( _time );
        
        _myName = TextFieldUtil.createField("Me: Testing locally", {mouseEnabled:false, selectable:false, x:20, y:35, width:150});
        if( !Constants.LOCAL_DEBUG_MODE) {
            _myName = TextFieldUtil.createField("Me: " + ClientContext.gameCtrl.room.getAvatarInfo( ClientContext.ourPlayerId).name, {mouseEnabled:false, selectable:false, x:20, y:35, width:150});
        }
            
        _hud.addChild( _myName );
        
        //The target overlay
        _targetSprite = new Sprite();
        _sprite.addChild( _targetSprite );
        _targetSprite.graphics.lineStyle(4, 0xcc0000);
        _targetSprite.graphics.drawCircle(0, 0, 20);
        _targetSprite.visible = false;
        
        _targetSpriteBlood = new Sprite();
        _sprite.addChild( _targetSpriteBlood );
        _targetSpriteBlood.x = -50;
        _targetSpriteBlood.y = -30; 
        
        _targetSpriteBloodText = TextFieldUtil.createField("", {mouseEnabled:false, selectable:false});
        _targetSpriteBloodText.x = 0;
        _targetSpriteBloodText.y = 0;
        _targetSpriteBlood.addChild( _targetSpriteBloodText );
        
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
            log.warning("updatePlayerState, but no props found");
            return;
        }
        
        
        showBlood( ClientContext.ourPlayerId );
        showXP( ClientContext.ourPlayerId );
        showLevel( ClientContext.ourPlayerId );
        showBloodBonds( ClientContext.ourPlayerId );
        showAction( ClientContext.ourPlayerId );
        showTime( ClientContext.ourPlayerId );
        showTarget( ClientContext.ourPlayerId );
        
    }
    
    protected function showBlood( playerId :int ) :void
    {
        log.debug("Showing player blood=" + SharedPlayerStateClient.getBlood( playerId ) + "/" + SharedPlayerStateClient.getMaxBlood( playerId ));
        _blood.graphics.clear();
        var bloodColor :int = SharedPlayerStateClient.isVampire( playerId ) ? 0xcc0000 : 0x0000ff;//Red or blue for vampire or thrall
        _blood.graphics.lineStyle(1, bloodColor);
        _blood.graphics.drawRect(0, 0, 100, 10);
        _blood.graphics.beginFill( bloodColor );
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
    
    protected function showXP( playerId :int ) :void
    {
        var currentXp :int = SharedPlayerStateClient.getXP( playerId ) ;
        var xpForNextLevel :int = Logic.xpNeededForLevel(SharedPlayerStateClient.getLevel(playerId) + 1);
        var xpForCurrentLevelLevel :int = Logic.xpNeededForLevel(SharedPlayerStateClient.getLevel(playerId));
        log.debug("Showing player xp=" + currentXp + "/" + xpForNextLevel);
        _xp.graphics.clear();
        var xpColor :int = 0x009900;//Green
        _xp.graphics.lineStyle(1, xpColor);
        _xp.graphics.drawRect(0, 0, 100, 10);
        _xp.graphics.beginFill( xpColor );
        if( xpForNextLevel > 0) {
            _xp.graphics.drawRect(0, 0, (Math.max(0, (currentXp - xpForCurrentLevelLevel)) * 100.0) / (xpForNextLevel - xpForCurrentLevelLevel), 10);
        }
        _xp.graphics.endFill();
        
        var xptext :String = "" + currentXp + "/" + xpForNextLevel;
        _xpText.text = xptext;
        
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
    protected function showTarget( playerId :int ) :void
    {
        _targetSprite.visible = false;
        
        
        var targetId :int = SharedPlayerStateClient.getTargetPlayer( playerId );
        var targetLocation :Array = SharedPlayerStateClient.getTargetLocation( playerId );
        _targetSpriteBlood.graphics.clear();
         _targetSpriteBloodText.text = "";
        if( !SharedPlayerStateClient.getTargetVisible( playerId )) {
            return;
        }
        
        if( targetId > 0 && targetLocation != null) {
            _targetSprite.visible = true;
            _target.text = "Target: " + SharedPlayerStateClient.getTargetName( playerId );
            
            var targetHeight :Number = SharedPlayerStateClient.getTargetHeight( playerId );
            var halfTargetAvatarHeight :Number = targetHeight*0.5/ClientContext.gameCtrl.local.getRoomBounds()[1];
            var p :Point = ClientContext.gameCtrl.local.locationToPaintable( targetLocation[0], halfTargetAvatarHeight, targetLocation[2]) as Point;
            _targetSprite.visible = true;
            _targetSprite.x = p.x;
            _targetSprite.y = p.y;
            
            //Show the targets blood
            var targetBlood :Number = SharedPlayerStateClient.getTargetBlood( playerId );
            var targetMaxBlood :Number = SharedPlayerStateClient.getTargetMaxBlood( playerId );
            
//            trace("showTarget() targetBlood=" + targetBlood); 
//            trace("showTarget() targetMaxBlood=" + targetMaxBlood);
            
            if( !isNaN( targetBlood ) && !isNaN( targetMaxBlood ) ) {
                
                
                var targetAvatarHeight :Number = targetHeight/ClientContext.gameCtrl.local.getRoomBounds()[1];
                var pointForBloodBar :Point = ClientContext.gameCtrl.local.locationToPaintable( targetLocation[0], targetAvatarHeight, targetLocation[2]) as Point;
                pointForBloodBar.y = pointForBloodBar.y - 30;//Adjust to be over the player name
                _targetSpriteBlood.x = pointForBloodBar.x;
                _targetSpriteBlood.y = pointForBloodBar.y;
                var bloodColor :int =  0xcc0000;
                _targetSpriteBlood.graphics.lineStyle(1, bloodColor);
                _targetSpriteBlood.graphics.drawRect(-50, -5, 100, 10);
                _targetSpriteBlood.graphics.beginFill( bloodColor );
                
                
                if( targetBlood > 0 && targetMaxBlood > 0) {
                    _targetSpriteBlood.graphics.drawRect(-50, -5, (targetBlood * 100.0) / targetMaxBlood, 10);
                }
                _targetSpriteBlood.graphics.endFill();
                
                var bloodtext :String = "" + targetBlood;
                if( bloodtext.indexOf(".") >= 0) {
                    bloodtext = bloodtext.slice(0, bloodtext.indexOf(".") + 3);
                }
                _targetSpriteBloodText.text = bloodtext;
            }
            else {
                _targetSpriteBloodText.text = "";
            }
        
                
                
        }
        else {
            log.error("showTarget, but location is null");
        }
        
//        var userData :Array = SharedPlayerStateClient.getClosestUserData(playerId);
//        if( userData != null && userData.length >= 1) {
//            if( userData.length == 1) {
//                _target.text = "Target: " + userData[0];
//            }
//            else if( userData.length > 1) {
//                _target.text = "Target: " + userData[0] + " " + userData[1];
//                
//                var location :Array = userData[2] as Array;
//                if( location == null) {
//                    log.error("showTarget, but location is null");
//                    return;
//                } 
//                
//                var halfTargetAvatarHeight :Number = userData[3]*0.5/ClientContext.gameCtrl.local.getRoomBounds()[1];
//                var p :Point = ClientContext.gameCtrl.local.locationToPaintable( location[0], halfTargetAvatarHeight, location[2]) as Point;
//                _targetSprite.visible = true;
//                _targetSprite.x = p.x;
//                _targetSprite.y = p.y;
//            }
//        }
    }
    
    protected function showTime( playerId :int ) :void
    {
        var date :Date = new Date( SharedPlayerStateClient.getTime( ClientContext.ourPlayerId ) );
        _time.text = "Quit last game at: " + date.toLocaleTimeString() + " " + date.toDateString();
        
        if( SharedPlayerStateClient.getTime( ClientContext.ourPlayerId ) == 1 ) {
            if( ClientContext.game.ctx.mainLoop.topMode !== new IntroHelpMode() ) {
                ClientContext.game.ctx.mainLoop.pushMode( new IntroHelpMode());
            } 
        }
    }

    protected var _sprite :Sprite;
    protected var _hud :DraggableSprite;
    
    protected var _blood :Sprite;
    protected var _bloodText :TextField;
    
    protected var _xp :Sprite;
    protected var _xpText :TextField;
    
    
    protected var _action :TextField;
    protected var _level :TextField;
    protected var _target :TextField;
    protected var _myName :TextField;
    protected var _bloodbonds :TextField;
    protected var _time :TextField;
    
    protected var _targetSprite :Sprite;
    protected var _targetSpriteBlood :Sprite;
    protected var _targetSpriteBloodText :TextField;
    
    protected var _checkRoomProps2ShowStatsTimer :Timer;//Stupid hack, the first time a player enters a room, the 
    
    protected static const log :Log = Log.getLog( HUD );
}

}