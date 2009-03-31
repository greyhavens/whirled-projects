package vampire.avatar
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.Command;
    import com.whirled.avrg.AVRGameControl;
    import com.whirled.contrib.EventHandlerManager;
    import com.whirled.contrib.avrg.AvatarHUD;
    import com.whirled.contrib.simplegame.objects.SceneButton;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.objects.SceneObjectPlayMovieClipOnce;
    import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
    import com.whirled.contrib.simplegame.tasks.AlphaTask;
    import com.whirled.contrib.simplegame.tasks.FunctionTask;
    import com.whirled.contrib.simplegame.tasks.SerialTask;
    import com.whirled.net.ElementChangedEvent;

    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    import vampire.client.ClientContext;
    import vampire.client.SharedPlayerStateClient;
    import vampire.client.VampireController;
    import vampire.client.events.PlayersFeedingEvent;
    import vampire.data.Codes;
    import vampire.data.Logic;
    import vampire.feeding.PlayerFeedingData;


/**
 * Show the HUD for blood, bloodbond status, targeting info etc all over the avatar in the room,
 * scaled for the avatars position and updated from the room props.
 *
 */
public class VampireAvatarHUD extends AvatarHUD
{
    public function VampireAvatarHUD(ctrl :AVRGameControl, userId:int)
    {
        super(ctrl, userId);
        _roomKey = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + _userId;

        //Listen for changes in blood levels
        registerListener(ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);
//        registerListener(ClientContext.ctrl.room, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);
//
//        registerListener(ClientContext.model, LineageUpdatedEvent.LINEAGE_UPDATED, updateLineageInfo);

                //Set up common UI elements
        _hudSprite = new Sprite();
        _displaySprite.addChild(_hudSprite);

//        registerListener(_hudSprite, MouseEvent.CLICK, function(...ignored) :void {
//            trace(playerId + " clicked ");
//        });

        if (ClientContext.model.bloodbonded == userId) {
            addBloodBondIcon();
        }

    }

//    protected function updateLineageInfo(e :LineageUpdatedEvent) :void
//    {
//        var currentMinions :int = e.lineage.getAllMinionsAndSubminions(playerId).size();
//        var currentSire :int = e.lineage.getSireId(playerId);
//        if(currentMinions > _localMinionCount || currentSire != _localSire) {
//            _localMinionCount = currentMinions;
//            _localSire = currentSire;
//            updateInfoHud();
//        }
//    }

    protected function addBloodBondIcon () :void
    {
        if (_bloodBondIcon == null) {
            _bloodBondIcon = ClientContext.instantiateMovieClip("HUD", "bond_icon", false);
            _bloodBondIcon.scaleX = _bloodBondIcon.scaleY = 2;
            addGlowFilter(_bloodBondIcon);
            //Go to the help page when you click on the icon
            Command.bind(_bloodBondIcon, MouseEvent.CLICK, VampireController.SHOW_INTRO, "default");
        }
        if (ClientContext.ourPlayerId != playerId) {
            _displaySprite.addChild(_bloodBondIcon);
        }

    }

    protected function removeBloodbondIcon () :void
    {
        trace("avatar " + playerId + " removing bb icon");
        if (_bloodBondIcon != null) {
            if (_bloodBondIcon.parent != null) {
                _bloodBondIcon.parent.removeChild(_bloodBondIcon);
            }
        }
    }

