package vampire.avatar
{
    import com.threerings.util.ArrayUtil;
    import com.whirled.avrg.AVRGameControl;
    import com.whirled.contrib.EventHandlerManager;
    import com.whirled.contrib.avrg.AvatarHUD;
    import com.whirled.contrib.simplegame.objects.SimpleTimer;
    import com.whirled.net.ElementChangedEvent;
    import com.whirled.net.MessageReceivedEvent;

    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import vampire.client.ClientContext;
    import vampire.client.events.HierarchyUpdatedEvent;
    import vampire.data.Codes;
    import vampire.data.Logic;
    import vampire.data.SharedPlayerStateClient;
    import vampire.data.VConstants;


/**
 * Show the HUD for blood, bloodbond status, targeting info etc all over the avatar in the room,
 * scaled for the avatars position and updated from the room props.
 *
 */
public class VampireAvatarHUD extends AvatarHUD
{
    public function VampireAvatarHUD( ctrl :AVRGameControl, userId:int)
    {
        super(ctrl, userId);
        trace("userId " + userId);
        _roomKey = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + _userId;

        //Listen for changes in blood levels
        registerListener(ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);
        registerListener(ClientContext.ctrl.room, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);

        registerListener(ClientContext.model, HierarchyUpdatedEvent.HIERARCHY_UPDATED, updateInfoHud);

        _hudSprite = new Sprite();
        _displaySprite.addChild( _hudSprite );
        _hudSprite.y = -10;




        _target_UI = ClientContext.instantiateMovieClip("HUD", "target_UI", true);
        _target_UI.mouseChildren = true;
        _hudSprite.addChild( _target_UI );

        buttonFeed.visible = false;

        registerListener(buttonFeed, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.hud.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_FEED_TARGET);
            ClientContext.controller.handleSendFeedRequest( playerId, false );
        });

        buttonFrenzy.visible = false;
        registerListener(buttonFrenzy, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleSendFeedRequest( playerId, true );

            if( _frenzyDelayRemaining <= 0 ) {
                _frenzyDelayRemaining = VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME;
            }
            if( VConstants.LOCAL_DEBUG_MODE) {
                _frenzyDelayRemaining = VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME;
                var t :SimpleTimer = new SimpleTimer(1, function() :void {
                   decrementTime();
                }, true);
                db.addObject( t );
            }
            _frenzyButtonClicked = true;
            buttonFrenzy.visible = false;
            showFrenzyTimerWithoutButton();
        });

        frenzyCountdown.visible = false;
        frenzyCountdown.addEventListener(MouseEvent.ROLL_OVER, function(...ignored) :void {
            waitingSign.visible = true;
        });
        frenzyCountdown.addEventListener(MouseEvent.ROLL_OUT, function(...ignored) :void {
            waitingSign.visible = false;
        });
        frenzyCountdown.y += 80;
        waitingSign.visible = false;
        waitingSign.y += 80;


        //HUD bits and bobs
        _hierarchyIcon = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
        _hierarchyIcon.mouseEnabled = false;
        _bloodBondIcon = ClientContext.instantiateMovieClip("HUD", "bond_icon", true);
        _blood = ClientContext.instantiateMovieClip("HUD", "target_blood_meter", false);
        _blood.height = 10;

        _preyStrain = ClientContext.instantiateMovieClip("HUD", "prey_strain", true);
        _preyStrain.scaleX = _preyStrain.scaleY = 2;
        _hudSprite.addChild( _blood );
        _hudSprite.addChild( _hierarchyIcon );
        _hudSprite.addChild( _bloodBondIcon );


        if( Logic.getPlayerPreferredBloodStrain( ClientContext.ourPlayerId ) == userId ) {
            _hudSprite.addChild( _preyStrain );
        }

        updateInfoHud();

        showNothing();

        buttonFeed.visible = false;

    }

    protected function decrementTime() :void
    {
        _frenzyDelayRemaining -= 1;
    }


