package popcraft.battle
{

public class UnitSpell
{
    public var type :uint;
    public var name :String;
    public var expireTime :Number = 0;

    public var speedScaleOffset :Number = 0;
    public var damageScaleOffset :Number = 0;

    public function combine (spell :UnitSpell) :void
    {
        speedScaleOffset += spell.speedScaleOffset;
        damageScaleOffset += spell.damageScaleOffset;
    }
}

}
