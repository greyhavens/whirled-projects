package {

import com.whirled.AvatarControl;

public class PlayerSprite extends QuestSprite
{
    public function PlayerSprite (ctrl :AvatarControl)
    {
        super(ctrl);

        _manaBar.y = 8;
        _manaBar.x = center(32);
        addChild(_manaBar);
    }

    override protected function tick () :void
    {
        super.tick();

        _ctrl.setMemory("mana", Math.min(getMana() + 0.05, 1));
    }

    override protected function handleMemory () :void
    {
        super.handleMemory();

        _manaBar.percent = getMana();
    }

    public function getMana () :Number
    {
        return _ctrl.getMemory("mana") as Number;
    }

    protected var _manaBar :ProgressBar = new ProgressBar(0x0000ff, 0x000000);
}

}
