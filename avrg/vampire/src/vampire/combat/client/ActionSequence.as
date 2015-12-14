package vampire.combat.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Util;
import com.whirled.contrib.DisplayUtil;
import com.threerings.flashbang.components.SceneComponent;
import com.threerings.flashbang.objects.SceneObjectParent;

import flash.display.DisplayObject;
import flash.display.Sprite;

import vampire.combat.data.Action;

/**
 * Displays the possible actions for a unit.
 * This is shown directly under the units
 */
public class ActionSequence extends SceneObjectParent
{
    public function ActionSequence(unit :UnitRecord)
    {
//        _playerControlled = playerControlled;
//        _data = data;
        _currentUnit = unit;
        _displaySprite.addChild(_draggebleSprite);
        setupUI();
    }

//    public function setUnit (u :CombatUnitInfo) :void
//    {
//        _currentUnit = u;
//    }

    public function setupUI() :void
    {
    }

    public function get currentAction () :ActionObject
    {
        return _actionSequence[0] as ActionObject;
    }

    protected function refresh () :void
    {
        //Show the previous action
        if (_previousAction != null) {
            _previousAction.x = 0;
            _previousAction.y = 0;
            Sprite(_previousAction.displayObject).mouseEnabled = false;
            Sprite(_previousAction.displayObject).mouseChildren = false;
        }

        if (_currentUnit.playerControlled) {
            //Show the sequence of actions
            var startX :int = ActionObject.WIDTH * 0.5;
            var startY :int = ActionObject.WIDTH * 1.5;
            function mapSceneToDisplay (l :SceneComponent) :DisplayObject {
                _displaySprite.addChild(l.displayObject);
                return l.displayObject;
            }
//            DisplayUtil.placeSequence(_displaySprite, _actionSequence.map(Util.adapt(mapSceneToDisplay)), startX, startY, false, 1);
            DisplayUtil.distribute(_actionSequence.map(Util.adapt(mapSceneToDisplay)), startX, startY, startX - (ActionObject.WIDTH / 2 * (_actionSequence.length + 1)), startY + (ActionObject.WIDTH / 2 * (_actionSequence.length + 1)));
        }
        else {
            for each (var action :ActionObject in _actionSequence) {
                DisplayUtil.detach(action.displayObject);
            }
        }
    }

    public function nextRound () :void
    {
        var currentAction :ActionObject = currentAction;

        if (currentAction != null) {
            currentAction.nextRound();
//            currentAction.nextRound();
            if (_currentUnit.energy < Action.energyCost(currentAction.action)) {
                destroyGameObject(currentAction);
                currentAction = new ActionObject(Action.REST, ActionObject.NULL);
                addSceneObject(currentAction);
                _actionSequence.unshift(currentAction);
            }
            //If we are warming up, show a REST symbol
            if (currentAction.warmUpRemaining > 0) {
//                currentAction.nextRound();
//                if (_previousAction != null) {
//                    destroyGameObject(_previousAction);
//
//                }
//                _previousAction = new ActionObject(Action.REST, ActionObject.NULL, _currentUnit);
//                addSceneObject(_previousAction);
//                refresh();
            }
            else {//Otherwise, put the current action to the previous
                shiftActions();
            }
        }
    }

    public function addAction (actionCode :int) :void
    {
        var actionUnits :int = _actionSequence.length;
        if (_actionSequence.length > 0) {
            actionUnits += ActionObject(_actionSequence[0]).warmUpRemaining;
        }

        if (actionUnits > 2) {
            return;
        }

//        trace("addAction " + Action.name(actionCode));
        var a :ActionObject = new ActionObject(actionCode, ActionObject.UNIT, _currentUnit);
        _actionSequence.push(a);
        addSceneObject(a);
        DisplayUtil.detach(a.displayObject);

//        _events.registerOneShotCallback(a.displayObject, MouseEvent.CLICK, function (...ignored) :void {
//            removeAction(a);
//            refresh();
//        });

        refresh();
    }

    public function removeAction (actionObj :ActionObject) :void
    {
//        log.debug("removeAction, start, ", "_actionSequence", _actionSequence);
        if (actionObj.warmUpRemaining < Action.warmUp(actionObj.action)) {
//            log.info("removeAction, warmup remaining", "actionObj", actionObj);
            return;
        }
//        log.debug("removeAction, Destroying");
        destroyGameObject(actionObj);
        ArrayUtil.removeAll(_actionSequence, actionObj);
        refresh();
//        log.debug("removeAction, end, ", "_actionSequence", _actionSequence);
    }

    public function shiftActions () :void
    {
        var current :ActionObject = _actionSequence.shift() as ActionObject;
        destroyGameObject(_previousAction);
        _previousAction = null;

        if (current != null) {
            destroyGameObject(current);
            _previousAction = new ActionObject(current.action, ActionObject.NULL, _currentUnit);
            addSceneObject(_previousAction);
        }
        refresh();
    }

//    override protected function get draggableObject () :InteractiveObject
//    {
//        return _draggebleSprite;
//    }

    public function previousCurrentAction () :ActionObject
    {
        return _previousAction;
    }


    protected var _draggebleSprite :Sprite = new Sprite();
    protected var _playerControlled :Boolean;
//    protected var _data :GameData;
    protected var _actionSequence :Array = [];
    protected var _previousAction :ActionObject = new ActionObject(Action.REST, ActionObject.NULL);
    protected var _currentUnit :UnitRecord;
    protected static var log :Log = Log.getLog(ActionSequence);
}
}
