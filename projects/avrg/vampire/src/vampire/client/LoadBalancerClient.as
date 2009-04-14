package vampire.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.LocationTask;
import com.whirled.net.MessageReceivedEvent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
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


        //Send a message when we start, so there is no delay for the player
        _ctrl.agent.sendMessage(LoadBalancingMsg.NAME, new LoadBalancingMsg().toBytes());

        _panel = ClientContext.instantiateMovieClip("HUD", "popup_relocate", true);
        _panel.mouseChildren = true;
        _displaySprite.addChild(_panel);

        var relocationText :TextField = _panel["relocation_text"] as TextField;
        registerListener(relocationText, MouseEvent.CLICK, function (...ignored) :void {
            var loc :Point = _ctrl.local.locationToPaintable(0.5, 0, 0);
            addTask(LocationTask.CreateEaseOut(loc.x, _panel.height / 2, 0.5));
        });
        relocationText.text = "Click to hunt elsewhere";



        registerListener(_panel["relocate_close"], MouseEvent.CLICK, deactivate);

        for (var ii :int = 0; ii < 4; ++ii) {
            var ground :MovieClip = _panel["ground_0" + (ii + 1)] as MovieClip;
            registerListener(ground, MouseEvent.CLICK, _roomMoveFunctions[ii]);
            registerListener(ground, MouseEvent.CLICK, deactivate);
            TextField(ground["room_name"]).text = "";
        }
    }

    override protected function update (dt:Number) :void
    {
        _timeSinceLoadMessageSent += dt;
    }

    public function activate () :void
    {
        //Send a data request to the server we we init.
        ClientUtil.fadeInSceneObject(this, _parent);
        if (_parent == null) {
            log.error("activate", "_parent", _parent);
        }

        var loc :Point = _ctrl.local.locationToPaintable(0.5, 0, 0);
        x = loc.x;
        y = -92;

        if (_timeSinceLoadMessageSent >= MIN_TIME_BETWEEN_MESSAGES) {
            _ctrl.agent.sendMessage(LoadBalancingMsg.NAME, new LoadBalancingMsg().toBytes());
            _timeSinceLoadMessageSent = 0;
        }
        var relocationText :TextField = _panel["relocation_text"] as TextField;
        if (ClientContext.getAvatarIds().length == 1) {
            relocationText.text = "Your prey has vanished. Click to hunt elsewhere.";
        }
        else {
            relocationText.text = "This room is crowded. Click to hunt elsewhere.";
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
        if (_ctrl.room.getPlayerIds().length <= 1) {
            TextField(_panel["relocation_text"]).text = ""
                 + "Choose another hunting ground...";
        }

        for (var ii :int = 0; ii < 4; ++ii) {

            removeEventListener(MouseEvent.CLICK, _roomMoveFunctions[ii]);

            var roomId :int = _roomIds[ii];
            var ground :MovieClip = _panel["ground_0" + (ii + 1)] as MovieClip;

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
    protected function moveToRoom (roomId :int) :void
    {
        if (roomId != 0) {
            deactivate();
            ClientContext.controller.handleMove(roomId);
        }
    }

    protected var _ctrl :AVRGameControl;
    protected var _roomIds :Array = [];
    protected var _roomNames :Array = [];
    protected var _roomMoveFunctions :Array = [moveToRoom1, moveToRoom2, moveToRoom3, moveToRoom4];
    protected var _displaySprite :Sprite = new Sprite();
    protected var _panel :MovieClip;
    protected var _parent :DisplayObjectContainer;

    protected var _timeSinceLoadMessageSent :Number = 0;
    protected static const MIN_TIME_BETWEEN_MESSAGES :Number = 5;

    public static const MESSAGE_ACTIVATE :String = "activateLoadBalancer";
    public static const NAME :String = "LoadBalancerClient";
    protected static const log :Log = Log.getLog(LoadBalancerClient);
}
}