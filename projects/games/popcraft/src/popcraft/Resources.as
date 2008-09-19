package popcraft {

public class Resources
{
    // game data
    [Embed(source="../../levels/defaultGameData.xml", mimeType="application/octet-stream")]
    public static const DEFAULT_GAME_DATA :Class;

    [Embed(source="../../levels/gameVariants.xml", mimeType="application/octet-stream")]
    public static const GAME_VARIANTS_DATA :Class;

    // gfx - all
    [Embed(source="../../rsrc/all/UI_bits.swf", mimeType="application/octet-stream")]
    public static const SWF_UI :Class;

    [Embed(source="../../rsrc/all/backgrounds.swf", mimeType="application/octet-stream")]
    public static const SWF_BG :Class;

    [Embed(source="../../rsrc/all/streetwalker.swf", mimeType="application/octet-stream")]
    public static const SWF_GRUNT :Class;

    [Embed(source="../../rsrc/all/runt.swf", mimeType="application/octet-stream")]
    public static const SWF_SAPPER :Class;

    [Embed(source="../../rsrc/all/handyman.swf", mimeType="application/octet-stream")]
    public static const SWF_HEAVY :Class;

    [Embed(source="../../rsrc/all/flesh.swf", mimeType="application/octet-stream")]
    public static const SWF_COLOSSUS :Class;

    [Embed(source="../../rsrc/all/ladyfingers.swf", mimeType="application/octet-stream")]
    public static const SWF_COURIER :Class;

    [Embed(source="../../rsrc/all/handy_attack.swf", mimeType="application/octet-stream")]
    public static const SWF_MISSILE :Class;

    [Embed(source="../../rsrc/all/splatter.swf", mimeType="application/octet-stream")]
    public static const SWF_SPLATTER :Class;

    [Embed(source="../../rsrc/all/pieces.swf", mimeType="application/octet-stream")]
    public static const SWF_PIECES :Class;

    [Embed(source="../../rsrc/all/dashboard.swf", mimeType="application/octet-stream")]
    public static const SWF_DASHBOARD :Class;

    [Embed(source="../../rsrc/all/infusions.swf", mimeType="application/octet-stream")]
    public static const SWF_INFUSIONS :Class;

    [Embed(source="../../rsrc/all/workshop.swf", mimeType="application/octet-stream")]
    public static const SWF_WORKSHOP :Class;

    // gfx - singleplayer
    [Embed(source="../../rsrc/sp/splash.png", mimeType="application/octet-stream")]
    public static const IMG_LEVELSELECTOVERLAY :Class;

    [Embed(source="../../rsrc/sp/splash_UI.swf", mimeType="application/octet-stream")]
    public static const SWF_LEVELSELECTUI :Class;

    [Embed(source="../../rsrc/sp/manual.swf", mimeType="application/octet-stream")]
    public static const SWF_MANUAL :Class;

    [Embed(source="../../rsrc/sp/weardd.swf", mimeType="application/octet-stream")]
    public static const SWF_BOSS :Class;

    [Embed(source="../../rsrc/sp/prologue.swf", mimeType="application/octet-stream")]
    public static const SWF_PROLOGUE :Class;

    [Embed(source="../../rsrc/sp/epilogue.swf", mimeType="application/octet-stream")]
    public static const SWF_EPILOGUE :Class;

    [Embed(source="../../rsrc/sp/iris.png", mimeType="application/octet-stream")]
    public static const IMG_PORTRAITIRIS :Class;

    [Embed(source="../../rsrc/sp/ivy.png", mimeType="application/octet-stream")]
    public static const IMG_PORTRAITIVY :Class;

    [Embed(source="../../rsrc/sp/jack.png", mimeType="application/octet-stream")]
    public static const IMG_PORTRAITJACK :Class;

    [Embed(source="../../rsrc/sp/pigsley.png", mimeType="application/octet-stream")]
    public static const IMG_PORTRAITPIGSLEY :Class;

    [Embed(source="../../rsrc/sp/ralph.png", mimeType="application/octet-stream")]
    public static const IMG_PORTRAITRALPH :Class;

    [Embed(source="../../rsrc/sp/weardd.png", mimeType="application/octet-stream")]
    public static const IMG_PORTRAITWEARDD :Class;

    // gfx - multiplayer
    [Embed(source="../../rsrc/mp/multiplayer.swf", mimeType="application/octet-stream")]
    public static const SWF_MULTIPLAYER :Class;

    [Embed(source="../../rsrc/mp/zombie_BG.jpg", mimeType="application/octet-stream")]
    public static const IMG_ZOMBIEBG :Class;

    // music
    [Embed(source="../../rsrc/audio/music/popcraft_music_night.mp3")]
    public static const MUSIC_NIGHT :Class;

    [Embed(source="../../rsrc/audio/music/popcraft_music_day.mp3")]
    public static const MUSIC_DAY :Class;

    // sfx
    [Embed(source="../../rsrc/audio/sfx/introscreen.mp3")]
    public static const SOUND_INTROSCREEN :Class;

    [Embed(source="../../rsrc/audio/sfx/book_pageturn1.mp3")]
    public static const SOUND_PAGETURN :Class;

    [Embed(source="../../rsrc/audio/sfx/book_pageturn2.mp3")]
    public static const SOUND_BOOKOPENCLOSE :Class;

    [Embed(source="../../rsrc/audio/sfx/base_destroy.mp3")]
    public static const SOUND_BASEDESTROY :Class;

    [Embed(source="../../rsrc/audio/sfx/player_lose.mp3")]
    public static const SOUND_LOSEGAME :Class;

    [Embed(source="../../rsrc/audio/sfx/player_win.mp3")]
    public static const SOUND_WINGAME :Class;

    [Embed(source="../../rsrc/audio/sfx/spell_armor.mp3")]
    public static const SOUND_RIGORMORTIS :Class;

    [Embed(source="../../rsrc/audio/sfx/spell_bloodlust.mp3")]
    public static const SOUND_BLOODLUST :Class;

    [Embed(source="../../rsrc/audio/sfx/spell_puzzle_mix.mp3")]
    public static const SOUND_PUZZLERESET :Class;

    [Embed(source="../../rsrc/audio/sfx/spell_expire.mp3")]
    public static const SOUND_SPELLEXPIRE :Class;

    [Embed(source="../../rsrc/audio/sfx/MONSTER_HISSING_01_IN.mp3")]
    public static const SOUND_GRUNT :Class;

    [Embed(source="../../rsrc/audio/sfx/streetwalker_death2.mp3")]
    public static const SOUND_GRUNTDEATH :Class;

    [Embed(source="../../rsrc/audio/sfx/ANIMAL_DEEP_GRUNT_1_JD.mp3")]
    public static const SOUND_HEAVY :Class;

    [Embed(source="../../rsrc/audio/sfx/handyman_death.mp3")]
    public static const SOUND_HEAVYDEATH :Class;

    [Embed(source="../../rsrc/audio/sfx/SMALL_DOG_SINGLE_BARK_01_S4.mp3")]
    public static const SOUND_SAPPER :Class;

    [Embed(source="../../rsrc/audio/sfx/EXPLOSION_CTE01_56_1.mp3")]
    public static const SOUND_SAPPERDEATH :Class;

    [Embed(source="../../rsrc/audio/sfx/fleshbehemoth_create.mp3")]
    public static const SOUND_COLOSSUS :Class;

    [Embed(source="../../rsrc/audio/sfx/fleshbehemoth_death.mp3")]
    public static const SOUND_COLOSSUSDEATH :Class;

    [Embed(source="../../rsrc/audio/sfx/KATYDID_SHAKING_JB.mp3")]
    public static const SOUND_COURIER :Class;

    [Embed(source="../../rsrc/audio/sfx/ladyfinger_death.mp3")]
    public static const SOUND_COURIERDEATH :Class;

    [Embed(source="../../rsrc/audio/sfx/boss_professor_spawn.mp3")]
    public static const SOUND_BOSS :Class;

    [Embed(source="../../rsrc/audio/sfx/submit_flesh.mp3")]
    public static const SOUND_FLESH :Class;

    [Embed(source="../../rsrc/audio/sfx/submit_blood.mp3")]
    public static const SOUND_BLOOD :Class;

    [Embed(source="../../rsrc/audio/sfx/submit_energy.mp3")]
    public static const SOUND_ENERGY :Class;

    [Embed(source="../../rsrc/audio/sfx/submit_metal4.mp3")]
    public static const SOUND_SCRAP :Class;

    [Embed(source="../../rsrc/audio/sfx/FAST_POWER_FAILURE_01_TF.mp3")]
    public static const SOUND_LOSTRESOURCES :Class;

    [Embed(source="../../rsrc/audio/sfx/B-BIRD-ROOSTER.mp3")]
    public static const SOUND_ROOSTER :Class;

    [Embed(source="../../rsrc/audio/sfx/WOLF_HOWLS_02_WW.mp3")]
    public static const SOUND_WOLF :Class;

    [Embed(source="../../rsrc/audio/sfx/CHIMES_1020_37_06.mp3")]
    public static const SOUND_CHIMES :Class;

    [Embed(source="../../rsrc/audio/sfx/ARM_SWING_PUNCH_2_S4.mp3")]
    public static const SOUND_HIT1 :Class;

    [Embed(source="../../rsrc/audio/sfx/ARM_SWING_PUNCH_3_S4.mp3")]
    public static const SOUND_HIT2 :Class;

    [Embed(source="../../rsrc/audio/sfx/ARM_SWING_PUNCH_6_S4.mp3")]
    public static const SOUND_HIT3 :Class;

    [Embed(source="../../rsrc/audio/sfx/AOS01061_TableHit01.mp3")]
    public static const SOUND_BASEHIT1 :Class;

    [Embed(source="../../rsrc/audio/sfx/AOS01062_TbleHit02.mp3")]
    public static const SOUND_BASEHIT2 :Class;

    [Embed(source="../../rsrc/audio/sfx/AOS01064_TbleHit04.mp3")]
    public static const SOUND_BASEHIT3 :Class;

    [Embed(source="../../rsrc/audio/sfx/SCI_FI_MAGICAL_ZING_03_G1.mp3")]
    public static const SOUND_SPELLDROP :Class;
}

}
