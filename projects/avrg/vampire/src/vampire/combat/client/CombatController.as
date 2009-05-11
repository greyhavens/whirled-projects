package vampire.combat.client
{
import aduros.net.RemoteProxy;

import com.threerings.util.ClassUtil;
import com.threerings.util.Controller;
import com.threerings.util.Log;
import com.whirled.contrib.DisplayUtil;

import flash.display.Sprite;
import flash.events.IEventDispatcher;

public class CombatController extends Controller
{
    public static const NEXT :String = "Next";
    public static const UNIT_CLICKED :String = "UnitClicked";
    public static const MENU_ACTION_CLICK :String = "MenuAction";
    public static const UNIT_ACTION_CLICK :String = "UnitAction";
    public static const MOUSE_OVER_UNIT :String = "MouseOverUnit";
    public static const MOUSE_OUT_UNIT :String = "RollOutUnit";


    public function CombatController(panel :IEventDispatcher, ctx :GameInstance,
        gameService :RemoteProxy)
    {
        _game = ctx;
        setControlledPanel(panel);
    }

    public function handleMouseOverUnit (unit :UnitRecord) :void
    {
//        DisplayUtil.detach(game.targetReticle);
//        log.debug("handleMouseOverUnit", "unit", unit.name, "playerControlled", unit.playerControlled, "target", (unit.target != null ? unit.target.name : null));
        if (!unit.playerControlled) {
                Sprite(unit.arenaIcon.displayObject).addChild(_game.targetReticle);
//            _game.panel.setMouseTarget(unit);
            game.panel.setUnitForRightInfo(unit);
        }
        else {
            if (unit.target != null) {
                Sprite(unit.target.arenaIcon.displayObject).addChild(_game.targetReticle);
//                trace("settin gtarget " + unit.target.name);
            }
        }


//        if (unit == null) {
//            DisplayUtil.removeAllChildren(_mouseOverTarget);
//        }
//        else {
//            if (unit != _game.selectedFriendlyUnit) {
//                trace("Adding display for unit " + unit.name);
//                _mouseOverTarget.addChild(unit.displayObject);
//                unit.x = 0;
//                unit.y = 0;
//
//            }
//        }

//        if (!unit.playerControlled) {
//
//        }
//        game.panel.
    }

    public function handleRollOutUnit (unit :UnitRecord) :void
    {
//        trace("Roll out");
        DisplayUtil.detach(_game.targetReticle);
//        _ctx.panel.setMouseTarget(null);
    }

//    REMOTE function doThingClient ( arg :int) :void
//    {
//        log.debug("doThingClient",  "arg", arg);
//    }

    public function handleUnitClicked (unit :UnitRecord) :void
    {
        if (unit == null) {
            return;
        }
//        log.debug("handleUnitClicked", "unit.controllingPlayer", unit.controllingPlayer, "_ctx.playerId", _game.playerId);
        if (unit.controllingPlayer != _game.playerId) {
//            game.panel.detachActionChooser();
//            game.selectedEnemyUnit = unit;
//
            //If it's an enemy unit, make it the target of the current selected friendly unit
            if (_game.selectedFriendlyUnit != null && game.modeStack.top() is ModePlayerChooseActions) {
                _game.selectedFriendlyUnit.setTarget(unit);
                Sprite(unit.arenaIcon.displayObject).addChild(_game.targetReticle);


//                if (ctx.selectedFriendlyUnit != null) {
//
//                }
            }

        }
        else {
            //Make selected friendly unit the selected
            if (game.modeStack.top() is ModePlayerChooseActions) {
//                game.panel.attachActionChooser();
                game.panel.actionChooser.showPossibleActions(unit);
            }
            game.selectedFriendlyUnit = unit;
            game.panel.unitStatsLayer.addChild(unit.displayObject);
        }
//        DisplayUtil.removeAllChildren(game.panel.unitStatsLayer);
//        if (unit.db == null) {
//            game.panel.addSceneObject(unit);
//        }
    }

    public function handleMenuAction (unit :UnitRecord, action :ActionObject) :void
    {
        if (game.selectedFriendlyUnit != null) {
            game.selectedFriendlyUnit.actions.addAction(action.action);
        }
    }

    public function handleUnitAction (unit :UnitRecord, action :ActionObject) :void
    {
        unit.actions.removeAction(action);
    }



    public function handleNext () :void
    {
        _game.modeStack.pop();
        _game.panel.modeLabel.text = ClassUtil.tinyClassName(_game.modeStack.top());
    }

    protected function get game () :GameInstance
    {
        return _game;
    }

    protected var _gameService :RemoteProxy;
    protected var _game :GameInstance;
    protected static var log :Log = Log.getLog(CombatController);

}
}