package vampire.avatar
{
    import com.threerings.flash.DisplayUtil;
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

    public function findSafely (name :String) :DisplayObject
    {
        var o :DisplayObject = DisplayUtil.findInHierarchy(_displaySprite, name);
        if (o == null) {
            throw new Error("Cannot find object: " + name);
        }
        return o;
    }

    protected function setupUITarget() :void
    {
        _hudSprite.addChild(_target_UI);

        //Listen for changes in the hierarchy
        registerListener(ClientContext.model, PlayersFeedingEvent.PLAYERS_FEEDING,
            handleUnavailablePlayerListChanged);

        _feedButton = new SceneButton(_target_UI.button_feed);

        _feedButton.registerButtonListener(MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleSendFeedRequest(playerId);

            ClientContext.avatarOverlay.setDisplayMode(VampireAvatarHUDOverlay.DISPLAY_MODE_OFF);
        });


        var buttonFresh :SimpleButton = _target_UI["button_fresh"] as SimpleButton;
        var buttonJoin :SimpleButton = _target_UI["button_join"] as SimpleButton;
        var buttonLineage :SimpleButton = _target_UI["button_lineage"] as SimpleButton;

        registerListener(buttonFresh, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleShowIntro("lineage");
        });

        registerListener(buttonJoin, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleShowIntro("default", playerId);
        });

        registerListener(buttonLineage, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleShowIntro("default", playerId);
        })

        Command.bind(MovieClip(_target_UI["strain"]), MouseEvent.CLICK,
            VampireController.SHOW_INTRO, "bloodtype");

        addGlowFilter(MovieClip(_target_UI["strain"]));
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

    }




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
                    && _ctrl.isConnected()
                    && _ctrl.local.getRoomBounds() != null
                    && _ctrl.local.getRoomBounds().length > 1) {

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

    protected function drawMouseSelectionGraphics () :void
    {
//        super.drawMouseSelectionGraphics();
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
        bloodType.gotoAndStop(Logic.getPlayerBloodStrain(playerId) + 1);
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

//        trace("setDisplayModeSelectableForFeed");
//
//        trace("isPlayerPartOfLineage="+isPlayerPartOfLineage);
//        trace("isAvatarPartOfLineage="+isAvatarPartOfLineage);
//        trace("ClientContext.model.isPlayer(playerId)="+ClientContext.model.isPlayer(playerId));

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
            if (isAvatarPartOfLineage && ClientContext.model.isPlayer(playerId)) {
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