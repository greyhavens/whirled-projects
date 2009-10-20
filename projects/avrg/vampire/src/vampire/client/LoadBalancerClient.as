package vampire.client
{
import com.threerings.flash.DisplayUtil;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.threerings.flashbang.objects.SceneObject;
import com.threerings.flashbang.objects.SceneObjectParent;
import com.threerings.flashbang.objects.SimpleSceneObject;
import com.threerings.flashbang.tasks.FunctionTask;
import com.threerings.flashbang.tasks.LocationTask;
import com.threerings.flashbang.tasks.ScaleTask;
import com.threerings.flashbang.tasks.SerialTask;
import com.threerings.flashbang.tasks.TimedTask;
import com.whirled.net.MessageReceivedEvent;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

import vampire.data.VConstants;
import vampire.net.messages.LoadBalancingMsg;

/**
 * Displays a UI with 6 rooms containing a small number of vampires.
 * Players can click on a room button to go to that room.
 *
 */
public class LoadBalancerClient extends SceneObjectParent
{
    public function LoadBalancerClient(ctrl :AVRGameControl, hud :HUD)
    {
        _ctrl = ctrl;
        registerListener(ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessageReceived);

        var expanded :MovieClip = hud.findSafely("hunting_grounds_expanded") as MovieClip;
        var collapsed :MovieClip = hud.findSafely("hunting_grounds_collapsed") as MovieClip;
        collapsed.parent.addChildAt(_displaySprite, collapsed.parent.getChildIndex(collapsed));
        collapsed.mouseEnabled = true;


        _huntingGroundsExpanded = new SimpleSceneObject(expanded);
        _huntingGroundsCollapsed = new SimpleSceneObject(collapsed);

        addGameObject(_huntingGroundsExpanded);
        addGameObject(_huntingGroundsCollapsed);
        ClientUtil.detach(expanded);

        _initialContractedLoc = new Point(_huntingGroundsCollapsed.x, _huntingGroundsCollapsed.y);


        var blackscreen :Shape = new Shape();
        blackscreen.graphics.beginFill(0);
        var bounds :Rectangle = _huntingGroundsCollapsed.displayObject.getBounds(_huntingGroundsCollapsed.displayObject.parent);
        blackscreen.graphics.drawRect(0, 0, bounds.width, bounds.height - 12);
        blackscreen.graphics.endFill();
        blackscreen.x = bounds.left;
        blackscreen.y = bounds.top;
        _blackScreen = new SimpleSceneObject(blackscreen);
        addGameObject(_blackScreen);

        _displaySprite.addChild(_blackScreen.displayObject);
        _displaySprite.addChild(_huntingGroundsCollapsed.displayObject);

        registerListener(collapsed["button_expand"], MouseEvent.CLICK, expand);
        registerListener(expanded["button_expand"], MouseEvent.CLICK, collapse);

        //Send a message when we start, so there is no delay for the player
        _ctrl.agent.sendMessage(LoadBalancingMsg.NAME, new LoadBalancingMsg().toBytes());

        for (var ii :int = 0; ii < VConstants.ROOMS_SHOWN_IN_LOAD_BALANCER; ++ii) {
            var ground :MovieClip = expanded["ground_0" + (ii + 1)] as MovieClip;
            registerListener(ground, MouseEvent.CLICK, _roomMoveFunctions[ii]);
            TextField(ground["room_name"]).text = "";
        }
    }

    protected function expand (...ignored) :void
    {

        if (_timeSinceLoadMessageSent >= VConstants.ROOMS_SHOWN_IN_LOAD_BALANCER) {
            _ctrl.agent.sendMessage(LoadBalancingMsg.NAME, new LoadBalancingMsg().toBytes());
            _timeSinceLoadMessageSent = 0;
        }

        _huntingGroundsCollapsed.addTask(new SerialTask(LocationTask.CreateEaseIn(
        _huntingGroundsExpanded.x, _huntingGroundsExpanded.y, 0.5),
            new FunctionTask(function () :void {
                ClientUtil.fadeInSceneObject(_huntingGroundsExpanded, _displaySprite);
            })));

        var scaleY :Number = (_huntingGroundsExpanded.y - _huntingGroundsCollapsed.y) / (_blackScreen.height - 1);


        _blackScreen.addTask(ScaleTask.CreateEaseIn(1, scaleY, 0.5));

        ClientContext.tutorial.clickedHuntingGrounds();
    }

    protected function collapse (...ignored) :void
    {
        ClientUtil.fadeOutAndDetachSceneObject(_huntingGroundsExpanded);
        _huntingGroundsCollapsed.addTask(new SerialTask(new TimedTask(ClientUtil.ANIMATION_TIME),
            LocationTask.CreateEaseIn( _initialContractedLoc.x, _initialContractedLoc.y, 0.5)));

        _blackScreen.addTask(new SerialTask(new TimedTask(ClientUtil.ANIMATION_TIME),
            ScaleTask.CreateEaseIn(1, 1, 0.5)));
    }

    override protected function update (dt:Number) :void
    {
        _timeSinceLoadMessageSent += dt;
    }

    public function findSafely (name :String) :DisplayObject
    {
        var o :DisplayObject = DisplayUtil.findInHierarchy(_displaySprite, name);
        if (o == null) {
            throw new Error("Cannot find object: " + name);
        }
        return o;
    }

    override protected function destroyed () :void
    {
        super.destroyed();
        _ctrl = null;
    }

    //Cache the message.
    protected function handleMessageReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == LoadBalancingMsg.NAME) {
            var msg :LoadBalancingMsg =
                ClientContext.msg.deserializeMessage(e.name, e.value) as LoadBalancingMsg;

            log.debug("handleMessageReceived", "msg", msg);

            if (msg != null) {
                _roomIds = msg.roomIds;
                _roomNames = msg.roomNames;

                if (ArrayUtil.contains(_roomIds, _ctrl.room.getRoomId())) {
                    var index :int = ArrayUtil.indexOf(_roomIds, _ctrl.room.getRoomId());
                    _roomIds.splice(index, 1);
                    _roomNames.splice(index, 1);
                }

                updateUI();

            }
            else {
                log.error("handleMessageReceived, WTF, msg is null", "e", e);
            }
        }
    }

