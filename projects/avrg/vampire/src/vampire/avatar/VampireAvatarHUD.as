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

        _roomKey = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + _userId;

        //Listen for changes in blood levels
        registerListener(ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);
        registerListener(ClientContext.ctrl.room, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);

        registerListener(ClientContext.model, HierarchyUpdatedEvent.HIERARCHY_UPDATED, updateInfoHud);

        _hudSprite = new Sprite();
        _displaySprite.addChild( _hudSprite );
        _hudSprite.y = -10;

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
//            if( _frenzyDelayRemaining > 0 ) {
//                return;
//            }
            ClientContext.hud.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_FEED_TARGET);
            ClientContext.controller.handleSendFeedRequest( playerId, false );
//            _selected = true;
//            _feedRequestDelayRemaining = FEED_REQUEST_DELAY;
        });

//        buttonFeed.x = -30;
        buttonFrenzy.visible = false;
        registerListener(buttonFrenzy, MouseEvent.CLICK, function (...ignored) :void {
//            if( _frenzyDelayRemaining > 0 ) {
//                return;
//            }
//            ClientContext.hud.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_FEED_TARGET);
            ClientContext.controller.handleSendFeedRequest( playerId, true );

            if( _frenzyDelayRemaining <= 0 ) {
                _frenzyDelayRemaining = VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME;
            }
//            if( !_isFrenzyCountingDown ) {//Only set our time if we are not already counting down
//            }
//            else {
//                _frenzyDelayRemaining = -1;
//            }
//            _selected = true;
            if( VConstants.LOCAL_DEBUG_MODE) {
                _frenzyDelayRemaining = VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME;
                var t :SimpleTimer = new SimpleTimer(1, function() :void {
                   decrementTime();
                }, true);
                db.addObject( t );
            }
            trace("setting _frenzyButtonClicked = true");
            _frenzyButtonClicked = true;
            buttonFrenzy.visible = false;
            showFrenzyTimerWithoutButton();
        });
//        buttonFrenzy.x = 30;

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


        _hudSprite.addChild( _blood );
        _hudSprite.addChild( _hierarchyIcon );
        _hudSprite.addChild( _bloodBondIcon );

        updateInfoHud();

        showNothing();


        //Add a selection box
//        _selectionBox = new Sprite();
//        _selectionBox.graphics.beginFill(0, 0.3);
//        _selectionBox.graphics.drawRect(-50, -30, 100, 200);
//        _selectionBox.graphics.endFill();

//        registerListener(_selectionBox, MouseEvent.ROLL_OUT, selectionBoxMouseOut);

//        registerListener(_selectionBox, MouseEvent.MOUSE_MOVE, function(e:MouseEvent) :void {
//            trace("Mouse move over selection box " + e );
//        });
//        _selectionBox.addEventListener(MouseEvent.MOUSE_OUT,hideFeedButtons);

//        _blood.addEventListener( MouseEvent.ROLL_OVER, bloodMouseOver);
//        _blood.addEventListener( MouseEvent.MOUSE_MOVE, bloodMouseOver);
//        _blood.addEventListener( MouseEvent.MOUSE_OVER, showFeedButtons);

    }

    protected function decrementTime() :void
    {
        _frenzyDelayRemaining -= 1;
    }

//    protected function bloodMouseOver( e :MouseEvent ) :void
//    {
//        if( !frenzyCountdown.visible ) {
////            if( !_hudSprite.contains(_selectionBox ) ) {
////                _hudSprite.addChildAt( _selectionBox, 0 );
////            }
//            buttonFeed.visible = true;
//            buttonFrenzy.visible = _multiPlayer;
//        }
//    }

    protected function selectionBoxMouseOut( e :MouseEvent ) :void
    {
//        trace("Mouse out " + e);
        if( e.relatedObject != null ) {
            return;
        }
//        if( _selectionBox.parent != null ) {
//            _selectionBox.parent.removeChild( _selectionBox );
//        }
        buttonFeed.visible = false;
        buttonFrenzy.visible = false;
    }




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



//        //Try to only update when necessary
//        if( !isNaN( playerIdUpdated ) ) {
//
//
//
//                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD) {
//                    showBlood( ClientContext.ourPlayerId );
//                }
//                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP) {
//                    showXP( ClientContext.ourPlayerId );
//                    showBlood( ClientContext.ourPlayerId );
//                }
////                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_LEVEL) {
////                    showLevel( ClientContext.ourPlayerId );
////                }
//                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED
//                    || e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME) {
//                    showBloodBonds( ClientContext.ourPlayerId );
////                    showTarget( ClientContext.ourPlayerId );
//                }
//
//
//
//                updateInfoHud();
//            }
//            else {
//                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {
//                    updateInfoHud();
//                }
//            }
//        }
//        else {
//            if( e.name == Codes.ROOM_PROP_MINION_HIERARCHY ) {
//                updateInfoHud();
//            }
//        }

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

//                    trace("handleMessageReceived, bloodbloodRecord=" + bbData);