//    protected function selectionBoxMouseOut( e :MouseEvent ) :void
//    {
//        if( e.relatedObject != null ) {
//            return;
//        }
//        buttonFeed.visible = false;
//        buttonFrenzy.visible = false;
//    }




    protected function handleElementChanged (e :ElementChangedEvent) :void
    {

        if( e.name == Codes.ROOM_PROP_MINION_HIERARCHY ) {
            updateInfoHud();
        }
        else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {
            updateInfoHud();
        }
        else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD) {
            var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );
            //If it's us, update the our HUD
            if( !isNaN( playerIdUpdated ) && playerIdUpdated == playerId) {
                updateBlood();
            }
        }
    }

    protected function handleMessageReceived( e :MessageReceivedEvent ) :void
    {
        if( e.name == VConstants.NAMED_EVENT_BLOODBLOOM_COUNTDOWN) {

            var bbData :Array = e.value as Array;
            if( bbData == null) {
                log.error("handleMessageReceived " + VConstants.NAMED_EVENT_BLOODBLOOM_COUNTDOWN + ", but bloodbloodRecord==null" );
                return;
            }

            var currentCountDownSecond :int = bbData[0];
            var preyId :int = bbData[1];
            if( preyId == playerId ) {

                if( currentCountDownSecond >= 1) {
                    if( _frenzyDelayRemaining <= 0) {
                        _frenzyDelayRemaining = currentCountDownSecond;
                    }
                    showFrenzyTimerIfCounting();
                }
                else {
                    _frenzyDelayRemaining = 0;
                    showNothing();
                }
            }
        }
    }


    protected static const BLOOD_BAR_MIN_WIDTH :int = 50;

    protected function updateBlood( ...ignored ) :void
    {
        var maxBlood :Number = VConstants.MAX_BLOOD_NONPLAYERS;
        if( isPlayer ) {
            maxBlood = SharedPlayerStateClient.getMaxBlood( playerId );
        }

        var currentBlood :Number = SharedPlayerStateClient.getBlood( playerId );
        if( isNaN( currentBlood ) ) {
            currentBlood = maxBlood;
        }

        _blood.width = BLOOD_BAR_MIN_WIDTH;
        _blood.height = 15;

        var scaleY :Number = maxBlood / VConstants.MAX_BLOOD_FOR_LEVEL(1);
        _blood.gotoAndStop(int(currentBlood*100.0/maxBlood) );

    }
    protected function updateInfoHud(...ignored) :void
    {

        updateBlood();

        var isHierarch :Boolean = VConstants.LOCAL_DEBUG_MODE
            || (ClientContext.model.hierarchy != null &&
                ClientContext.model.hierarchy.isPlayerSireOrMinionOfPlayer( playerId,
                ClientContext.ourPlayerId ));


        var isBloodBond :Boolean = VConstants.LOCAL_DEBUG_MODE ||
            (SharedPlayerStateClient.getBloodBonded( ClientContext.ourPlayerId ) == playerId);

        _hierarchyIcon.visible = isHierarch;
        _bloodBondIcon.visible = isBloodBond;


        _hierarchyIcon.x = 16;
        _bloodBondIcon.x = -16;

    }

    override public function get isPlayer() :Boolean
    {
        return ArrayUtil.contains( ClientContext.ctrl.room.getPlayerIds(), playerId );
    }

    public function setDisplayModeInvisible() :void
    {
        if( _frenzyDelayRemaining ) {
            showFrenzyTimerWithoutButton()
        }
        else {
            showNothing();
        }

    }

    public function setDisplayModeSelectableForFeed( multiplayer :Boolean ) :void
    {
        _displaySprite.addChild( _hudSprite );
        trace("1");
        buttonFeed.visible = true;
        buttonFrenzy.visible = multiplayer;
    }

    public function setDisplayModeShowInfo() :void
    {
        showBloodBarOnly();
        showFrenzyTimerIfCounting();
    }

    public function setSelectedForFeed( multiplayer :Boolean ) :void
    {
        _displaySprite.addChild( _hudSprite );


        if( multiplayer ) {
            showFeedButtonOnly();
        }
        else {
            showFeedAndFrenzyButton();
        }

        showFrenzyTimerIfCounting();

    }



    override protected function update( dt :Number ) :void
    {
        super.update(dt);

        _frenzyDelayRemaining -= dt;

        _frenzyDelayRemaining = Math.max( _frenzyDelayRemaining, 0 );
        showFrenzyTimerIfCounting();

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


        if( _hudSprite != null && _hotspot != null && hotspot.length >= 2// && !isNaN(_zScaleFactor)
            && !isNaN(hotspot[0]) && !isNaN(hotspot[1]) ) {

            _hudSprite.graphics.clear();
            _hudSprite.graphics.beginFill(0, 0.3);
            _hudSprite.graphics.drawCircle(0, 0, 20 );
            _hudSprite.graphics.endFill();
        }

    }


    public function showBloodBarOnly() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );
        buttonFeed.visible = false;
        buttonFrenzy.visible = false;
        frenzyCountdown.visible = false;

    }

    public function showFeedButtonOnly() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );

        trace("2")
        buttonFeed.visible = true;
        buttonFrenzy.visible = false;
        frenzyCountdown.visible = false;
    }
    public function showFeedAndFrenzyButton() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );
        trace("3")
        buttonFeed.visible = true;
        buttonFrenzy.visible = true;
        frenzyCountdown.visible = false;
    }

    public function showFrenzyTimerWithoutButton() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );

        buttonFeed.visible = false;
        buttonFrenzy.visible = false;
        frenzyCountdown.visible = true;
    }

    public function showFrenzyTimerWithButton() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }
        _displaySprite.addChild( _hudSprite );

        buttonFeed.visible = false;
        buttonFrenzy.visible = true;
        frenzyCountdown.visible = true;
    }

    protected function showFrenzyTimerIfCounting() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        if( (_frenzyDelayRemaining > 0 ) && ClientContext.model.isVampire()) {

            _displaySprite.addChild( _hudSprite );
            buttonFeed.visible = false;
            frenzyCountdown.visible = true;
            buttonFrenzy.visible = !_frenzyButtonClicked;
            frenzyCountdown.gotoAndStop( int( 100 - (_frenzyDelayRemaining*100 / VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME) ));
        }
        else {
            frenzyCountdown.visible = false;
            _frenzyButtonClicked = false;
        }
    }

    public function showNothing() :void
    {
        if( _displaySprite.contains( _hudSprite ) ) {
            _displaySprite.removeChild( _hudSprite );
        }
        buttonFeed.visible = false;
        buttonFrenzy.visible = false;
        frenzyCountdown.visible = false;
    }


    protected var _hudMouseEvents :EventHandlerManager = new EventHandlerManager();

    protected var _hudSprite :Sprite;
    protected var _target_UI :MovieClip;
    protected var _bloodBondIcon :MovieClip;
    protected var _hierarchyIcon :SimpleButton;
    protected var _blood :MovieClip;
    protected var _preyStrain :MovieClip;

    protected var _roomKey :String;

    protected var _frenzyDelayRemaining :Number = -1;
    protected var _frenzyButtonClicked :Boolean;



}
}