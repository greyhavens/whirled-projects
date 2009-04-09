package vampire.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.net.MessageReceivedEvent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.data.VConstants;
import vampire.net.messages.LoadBalancingMsg;

/**
 * Displays a UI with 6 rooms containing a small number of vampires.
 * Players can click on a room button to go to that room.
 *
 */
public class LoadBalancerClient extends SceneObject
{
    public function LoadBalancerClient(ctrl :AVRGameControl, parent :DisplayObjectContainer)
    {
        _ctrl = ctrl;
        registerListener(ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessageReceived);
        _parent = parent;
    }

    public function activate () :void
    {
        //Send a data request to the server we we init.
//        ClientUtil.fadeInSceneObject(this, _parent);
        if (!_isWaitingForRoomDataMessage) {
            _ctrl.agent.sendMessage(LoadBalancingMsg.NAME, new LoadBalancingMsg().toBytes());
            _isWaitingForRoomDataMessage = true;
        }
    }

    public function deactivate (...ignored) :void
    {
        ClientUtil.fadeOutAndDetachSceneObject(this);
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

            _isWaitingForRoomDataMessage = false;
            var msg :LoadBalancingMsg =
                ClientContext.msg.deserializeMessage(e.name, e.value) as LoadBalancingMsg;

            if (msg != null) {
                _roomIds = msg.roomIds;
                _roomNames = msg.roomNames;

                if (ArrayUtil.contains(_roomIds, _ctrl.room.getRoomId())) {
                    var index :int = ArrayUtil.indexOf(_roomIds, _ctrl.room.getRoomId());
                    _roomIds.splice(index, 1);
                    _roomNames.splice(index, 1);
                }

                showRoomsAsChatLinks(_roomIds, _roomNames);

//                updateUI();

            }
            else {
                log.error("handleMessageReceived, WTF, msg is null", "e", e);
            }
        }
    }

    protected function showRoomsAsChatLinks (roomIds :Array, roomNames :Array) :void
    {
        _ctrl.local.feedback("Click a room link to hunt other players:");
        for (var ii :int = 0; ii < roomIds.length; ++ii) {
            if (VConstants.MODE_DEV) {
                _ctrl.local.feedback(roomNames + ": http://localhost:8080/#world-s" + roomIds[ii]);
            }
            else {
                _ctrl.local.feedback(roomNames + ": http://www.whirled.com/#world-s" + roomIds[ii]);
            }
        }
    }

    protected function updateUI () :void
    {
        ClientUtil.detach(_panel);
        _panel = ClientContext.instantiateMovieClip("HUD", "popup_relocate", true);
        _panel.mouseChildren = true;
//        _panel.mouseEnabled = true;
        _displaySprite.addChild(_panel);

        ClientContext.placeTopMiddle(displayObject);
//        y += displayObject.height;

        registerListener(_panel["relocate_close"], MouseEvent.CLICK, deactivate);

//        ClientUtil.fadeInSceneObject(this);

        //Change the text if there is no-one in the room.
        if (_ctrl.room.getPlayerIds().length <= 1) {
            TextField(_panel["relocation_text"]).text = "Your prey has escaped.  "
                 + "Choose another hunting ground...";
        }

        for (var ii :int = 0; ii < 4; ++ii) {
            var roomId :int = _roomIds[ii];

            var ground :MovieClip = _panel["ground_0" + (ii + 1)] as MovieClip;

            if (ground != null) {
                addGlowFilter(ground);
                if (ii <= _roomNames.length - 1) {
                    TextField(ground["room_name"]).text = _roomNames[ii];
                    Command.bind(ground, MouseEvent.CLICK, VampireController.MOVE, roomId);
                    registerListener(ground, MouseEvent.CLICK, deactivate);
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

    override protected function addedToDB () :void
    {
        super.addedToDB();
//        activate();
//        if (VConstants.LOCAL_DEBUG_MODE) {
//            _roomIds = [1,2,3,4];
//            _roomNames = ["1", "2 dsaj dflasdfj", "dfdfgdfg", "56456456456"];
//            updateUI();
//        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected function addGlowFilter(obj : InteractiveObject) :void
    {
        registerListener(obj, MouseEvent.ROLL_OVER, function(...ignored) :void {
            obj.filters = [ClientUtil.glowFilter];
        });
        registerListener(obj, MouseEvent.ROLL_OUT, function(...ignored) :void {
            obj.filters = [];
        })
    }

//    public function get loadBalancingMsg () :LoadBalancingMsg
//    {
//        return _loadBalancingMsg;
//    }


    protected var _ctrl :AVRGameControl;
    protected var _roomIds :Array = [];
    protected var _roomNames :Array = [];
    protected var _displaySprite :Sprite = new Sprite();
    protected var _panel :MovieClip;
    protected var _parent :DisplayObjectContainer;

    protected var _isWaitingForRoomDataMessage :Boolean = false;

//    protected var _loadBalancingMsg :LoadBalancingMsg;
//    public static const MESSAGE_ROOMIDS_AND_POPULATIONS :String = "roomIdsAndPlayers";
    public static const MESSAGE_ACTIVATE :String = "activateLoadBalancer";
    public static const NAME :String = "LoadBalancerClient";
    protected static const log :Log = Log.getLog(LoadBalancerClient);
}
}