    protected function setupUI () :void
    {

//        _blood = ClientContext.instantiateMovieClip("HUD", "target_blood_meter", false);
//        _blood.height = 10;
//        _hudSprite.addChild(_blood);
//        _bloodMouseDetector = new Sprite();
//        _hudSprite.addChild(_bloodMouseDetector);
//
//
//
        _target_UI = ClientContext.instantiateMovieClip("HUD", "target_UI", false);
        _target_UI.alpha = 0;
        _targetUIScene = new SimpleSceneObject(_target_UI);
        db.addObject(_targetUIScene);


//
        //Set up UI elements depending if we are the players avatar
        if(playerId == ClientContext.ourPlayerId) {
//            setupUIYourAvatar();
        }
        else {
            setupUITarget();
        }
    }

//    protected function glowBloodBarIfValidTarget() :void
//    {
//        var validTarget :Boolean = false;
//        if(isPlayer) {
//            if(SharedPlayerStateClient.getCurrentAction(playerId) == VConstants.GAME_MODE_BARED
//                && SharedPlayerStateClient.getBlood(playerId) > 1) {
//
//                validTarget = true;
//            }
//        }
//        else {
//
//            if(isChattedEnoughForTargeting && SharedPlayerStateClient.getBlood(playerId) > 1) {
//
//                validTarget = true;
//            }
//        }
//
//        if(validTarget || VConstants.LOCAL_DEBUG_MODE) {
//            _blood.filters = [ClientContext.glowFilter];
//        }
//        else {
//            _blood.filters = [];
//        }
//    }

//    protected function get isChattedEnoughForTargeting() :Boolean
//    {
//        var targets :Array = _ctrl.room.getEntityProperty(
//                AvatarGameBridge.ENTITY_PROPERTY_CHAT_TARGETS, ClientContext.ourEntityId) as Array;
//
//        if(targets != null && ArrayUtil.contains(targets, playerId)){
//
//            return true;
//        }
//
//        return false;
//    }



    protected function setupUITarget() :void
    {
        _hudSprite.addChild(_target_UI);

        //Listen for changes in the hierarchy
//        registerListener(ClientContext.model, LineageUpdatedEvent.LINEAGE_UPDATED, updateInfoHud);
        registerListener(ClientContext.model, PlayersFeedingEvent.PLAYERS_FEEDING,
            handleUnavailablePlayerListChanged);

        _feedButton = new SceneButton(_target_UI.button_feed);

        _feedButton.registerButtonListener(MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleSendFeedRequest(playerId);

            ClientContext.avatarOverlay.setDisplayMode(VampireAvatarHUDOverlay.DISPLAY_MODE_OFF);
//            showBloodBarOnly();
//            _isMouseOver = false;
//            _feedButton.alpha = 0;
//            _frenzyButton.alpha = 0;
        });


        var buttonFresh :SimpleButton = _target_UI["button_fresh"] as SimpleButton;
        var buttonJoin :SimpleButton = _target_UI["button_join"] as SimpleButton;
        var buttonLineage :SimpleButton = _target_UI["button_lineage"] as SimpleButton;

//        Command.bind(buttonFresh, MouseEvent.CLICK, VampireController.SHOW_INTRO, "lineage");
        registerListener(buttonFresh, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleShowIntro("lineage");
        });

        registerListener(buttonJoin, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleShowIntro("default", playerId);
        });

        registerListener(buttonLineage, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleShowIntro("default", playerId);
        })






        //HUD bits and bobs
//        _hierarchyIcon = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
//        _hierarchyIcon.mouseEnabled = true;
//        _hierarchyIcon.scaleX = _hierarchyIcon.scaleY = 0.8;


//        _preyStrainDroplet = ClientContext.instantiateMovieClip("HUD", "prey_strain", false);
//        _preyStrainDroplet.scaleX = _preyStrainDroplet.scaleY = 2;


//        _preyStrain = ClientContext.instantiateMovieClip("HUD", "type", false);


