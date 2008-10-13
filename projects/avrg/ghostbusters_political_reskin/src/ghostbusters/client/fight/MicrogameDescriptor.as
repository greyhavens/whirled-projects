package ghostbusters.client.fight {

import ghostbusters.client.fight.common.MicrogameMode;

public class MicrogameDescriptor
{
    public function MicrogameDescriptor (weaponTypeName :String, baseDifficulty :int, gameClass :Class)
    {
        _weaponTypeName = weaponTypeName;
        _baseDifficulty = baseDifficulty;
        _gameClass = gameClass;
    }

    public function get weaponTypeName () :String
    {
        return _weaponTypeName;
    }

    public function get baseDifficulty () :int
    {
        return _baseDifficulty;
    }

    public function instantiateGame (weaponLevel :int, context :MicrogameContext) :MicrogameMode
    {
        if (weaponLevel < _baseDifficulty) {
            throw new Error("weaponLevel must be >= baseDifficulty");
        }

        return (new _gameClass(weaponLevel - _baseDifficulty, context) as MicrogameMode);
    }

    protected var _weaponTypeName :String;
    protected var _baseDifficulty :int;
    protected var _gameClass :Class;
}

}