//    protected function showRoomsAsChatLinks (roomIds :Array, roomNames :Array) :void
//    {
//        _ctrl.local.feedback("Click a room link to hunt other players:");
//        for (var ii :int = 0; ii < roomIds.length; ++ii) {
//            if (VConstants.MODE_DEV) {
//                _ctrl.local.feedback(roomNames[ii] + ": http://localhost:8080/#world-s" + roomIds[ii]);
//            }
//            else {
//                _ctrl.local.feedback(roomNames[ii] + ": http://www.whirled.com/#world-s" + roomIds[ii]);
//            }
//        }
//    }

    protected function updateUI () :void
    {
        //Change the text if there is no-one in the room.
//        if (_ctrl.room.getPlayerIds().length <= 1) {
//            TextField(_panel["relocation_text"]).text = ""
//                 + "Choose another hunting ground...";
//        }

        for (var ii :int = 0; ii < VConstants.ROOMS_SHOWN_IN_LOAD_BALANCER; ++ii) {

//            if (_roomMoveFunctions[ii] != null) {
//                removeEventListener(MouseEvent.CLICK, _roomMoveFunctions[ii]);
//            }
            var roomId :int = _roomIds[ii];
            var ground :MovieClip = _huntingGroundsExpanded.displayObject["ground_0" + (ii + 1)] as MovieClip;

            if (ground != null) {
                addGlowFilter(ground);
                if (ii <= _roomNames.length - 1) {
                    TextField(ground["room_name"]).text = _roomNames[ii];
                }
                else {
                    TextField(ground["room_name"]).text = "";
                }
            }
            else {
                log.error("ground_0" + (ii + 1) + " null");
            }
        }
    }

//    override public function get displayObject () :DisplayObject
//    {
//        return _displaySprite;
//    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected function addGlowFilter(obj : InteractiveObject) :void
    {
        registerListener(obj, MouseEvent.ROLL_OVER, function(...ignored) :void {
            obj.filters = [ClientUtil.GLOW_FILTER];
        });
        registerListener(obj, MouseEvent.ROLL_OUT, function(...ignored) :void {
            obj.filters = [];
        })
    }

    protected function moveToRoom1 (...ignored) :void
    {
        moveToRoom(_roomIds[0]);
    }
    protected function moveToRoom2 (...ignored) :void
    {
        moveToRoom(_roomIds[1]);
    }
    protected function moveToRoom3 (...ignored) :void
    {
        moveToRoom(_roomIds[2]);
    }
    protected function moveToRoom4 (...ignored) :void
    {
        moveToRoom(_roomIds[3]);
    }
    protected function moveToRoom5 (...ignored) :void
    {
        moveToRoom(_roomIds[4]);
    }
    protected function moveToRoom (roomId :int) :void
    {
        collapse();
        ClientContext.tutorial.clickedRoom();
        if (roomId != 0) {
            ClientContext.controller.handleMove(roomId);
        }
    }

    protected var _ctrl :AVRGameControl;
    protected var _roomIds :Array = [];
    protected var _roomNames :Array = [];
    protected var _roomMoveFunctions :Array = [moveToRoom1,
                                               moveToRoom2,
                                               moveToRoom3,
                                               moveToRoom4,
                                               moveToRoom5];
    protected var _huntingGroundsExpanded :SceneObject;
    protected var _huntingGroundsCollapsed :SceneObject;
    protected var _blackScreen :SceneObject;
    protected var _initialContractedLoc :Point;



    protected var _timeSinceLoadMessageSent :Number = 0;

    public static const NAME :String = "LoadBalancerClient";
    protected static const log :Log = Log.getLog(LoadBalancerClient);
}
}