//                    _resetHUDStateDelay = 3;

                    if( currentCountDownSecond >= 1) {
//                        _isFrenzyCountingDown = true;
                        if( _frenzyDelayRemaining <= 0) {
                            _frenzyDelayRemaining = currentCountDownSecond;
                        }
                        showFrenzyTimerIfCounting();
//                        frenzyCountdown.visible = true;
//                        buttonFrenzy.visible = !_selected;
//                        buttonFeed.visible = false;
                    }
                    else {
//                        trace(playerId + " resetting");
//                        _isFrenzyCountingDown = false;
                        _frenzyDelayRemaining = 0;
//                        _resetHUDStateDelay = 0;
                        showNothing();
//                        frenzyCountdown.visible = false;
//                        buttonFrenzy.visible = false;
//                        buttonFeed.visible = false;
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

//        _blood.y = 10;

        var scaleY :Number = maxBlood / VConstants.MAX_BLOOD_FOR_LEVEL(1);
//        _blood.scaleY = 50;//scaleY;
//        trace("blood frame=" + (currentBlood*100/maxBlood));
        _blood.gotoAndStop(int(currentBlood*100.0/maxBlood) );

    }
    protected function updateInfoHud(...ignored) :void
    {

        updateBlood();
//        var currentBlood :Number = SharedPlayerStateClient.getBlood( playerId );
//        if( isNaN( currentBlood ) ) {
//            currentBlood = 1;
//        }
//        var maxBlood :Number = VConstants.MAX_BLOOD_NONPLAYERS;
//        if( isPlayer ) {
//            maxBlood = SharedPlayerStateClient.getMaxBlood( playerId );
//        }

//        trace("updateInfoHud() player=" + playerId + ", currentBlood=" + currentBlood + "/" + maxBlood);

        var isHierarch :Boolean = VConstants.LOCAL_DEBUG_MODE
            || (ClientContext.model.hierarchy != null &&
                ClientContext.model.hierarchy.isPlayerSireOrMinionOfPlayer( playerId,
                ClientContext.ourPlayerId ));


        var isBloodBond :Boolean = VConstants.LOCAL_DEBUG_MODE ||
            (SharedPlayerStateClient.getBloodBonded( ClientContext.ourPlayerId ) == playerId);

        _hierarchyIcon.visible = isHierarch;
        _bloodBondIcon.visible = isBloodBond;


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
        if( _frenzyDelayRemaining ) {
            showFrenzyTimerWithoutButton()
        }
        else {
            showNothing();
        }

//        if( ClientContext.ourPlayerId == playerId || !_frenzyDelayRemaining) {
//
//            trace(playerId + " invisible, buttonFrenzy.visible=" + buttonFrenzy.visible + ", _selected=" + _selected);
//            _hudMouseEvents.freeAllHandlers();
//            if( _displaySprite.contains( _hudSprite ) ) {
//                _displaySprite.removeChild( _hudSprite );
//            }
////            if( _selectionBox.parent != null ) {
////                _selectionBox.parent.removeChild( _selectionBox );
////            }
//
////            _selected = false;
//        }
    }

    public function setDisplayModeSelectableForFeed( multiplayer :Boolean ) :void
    {
        _displaySprite.addChild( _hudSprite );
        _multiPlayer = multiplayer;
//        _hudSprite.addChild( _target_UI );
        buttonFeed.visible = true;
        buttonFrenzy.visible = multiplayer;

//        _frenzyDelayRemaining = multiplayer ? VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME : 0;
//        frenzyCountdown.visible = _frenzyDelayRemaining > 0 ? true : false;
//        buttonFrenzy.visible = multiplayer || frenzyCountdown.visible;
//        waitingSign.visible = false;
//        _selected = false;
    }

    public function setDisplayModeShowInfo() :void
    {
//        trace(playerId + " setDisplayModeShowInfo");//, _selected=" + _selected);

        showBloodBarOnly();
        showFrenzyTimerIfCounting();
//        _hudMouseEvents.freeAllHandlers();

//        _hudSprite.addChild( _target_UI );
//        buttonFeed.visible = false;
//        trace("_frenzyDelayRemaining="+_frenzyDelayRemaining);
//        frenzyCountdown.visible = _isFrenzyCountingDown > 0 ? true : false;
//        buttonFrenzy.visible = frenzyCountdown.visible && !_selected;
//        waitingSign.visible = false;
//        _selected = false;
    }

    public function setSelectedForFeed( multiplayer :Boolean ) :void
    {
//        trace("setSelectedForFeed");
        _displaySprite.addChild( _hudSprite );


        if( multiplayer ) {
            showFeedButtonOnly();
        }
        else {
            showFeedAndFrenzyButton();
        }

        showFrenzyTimerIfCounting();

////        _hudSprite.addChild( _target_UI );
//        buttonFeed.visible = false;
//        buttonFrenzy.visible = false;
//        _frenzyDelayRemaining = multiplayer ? VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME : 0;
//        frenzyCountdown.visible = _frenzyDelayRemaining > 0 ? true : false;
//        trace("frenzyCountdown.visible=" + frenzyCountdown.visible);
////        frenzyCountdown.visible = multiplayer;
//        frenzyCountdown.gotoAndPlay(1);
//        waitingSign.visible = false;

//        _feedRequestDelayRemaining = frenzyCountdown.visible ? VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME : 0;

//        _selected = true;
    }



    override protected function update( dt :Number ) :void
    {
        super.update(dt);


//        if( _resetHUDStateDelay > 0 ) {
//            _resetHUDStateDelay -= dt;
//            _resetHUDStateDelay = Math.max( _resetHUDStateDelay, 0 );
//
//            if( _resetHUDStateDelay <= 0 ) {
//                showBloodBarOnly();
//                _selected = false;
//                _isFrenzyCountingDown = false;
//                _frenzyDelayRemaining = 0;
//            }
//        }

//        if( _frenzyDelayRemaining > 0 ) {
//            trace(playerId + " _frenzyDelayRemaining=" + _frenzyDelayRemaining );
//        }
//        if( _frenzyDelayRemaining > 0 && _frenzyDelayRemaining - dt) {
//            _frenzyButtonClicked = false;
//        }
        _frenzyDelayRemaining -= dt;

//        if( _frenzyDelayRemaining <= 0) {
//            _isFrenzyCountingDown = false;
//        }
        _frenzyDelayRemaining = Math.max( _frenzyDelayRemaining, 0 );
        showFrenzyTimerIfCounting();

//        trace("VampireHUD location (" + x + ", " + y + ")");
        //This is not coupled to the server time ATM.  I figure, it's only waiting for other
        //players and this isn't critical to sync.
//        if( _isFrenzyCountingDown || _frenzyDelayRemaining ) {
//            _resetHUDStateDelay = 2;
//            frenzyCountdown.visible = true;
//            _frenzyDelayRemaining = Math.max(_frenzyDelayRemaining, 0);
//            showFrenzyTimerIfCounting();
////            frenzyCountdown.gotoAndStop( int( 100 - (_frenzyDelayRemaining*100 / VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME) ));
////            buttonFeed.visible = false;
////            buttonFrenzy.visible = !_selected;
//        }
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
//            _hudSprite.y = -_hotspot[1] * _zScaleFactor;
//            _target_UI.y = _hotspot[1]/4;

            _hudSprite.graphics.clear();
            _hudSprite.graphics.beginFill(0, 0.3);
            _hudSprite.graphics.drawCircle(0, 0, 20 );
//            _hudSprite.graphics.drawRect( -hotspot[0]*_zScaleFactor/2, 0, hotspot[0]*_zScaleFactor, hotspot[1]*_zScaleFactor);
            _hudSprite.graphics.endFill();
        }

