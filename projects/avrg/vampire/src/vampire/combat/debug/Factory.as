package vampire.combat.debug
{
import com.threerings.util.Util;
import com.whirled.contrib.DisplayUtil;

import flash.display.Bitmap;
import flash.display.Sprite;

import vampire.combat.UnitProfile;
import vampire.combat.client.ClientCtx;
import vampire.combat.client.GameInstance;
import vampire.combat.client.LocationHandler;
import vampire.combat.client.UnitRecord;
import vampire.combat.data.ProfileData;

public class Factory
{
    public static function createUnitFromProfile (playerId :int, name :String, profile :UnitProfile, team :int, controller :int, range :int) :UnitRecord
    {
        var u :UnitRecord = new UnitRecord(playerId == controller , name, profile, range);
        u.controllingPlayer = controller;
        u.profile = profile;
        u.team = team;
        u.range = range;
        u.energy = profile.stamina;
        u.maxEnergy = profile.stamina;
//        u.items = new Items();
        u.health = profile.maxHealth;
        return u;
    }

    public static function createArenaIcon (unit :UnitRecord) :Sprite
    {
        var s :Sprite = new Sprite();
        DisplayUtil.drawText(s, unit.name, -30, -50);
        var b :Bitmap;
        switch (unit.profile.type) {
            case ProfileData.BASIC_VAMPIRE1:
            b = ClientCtx.instantiateBitmap("vamp1");
            break;

            case ProfileData.BASIC_VAMPIRE2:
            b = ClientCtx.instantiateBitmap("vamp2");
            break;

            default:
            break;
        }

        if (b != null) {
            if (b.width > 60) {
                b.scaleX = b.scaleY = 60 / b.width;
                b.x = -b.width / 2;
                b.y = -b.height / 2;
            }
            s.addChild(b);
        }
        else {
            s.graphics.beginFill(0);
            s.graphics.drawCircle(0,0,20);
            s.graphics.endFill();
        }

        return s;
    }

    public static function createBasicUnitProfile (id :int, type :int) :UnitProfile
    {
        var u :UnitProfile = new UnitProfile(id, type);
        Util.init(u, ProfileData.get(type));
        return u;
    }

    public static function createBasicGameData (playerId :int) :GameInstance
    {
        var c :GameInstance = new GameInstance();
        c.friendlyUnits.push(createUnitFromProfile(playerId, "Some guy", createBasicUnitProfile(1, ProfileData.BASIC_VAMPIRE1), 0, 1, LocationHandler.CLOSE));
        c.friendlyUnits.push(createUnitFromProfile(playerId, "Badass", createBasicUnitProfile(2, ProfileData.BASIC_VAMPIRE2), 0, 1, LocationHandler.RANGED));

        c.enemyUnits.push(createUnitFromProfile(playerId, "Evil 1", createBasicUnitProfile(3, ProfileData.BASIC_VAMPIRE1), 1, 2, LocationHandler.CLOSE));
        c.enemyUnits.push(createUnitFromProfile(playerId, "Evil 2", createBasicUnitProfile(4, ProfileData.BASIC_VAMPIRE2), 1, 2, LocationHandler.CLOSE));
//        c.enemyUnits.push(createUnitFromProfile(playerId, "Evil 3", createBasicUnitProfile(5, ProfileData.BASIC_VAMPIRE2), 1, 2, LocationHandler.RANGED));
//        c.enemyUnits.push(createUnitFromProfile(playerId, "Evil 4", createBasicUnitProfile(6, ProfileData.BASIC_VAMPIRE2), 1, 2, LocationHandler.RANGED));
//        c.enemyUnits.push(createUnitFromProfile(playerId, "Evil 5", createBasicUnitProfile(7, ProfileData.BASIC_VAMPIRE2), 1, 2, LocationHandler.CLOSE));
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