//        //Add a mouse move listener to the blood.  This triggers showing the feed buttons
//        var showMenuFunction :Function = function(...ignored) :void {
//            _isMouseOver = true;
//
//
//            if(VConstants.LOCAL_DEBUG_MODE) {
//                _hudSprite.addChildAt(_mouseOverSprite, 0);
//                showFeedAndFrenzyButton();
//                return;
//            }
//            var isPlayer :Boolean = ArrayUtil.contains(_ctrl.room.getPlayerIds(), playerId);
//
//            //Only show feed buttons if there is sufficient blood
//            if((!isPlayer && !isChattedEnoughForTargeting) || SharedPlayerStateClient.getBlood(playerId) <= 1) {
////                trace(" doing nothing because:");
////                trace("   isPlayer=" + isPlayer);
////                trace("   isChattedEnoughForTargeting=" + isChattedEnoughForTargeting);
////                trace("   SharedPlayerStateClient.getBlood(" + playerId + ") <= 1)=" + (SharedPlayerStateClient.getBlood(playerId) <= 1));
////                trace("   SharedPlayerStateClient.getBlood(" + playerId + ")=" + SharedPlayerStateClient.getBlood(playerId));
//                return;
//            }
//
//
//            var action :String = SharedPlayerStateClient.getCurrentAction(playerId);
//            //Show feed buttons if we are a player in bared mode, or a non-player
//            if(!isPlayer || (action != null && action == VConstants.GAME_MODE_BARED)) {
//
//                _hudSprite.addChildAt(_mouseOverSprite, 0);
//                //Make sure the frenzy button is only shown if there are more than 2 predators.
//                //This misses the case where there are two preds, and a non player, and the preds
//                //are feeding from each other.
//                if(getPotentialPredatorIds().size() > 1 && ClientContext.avatarNumberInRoom > 2) {
//                    showFeedAndFrenzyButton();
//                }
//                else {
//                    showFeedButtonOnly();
//                }
//            }
//            else {
////                trace(" more doing nothing because:");
////                trace("   action=" + action);
//            }
//
//        }

        //Make sure that if any part of the menu is moused over, show the action buttons
//        registerListener(_blood, MouseEvent.ROLL_OVER, showMenuFunction);
//        registerListener(_hierarchyIcon, MouseEvent.ROLL_OVER, showMenuFunction);
//        registerListener(_bloodBondIcon, MouseEvent.ROLL_OVER, showMenuFunction);
//        registerListener(_preyStrain, MouseEvent.ROLL_OVER, showMenuFunction);
//        registerListener(_bloodMouseDetector, MouseEvent.ROLL_OVER, showMenuFunction);
//        registerListener(_bloodMouseDetector, MouseEvent.MOUSE_MOVE, showMenuFunction);


//        _hudSprite.addChild(_hierarchyIcon);

//        if(Logic.getPlayerPreferredBloodStrain(ClientContext.ourPlayerId) == playerId) {
//            _hudSprite.addChild(_preyStrainDroplet);
//            _preyStrainDroplet.y -= 15;
//        }



//        addGlowFilter(_preyStrainDroplet);

        //Go to the help page when you click on the icon
//        Command.bind(_hierarchyIcon, MouseEvent.CLICK, VampireController.SHOW_INTRO, "default");
//        Command.bind(_preyStrainDroplet, MouseEvent.CLICK,
//            VampireController.SHOW_INTRO, "bloodtype");
        Command.bind(MovieClip(_target_UI["strain"]), MouseEvent.CLICK,
            VampireController.SHOW_INTRO, "bloodtype");

        addGlowFilter(MovieClip(_target_UI["strain"]));

//        Command.bind(_blood, MouseEvent.CLICK, VampireController.SHOW_INTRO, "feedinggame");


        //Add a glow if we are a valid target
//        _glowTimer = new SimpleTimer(1, glowBloodBarIfValidTarget, true);



        updateInfoHud();

    }

    /**
    * If we are in the list, sent from the server, of players currently feeding, or predators
    * in a lobby, make sure we are not available for feeding.
    */
    protected function handleUnavailablePlayerListChanged (e :PlayersFeedingEvent) :void
    {
        if (ArrayUtil.contains(e.playersFeeding, playerId)) {
//            trace(playerId + " handleUnavailablePlayerListChanged " + e.playersFeeding);
            setDisplayModeInvisible();
        }
    }

