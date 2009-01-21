package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.contrib.EventHandlers;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.MainLoop;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.utils.Timer;

import vampire.data.Constants;
import vampire.data.SharedPlayerStateClient;

/**
 * The main game HUD, showing e.g. blood, game notifications, and buttons to select the subgame to
 * play.
 */
public class HUD extends DraggableSprite
{
    public function HUD()
    {
        super(ClientContext.gameCtrl, "HUD");
        
        setupUI();
        
        ClientContext.model.addEventListener( PlayerStateChangedEvent.NAME, playerUpdated );
        log.debug("Starting HUD");
        
        updatePlayerState( ClientContext.ourPlayerId );
//        if( ClientContext.model.isState ) {
//            log.debug("    there is our state in the room props.");
//            updatePlayerState( ClientContext.model.state );
//        }
//        else {
//            log.debug("    our state is not in the room props.");
//        }

        // now that we know our dimensions, initialize DraggableSprite
        
        init( new Rectangle(0, 0, 100, 100), 10, 10, 10, 10);
        
        
        var proximityTimer :Timer = new Timer(1000, 0);
        EventHandlers.registerListener( proximityTimer, TimerEvent.TIMER, checkProximity);    
        proximityTimer.start();    
    }
    
    protected function checkProximity( ...ignored) :void
    {
        trace("Checking proximity");
        var av :AVRGameAvatar = ClientContext.gameCtrl.room.getAvatarInfo( ClientContext.ourPlayerId);
        var mylocation :Point = new Point( av.x, av.y );
        var closestOtherPlayerId :int = -1;
        var closestOtherPlayerDistance :Number = Number.MAX_VALUE;
        
        for each( var playerid :int in ClientContext.gameCtrl.room.getPlayerIds()) {
            if( playerid == ClientContext.ourPlayerId) {
                continue;
            }
            av = ClientContext.gameCtrl.room.getAvatarInfo( playerid );
            var otherPlayerPoint :Point = new Point( av.x, av.y );
            var distance :Number = Point.distance( mylocation, otherPlayerPoint);
            if( distance < closestOtherPlayerDistance) {
                closestOtherPlayerId = playerid;
                closestOtherPlayerDistance = distance;
            }
        }
        
        if( closestOtherPlayerId > 0) {
            _target.text = "Target: " + ClientContext.gameCtrl.room.getAvatarInfo( closestOtherPlayerId ).name;
        }
    }
    
    
    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return _hud != null && _hud.hitTestPoint(x, y, shapeFlag);
    }
    
    protected function setupUI() :void
    {
        _hud = new Sprite();
        addChild( _hud );
        _hud.graphics.beginFill(0xffffff);
        _hud.graphics.drawRect(0, 0, 450, 50);
        _hud.graphics.drawRect(290, 50, 160, 150);
        _hud.graphics.endFill();
        
        var startX :int = 30;
        var startY :int = 0;
            
        for each ( var mode :String in Constants.GAME_MODES) {
            var button :SimpleTextButton = new SimpleTextButton( mode );
            button.x = startX;
            button.y = startY;
            startX += 90;
            Command.bind( button, MouseEvent.CLICK, VampireController.SWITCH_MODE, [MainLoop.instance, mode]);
            _hud.addChild( button );
        }
        
        _blood = new Sprite();
        _hud.addChild( _blood );
        _blood.x = 50;
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
        
        _target = TextFieldUtil.createField("Target: ", {mouseEnabled:false, selectable:false, x:300, y:75});
        _hud.addChild( _target );
        
    }
    
    
    protected function playerUpdated( e :PlayerStateChangedEvent ) :void
    {
        updatePlayerState( e.playerId );
    }
    
    public function updatePlayerState( playerId :int ) :void
    {
        if( !SharedPlayerStateClient.isProps( playerId )) {
            log.debug("updatePlayerState, but no props found");
            return;
        }
        
        showBlood( playerId );
        _action.text = "Action: " + SharedPlayerStateClient.getCurrentAction( playerId );
        _level.text = "Level: " + SharedPlayerStateClient.getLevel( playerId );
        
        changeToMode( SharedPlayerStateClient.getCurrentAction( playerId ) );
    }
    
    public function changeToMode( mode :String ) :void
    {
        var classSting :String = "vampire.client.modes." + mode + "Mode";
        var modeClass :Class = ClassUtil.getClassByName(classSting);
        log.debug("Changing to mode=" + classSting);
        if( modeClass == null) {
            log.error("no mode class found");
        }
        else {
            
            var m :AppMode = new modeClass() as AppMode;
            log.debug("new mode=" + ClassUtil.getClassName( m ) );
            log.debug("current mode=" + ClassUtil.getClassName( MainLoop.instance.topMode ) );
            if( m !== MainLoop.instance.topMode) {
                MainLoop.instance.changeMode( m );
            }
            else{
                log.debug("Not changing mode because the mode is already on top, m=" + m);
            }
        }
    }
    
    protected function showBlood( playerId :int ) :void
    {
        log.debug("Showing player blood=" + SharedPlayerStateClient.getBlood( playerId ) + "/" + SharedPlayerStateClient.getMaxBlood( playerId ));
        _blood.graphics.clear();
        _blood.graphics.lineStyle(1, 0xcc0000);
        _blood.graphics.drawRect(0, 0, 100, 10);
        _blood.graphics.beginFill( 0xcc0000 );
        _blood.graphics.drawRect(0, 0, (SharedPlayerStateClient.getBlood( playerId ) * 100.0) / SharedPlayerStateClient.getMaxBlood( playerId ), 10);
        _blood.graphics.endFill();
        
        _bloodText.text = "" + SharedPlayerStateClient.getBlood( playerId );
        
    }
    
    protected var _hud :Sprite;
    
    protected var _blood :Sprite;
    protected var _bloodText :TextField;
    protected var _action :TextField;
    protected var _level :TextField;
    protected var _target :TextField;
    
    protected static const log :Log = Log.getLog( HUD );
}

}