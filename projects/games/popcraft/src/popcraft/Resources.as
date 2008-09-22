package popcraft {

import com.whirled.contrib.LevelPacks;
import com.whirled.contrib.simplegame.resource.*;

public class Resources
{
    public static function loadBaseResources (loadCompleteCallback :Function = null,
        loadErrorCallback :Function = null) :void
    {
        var rm :ResourceManager = ResourceManager.instance;

        // data
        rm.pendResourceLoad("gameData", "defaultGameData", { embeddedClass: DEFAULT_GAME_DATA });

        // gfx
        rm.pendResourceLoad("swf", "ui",  { embeddedClass: SWF_UI });
        rm.pendResourceLoad("swf", "multiplayer",  { embeddedClass: SWF_MULTIPLAYER });
        rm.pendResourceLoad("image", "zombieBg",  { embeddedClass: IMG_ZOMBIEBG });
        rm.pendResourceLoad("image", "levelSelectOverlay",  { embeddedClass: IMG_LEVELSELECTOVERLAY });
        rm.pendResourceLoad("swf", "levelSelectUi",  { embeddedClass: SWF_LEVELSELECTUI });
        rm.pendResourceLoad("swf", "manual",  { embeddedClass: SWF_MANUAL });
        rm.pendResourceLoad("swf", "bg",  { embeddedClass: SWF_BG });

        rm.pendResourceLoad("swf", "grunt", { embeddedClass: SWF_GRUNT });
        rm.pendResourceLoad("swf", "sapper", { embeddedClass: SWF_SAPPER });
        rm.pendResourceLoad("swf", "heavy", { embeddedClass: SWF_HEAVY });
        rm.pendResourceLoad("swf", "colossus", { embeddedClass: SWF_COLOSSUS });
        rm.pendResourceLoad("swf", "courier", { embeddedClass: SWF_COURIER });
        rm.pendResourceLoad("swf", "boss", { embeddedClass: SWF_BOSS });
        rm.pendResourceLoad("swf", "missile", { embeddedClass: SWF_MISSILE });
        rm.pendResourceLoad("swf", "splatter", { embeddedClass: SWF_SPLATTER });

        rm.pendResourceLoad("swf", "puzzlePieces", { embeddedClass: SWF_PIECES });
        rm.pendResourceLoad("swf", "dashboard", { embeddedClass: SWF_DASHBOARD });
        rm.pendResourceLoad("swf", "infusions", { embeddedClass: SWF_INFUSIONS });
        rm.pendResourceLoad("swf", "workshop", { embeddedClass: SWF_WORKSHOP });

        rm.pendResourceLoad("swf", "prologue", { embeddedClass: SWF_PROLOGUE });
        rm.pendResourceLoad("swf", "epilogue", { embeddedClass: SWF_EPILOGUE });

        rm.pendResourceLoad("image", "portrait_iris", { embeddedClass: IMG_PORTRAITIRIS });
        rm.pendResourceLoad("image", "portrait_ivy", { embeddedClass: IMG_PORTRAITIVY });
        rm.pendResourceLoad("image", "portrait_jack", { embeddedClass: IMG_PORTRAITJACK });
        rm.pendResourceLoad("image", "portrait_pigsley", { embeddedClass: IMG_PORTRAITPIGSLEY });
        rm.pendResourceLoad("image", "portrait_ralph", { embeddedClass: IMG_PORTRAITRALPH });
        rm.pendResourceLoad("image", "portrait_weardd", { embeddedClass: IMG_PORTRAITWEARDD });

        // sfx
        rm.pendResourceLoad("sound", "sfx_introscreen", { embeddedClass: SOUND_INTROSCREEN, volume: 0.3, priority: 10 });
        rm.pendResourceLoad("sound", "sfx_pageturn", { embeddedClass: SOUND_PAGETURN, priority: 9 });
        rm.pendResourceLoad("sound", "sfx_bookopenclose", { embeddedClass: SOUND_BOOKOPENCLOSE, priority: 9 });

        rm.pendResourceLoad("sound", "sfx_create_grunt", { embeddedClass: SOUND_GRUNT, priority: 2 });
        rm.pendResourceLoad("sound", "sfx_create_heavy", { embeddedClass: SOUND_HEAVY, priority: 2 });
        rm.pendResourceLoad("sound", "sfx_create_sapper", { embeddedClass: SOUND_SAPPER, priority: 2 });
        rm.pendResourceLoad("sound", "sfx_create_colossus", { embeddedClass: SOUND_COLOSSUS, priority: 2 });
        rm.pendResourceLoad("sound", "sfx_create_courier", { embeddedClass: SOUND_COURIER, priority: 2 });
        rm.pendResourceLoad("sound", "sfx_create_boss", { embeddedClass: SOUND_BOSS, priority: 2 });
        rm.pendResourceLoad("sound", "sfx_death_grunt", { embeddedClass: SOUND_GRUNTDEATH });
        rm.pendResourceLoad("sound", "sfx_death_heavy", { embeddedClass: SOUND_HEAVYDEATH });
        rm.pendResourceLoad("sound", "sfx_death_sapper", { embeddedClass: SOUND_SAPPERDEATH });
        rm.pendResourceLoad("sound", "sfx_death_courier", { embeddedClass: SOUND_COURIERDEATH, volume: 0.7 });
        rm.pendResourceLoad("sound", "sfx_death_colossus", { embeddedClass: SOUND_COLOSSUSDEATH });
        rm.pendResourceLoad("sound", "sfx_death_base", { embeddedClass: SOUND_BASEDESTROY, priority: 7 });

        rm.pendResourceLoad("sound", "sfx_rigormortis", { embeddedClass: SOUND_RIGORMORTIS, priority: 5 });
        rm.pendResourceLoad("sound", "sfx_bloodlust", { embeddedClass: SOUND_BLOODLUST, priority: 5 });
        rm.pendResourceLoad("sound", "sfx_puzzleshuffle", { embeddedClass: SOUND_PUZZLERESET, priority: 5 });
        rm.pendResourceLoad("sound", "sfx_spellexpire", { embeddedClass: SOUND_SPELLEXPIRE, priority: 4 });

        rm.pendResourceLoad("sound", "sfx_losegame", { embeddedClass: SOUND_LOSEGAME });
        rm.pendResourceLoad("sound", "sfx_wingame", { embeddedClass: SOUND_WINGAME });

        rm.pendResourceLoad("sound", "sfx_rsrc_white", { embeddedClass: SOUND_FLESH });
        rm.pendResourceLoad("sound", "sfx_rsrc_red", { embeddedClass: SOUND_BLOOD });
        rm.pendResourceLoad("sound", "sfx_rsrc_blue", { embeddedClass: SOUND_ENERGY });
        rm.pendResourceLoad("sound", "sfx_rsrc_yellow", { embeddedClass: SOUND_SCRAP });
        rm.pendResourceLoad("sound", "sfx_rsrc_lost", { embeddedClass: SOUND_LOSTRESOURCES });

        rm.pendResourceLoad("sound", "sfx_day", { embeddedClass: SOUND_ROOSTER, priority: 9 });
        rm.pendResourceLoad("sound", "sfx_night", { embeddedClass: SOUND_WOLF, priority: 9 });
        rm.pendResourceLoad("sound", "sfx_dawn", { embeddedClass: SOUND_CHIMES, priority: 9 });

        rm.pendResourceLoad("sound", "sfx_hit1", { embeddedClass: SOUND_HIT1});
        rm.pendResourceLoad("sound", "sfx_hit2", { embeddedClass: SOUND_HIT2 });
        rm.pendResourceLoad("sound", "sfx_hit3", { embeddedClass: SOUND_HIT3 });
        rm.pendResourceLoad("sound", "sfx_basehit1", { embeddedClass: SOUND_BASEHIT1, volume: 0.5 });
        rm.pendResourceLoad("sound", "sfx_basehit2", { embeddedClass: SOUND_BASEHIT2, volume: 0.5 });
        rm.pendResourceLoad("sound", "sfx_basehit3", { embeddedClass: SOUND_BASEHIT3, volume: 0.5 });

        rm.pendResourceLoad("sound", "sfx_spelldrop", { embeddedClass: SOUND_SPELLDROP, priority: 4 });

        // the gameVariants must be loaded after the default game data has finished
        // loading, so do that in a callback function here
        rm.load(
            function () :void {
                rm.pendResourceLoad("gameVariants", "gameVariants", { embeddedClass: GAME_VARIANTS_DATA });
                rm.load(loadCompleteCallback, loadErrorCallback);
            },
            loadErrorCallback);
    }

    public static function getMusic (musicName :String) :SoundResource
    {
        // music is loaded out of level packs
        var rm :ResourceManager = ResourceManager.instance;
        var sound :SoundResource = rm.getResource(musicName) as SoundResource;
        if (sound == null) {
            rm.pendResourceLoad(
                "sound",
                musicName,
                {   url: LevelPacks.getMediaURL(musicName),
                    completeImmediately: true,
                    type: "music",
                    volume: 0.7,
                    priority: 10
                }
            );
            rm.load();
            sound = rm.getResource(musicName) as SoundResource;
        }

        return sound;
    }

    // game data
    [Embed(source="../../levels/defaultGameData.xml", mimeType="application/octet-stream")]
    protected static const DEFAULT_GAME_DATA :Class;

    [Embed(source="../../levels/gameVariants.xml", mimeType="application/octet-stream")]
    protected static const GAME_VARIANTS_DATA :Class;

    // gfx - all
    [Embed(source="../../rsrc/all/UI_bits.swf", mimeType="application/octet-stream")]
    protected static const SWF_UI :Class;

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

    // gfx - singleplayer
    [Embed(source="../../rsrc/sp/splash.png", mimeType="application/octet-stream")]
    protected static const IMG_LEVELSELECTOVERLAY :Class;

    [Embed(source="../../rsrc/sp/splash_UI.swf", mimeType="application/octet-stream")]
    protected static const SWF_LEVELSELECTUI :Class;

    [Embed(source="../../rsrc/sp/manual.swf", mimeType="application/octet-stream")]
    protected static const SWF_MANUAL :Class;

    [Embed(source="../../rsrc/sp/weardd.swf", mimeType="application/octet-stream")]
    protected static const SWF_BOSS :Class;

    [Embed(source="../../rsrc/sp/prologue.swf", mimeType="application/octet-stream")]
    protected static const SWF_PROLOGUE :Class;

    [Embed(source="../../rsrc/sp/epilogue.swf", mimeType="application/octet-stream")]
    protected static const SWF_EPILOGUE :Class;

    [Embed(source="../../rsrc/sp/iris.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAITIRIS :Class;

    [Embed(source="../../rsrc/sp/ivy.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAITIVY :Class;

    [Embed(source="../../rsrc/sp/jack.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAITJACK :Class;

    [Embed(source="../../rsrc/sp/pigsley.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAITPIGSLEY :Class;

    [Embed(source="../../rsrc/sp/ralph.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAITRALPH :Class;

    [Embed(source="../../rsrc/sp/weardd.png", mimeType="application/octet-stream")]
    protected static const IMG_PORTRAITWEARDD :Class;

    // gfx - multiplayer
    [Embed(source="../../rsrc/mp/multiplayer.swf", mimeType="application/octet-stream")]
    protected static const SWF_MULTIPLAYER :Class;

    [Embed(source="../../rsrc/mp/zombie_BG.jpg", mimeType="application/octet-stream")]
    protected static const IMG_ZOMBIEBG :Class;

    // sfx
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