//    protected function setupUIYourAvatar() :void
//    {
//
//        //Detach the bare buttons only used on our own avatar
//        for each(var unusedButton :DisplayObject in [_target_UI.button_feed,
//            _target_UI.button_frenzy, _target_UI.frenzy_countdown, _target_UI.waiting_sign]) {
//
//            unusedButton.parent.removeChild(unusedButton);
//        }
//
//
//
//        _bareButton = new SceneButton(_target_UI.button_bare);
//        _unbareButton = new SceneButton(_target_UI.button_revert);
//        _bareButton.mouseEnabled = true;
//        _bareButton.y = FEED_BUTTON_Y;
//        _unbareButton.y = _bareButton.y;
//
//        _bareButton.alpha = 0;
//        _unbareButton.alpha = 0;
//
//
//        _bareButton.registerButtonListener(MouseEvent.CLICK, function (...ignored) :void {
//            _bareButton.alpha = 0;
//            if(_bareButton.button.parent != null) {
//                _bareButton.button.parent.removeChild(_bareButton.button);
//            }
//            _hudSprite.addChild(_unbareButton.displayObject);
//            _unbareButton.alpha = 1;
//            ClientContext.controller.handleSwitchMode(VConstants.GAME_MODE_BARED);
//        });
//
//        _unbareButton.registerButtonListener(MouseEvent.CLICK, function (...ignored) :void {
//            _unbareButton.alpha = 0;
//            if(_unbareButton.button.parent != null) {
//                _unbareButton.button.parent.removeChild(_unbareButton.button);
//            }
//            _hudSprite.addChild(_bareButton.displayObject);
//            _bareButton.alpha = 1;
//            _ctrl.player.setAvatarState(VConstants.GAME_MODE_NOTHING);
//            ClientContext.controller.handleSwitchMode(VConstants.GAME_MODE_NOTHING);
//        });
//
//        //Add a mouse move listener to the blood.  This triggers showing the feed buttons
//
//        var showMenuFunction :Function = function(...ignored) :void {
//            _isMouseOver = true;
//            _hudSprite.addChildAt(_mouseOverSprite, 0);
//
//            if(ClientContext.model.action == VConstants.GAME_MODE_BARED) {
//                showUnBareButton();
//            }
//            else {
//                showBareButton();
//            }
//
//        }
//
//        //Make sure that if any part of the menu is moused over, show the action buttons
//        registerListener(_blood, MouseEvent.ROLL_OVER, showMenuFunction);
//        registerListener(_bloodMouseDetector, MouseEvent.ROLL_OVER, showMenuFunction);
//        registerListener(_bloodMouseDetector, MouseEvent.MOUSE_MOVE, showMenuFunction);
//
//        updateBlood();
//
//    }

    protected function addGlowFilter(obj : InteractiveObject) :void
    {
        registerListener(obj, MouseEvent.ROLL_OVER, function(...ignored) :void {
            obj.filters = [ClientContext.glowFilter];
        });
        registerListener(obj, MouseEvent.ROLL_OUT, function(...ignored) :void {
            obj.filters = [];
        })
    }

    override protected function addedToDB():void
    {
        super.addedToDB();
        setupUI();
        setDisplayModeInvisible();

//        if(ClientContext.ourPlayerId == playerId) {
//            mode.addObject(_bareButton);
//            mode.addObject(_unbareButton);
//        }
//        else {
//            mode.addObject(_frenzyButton);
//            mode.addObject(_feedButton);
//
//            mode.addObject(_glowTimer);
//        }
    }

//    override protected function destroyed():void
//    {
//        var allButtons :Array = [_feedButton, _frenzyButton, _bareButton, _unbareButton];
//        for each(var b :SceneButton in allButtons) {
//            if(b != null && b.isLiveObject) {
//                b.destroySelf()
//            }
//        }
//
//        if(_glowTimer != null && _glowTimer.isLiveObject) {
//            _glowTimer.destroySelf()
//        }
//
//    }
//    protected function decrementTime() :void
//    {
//        _frenzyDelayRemaining -= 1;
//    }


