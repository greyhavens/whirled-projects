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
import com.threerings.util.EmbeddedSwfLoader;

import ghostbusters.client.ClipHandler;
import ghostbusters.client.Content;
import ghostbusters.client.Game;

public class GameFrame extends Sprite
{
    public function GameFrame (readyCallback :Function)
    {
        new ClipHandler(new Content.FRAME()), function (clip :MovieClip) :void {
            _frame = clip;
            maybeReady(readyCallback);
        }
        new ClipHandler(new Content.INVENTORY()), function (clip :MovieClip) :void {
            _inventory = clip;
            maybeReady(readyCallback);
        }
    }

    public function frameContent (content :DisplayObject) :void
    {
        if (_content != null) {
            _frame.removeChild(_content);
        }
        _content = content;
        if (_content != null) {
            _frame.addChild(_content);
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
        if (_frame != null && _inventory != null) {
            this.addChild(_frame);
            this.addChild(_inventory);

            _inventory.x = (_frame.width - _inventory.width) / 2;
            _inventory.y = (_frame.height + 20);

            safelyAdd(CHOOSE_LANTERN, pickLoot);
            safelyAdd(CHOOSE_BLASTER, pickLoot);
            safelyAdd(CHOOSE_OUIJA, pickLoot);
            safelyAdd(CHOOSE_POTIONS, pickLoot);

            callback(this);
        }
    }

    protected function safelyAdd (name :String, callback :Function) :void
    {
        findSafely(name).addEventListener(MouseEvent.CLICK, callback);
    }

    protected function findSafely (name :String) :DisplayObject
    {
        var o :DisplayObject = DisplayUtil.findInHierarchy(_inventory, name);
        if (o == null) {
            throw new Error("Cannot find object: " + name);
        }
        return o;
    }

    protected function pickLoot (evt :MouseEvent) :void
    {
        var button :SimpleButton = evt.target as SimpleButton;
        if (button == null) {
            Game.log.debug("Clicky is not SimpleButton: " + evt.target);
            return;
        }

        switch(button.name) {
        case CHOOSE_LANTERN:
            Game.panel.hud.chooseWeapon(HUD.LOOT_LANTERN);
            break;

        case CHOOSE_BLASTER:
            Game.panel.hud.chooseWeapon(HUD.LOOT_BLASTER);
            break;

        case CHOOSE_OUIJA:
            Game.panel.hud.chooseWeapon(HUD.LOOT_OUIJA);
            break;

        case CHOOSE_POTIONS:
            Game.panel.hud.chooseWeapon(HUD.LOOT_POTIONS);
            break;

        default:
            Game.log.debug("Eeek, unknown target: " + button.name);
        }
    }

    protected var _frame :MovieClip;
    protected var _inventory :MovieClip;

    protected var _content :DisplayObject;

    // relative the frame's coordinate system, where can we place the framed material?
    protected static const INSIDE :Rectangle = new Rectangle(22, 102, 305, 230);

    protected static const CHOOSE_LANTERN :String = "choose_lantern";
    protected static const CHOOSE_BLASTER :String = "choose_blaster";
    protected static const CHOOSE_OUIJA :String = "choose_ouija";
    protected static const CHOOSE_POTIONS :String = "choose_heal";
}
}
