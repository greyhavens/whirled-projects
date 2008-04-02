package popcraft.battle {

public class UnitBuilder
{
    public static function create () :UnitBuilder { return new UnitBuilder(); }

    public function name (val :String) :UnitBuilder { _unitData.name = val; return this; }
    public function resourceCosts (val :Array) :UnitBuilder { _unitData.resourceCosts = val; return this; }
    public function baseMoveSpeed (val :Number) :UnitBuilder { _unitData.baseMoveSpeed = val; return this; }
    public function maxHealth (val :int) :UnitBuilder { _unitData.maxHealth = val; return this; }
    public function armor (val :UnitArmor) :UnitBuilder { _unitData.armor = val; return this; }
    public function weapon (val :UnitWeapon) :UnitBuilder { _unitData.weapons = [ val ]; return this; }
    public function weapons (val :Array) :UnitBuilder { _unitData.weapons = val; return this; }
    public function collisionRadius (val :Number) :UnitBuilder { _unitData.collisionRadius = val; return this; }
    public function detectRadius (val :Number) :UnitBuilder { _unitData.detectRadius = val; return this; }
    public function loseInterestRadius (val :Number) :UnitBuilder { _unitData.loseInterestRadius = val; return this; }

    public function get unitData () :UnitData { return _unitData; }

    protected var _unitData :UnitData;
}

}
