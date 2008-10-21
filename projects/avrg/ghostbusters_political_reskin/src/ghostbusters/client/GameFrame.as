//
// $Id$

package ghostbusters.client {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.utils.ByteArray;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.geom.Rectangle;

import com.threerings.flash.DisplayUtil;
import com.threerings.util.Command;
import com.threerings.util.EmbeddedSwfLoader;

import ghostbusters.client.ClipHandler;
import ghostbusters.client.Content;
import ghostbusters.client.GameController;
import ghostbusters.client.Game;
import ghostbusters.data.Codes;

public class GameFrame extends DraggableSprite
{
    public function GameFrame (readyCallback :Function)
    {
        super(Game.control);

        _frame = new ClipHandler(new Content.FRAME(), function () :void {
            maybeReady(readyCallback);
        });
        _inventory = new ClipHandler(new Content.INVENTORY(), function () :void {
            maybeReady(readyCallback);
        });
    }

    public function frameContent (content :DisplayObject) :void
    {
        if (_content != null) {
            _frame.clip.removeChild(_content);
        }
        _content = content;
        if (_content != null) {
            _frame.clip.addChild(_content);
            _content.x = INSIDE.left;
            _content.y = INSIDE.top;
        }
    }

    public function getContentBounds () :Rectangle
    {
        return INSIDE;
    }

    protected function maybeReady (callback :Function) :void
    {
        if (_frame.clip == null || _inventory.clip == null) {
            // we'll be called again
            return;
        }

        super.init(new Rectangle(0, 0, _frame.width, _frame.height),
//                   SNAP_NONE, 300, SNAP_TOP, -1);
                   SNAP_LEFT, 0, SNAP_TOP, -1);//SKIN

        this.addChild(_frame);
        this.addChild(_inventory);

//        _inventory.x = (_frame.width - _inventory.width - INVENTORY.left) / 2;
        _inventory.x = 0;
        _inventory.y = (_frame.height + 20 - INVENTORY.top);
        
        //SKIN
        Command.bind(findSafely(CHOOSE_QUOTE), MouseEvent.CLICK,
                     GameController.CHOOSE_WEAPON, Codes.WPN_QUOTE);
        Command.bind(findSafely(CHOOSE_IRAQ), MouseEvent.CLICK,
                     GameController.CHOOSE_WEAPON, Codes.WPN_IRAQ);
        Command.bind(findSafely(CHOOSE_VOTE), MouseEvent.CLICK,
                     GameController.CHOOSE_WEAPON, Codes.WPN_VOTE);
        Command.bind(findSafely(CHOOSE_PRESS), MouseEvent.CLICK,
                     GameController.CHOOSE_WEAPON, Codes.WPN_PRESS);

        callback(this);
    }

    protected function findSafely (name :String) :DisplayObject
    {
        var o :DisplayObject = DisplayUtil.findInHierarchy(_inventory, name);
        if (o == null) {
            throw new Error("Cannot find object: " + name);
        }
        return o;
    }

    protected var _frame :ClipHandler;
    protected var _inventory :ClipHandler;

    protected var _content :DisplayObject;

    // relative the frame's coordinate system, where can we place the framed material?
//    protected static const INSIDE :Rectangle = new Rectangle(22, 102, 305, 230);
//    protected static const INVENTORY :Rectangle = new Rectangle(88, 88, 144, 28);
    
    protected static const INSIDE :Rectangle = new Rectangle(22, 102, 305, 230);
    protected static const INVENTORY :Rectangle = new Rectangle(0, 88, 144, 28);

     //SKIN
    protected static const CHOOSE_QUOTE :String = "choose_quote";
    protected static const CHOOSE_IRAQ :String = "choose_iraq";
    protected static const CHOOSE_VOTE :String = "choose_vote";
    protected static const CHOOSE_PRESS :String = "choose_press";
   
//    protected static const CHOOSE_LANTERN :String = "choose_lantern";
//    protected static const CHOOSE_BLASTER :String = "choose_blaster";
//    protected static const CHOOSE_OUIJA :String = "choose_ouija";
//    protected static const CHOOSE_POTIONS :String = "choose_heal";
}
}
