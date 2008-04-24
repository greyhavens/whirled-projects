package popcraft.battle {

public class UnitDataBuilder
{
    public static function create () :UnitDataBuilder { return new UnitDataBuilder(); }

    public function name (val :String) :UnitDataBuilder { _unitData.name = val; return this; }
    public function displayName (val :String) :UnitDataBuilder { _unitData.displayName = val; return this; }
    public function description (val :String) :UnitDataBuilder { _unitData.description = val; return this; }
    public function resourceCosts (val :Array) :UnitDataBuilder { _unitData.resourceCosts = val; return this; }
    public function baseMoveSpeed (val :Number) :UnitDataBuilder { _unitData.baseMoveSpeed = val; return this; }
    public function maxHealth (val :int) :UnitDataBuilder { _unitData.maxHealth = val; return this; }
    public function armor (val :UnitArmorData) :UnitDataBuilder { _unitData.armor = val; return this; }
    public function weapon (val :UnitWeaponData) :UnitDataBuilder { _unitData.weapon = val; return this; }
    public function collisionRadius (val :Number) :UnitDataBuilder { _unitData.collisionRadius = val; return this; }
    public function detectRadius (val :Number) :UnitDataBuilder { _unitData.detectRadius = val; return this; }
    public function loseInterestRadius (val :Number) :UnitDataBuilder { _unitData.loseInterestRadius = val; return this; }

    public function get unitData () :UnitData { return _unitData; }

    protected var _unitData :UnitData = new UnitData();
}

}
