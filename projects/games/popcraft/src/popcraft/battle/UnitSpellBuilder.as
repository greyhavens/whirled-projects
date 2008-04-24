package popcraft.battle {

public class UnitSpellBuilder
{
    public static function create () :UnitSpellBuilder { return new UnitSpellBuilder(); }

    public function type (val :uint) :UnitSpellBuilder { _spell.type = val; return this; }
    public function displayName (val :String) :UnitSpellBuilder { _spell.displayName = val; return this; }
    public function expireTime (val :Number) :UnitSpellBuilder { _spell.expireTime = val; return this; }

    public function speedScaleOffset (val :Number) :UnitSpellBuilder { _spell.speedScaleOffset = val; return this; }
    public function damageScaleOffset (val :Number) :UnitSpellBuilder { _spell.damageScaleOffset = val; return this; }

    public function get spell () :UnitSpellData { return _spell; }

    protected var _spell :UnitSpellData = new UnitSpellData();
}

}
