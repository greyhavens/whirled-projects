package vampire.avatar
{
    import com.threerings.util.ArrayUtil;
    import com.whirled.contrib.avrg.AvatarHUD;
    import com.whirled.net.ElementChangedEvent;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    import vampire.client.ClientContext;
    import vampire.client.events.HierarchyUpdatedEvent;
    import vampire.data.Codes;
    import vampire.data.SharedPlayerStateClient;
    import vampire.data.VConstants;
    import vampire.feeding.Constants;
    import vampire.server.BloodBloomGameRecord;
    
    
/**
 * Show the HUD for blood, bloodbond status, targeting info etc all over the avatar in the room, 
 * scaled for the avatars position and updated from the room props.
 * 
 */
public class VampireAvatarHUD extends AvatarHUD
{
    public function VampireAvatarHUD(userId:int)
    {
        super(userId);
        
        _roomKey = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + _userId;
        
        //Listen for changes in blood levels
        registerListener(ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);
        registerListener(ClientContext.ctrl.room, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);
        
        registerListener(ClientContext.model, HierarchyUpdatedEvent.HIERARCHY_UPDATED, updateInfoHud);
        
        _hudSprite = new Sprite();
        _sprite.addChild( _hudSprite );
        
//        var anchorSprite :Sprite = new Sprite();
//        anchorSprite.graphics.beginFill(0);
//        anchorSprite.graphics.drawCircle(0,0,20);
//        anchorSprite.graphics.endFill();
//        _hudSprite.addChild( anchorSprite );
        
//        _hudSprite.addEventListener(MouseEvent.CLICK, function (...ignored) :void {
//            trace("clkk");
//        });
        
        
        
        _target_UI = ClientContext.instantiateMovieClip("HUD", "target_UI", true);
        _target_UI.mouseChildren = true;
        _hudSprite.addChild( _target_UI );
//        
//        _sprite.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent) :void {
//            trace("Mouse " + e.localX + ", " + e.localY);   
//            
//            var dot :Shape = new Shape();
//            
//            dot.graphics.beginFill(1);
//            dot.graphics.drawCircle(e.localX, e.localY, 3);
//            dot.graphics.endFill()
//            _sprite.addChild( dot );
//        });
        
        buttonFeed.visible = false;
        
        registerListener(buttonFeed, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.hud.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_FEED_TARGET);
            ClientContext.controller.handleSendFeedRequest( playerId, false );    
        });
        
//        buttonFeed.x = -30;
        
        buttonFrenzy.visible = false;
        registerListener(buttonFrenzy, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.hud.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_FEED_TARGET);
            ClientContext.controller.handleSendFeedRequest( playerId, true );    
        });