//    protected function getPotentialPredatorIds() :HashSet
//    {
//
//        if(VConstants.LOCAL_DEBUG_MODE) {
//            var a :HashSet = new HashSet();
//            a.add(1);
//            a.add(2);
//            return a;
//        }
//
//        var preds :HashSet = new HashSet();
//
//        var playerIds :Array = _ctrl.room.getPlayerIds();
//        for each(var playerId :int in playerIds) {
//            if(SharedPlayerStateClient.isVampire(playerId)
//                && SharedPlayerStateClient.getCurrentAction(playerId) != VConstants.GAME_MODE_BARED) {
//                preds.add(playerId);
//            }
//        }
//
//        return preds;
//
//    }

//    protected function getValidPlayerIdTargets() :HashSet
//    {
//
//        if(VConstants.LOCAL_DEBUG_MODE) {
//            var a :HashSet = new HashSet();
//            a.add(1);
//            a.add(2);
//            return a;
//        }
//
//        var validIds :HashSet = new HashSet();
//
//        if(!ClientContext.model.isVampire()) {
//            return validIds;
//        }
//
//        var playerIds :Array = _ctrl.room.getPlayerIds();
//
//        var validCHatTargets :Array = ClientContext.model.validNonPlayerTargetsFromChatting;
//
//        //Add the nonplayers
//        validCHatTargets.forEach(function(playerId :int, ...ignored) :void {
//            if(!ArrayUtil.contains(playerIds, playerId)) {
//                if(isNaN(SharedPlayerStateClient.getBlood(playerId)) || SharedPlayerStateClient.getBlood(playerId) > 1) {
//                    validIds.add(playerId);
//                }
//            }
//        });
//
//        //Add players in 'bare' mode
//        for each(var playerId :int in playerIds) {
//
//            if(playerId == _ctrl.player.getPlayerId()) {
//                continue;
//            }
//
//            var action :String = SharedPlayerStateClient.getCurrentAction(playerId);
//            if(action != null && action == VConstants.GAME_MODE_BARED
//                && SharedPlayerStateClient.getBlood(playerId) > 1) {
//
//                validIds.add(playerId);
//            }
//        }
//
//        return validIds;
//    }




    protected function handleElementChanged (e :ElementChangedEvent) :void
    {
        var oldLevel :int;
        var newLevel :int;
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName(e.name);


        //If it's us, update the our HUD
        if(!isNaN(playerIdUpdated) && playerIdUpdated == playerId) {
            if(e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP) {

                if (e.newValue > e.oldValue) {
                    var levelUp :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                        ClientContext.instantiateMovieClip("HUD", "bloodup_feedback", true));
                    if (mode != null && levelUp != null) {
                        mode.addSceneObject(levelUp, _displaySprite);
                    }
                }

            }
            //Animate a bloodbond animation
            else if(e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {
                trace("avatar " + playerId + " bloodbond updated to " + e.newValue);
                if(e.newValue != 0) {
                    var bloodBondMovie :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                            ClientContext.instantiateMovieClip("HUD", "bloodbond_feedback", true));
                    mode.addSceneObject(bloodBondMovie, _displaySprite);
                }
            }
        }

        if(!isNaN(playerIdUpdated) && playerIdUpdated == ClientContext.ourPlayerId) {
            if(e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {
                removeBloodbondIcon();
                if (e.newValue == playerId) {
                    addBloodBondIcon();
                }
            }
        }

    }