//        _target_UI.y = hotspot[1] * _zScaleFactor;

//        _sprite.graphics.clear();
//        _sprite.graphics.beginFill(0, 0);
//        _sprite.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
//        _sprite.graphics.endFill();
    }

//    public function get selected() :Boolean
//    {
//        return _selected;
//    }
//
//    public function set selected( s :Boolean) :void
//    {
//        _selected = s;
////        _resetHUDStateDelay = 2;
//    }

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

//            trace("_frenzyButtonClicked=" + _frenzyButtonClicked);
        if( (_frenzyDelayRemaining > 0 ) && ClientContext.model.isVampire()) {

//        trace(playerId + " showFrenzyTimerIfCounting=" + showFrenzyTimerIfCounting);
//        trace(playerId + " _isFrenzyCountingDown=" + _isFrenzyCountingDown);
            _displaySprite.addChild( _hudSprite );
//            trace(playerId + " showing frenzy timer");
            buttonFeed.visible = false;
            frenzyCountdown.visible = true;
            buttonFrenzy.visible = !_frenzyButtonClicked;
            frenzyCountdown.gotoAndStop( int( 100 - (_frenzyDelayRemaining*100 / VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME) ));
//            _resetHUDStateDelay = 3;
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
//    protected var _selectionBox :Sprite;
    protected var _target_UI :MovieClip;
    protected var _bloodBondIcon :MovieClip;
    protected var _hierarchyIcon :SimpleButton;
    protected var _blood :MovieClip;



//    protected var _selected :Boolean = false;
    protected var _multiPlayer :Boolean;


    protected var _roomKey :String;

    protected var _frenzyDelayRemaining :Number = -1;//Prevent two event fired immediately after another
    protected var _frenzyButtonClicked :Boolean;
//    protected var _isFrenzyCountingDown :Boolean = false;

    /**After this time elapses, reset our state.  */
//    protected var _resetHUDStateDelay :Number = 0;


//    protected static const FEED_REQUEST_DELAY :Number = 0.6;

    public static const STATE_SHOW_INFO :int = 0;
//    public static const STATE_ :int = 0;


}
}