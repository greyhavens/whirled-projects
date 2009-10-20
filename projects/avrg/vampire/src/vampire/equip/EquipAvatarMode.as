package equip
{
import com.threerings.flashbang.AppMode;

import flash.display.Sprite;

public class EquipAvatarMode extends AppMode
{
    public function EquipAvatarMode()
    {
        super();
        controller = new EquipController(modeSprite, this);
    }

    override protected function setup () :void
    {
        super.setup();

        modeSprite.addChild(itemLayer);
        EquipCtx.itemLayer = itemLayer;

        avatarDisplay = new AvatarEquipScene();
        modeSprite.addChild(avatarDisplay.displayObject);
        avatarDisplay.x = 180;
        avatarDisplay.y = 50;
        addObject(avatarDisplay);


        itemDisplay = new ItemsDisplay();
        modeSprite.addChild(itemDisplay.displayObject);
        itemDisplay.x = 20;
        itemDisplay.y = 300;
        addObject(itemDisplay);

        mouseFollower = new MouseFollower();
        addObject(mouseFollower);

        //Item layer goes on top
        modeSprite.setChildIndex(itemLayer, modeSprite.numChildren - 1);

    }

    public function getBox (item :ItemObject) :EquipBox
    {
        if (itemDisplay.isHoldingItem(item)) {
            return itemDisplay.getBox(item);
        }
        else if (avatarDisplay.isHoldingItem(item)) {
            return avatarDisplay.getBox(item);
        }
        return null;

    }

    public var itemLayer :Sprite = new Sprite();
    public var itemDisplay :ItemsDisplay;
    public var avatarDisplay :AvatarEquipScene;

    public var mouseFollower :MouseFollower;
    protected var controller :EquipController;
}
}
