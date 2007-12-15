package popcraft.battle {

import popcraft.*;

import core.AppObject;

import flash.display.Bitmap;

/**
 * If ActionScript allowed the creation of abstract classes or private constructors, I would do that here.
 * Alas, it doesn't. But Unit is not intended to be instantiated directly.
 */
public class Unit extends AppObject
{
    public function Unit (unitType :uint, owningPlayerId :uint)
    {
        _unitType = unitType;
        _owningPlayerId = owningPlayerId;

        _unitData = (Constants.UNIT_DATA[unitType] as UnitData);
    }

    protected function createOwningPlayerGlowForBitmap (bitmap :Bitmap) :Bitmap
    {
        return Util.createGlowBitmap(bitmap, Constants.PLAYER_COLORS[_owningPlayerId] as uint);
    }

    public function applyAttack (attack :UnitAttack) :void
    {
        // calculate damage
        var damage :uint = uint(_unitData.armor.getAttackDamage(attack));
        damage = Math.min(damage, _health);
        _health -= damage;
    }

    public function get owningPlayerId () :uint
    {
        return _owningPlayerId;
    }

    public function get unitType () :uint
    {
        return _unitType;
    }

    public function get health () :uint
    {
        return _health;
    }

    protected var _owningPlayerId :uint;
    protected var _unitType :uint;
    protected var _unitData :UnitData;
    protected var _health :uint;
}

}
