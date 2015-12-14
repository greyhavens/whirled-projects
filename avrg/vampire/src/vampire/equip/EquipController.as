package equip
{
import com.threerings.util.Controller;

import flash.events.EventDispatcher;

public class EquipController extends Controller
{
    public static const ITEM_MOUSE_DOWN :String = "ItemMouseDown";
    public static const ITEM_MOUSE_UP :String = "ItemMouseUp";

    public function EquipController(panel :EventDispatcher, mode :EquipAvatarMode)
    {
        super.setControlledPanel(panel);
        _mode = mode;
    }

    public function handleItemMouseDown (item :ItemObject) :void
    {
        _mode.mouseFollower.followMouse(item.displayObject, MouseFollower.UNTIL_MOUSE_UP, function () :void {
            handleItemMouseUp(item);
        });
    }

    public function handleItemMouseUp (item :ItemObject) :void
    {
        var equipBox :EquipBox = _mode.avatarDisplay.getBoxOverlapping(item);
        if (equipBox == null) {
            equipBox = _mode.itemDisplay.getBoxOverlapping(item);
        }
        if (equipBox != null) {
            equipBox.addItem(item);
        }
        else {
            equipBox = _mode.getBox(item);
            equipBox.moveItemToBox();
        }

    }

    protected var _mode :EquipAvatarMode;

}
}
