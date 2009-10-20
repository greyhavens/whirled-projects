package vampire.combat.client
{
import com.threerings.flashbang.objects.SceneObjectParent;

import vampire.combat.data.Action;

public class ActionChooser extends SceneObjectParent
{
    public function ActionChooser()
    {
        super();
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        setupUI();
    }

    public function setupUI() :void
    {
//        showPossibleActions();
    }

    public function showPossibleActions (unit :UnitRecord) :void
    {
        var startX :int = 50;
        var startY :int = 50;
        for each (var actionCode :int in Action.ALL_ACTIONS) {
            var ao :ActionObject = new ActionObject(actionCode, ActionObject.MENU);
            addSceneObject(ao);
//            var ao :ActionObject = addActionChoice(actionCode);
            ao.x = startX;
            ao.y = startY;
            startY += ao.height / 2 + 5;
        }
    }
    //Only called by showPossibleActions
//    protected function addActionChoice (actionCode :int) :ActionObject
//    {
//        var ao :ActionObject = new ActionObject(actionCode);
//        addSceneObject(ao);
//        registerListener(ao.displayObject, MouseEvent.CLICK, function (...ignored) :void {
//            addAction(actionCode);
//        });
//        return ao;
//    }

}
}
