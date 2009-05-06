package vampire.combat.debug
{
import com.threerings.util.Util;

import vampire.combat.CombatUnit;
import vampire.combat.UnitProfile;
import vampire.combat.client.CombatGameCtx;

public class Factory
{
    public static function createUnitFromProfile (profile :UnitProfile, team :int, controller :int) :CombatUnit
    {
        var u :CombatUnit = new CombatUnit();
        u.profile = profile;
        u.team = team;
        u.energy = 1;
//        u.items = new Items();
        u.currentHealth = profile.maxHealth;
        return u;
    }


    public static function createBasicUnitProfile (id :int) :UnitProfile
    {
        var u :UnitProfile = new UnitProfile(id, "vampire", 0.5, 0.5, 0.5, 0.5, 1.0, [1,1]);

        return u;
    }

    public static function createBasicCtx () :CombatGameCtx
    {
        var c :CombatGameCtx = new CombatGameCtx();
        c.units.push(createUnitFromProfile(createBasicUnitProfile(1), 0, 1));
        c.units.push(createUnitFromProfile(createBasicUnitProfile(2), 0, 2));
        return c;
    }

    public static function createProfile (obj :Object) :UnitProfile
    {
        var profile :UnitProfile = new UnitProfile();
        Util.init(profile, obj);
        return profile;
    }

}
}