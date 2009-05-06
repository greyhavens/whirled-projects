package vampire.combat.client
{
import aduros.net.RemoteProxy;

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.contrib.DisplayUtil;
import com.whirled.contrib.GameMode;
import com.whirled.contrib.GameModeStack;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimpleGame;

import flash.display.Sprite;

import vampire.combat.CombatUnit;

public class CombatClient
{
    public function CombatClient(game :SimpleGame, mode :AppMode, clientContext :CombatGameCtx,
        gameService :RemoteProxy)
    {
        _ctx = clientContext;
        _ctx.game = game;
        _ctx.mode = mode;
        _ctx.rsrcs = _ctx.game.ctx.rsrcs;
//        _ctx.baseLayer = new Sprite();
//        mode.modeSprite.addChild(_ctx.baseLayer);

        //Panel setup.  All created sceneobjects go here so they will be cleaned up
        _ctx.panel = new CombatPanel();
        _ctx.mode.addSceneObject(_ctx.panel, mode.modeSprite);
        //Controller setup
        _ctx.controller = new CombatController(_ctx.panel.displayObject, _ctx, gameService);

        // load resources
        _ctx.rsrcs.queueResourceLoad("swf", "blood", { embeddedClass: SWF_BLOOD });
        _ctx.rsrcs.loadQueuedResources(
            function () :void {
                _resourcesLoaded = true;
                maybeFinishInit();
            },
            onResourceLoadErr);

    }

    public function shutdown () :void
    {
        _ctx.panel.destroySelf();
//        DisplayUtil.detach(_ctx.baseLayer);
    }

    protected function onResourceLoadErr (err :String) :void
    {
    }

    protected function maybeFinishInit () :void
    {




        //Create a mode stack for cycling through game modes
        _ctx.modeStack = new GameModeStack(modeChangedCallback);
//        _ctx.mode.modeSprite.addChild(_ctx.baseLayer);

        //Add the modes to a continuously running cycle
        _modeCycle = new ModeCycle(_ctx.modeStack);
        _ctx.modeStack.clear();
        var cycleStartMode :GameMode = _modeCycle.addMode(new ModeAIChooseActions(_ctx));
        _modeCycle.addMode(new ModePlayerChooseActions(_ctx));
        _modeCycle.addMode(new ModeShowCombatAnimations(_ctx));

        _ctx.modeStack.push(cycleStartMode);
        _ctx.modeStack.push(new ModeInitCombat(_ctx));

//        var startX :int = 100;
//        var startY :int = 100;
//        for each (var u :CombatUnit in _ctx.units) {
//            var so :UnitDisplay = new UnitDisplay(u);
//            _ctx.mode.addSceneObject(so, _ctx.baseLayer);
//            so.x = startX;
//            so.y = startY;
//            startX += 120;
//        }

    }

    protected function beginRound () :void
    {

    }

    protected function modeChangedCallback (oldMode :GameMode, newMode :GameMode) :void
    {
        trace("mode changed");
        _modeCycle.modeChangedCallback(oldMode, newMode);
    }

    protected var _modeCycle :ModeCycle;

    protected var _ctx :CombatGameCtx;
    protected var _inited :Boolean;
    protected var _resourcesLoaded :Boolean;
    protected var _unitDisplays :HashMap = new HashMap();
    protected static var log :Log = Log.getLog(CombatClient);

    [Embed(source="../../../../rsrc/feeding/blood.swf", mimeType="application/octet-stream")]
    protected static const SWF_BLOOD :Class;

}
}