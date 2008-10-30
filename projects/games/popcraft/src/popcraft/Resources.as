package popcraft {

import com.threerings.util.FileUtil;
import com.whirled.contrib.LevelPacks;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import popcraft.ui.GenericLoadingMode;

public class Resources
{
    public static function loadLevelPackResourcesAndSwitchModes (resourceNames :Array,
        nextMode :AppMode) :void
    {
        loadLevelPackResources(
            resourceNames,
            function () :void { AppContext.mainLoop.changeMode(nextMode); }
        );
    }

    public static function loadLevelPackResources (resourceNames :Array, callback :Function) :void
    {
        if (queueLevelPackResources(resourceNames)) {
            MainLoop.instance.pushMode(new LevelPackLoadingMode(callback));
        } else {
            callback();
        }
    }

    public static function queueLevelPackResources (resourceNames :Array) :Boolean
    {
        var needsLoad :Boolean;
        var rm :ResourceManager = ResourceManager.instance;
        for each (var name :String in resourceNames) {
            if (rm.getResource(name) == null) {
                var mediaUrl :String = AppContext.allLevelPacks.getMediaURL(name);
                if (mediaUrl == null) {
                    throw new Error("unrecognized resource: '" + name + "'");
                }

                // determine the resource type from the file suffix
                var suffix :String = FileUtil.getDotSuffix(mediaUrl);
                var resourceType :String;
                switch (suffix) {
                case "swf":
                    resourceType = "swf";
                    break;
                case "png":
                case "jpg":
                case "gif":
                    resourceType = "image";
                    break;
                case "mp3":
                    resourceType = "sound";
                    break;
                default:
                    throw new Error("unrecognized file suffix '" + suffix + "'");
                    break;
                }

                rm.queueResourceLoad(resourceType, name, { url: mediaUrl });
                needsLoad = true;
            }
        }

        return needsLoad;
    }

    public static function loadBaseResources (loadCompleteCallback :Function = null,
        loadErrorCallback :Function = null) :void
    {
        var rm :ResourceManager = ResourceManager.instance;

        // data
        rm.queueResourceLoad(Constants.RESTYPE_GAMEDATA, Constants.RSRC_DEFAULTGAMEDATA, { embeddedClass: DEFAULT_GAME_DATA });

        // gfx
        rm.queueResourceLoad("swf", "manual", { embeddedClass: SWF_MANUAL });

        rm.queueResourceLoad("image", "endlessThumb1", { embeddedClass: IMG_ENDLESSTHUMB1 });
        rm.queueResourceLoad("image", "endlessThumb2", { embeddedClass: IMG_ENDLESSTHUMB2 });
        rm.queueResourceLoad("image", "endlessThumb3", { embeddedClass: IMG_ENDLESSTHUMB3 });
        rm.queueResourceLoad("image", "endlessThumb4", { embeddedClass: IMG_ENDLESSTHUMB4 });
        rm.queueResourceLoad("image", "endlessThumb5", { embeddedClass: IMG_ENDLESSTHUMB5 });
        rm.queueResourceLoad("image", "endlessThumb6", { embeddedClass: IMG_ENDLESSTHUMB6 });
        rm.queueResourceLoad("image", "endlessThumb7", { embeddedClass: IMG_ENDLESSTHUMB7 });
        rm.queueResourceLoad("image", "endlessThumb8", { embeddedClass: IMG_ENDLESSTHUMB8 });
        rm.queueResourceLoad("image", "endlessThumb9", { embeddedClass: IMG_ENDLESSTHUMB9 });

        rm.queueResourceLoad("image", "portrait_iris", { embeddedClass: IMG_PORTRAIT_IRIS });
        rm.queueResourceLoad("image", "portrait_ivy", { embeddedClass: IMG_PORTRAIT_IVY });
        rm.queueResourceLoad("image", "portrait_jack", { embeddedClass: IMG_PORTRAIT_JACK });
        rm.queueResourceLoad("image", "portrait_pigsley", { embeddedClass: IMG_PORTRAIT_PIGSLEY });
        rm.queueResourceLoad("image", "portrait_ralph", { embeddedClass: IMG_PORTRAIT_RALPH });
        rm.queueResourceLoad("image", "portrait_weardd", { embeddedClass: IMG_PORTRAIT_WEARDD });
        rm.queueResourceLoad("image", "portrait_dante", { embeddedClass: IMG_PORTRAIT_DANTE });
        rm.queueResourceLoad("image", "portrait_eloise", { embeddedClass: IMG_PORTRAIT_ELOISE });
        rm.queueResourceLoad("image", "portrait_horace", { embeddedClass: IMG_PORTRAIT_HORACE });
        rm.queueResourceLoad("image", "portrait_ursula", { embeddedClass: IMG_PORTRAIT_URSULA });

        rm.queueResourceLoad("swf", "splashUi", { embeddedClass: SWF_SPLASH_UI });
        rm.queueResourceLoad("swf", "uiBits",  { embeddedClass: SWF_UIBITS });
        rm.queueResourceLoad("swf", "bg",  { embeddedClass: SWF_BG });

        rm.queueResourceLoad("swf", "grunt", { embeddedClass: SWF_GRUNT });
        rm.queueResourceLoad("swf", "sapper", { embeddedClass: SWF_SAPPER });
        rm.queueResourceLoad("swf", "heavy", { embeddedClass: SWF_HEAVY });
        rm.queueResourceLoad("swf", "colossus", { embeddedClass: SWF_COLOSSUS });
        rm.queueResourceLoad("swf", "courier", { embeddedClass: SWF_COURIER });
        rm.queueResourceLoad("swf", "missile", { embeddedClass: SWF_MISSILE });
        rm.queueResourceLoad("swf", "splatter", { embeddedClass: SWF_SPLATTER });

        rm.queueResourceLoad("swf", "puzzlePieces", { embeddedClass: SWF_PIECES });
        rm.queueResourceLoad("swf", "dashboard", { embeddedClass: SWF_DASHBOARD });
        rm.queueResourceLoad("swf", "infusions", { embeddedClass: SWF_INFUSIONS });
        rm.queueResourceLoad("swf", "workshop", { embeddedClass: SWF_WORKSHOP });

        // sfx
        rm.queueResourceLoad("sound", "sfx_gatedrop", { embeddedClass: SOUND_GATEDROP, priority: 8 });
        rm.queueResourceLoad("sound", "sfx_gateopen", { embeddedClass: SOUND_GATEOPEN, priority: 8 });
        rm.queueResourceLoad("sound", "sfx_gotmultiplier", { embeddedClass: SOUND_GOTMULTIPLIER, priority: 4 });
        rm.queueResourceLoad("sound", "sfx_lostmultiplier", { embeddedClass: SOUND_LOSTMULTIPLIER, priority: 4 });
        rm.queueResourceLoad("sound", "sfx_tesla2", { embeddedClass: SOUND_TESLA2, volume: 0.3 });
        rm.queueResourceLoad("sound", "sfx_resurrect", { embeddedClass: SOUND_RESURRECT, priority: 9 });

        rm.queueResourceLoad("sound", "sfx_introscreen", { embeddedClass: SOUND_INTROSCREEN, volume: 0.3, priority: 10 });
        rm.queueResourceLoad("sound", "sfx_pageturn", { embeddedClass: SOUND_PAGETURN, priority: 9 });
        rm.queueResourceLoad("sound", "sfx_bookopenclose", { embeddedClass: SOUND_BOOKOPENCLOSE, priority: 9 });

        rm.queueResourceLoad("sound", "sfx_create_grunt", { embeddedClass: SOUND_GRUNT, priority: 2 });
        rm.queueResourceLoad("sound", "sfx_create_heavy", { embeddedClass: SOUND_HEAVY, priority: 2 });
        rm.queueResourceLoad("sound", "sfx_create_sapper", { embeddedClass: SOUND_SAPPER, priority: 2 });
        rm.queueResourceLoad("sound", "sfx_create_colossus", { embeddedClass: SOUND_COLOSSUS, priority: 2 });
        rm.queueResourceLoad("sound", "sfx_create_courier", { embeddedClass: SOUND_COURIER, priority: 2 });
        rm.queueResourceLoad("sound", "sfx_create_boss", { embeddedClass: SOUND_BOSS, priority: 2 });
        rm.queueResourceLoad("sound", "sfx_death_grunt", { embeddedClass: SOUND_GRUNTDEATH });
        rm.queueResourceLoad("sound", "sfx_death_heavy", { embeddedClass: SOUND_HEAVYDEATH });
        rm.queueResourceLoad("sound", "sfx_death_sapper", { embeddedClass: SOUND_SAPPERDEATH });
        rm.queueResourceLoad("sound", "sfx_death_courier", { embeddedClass: SOUND_COURIERDEATH, volume: 0.7 });
        rm.queueResourceLoad("sound", "sfx_death_colossus", { embeddedClass: SOUND_COLOSSUSDEATH });
        rm.queueResourceLoad("sound", "sfx_death_base", { embeddedClass: SOUND_BASEDESTROY, priority: 7 });

        rm.queueResourceLoad("sound", "sfx_rigormortis", { embeddedClass: SOUND_RIGORMORTIS, priority: 5 });
        rm.queueResourceLoad("sound", "sfx_bloodlust", { embeddedClass: SOUND_BLOODLUST, priority: 5 });
        rm.queueResourceLoad("sound", "sfx_puzzleshuffle", { embeddedClass: SOUND_PUZZLERESET, priority: 5 });
        rm.queueResourceLoad("sound", "sfx_spellexpire", { embeddedClass: SOUND_SPELLEXPIRE, priority: 4 });

        rm.queueResourceLoad("sound", "sfx_losegame", { embeddedClass: SOUND_LOSEGAME });
        rm.queueResourceLoad("sound", "sfx_wingame", { embeddedClass: SOUND_WINGAME });

        rm.queueResourceLoad("sound", "sfx_rsrc_white", { embeddedClass: SOUND_FLESH });
        rm.queueResourceLoad("sound", "sfx_rsrc_red", { embeddedClass: SOUND_BLOOD });
        rm.queueResourceLoad("sound", "sfx_rsrc_blue", { embeddedClass: SOUND_ENERGY });
        rm.queueResourceLoad("sound", "sfx_rsrc_yellow", { embeddedClass: SOUND_SCRAP });
        rm.queueResourceLoad("sound", "sfx_rsrc_lost", { embeddedClass: SOUND_LOSTRESOURCES });

        rm.queueResourceLoad("sound", "sfx_day", { embeddedClass: SOUND_ROOSTER, priority: 9 });
        rm.queueResourceLoad("sound", "sfx_night", { embeddedClass: SOUND_WOLF, priority: 9 });
        rm.queueResourceLoad("sound", "sfx_dawn", { embeddedClass: SOUND_CHIMES, priority: 9 });

        rm.queueResourceLoad("sound", "sfx_hit1", { embeddedClass: SOUND_HIT1});
        rm.queueResourceLoad("sound", "sfx_hit2", { embeddedClass: SOUND_HIT2 });
        rm.queueResourceLoad("sound", "sfx_hit3", { embeddedClass: SOUND_HIT3 });
        rm.queueResourceLoad("sound", "sfx_basehit1", { embeddedClass: SOUND_BASEHIT1, volume: 0.5 });
        rm.queueResourceLoad("sound", "sfx_basehit2", { embeddedClass: SOUND_BASEHIT2, volume: 0.5 });
        rm.queueResourceLoad("sound", "sfx_basehit3", { embeddedClass: SOUND_BASEHIT3, volume: 0.5 });

        rm.queueResourceLoad("sound", "sfx_spelldrop", { embeddedClass: SOUND_SPELLDROP, priority: 4 });

        // the gameVariants must be loaded after the default game data has finished
        // loading, so do that in a callback function here
        rm.loadQueuedResources(
            function () :void {
                rm.queueResourceLoad(
                    Constants.RESTYPE_GAMEVARIANTS,
                    Constants.RSRC_GAMEVARIANTS,
                    { embeddedClass: GAME_VARIANTS_DATA });

                rm.loadQueuedResources(loadCompleteCallback, loadErrorCallback);
            },
            loadErrorCallback);
    }

    public static function getMusic (musicName :String) :SoundResource
    {
        // music is loaded out of level packs
        var rm :ResourceManager = ResourceManager.instance;
        var sound :SoundResource = rm.getResource(musicName) as SoundResource;
        if (sound == null) {
            rm.queueResourceLoad(
                "sound",
                musicName,
                {   url: AppContext.allLevelPacks.getMediaURL(musicName),
                    completeImmediately: true,
                    type: "music",
                    volume: 0.7,
                    priority: 10
                }
            );
            rm.loadQueuedResources();
            sound = rm.getResource(musicName) as SoundResource;
        }

        return sound;
    }

    public static const MP_LEVEL_PACK_RESOURCES :Array = [
        "multiplayer_lobby",
        "zombieBg",
    ];

    public static const SP_LEVEL_PACK_RESOURCES :Array = [
        "boss",
    ];

    public static const PROLOGUE_RESOURCES :Array = [ "prologue" ];
    public static const EPILOGUE_RESOURCES :Array = [ "epilogue" ];

    // game data
    [Embed(source="../../levels/defaultGameData.xml", mimeType="application/octet-stream")]
    protected static const DEFAULT_GAME_DATA :Class;
    [Embed(source="../../levels/gameVariants.xml", mimeType="application/octet-stream")]
    protected static const GAME_VARIANTS_DATA :Class;

    // gfx - all
    [Embed(source="../../rsrc/all/manual.swf", mimeType="application/octet-stream")]
    protected static const SWF_MANUAL :Class;

    [Embed(source="../../rsrc/all/iris.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAIT_IRIS :Class;
    [Embed(source="../../rsrc/all/ivy.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAIT_IVY :Class;
    [Embed(source="../../rsrc/all/jack.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAIT_JACK :Class;
    [Embed(source="../../rsrc/all/pigsley.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAIT_PIGSLEY :Class;
    [Embed(source="../../rsrc/all/RALPH.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAIT_RALPH :Class;
    [Embed(source="../../rsrc/all/weardd.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAIT_WEARDD :Class;
    [Embed(source="../../rsrc/all/dante.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAIT_DANTE :Class;
    [Embed(source="../../rsrc/all/eloise.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAIT_ELOISE :Class;
    [Embed(source="../../rsrc/all/horace.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAIT_HORACE :Class;
    [Embed(source="../../rsrc/all/ursula.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAIT_URSULA :Class;

    [Embed(source="../../rsrc/all/endless_1_thumb.jpg", mimeType="application/octet-stream")]
    protected static const IMG_ENDLESSTHUMB1 :Class;
    [Embed(source="../../rsrc/all/endless_2_thumb.jpg", mimeType="application/octet-stream")]
    protected static const IMG_ENDLESSTHUMB2 :Class;
    [Embed(source="../../rsrc/all/endless_3_thumb.jpg", mimeType="application/octet-stream")]
    protected static const IMG_ENDLESSTHUMB3 :Class;
    [Embed(source="../../rsrc/all/endless_4_thumb.jpg", mimeType="application/octet-stream")]
    protected static const IMG_ENDLESSTHUMB4 :Class;
    [Embed(source="../../rsrc/all/endless_5_thumb.jpg", mimeType="application/octet-stream")]
    protected static const IMG_ENDLESSTHUMB5 :Class;
    [Embed(source="../../rsrc/all/endless_6_thumb.jpg", mimeType="application/octet-stream")]
    protected static const IMG_ENDLESSTHUMB6 :Class;
    [Embed(source="../../rsrc/all/endless_7_thumb.jpg", mimeType="application/octet-stream")]
    protected static const IMG_ENDLESSTHUMB7 :Class;
    [Embed(source="../../rsrc/all/endless_8_thumb.jpg", mimeType="application/octet-stream")]
    protected static const IMG_ENDLESSTHUMB8 :Class;
    [Embed(source="../../rsrc/all/endless_9_thumb.jpg", mimeType="application/octet-stream")]
    protected static const IMG_ENDLESSTHUMB9 :Class;

    [Embed(source="../../rsrc/all/splash_UI.swf", mimeType="application/octet-stream")]
    protected static const SWF_SPLASH_UI :Class;
    [Embed(source="../../rsrc/all/UI_bits.swf", mimeType="application/octet-stream")]
    protected static const SWF_UIBITS :Class;
    [Embed(source="../../rsrc/all/backgrounds.swf", mimeType="application/octet-stream")]
    protected static const SWF_BG :Class;
    [Embed(source="../../rsrc/all/streetwalker.swf", mimeType="application/octet-stream")]
    protected static const SWF_GRUNT :Class;
    [Embed(source="../../rsrc/all/runt.swf", mimeType="application/octet-stream")]
    protected static const SWF_SAPPER :Class;
    [Embed(source="../../rsrc/all/handyman.swf", mimeType="application/octet-stream")]
    protected static const SWF_HEAVY :Class;
    [Embed(source="../../rsrc/all/flesh.swf", mimeType="application/octet-stream")]
    protected static const SWF_COLOSSUS :Class;
    [Embed(source="../../rsrc/all/ladyfingers.swf", mimeType="application/octet-stream")]
    protected static const SWF_COURIER :Class;
    [Embed(source="../../rsrc/all/handy_attack.swf", mimeType="application/octet-stream")]
    protected static const SWF_MISSILE :Class;
    [Embed(source="../../rsrc/all/splatter.swf", mimeType="application/octet-stream")]
    protected static const SWF_SPLATTER :Class;
    [Embed(source="../../rsrc/all/pieces.swf", mimeType="application/octet-stream")]
    protected static const SWF_PIECES :Class;
    [Embed(source="../../rsrc/all/dashboard.swf", mimeType="application/octet-stream")]
    protected static const SWF_DASHBOARD :Class;
    [Embed(source="../../rsrc/all/infusions.swf", mimeType="application/octet-stream")]
    protected static const SWF_INFUSIONS :Class;
    [Embed(source="../../rsrc/all/workshop.swf", mimeType="application/octet-stream")]
    protected static const SWF_WORKSHOP :Class;

    // sfx
    [Embed(source="../../rsrc/audio/sfx/gatedrop_1.mp3")]
    protected static const SOUND_GATEDROP :Class;
    [Embed(source="../../rsrc/audio/sfx/gateopen_3_revision.mp3")]
    protected static const SOUND_GATEOPEN :Class;
    [Embed(source="../../rsrc/audio/sfx/multiplier_got3.mp3")]
    protected static const SOUND_GOTMULTIPLIER :Class;
    [Embed(source="../../rsrc/audio/sfx/multiplier_lost2b.mp3")]
    protected static const SOUND_LOSTMULTIPLIER :Class;
    [Embed(source="../../rsrc/audio/sfx/tesla2.mp3")]
    protected static const SOUND_TESLA2 :Class;
    [Embed(source="../../rsrc/audio/sfx/workshop_revive_revision2.mp3")]
    protected static const SOUND_RESURRECT :Class;

    [Embed(source="../../rsrc/audio/sfx/introscreen.mp3")]
    protected static const SOUND_INTROSCREEN :Class;
    [Embed(source="../../rsrc/audio/sfx/book_pageturn1.mp3")]
    protected static const SOUND_PAGETURN :Class;
    [Embed(source="../../rsrc/audio/sfx/book_pageturn2.mp3")]
    protected static const SOUND_BOOKOPENCLOSE :Class;
    [Embed(source="../../rsrc/audio/sfx/base_destroy.mp3")]
    protected static const SOUND_BASEDESTROY :Class;
    [Embed(source="../../rsrc/audio/sfx/player_lose.mp3")]
    protected static const SOUND_LOSEGAME :Class;
    [Embed(source="../../rsrc/audio/sfx/player_win.mp3")]
    protected static const SOUND_WINGAME :Class;
    [Embed(source="../../rsrc/audio/sfx/spell_armor.mp3")]
    protected static const SOUND_RIGORMORTIS :Class;
    [Embed(source="../../rsrc/audio/sfx/spell_bloodlust.mp3")]
    protected static const SOUND_BLOODLUST :Class;
    [Embed(source="../../rsrc/audio/sfx/spell_puzzle_mix.mp3")]
    protected static const SOUND_PUZZLERESET :Class;
    [Embed(source="../../rsrc/audio/sfx/spell_expire.mp3")]
    protected static const SOUND_SPELLEXPIRE :Class;
    [Embed(source="../../rsrc/audio/sfx/MONSTER_HISSING_01_IN.mp3")]
    protected static const SOUND_GRUNT :Class;
    [Embed(source="../../rsrc/audio/sfx/streetwalker_death2.mp3")]
    protected static const SOUND_GRUNTDEATH :Class;
    [Embed(source="../../rsrc/audio/sfx/ANIMAL_DEEP_GRUNT_1_JD.mp3")]
    protected static const SOUND_HEAVY :Class;
    [Embed(source="../../rsrc/audio/sfx/handyman_death.mp3")]
    protected static const SOUND_HEAVYDEATH :Class;
    [Embed(source="../../rsrc/audio/sfx/SMALL_DOG_SINGLE_BARK_01_S4.mp3")]
    protected static const SOUND_SAPPER :Class;
    [Embed(source="../../rsrc/audio/sfx/EXPLOSION_CTE01_56_1.mp3")]
    protected static const SOUND_SAPPERDEATH :Class;
    [Embed(source="../../rsrc/audio/sfx/fleshbehemoth_create.mp3")]
    protected static const SOUND_COLOSSUS :Class;
    [Embed(source="../../rsrc/audio/sfx/fleshbehemoth_death.mp3")]
    protected static const SOUND_COLOSSUSDEATH :Class;
    [Embed(source="../../rsrc/audio/sfx/KATYDID_SHAKING_JB.mp3")]
    protected static const SOUND_COURIER :Class;
    [Embed(source="../../rsrc/audio/sfx/ladyfinger_death.mp3")]
    protected static const SOUND_COURIERDEATH :Class;
    [Embed(source="../../rsrc/audio/sfx/boss_professor_spawn.mp3")]
    protected static const SOUND_BOSS :Class;
    [Embed(source="../../rsrc/audio/sfx/submit_flesh.mp3")]
    protected static const SOUND_FLESH :Class;
    [Embed(source="../../rsrc/audio/sfx/submit_blood.mp3")]
    protected static const SOUND_BLOOD :Class;
    [Embed(source="../../rsrc/audio/sfx/submit_energy.mp3")]
    protected static const SOUND_ENERGY :Class;
    [Embed(source="../../rsrc/audio/sfx/submit_metal4.mp3")]
    protected static const SOUND_SCRAP :Class;
    [Embed(source="../../rsrc/audio/sfx/FAST_POWER_FAILURE_01_TF.mp3")]
    protected static const SOUND_LOSTRESOURCES :Class;
    [Embed(source="../../rsrc/audio/sfx/B-BIRD-ROOSTER.mp3")]
    protected static const SOUND_ROOSTER :Class;
    [Embed(source="../../rsrc/audio/sfx/WOLF_HOWLS_02_WW.mp3")]
    protected static const SOUND_WOLF :Class;
    [Embed(source="../../rsrc/audio/sfx/CHIMES_1020_37_06.mp3")]
    protected static const SOUND_CHIMES :Class;
    [Embed(source="../../rsrc/audio/sfx/ARM_SWING_PUNCH_2_S4.mp3")]
    protected static const SOUND_HIT1 :Class;
    [Embed(source="../../rsrc/audio/sfx/ARM_SWING_PUNCH_3_S4.mp3")]
    protected static const SOUND_HIT2 :Class;
    [Embed(source="../../rsrc/audio/sfx/ARM_SWING_PUNCH_6_S4.mp3")]
    protected static const SOUND_HIT3 :Class;
    [Embed(source="../../rsrc/audio/sfx/AOS01061_TableHit01.mp3")]
    protected static const SOUND_BASEHIT1 :Class;
    [Embed(source="../../rsrc/audio/sfx/AOS01062_TbleHit02.mp3")]
    protected static const SOUND_BASEHIT2 :Class;
    [Embed(source="../../rsrc/audio/sfx/AOS01064_TbleHit04.mp3")]
    protected static const SOUND_BASEHIT3 :Class;
    [Embed(source="../../rsrc/audio/sfx/SCI_FI_MAGICAL_ZING_03_G1.mp3")]
    protected static const SOUND_SPELLDROP :Class;
}

}

import com.whirled.contrib.simplegame.AppMode;
import flash.display.Graphics;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;
import popcraft.ui.GenericLoadingMode;
import com.whirled.contrib.simplegame.resource.ResourceManager;
import popcraft.ui.GenericLoadErrorMode;

class LevelPackLoadingMode extends GenericLoadingMode
{
    public function LevelPackLoadingMode (callback :Function)
    {
        ResourceManager.instance.loadQueuedResources(
            function () :void {
                AppContext.mainLoop.popMode();
                callback();
            },
            function (err :String) :void {
                AppContext.mainLoop.unwindToMode(new GenericLoadErrorMode(err));
            }
        );
    }
}