//    protected function updateBlood(...ignored) :void
//    {
//        var maxBlood :Number = VConstants.MAX_BLOOD_NONPLAYERS;
//        if(isPlayer) {
//            maxBlood = SharedPlayerStateClient.getMaxBlood(playerId);
//        }
//
//        var currentBlood :Number = SharedPlayerStateClient.getBlood(playerId);
//        if(isNaN(currentBlood) || currentBlood == 0) {
//            currentBlood = maxBlood;
//        }
//
//        _blood.width = maxBlood/2;//BLOOD_BAR_MIN_WIDTH;
//        _blood.height = 15;
//
//        _bloodMouseDetector.graphics.clear();
//        _bloodMouseDetector.graphics.beginFill(0xffffff, 0);
//        _bloodMouseDetector.graphics.drawRect(_blood.x - _blood.width / 2, _blood.y - _blood.height / 2, _blood.width, _blood.height);
//        _bloodMouseDetector.graphics.endFill();
//
////        var scaleY :Number = maxBlood / VConstants.MAX_BLOOD_FOR_LEVEL(1);
//        _blood.gotoAndStop(int(currentBlood*100.0/maxBlood));
//
//    }
    protected function updateInfoHud (...ignored) :void
    {
        //If it's our avatar HUD, don't show any extra details.
        if(ClientContext.ourPlayerId == playerId) {
            return;
        }

//        updateBlood();

//        var isHierarch :Boolean = VConstants.LOCAL_DEBUG_MODE
//            || (ClientContext.model.lineage != null &&
//                ClientContext.model.lineage.isPlayerSireOrMinionOfPlayer(playerId,
//                ClientContext.ourPlayerId));


//        var isBloodBond :Boolean = VConstants.LOCAL_DEBUG_MODE ||
//            (SharedPlayerStateClient.getBloodBonded(ClientContext.ourPlayerId) == playerId);
//
////        _hierarchyIcon.visible = isHierarch;
//        _bloodBondIcon.visible = isBloodBond;
//
//
////        _hierarchyIcon.x = 16;
//        _bloodBondIcon.x = -16;

    }

    override public function get isPlayer () :Boolean
    {
        return ArrayUtil.contains(ClientContext.ctrl.room.getPlayerIds(), playerId);
    }




    override protected function update (dt :Number) :void
    {
        try {
            super.update(dt);

            if (hotspot != null
                    && hotspot.length > 1
                    && _ctrl != null
                    && _ctrl.isConnected()) {
                var heightLogical :Number = hotspot[1]/_ctrl.local.getRoomBounds()[1];

                var p1 :Point = _ctrl.local.locationToPaintable(_location[0], _location[1], _location[2]);
                var p2 :Point = _ctrl.local.locationToPaintable(_location[0], heightLogical, _location[2]);

                var absoluteHeight :Number = Math.abs(p2.y - p1.y);
                _target_UI.y = absoluteHeight / 2;

            }

        }
        catch (err :Error) {
            log.error(err.getStackTrace());
        }
    }


    protected function get frenzyCountdown () :MovieClip
    {
        return _target_UI.frenzy_countdown;
    }

    protected function get waitingSign () :MovieClip
    {
        return _target_UI.waiting_sign;
    }

    override protected function drawMouseSelectionGraphics () :void
    {
        super.drawMouseSelectionGraphics();
        //Draw an invisible box to detect mouse movement/clicks

        if(_hudSprite != null && _hotspot != null && hotspot.length >= 2// && !isNaN(_zScaleFactor)
            && !isNaN(hotspot[0]) && !isNaN(hotspot[1])) {

            _hudSprite.graphics.clear();
            _hudSprite.graphics.beginFill(0, 0.3);
            _hudSprite.graphics.drawCircle(0, 0, 20);
            _hudSprite.graphics.endFill();
        }

    }

    protected function animateShowSceneObject (sceneButton :SceneObject) :void
    {
        _hudSprite.addChild(sceneButton.displayObject);
//        sceneButton.mouseEnabled = true;
        sceneButton.addTask(AlphaTask.CreateEaseIn(1, ANIMATION_TIME));
    }

    protected function animateHideSceneObject (sceneButton :SceneObject) :void
    {
        if(sceneButton == null || sceneButton.displayObject == null ||
            sceneButton.displayObject.parent == null) {
            return;
        }

        var serialTask :SerialTask = new SerialTask();
        serialTask.addTask(AlphaTask.CreateEaseIn(0, ANIMATION_TIME));
        serialTask.addTask(new FunctionTask(function() :void {

            if(sceneButton.displayObject.parent == null) {
                return;
            }

            if(sceneButton.displayObject.parent.contains(sceneButton.displayObject)) {
                sceneButton.displayObject.parent.removeChild(sceneButton.displayObject);
            }
        }));
        sceneButton.addTask(serialTask);
    }

    public function setDisplayModeSelectableForFeed () :void
    {
//        trace(playerId + " setDisplayModeSelectableForFeed, hotspot=" + hotspot);


        _displaySprite.addChild(_hudSprite);
        _hudSprite.addChild(_target_UI);
        animateShowSceneObject(_targetUIScene);

//        _hudSprite.addChild(_mouseOverSprite);

        //Adjust the graphics, now that we have a hotspot
    //        if (_target_UI != null && hotspot != null) {
    //            _target_UI.y = hotspot[1] / 2;
    //        }

//        _hierarchyIcon.y = hotspot[1] / 2;

//        _preyStrainDroplet.y = hotspot[1] / 2;

        //Show relevant strain info
        var bloodType :MovieClip = _target_UI["strain"] as MovieClip;
        bloodType.gotoAndStop(Logic.getPlayerBloodStrain(playerId));
        var pdf :PlayerFeedingData = ClientContext.model.playerFeedingData;
        if (pdf.canCollectStrainFromPlayer(Logic.getPlayerBloodStrain(playerId), playerId)){
            bloodType.visible = true;
            bloodType.mouseEnabled = true;
        }
        else {
            bloodType.visible = false;
            bloodType.mouseEnabled = false;
        }
        _isShowingFeedButton = true;


        //Show the appropriate button
        //First detach them all
        var buttonFresh :SimpleButton = _target_UI["button_fresh"] as SimpleButton;
        var buttonJoin :SimpleButton = _target_UI["button_join"] as SimpleButton;
        var buttonLineage :SimpleButton = _target_UI["button_lineage"] as SimpleButton;

        for each (var d :DisplayObject in [buttonFresh, buttonJoin, buttonLineage]) {
            if (d != null && d.parent != null) {
                d.parent.removeChild(d);
            }
        }

        var isPlayerPartOfLineage :Boolean =
            ClientContext.model.lineage.isMemberOfLineage(ClientContext.ourPlayerId);
        var isAvatarPartOfLineage :Boolean =
            ClientContext.model.lineage.isMemberOfLineage(playerId);


        if (isPlayerPartOfLineage) {
            var avatarHasNoSire :Boolean = !ClientContext.model.lineage.isSireExisting(playerId);
            if (avatarHasNoSire) {
                _target_UI.addChild(buttonFresh);
            }
            else {
                _target_UI.addChild(buttonLineage);
            }
        }
        else {
            if (isAvatarPartOfLineage) {
                _target_UI.addChild(buttonJoin);
            }
            else {
                _target_UI.addChild(buttonLineage);
            }
        }


    }

    public function setDisplayModeInvisible() :void
    {
        _hudSprite.graphics.clear();
        animateHideSceneObject(_targetUIScene);
        _isShowingFeedButton = false;
    }

    public function get isShowingFeedButton () :Boolean
    {
        return _isShowingFeedButton;
    }

    /**
    * Accessed by the tutorial for fixing a targeting movieclip.
    */
    public function get targetUI () :MovieClip
    {
        return _target_UI;
    }

    /**
    * Monitored by the tutorial.  The tutorial can anchor a targeting sprite
    * to the hud.
    */
    protected var _isShowingFeedButton :Boolean;

    protected var _hudMouseEvents :EventHandlerManager = new EventHandlerManager();

    protected var _hudSprite :Sprite;
    protected var _target_UI :MovieClip;
    protected var _bloodBondIcon :MovieClip;
    protected var _preyStrain :MovieClip;

    protected var _roomKey :String;

    protected var _feedButton :SceneButton;
    protected var _targetUIScene :SceneObject;


    protected static const ANIMATION_TIME :Number = 0.2;

}
}