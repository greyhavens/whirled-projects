package popcraft.battle {

import com.whirled.contrib.simplegame.util.NumRange;
import com.whirled.contrib.simplegame.util.Rand;

public class UnitWeaponBuilder
{
    public static function create () :UnitWeaponBuilder { return new UnitWeaponBuilder(); }

    public function isRanged (val :Boolean) :UnitWeaponBuilder { _weapon.isRanged = val; return this; }
    public function isAOE (val :Boolean) :UnitWeaponBuilder { _weapon.isAOE = val; return this; }
    public function damageType (val :uint) :UnitWeaponBuilder { _weapon.damageType = val; return this; }
    public function damageRange (lo :Number, hi :Number) :UnitWeaponBuilder { _weapon.damageRange = new NumRange(lo, hi, Rand.STREAM_GAME); return this; }
    public function targetClassMask (val :uint) :UnitWeaponBuilder { _weapon.targetClassMask = val; return this; }
    public function cooldown (val :Number) :UnitWeaponBuilder { _weapon.cooldown = val; return this; }
    public function maxAttackDistance (val :Number) :UnitWeaponBuilder { _weapon.maxAttackDistance = val; return this; }
    public function missileSpeed (val :Number) :UnitWeaponBuilder { _weapon.missileSpeed = val; return this; }
    public function aoeRadius (val :Number) :UnitWeaponBuilder { _weapon.aoeRadius = val; return this; }

    public function get weapon () :UnitWeapon { return _weapon; }

    protected var _weapon :UnitWeapon = new UnitWeapon();

}

}
