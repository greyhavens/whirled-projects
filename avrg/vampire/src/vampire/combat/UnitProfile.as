package vampire.combat
{
import com.threerings.util.ClassUtil;

import flash.utils.ByteArray;

/**
 * Stores all the stats etc of a unit in combat.
 *
 * These attributes are *not* meant to be modified during combat.
 */
public class UnitProfile
{
    public function UnitProfile(id :int = 0,
                                type :int = 0,
                                strength :Number = 0,
                                speed :Number = 0,
                                stamina :Number = 0,
                                mind :Number = 0,
                                maxHealth :Number = 0,
                                defaultWeapons :int = 0)

    {
        _unitId = id;
        _unitType = type;
        _strength = strength;
        _speed = speed;
        _stamina = stamina;
        _mind = mind;
        _maxHealth = maxHealth;
        _weaponsDefault = defaultWeapons;// == null ? [] : defaultWeapons;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        _unitId = bytes.readInt();
        _unitType = bytes.readInt();
        _strength = bytes.readFloat();
        _speed = bytes.readFloat();
        _stamina = bytes.readFloat();
        _mind = bytes.readFloat();
        _maxHealth = bytes.readFloat();
        _weaponsDefault = bytes.readInt();//bytes.readObject() as Array;
    }

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        if(bytes == null) {
            bytes = new ByteArray();
        }
        bytes.writeInt(_unitId);
        bytes.writeInt(_unitType);
        bytes.writeFloat(_strength);
        bytes.writeFloat(_speed);
        bytes.writeFloat(_stamina);
        bytes.writeFloat(_mind);
        bytes.writeFloat(_maxHealth);
        bytes.writeInt(_weaponsDefault);
        return bytes;
    }

    public function get strength () :Number
    {
        return _strength;
    }
    public function set strength (value :Number) :void
    {
        _strength = value;
    }

    public function get speed () :Number
    {
        return _speed;
    }
    public function set speed (value :Number) :void
    {
        _speed = value;
    }

    public function get stamina () :Number
    {
        return _stamina;
    }
    public function set stamina (value :Number) :void
    {
        _stamina = value;
    }

    public function get mind () :Number
    {
        return _mind;
    }
    public function set mind (value :Number) :void
    {
        _mind = value;
    }

    public function get maxHealth () :Number
    {
        return _maxHealth;
    }
    public function set maxHealth (value :Number) :void
    {
        _maxHealth = value;
    }

    public function get type () :int
    {
        return _unitType;
    }
    public function set type (value :int) :void
    {
        _unitType = value;
    }

    public function get id () :int
    {
        return _unitId;
    }
    public function set id (value :int) :void
    {
        _unitId = value;
    }

    public function get weaponDefault () :int
    {
        return _weaponsDefault;//.slice();
    }
    public function set weaponDefault (value :int) :void
    {
        _weaponsDefault = value;//.slice();
    }



    public function toString () :String
    {
        return ClassUtil.tinyClassName(this)
            + "\n\tstrength=" + strength
            + "\n\tspeed=" + speed
            + "\n\tstamina=" + stamina
            + "\n\tmind=" + mind
            + "\n\thealth=" + maxHealth
            + "\n\tid=" + id
            + "\n\ttype=" + type
    }


    protected var _unitId :int;
    protected var _unitType :int;
    protected var _strength :Number;
    protected var _speed :Number;
    protected var _stamina :Number;
    protected var _maxHealth :Number;
    protected var _mind :Number;

    protected var _weaponsDefault :int;

//    protected var _specialAbilities :
//    protected var _items :Items;



}
}
