package equip.debug
{
import com.threerings.util.Log;
import com.threerings.flashbang.Config;
import com.threerings.flashbang.FlashbangApp;

import equip.EquipAvatarMode;
import equip.EquipCtx;
import equip.PlayerEquipData;

import flash.display.Sprite;


[SWF(width="1000", height="600")]
public class DebugEquip extends Sprite
{
    public function DebugEquip()
    {
        Log.setLevel("", Log.DEBUG);
        var gameSprite :Sprite = new Sprite();
        addChild(gameSprite);
        var config :Config = new Config();
        config.hostSprite = gameSprite;
        EquipCtx.game = new FlashbangApp(config);
        EquipCtx.game.run();
        EquipCtx.rsrcs = EquipCtx.game.ctx.rsrcs;

        // load resources
        EquipCtx.rsrcs.queueResourceLoad("image", "sword", { embeddedClass: IMG_SWORD });
        EquipCtx.rsrcs.queueResourceLoad("image", "pants", { embeddedClass: IMG_PANTS });
        EquipCtx.rsrcs.queueResourceLoad("image", "body", { embeddedClass: IMG_BODY });
        EquipCtx.rsrcs.loadQueuedResources(function () :void {
            begin();
        }, onResourceLoadErr);
    }

    protected function onResourceLoadErr (err :String) :void
    {
    }

    protected function begin () :void
    {
        //Create the player data
        EquipCtx.playerEquipData = new PlayerEquipData();

        //Add the new mode.
        var equipMode :EquipAvatarMode = new EquipAvatarMode();
        EquipCtx.game.ctx.mainLoop.pushMode(equipMode);

    }

    [Embed(source="../../../rsrc/equip/body.jpg", mimeType="application/octet-stream")]
    protected static const IMG_BODY :Class;

    [Embed(source="../../../rsrc/equip/sword.jpg", mimeType="application/octet-stream")]
    protected static const IMG_SWORD :Class;

    [Embed(source="../../../rsrc/equip/pants.jpg", mimeType="application/octet-stream")]
    protected static const IMG_PANTS :Class;
}
}
