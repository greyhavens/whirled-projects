package popcraft.data {

import com.whirled.contrib.simplegame.util.NumRange;
import com.whirled.contrib.simplegame.util.Rand;

public class UnitWeaponBuilder
{
    public static function create () :UnitWeaponBuilder { return new UnitWeaponBuilder(); }

    public function isRanged (val :Boolean) :UnitWeaponBuilder { _weapon.isRanged = val; return this; }
    public function isAOE (val :Boolean) :UnitWeaponBuilder { _weapon.isAOE = val; return this; }
    public function damageType (val :uint) :UnitWeaponBuilder { _weapon.damageType = val; return this; }
    public function damageRange (lo :Number, hi :Number) :UnitWeaponBuilder { _weapon.damageRange = new NumRange(lo, hi, Rand.STREAM_GAME); return this; }
    public function cooldown (val :Number) :UnitWeaponBuilder { _weapon.cooldown = val; return this; }
    public function maxAttackDistance (val :Number) :UnitWeaponBuilder { _weapon.maxAttackDistance = val; return this; }

    public function missileSpeed (val :Number) :UnitWeaponBuilder { _weapon.missileSpeed = val; return this; }

    public function aoeRadius (val :Number) :UnitWeaponBuilder { _weapon.aoeRadius = val; return this; }
    public function aoeAnimationName (val :String) :UnitWeaponBuilder { _weapon.aoeAnimationName = val; return this; }
    public function aoeDamageFriendlies (val :Boolean) :UnitWeaponBuilder { _weapon.aoeDamageFriendlies = val; return this; }

    public function get weapon () :UnitWeaponData { return _weapon; }

    protected var _weapon :UnitWeaponData = new UnitWeaponData();

}

}
