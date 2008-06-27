package popcraft {

public class Resources
{
    // game data
    [Embed(source="../../levels/defaultGameData.xml", mimeType="application/octet-stream")]
    public static const DEFAULT_GAME_DATA :Class;

    [Embed(source="../../levels/gameVariants.xml", mimeType="application/octet-stream")]
    public static const GAME_VARIANTS_DATA :Class;

    // gfx
    [Embed(source="../../rsrc/UI_bits.swf", mimeType="application/octet-stream")]
    public static const SWF_UI :Class;

    [Embed(source="../../rsrc/splash_BG.swf", mimeType="application/octet-stream")]
    public static const SWF_SPLASH :Class;

    [Embed(source="../../rsrc/manual.swf", mimeType="application/octet-stream")]
    public static const SWF_MANUAL :Class;

    [Embed(source="../../rsrc/backgrounds.swf", mimeType="application/octet-stream")]
    public static const SWF_BG :Class;

    [Embed(source="../../rsrc/streetwalker.swf", mimeType="application/octet-stream")]
    public static const SWF_GRUNT :Class;

    [Embed(source="../../rsrc/runt.swf", mimeType="application/octet-stream")]
    public static const SWF_SAPPER :Class;

    [Embed(source="../../rsrc/handyman.swf", mimeType="application/octet-stream")]
    public static const SWF_HEAVY :Class;

    [Embed(source="../../rsrc/flesh.swf", mimeType="application/octet-stream")]
    public static const SWF_COLOSSUS :Class;

    [Embed(source="../../rsrc/ladyfingers.swf", mimeType="application/octet-stream")]
    public static const SWF_COURIER :Class;

    [Embed(source="../../rsrc/weardd.swf", mimeType="application/octet-stream")]
    public static const SWF_BOSS :Class;

    [Embed(source="../../rsrc/handy_attack.swf", mimeType="application/octet-stream")]
    public static const SWF_MISSILE :Class;

    [Embed(source="../../rsrc/splatter.swf", mimeType="application/octet-stream")]
    public static const SWF_BLOOD :Class;

    [Embed(source="../../rsrc/pieces.swf", mimeType="application/octet-stream")]
    public static const SWF_PIECES :Class;

    [Embed(source="../../rsrc/dashboard.swf", mimeType="application/octet-stream")]
    public static const SWF_DASHBOARD :Class;

    [Embed(source="../../rsrc/infusions.swf", mimeType="application/octet-stream")]
    public static const SWF_INFUSIONS :Class;

    [Embed(source="../../rsrc/workshop.swf", mimeType="application/octet-stream")]
    public static const SWF_WORKSHOP :Class;

    [Embed(source="../../rsrc/photo.swf", mimeType="application/octet-stream")]
    public static const SWF_CLASSPHOTO :Class;

    [Embed(source="../../rsrc/iris.png", mimeType="application/octet-stream")]
    public static const IMG_PORTRAITIRIS :Class;

    [Embed(source="../../rsrc/ivy.png", mimeType="application/octet-stream")]
    public static const IMG_PORTRAITIVY :Class;

    [Embed(source="../../rsrc/jack.png", mimeType="application/octet-stream")]
    public static const IMG_PORTRAITJACK :Class;

    [Embed(source="../../rsrc/pigsley.png", mimeType="application/octet-stream")]
    public static const IMG_PORTRAITPIGSLEY :Class;

    [Embed(source="../../rsrc/ralph.png", mimeType="application/octet-stream")]
    public static const IMG_PORTRAITRALPH :Class;

    // audio
    [Embed(source="../../rsrc/audio/popcraft_music_night.mp3")]
    public static const MUSIC_NIGHT :Class;

    [Embed(source="../../rsrc/audio/popcraft_music_day.mp3")]
    public static const MUSIC_DAY :Class;

    [Embed(source="../../rsrc/audio/introscreen.mp3")]
    public static const SOUND_INTROSCREEN :Class;

    [Embed(source="../../rsrc/audio/book_pageturn1.mp3")]
    public static const SOUND_PAGETURN :Class;

    [Embed(source="../../rsrc/audio/book_pageturn2.mp3")]
    public static const SOUND_BOOKOPENCLOSE :Class;

    [Embed(source="../../rsrc/audio/base_destroy.mp3")]
    public static const SOUND_BASEDESTROY :Class;

    [Embed(source="../../rsrc/audio/player_lose.mp3")]
    public static const SOUND_LOSEGAME :Class;

    [Embed(source="../../rsrc/audio/player_win.mp3")]
    public static const SOUND_WINGAME :Class;

    [Embed(source="../../rsrc/audio/spell_armor.mp3")]
    public static const SOUND_RIGORMORTIS :Class;

    [Embed(source="../../rsrc/audio/spell_bloodlust.mp3")]
    public static const SOUND_BLOODLUST :Class;

    [Embed(source="../../rsrc/audio/spell_puzzle_mix.mp3")]
    public static const SOUND_PUZZLERESET :Class;

    [Embed(source="../../rsrc/audio/spell_expire.mp3")]
    public static const SOUND_SPELLEXPIRE :Class;

    [Embed(source="../../rsrc/audio/MONSTER_HISSING_01_IN.mp3")]
    public static const SOUND_GRUNT :Class;

    [Embed(source="../../rsrc/audio/streetwalker_death2.mp3")]
    public static const SOUND_GRUNTDEATH :Class;

    [Embed(source="../../rsrc/audio/ANIMAL_DEEP_GRUNT_1_JD.mp3")]
    public static const SOUND_HEAVY :Class;

    [Embed(source="../../rsrc/audio/handyman_death.mp3")]
    public static const SOUND_HEAVYDEATH :Class;

    [Embed(source="../../rsrc/audio/SMALL_DOG_SINGLE_BARK_01_S4.mp3")]
    public static const SOUND_SAPPER :Class;

    [Embed(source="../../rsrc/audio/EXPLOSION_CTE01_56_1.mp3")]
    public static const SOUND_SAPPERDEATH :Class;

    [Embed(source="../../rsrc/audio/fleshbehemoth_create.mp3")]
    public static const SOUND_COLOSSUS :Class;

    [Embed(source="../../rsrc/audio/fleshbehemoth_death.mp3")]
    public static const SOUND_COLOSSUSDEATH :Class;

    [Embed(source="../../rsrc/audio/KATYDID_SHAKING_JB.mp3")]
    public static const SOUND_COURIER :Class;

    [Embed(source="../../rsrc/audio/ladyfinger_death.mp3")]
    public static const SOUND_COURIERDEATH :Class;

    [Embed(source="../../rsrc/audio/boss_professor_spawn.mp3")]
    public static const SOUND_BOSS :Class;

    [Embed(source="../../rsrc/audio/submit_flesh.mp3")]
    public static const SOUND_FLESH :Class;

    [Embed(source="../../rsrc/audio/submit_blood.mp3")]
    public static const SOUND_BLOOD :Class;

    [Embed(source="../../rsrc/audio/submit_energy.mp3")]
    public static const SOUND_ENERGY :Class;

    [Embed(source="../../rsrc/audio/submit_metal4.mp3")]
    public static const SOUND_SCRAP :Class;

    [Embed(source="../../rsrc/audio/FAST_POWER_FAILURE_01_TF.mp3")]
    public static const SOUND_LOSTRESOURCES :Class;

    [Embed(source="../../rsrc/audio/B-BIRD-ROOSTER.mp3")]
    public static const SOUND_ROOSTER :Class;

    [Embed(source="../../rsrc/audio/WOLF_HOWLS_02_WW.mp3")]
    public static const SOUND_WOLF :Class;

    [Embed(source="../../rsrc/audio/CHIMES_1020_37_06.mp3")]
    public static const SOUND_CHIMES :Class;

    [Embed(source="../../rsrc/audio/ARM_SWING_PUNCH_2_S4.mp3")]
    public static const SOUND_HIT1 :Class;

    [Embed(source="../../rsrc/audio/ARM_SWING_PUNCH_3_S4.mp3")]
    public static const SOUND_HIT2 :Class;

    [Embed(source="../../rsrc/audio/ARM_SWING_PUNCH_6_S4.mp3")]
    public static const SOUND_HIT3 :Class;

    [Embed(source="../../rsrc/audio/AOS01061_TableHit01.mp3")]
    public static const SOUND_BASEHIT1 :Class;

    [Embed(source="../../rsrc/audio/AOS01062_TbleHit02.mp3")]
    public static const SOUND_BASEHIT2 :Class;

    [Embed(source="../../rsrc/audio/AOS01064_TbleHit04.mp3")]
    public static const SOUND_BASEHIT3 :Class;

    [Embed(source="../../rsrc/audio/SCI_FI_MAGICAL_ZING_03_G1.mp3")]
    public static const SOUND_SPELLDROP :Class;
}

}