//        buttonFrenzy.x = 30;
        
        frenzyCountdown.visible = false;
        frenzyCountdown.addEventListener(MouseEvent.ROLL_OVER, function(...ignored) :void {
            waitingSign.visible = true;    
        });
        frenzyCountdown.addEventListener(MouseEvent.ROLL_OUT, function(...ignored) :void {
            waitingSign.visible = false;    
        });
        waitingSign.visible = false;
        
        
        
        //HUD bits and bobs
        _hierarchyIcon = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
        _hierarchyIcon.mouseEnabled = false;
        _bloodBondIcon = ClientContext.instantiateMovieClip("HUD", "bond_icon", true);
        _blood = ClientContext.instantiateMovieClip("HUD", "target_blood_meter", false);
        
        
        
        _hudSprite.addChild( _blood );  
        _hudSprite.addChild( _hierarchyIcon );
        _hudSprite.addChild( _bloodBondIcon );
        
        updateInfoHud();
        
    }
    
    protected function handleElementChanged (e :ElementChangedEvent) :void
    {
        
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );
        
        //Try to only update when necessary
        if( !isNaN( playerIdUpdated ) ) { 
            //If it's us, update the our HUD
            if( playerIdUpdated == playerId) {
                updateInfoHud();
            }
            else {
                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {
                    updateInfoHud();
                }
            }
        }
        else {
            if( e.name == Codes.ROOM_PROP_MINION_HIERARCHY ) {
                updateInfoHud();
            }
        }
        
    }
    protected function handleMessageReceived( e :MessageReceivedEvent ) :void
    {
        if( e.name == VConstants.NAMED_EVENT_BLOODBLOOM_COUNTDOWN) {
            var bloodbloodRecord :BloodBloomGameRecord = BloodBloomGameRecord.fromArray( e.value as Array );
            if( bloodbloodRecord != null ) {
                if( bloodbloodRecord.preyId == playerId ) {
                    frenzyCountdown.gotoAndStop( int(bloodbloodRecord.currentCountDownSecond * 100 / Constants.GAME_TIME) );
                    frenzyCountdown.visible = true;
                }
            }
            else {
                log.error("handleMessageReceived " + VConstants.NAMED_EVENT_BLOODBLOOM_COUNTDOWN + ", but bloodbloodRecord==null" );
            }
        }
    }
    
    
    protected static const BLOOD_BAR_MIN_WIDTH :int = 50;
    
    protected function updateInfoHud(...ignored) :void
    {
        var currentBlood :Number = SharedPlayerStateClient.getBlood( playerId );
        if( isNaN( currentBlood ) ) {
            currentBlood = 1;
        }
        var maxBlood :Number = VConstants.MAX_BLOOD_NONPLAYERS;
        if( isPlayer ) {
            maxBlood = SharedPlayerStateClient.getMaxBlood( playerId ); 
        }
        
//        trace("updateInfoHud() player=" + playerId + ", currentBlood=" + currentBlood + "/" + maxBlood);
        
        var isHierarch :Boolean = VConstants.LOCAL_DEBUG_MODE 
            || (ClientContext.model.hierarchy != null && 
                ClientContext.model.hierarchy.isPlayerSireOrMinionOfPlayer( playerId, 
                ClientContext.ourPlayerId ));
            
        
        var isBloodBond :Boolean = VConstants.LOCAL_DEBUG_MODE || 
            (SharedPlayerStateClient.getBloodBonded( ClientContext.ourPlayerId ) == playerId);
        
        _hierarchyIcon.visible = isHierarch;
        _bloodBondIcon.visible = isBloodBond;
        
        _blood.width = BLOOD_BAR_MIN_WIDTH;
        _blood.height = 30;
        
//        _blood.y = 10;
        
        var scaleY :Number = maxBlood / VConstants.MAX_BLOOD_FOR_LEVEL(1);
//        _blood.scaleY = 50;//scaleY;
//        trace("blood frame=" + (currentBlood*100/maxBlood));
        _blood.gotoAndStop(int(currentBlood*100.0/maxBlood) );
//        _blood.gotoAndStop(50);
            
//        _blood.width = maxBlood;
//        _hierarchyIcon.y = 40;
        _hierarchyIcon.x = 10;
        
//        _bloodBondIcon.y = 40;
        _bloodBondIcon.x = -10;
             
    }
    
    override public function get isPlayer() :Boolean
    {
        return ArrayUtil.contains( ClientContext.ctrl.room.getPlayerIds(), playerId );
    }
    
    public function setDisplayModeInvisible() :void
    {
        if( _sprite.contains( _hudSprite ) ) {
            _sprite.removeChild( _hudSprite );
        }
//        if( _hudSprite.contains( _target_UI ) ) {
//            _hudSprite.removeChild( _target_UI );
//        }
        _selected = false;
    }
    
    public function setDisplayModeSelectableForFeed( multiplayer :Boolean ) :void
    {
        _sprite.addChild( _hudSprite );
        
//        _hudSprite.addChild( _target_UI );
        buttonFeed.visible = true;
        buttonFrenzy.visible = multiplayer;
        frenzyCountdown.visible = false;
//        waitingSign.visible = false;
        _selected = false;
    }
    
    public function setDisplayModeShowInfo() :void
    {
        _sprite.addChild( _hudSprite );
        
//        _hudSprite.addChild( _target_UI );   
        buttonFeed.visible = false;
        buttonFrenzy.visible = false;
        frenzyCountdown.visible = false;
        waitingSign.visible = false; 
        _selected = false;
    }
    
    public function setSelectedForFeed( multiplayer :Boolean ) :void
    {
        _sprite.addChild( _hudSprite );
        
//        _hudSprite.addChild( _target_UI );
        buttonFeed.visible = false;
        buttonFrenzy.visible = false;
        frenzyCountdown.visible = multiplayer;
        frenzyCountdown.gotoAndPlay(1);
        waitingSign.visible = false;
        
        _frenzyTimer = frenzyCountdown.visible ? VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME : 0;
        
        _selected = true;
    }
    

    
    override protected function update( dt :Number ) :void
    {
        if( frenzyCountdown.visible ) {
            if( _frenzyTimer > 0 ) {
                _frenzyTimer -= dt;
                _frenzyTimer = Math.max(_frenzyTimer, 0);
                frenzyCountdown.gotoAndStop( int( _frenzyTimer*100 / VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME ));
            }
        }
    }
    
    
    protected function get buttonFeed() :SimpleButton
    {
        return _target_UI.button_feed;
    }
    protected function get buttonFrenzy() :SimpleButton
    {
        return _target_UI.button_frenzy;
    }
    protected function get frenzyCountdown() :MovieClip
    {
        return _target_UI.frenzy_countdown;
    }
    
    protected function get waitingSign() :MovieClip
    {
        return _target_UI.waiting_sign;
    }
    
    override protected function drawMouseSelectionGraphics() :void
    {
        super.drawMouseSelectionGraphics();
        //Draw an invisible box to detect mouse movement/clicks
        
        
        if( _hudSprite != null && _hotspot != null && hotspot.length >= 2 && !isNaN(_zScaleFactor) 
            && !isNaN(hotspot[0]) && !isNaN(hotspot[1]) ) {
            _hudSprite.y = -_hotspot[1] * _zScaleFactor;
            _target_UI.y = _hotspot[1]/4;
            
//            _hudSprite.graphics.clear();
//            _hudSprite.graphics.beginFill(0, 0.3);
//            _hudSprite.graphics.drawRect( -hotspot[0]*_zScaleFactor/2, 0, hotspot[0]*_zScaleFactor, hotspot[1]*_zScaleFactor);
//            _hudSprite.graphics.endFill();
        }
        
//        _target_UI.y = hotspot[1] * _zScaleFactor;
        
//        _sprite.graphics.clear();
//        _sprite.graphics.beginFill(0, 0);
//        _sprite.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
//        _sprite.graphics.endFill();
    }
    
    public function get selected() :Boolean
    {
        return _selected;
    }
    
    
    protected var _hudSprite :Sprite;
    protected var _target_UI :MovieClip;
    protected var _bloodBondIcon :MovieClip;
    protected var _hierarchyIcon :SimpleButton;
    protected var _blood :MovieClip;
    protected var _selected :Boolean = false;
    
    protected var _frenzyTimer :Number = 0;
    
    protected var _roomKey :String;
    
    
}
}