package bingo {

import flash.geom.Point;

public class Constants
{
    public static const VERSION :Number = 0.002;

    public static const ALLOW_CHEATS :Boolean = true;
    public static const FORCE_SINGLEPLAYER :Boolean = false;

    // cosmetic bits
    public static const CARD_LOC :Point = new Point(10, 10);
    public static const BALL_LOC :Point = new Point(400, 150);
    public static const BINGO_BUTTON_LOC :Point = new Point(400, 300);
    public static const QUIT_BUTTON_LOC :Point = new Point(400, 360);
    public static const WINNER_TEXT_LOC :Point = new Point(50, 400);
    public static const SCOREBOARD_LOC :Point = new Point(500, 10);

    // gameplay bits
    public static const CARD_WIDTH :int = 5;
    public static const CARD_HEIGHT :int = 5;
    public static const FREE_SPACE :Point = new Point(2, 2);

    public static const NEW_BALL_DELAY_S :Number = 1;
    public static const NEW_ROUND_DELAY_S :Number = 5;

    public static const USE_ITEM_NAMES_AS_TAGS :Boolean = false;
    public static const CARD_ITEMS_ARE_UNIQUE :Boolean = true;

    public static const MAX_MATCHES_PER_BALL :int = 3;

    public static const NUM_SCOREBOARD_NAMES :int = 5;

    public static const ITEMS :Array = [

        new BingoItem("Pearls", ["neck", "jewelry", "necklace", "beaded", "white", ], Resources.IMG_PEARLS),
        new BingoItem("choker", ["neck", "jewelry", "necklace", "gem", "pink", ], Resources.IMG_CHOKER),
        new BingoItem("diamond necklace", ["neck", "jewelry", "necklace", "gem", "blue?", ], Resources.IMG_DIAMONDNECKLACE),
        new BingoItem("brown shell necklace", ["neck", "jewelry", "necklace", "shell", "brown", ], Resources.IMG_SHELLNECKLACEBROWN),
        new BingoItem("blue shell necklace", ["neck", "jewelry", "necklace", "shell", "blue", ], Resources.IMG_SHELLNECKLACEBLUE),
        new BingoItem("gold locket", ["neck", "jewelry", "necklace", "locket", "gold", ], Resources.IMG_LOCKETGOLD),
        new BingoItem("silver locket", ["neck", "jewelry", "necklace", "locket", "silver", ], Resources.IMG_LOCKETSILVER),
        new BingoItem("yellow pendant", ["neck", "jewelry", "necklace", "pendant", "yellow", "gold", ], Resources.IMG_GOLDPENDANTYELLOW),
        new BingoItem("green pendant", ["neck", "jewelry", "necklace", "pendant", "green", "gold", ], Resources.IMG_GOLDPENDANTGREEN),
        new BingoItem("orange pendant", ["neck", "jewelry", "necklace", "pendant", "orange", "gold", ], Resources.IMG_GOLDPENDANTORANGE),
        new BingoItem("blue pendant", ["neck", "jewelry", "necklace", "pendant", "blue", "gold", ], Resources.IMG_GOLDPENDANTBLUE),
        new BingoItem("purple pendant", ["neck", "jewelry", "necklace", "pendant", "purple", "gold", ], Resources.IMG_GOLDPENDANTPURPLE),
        new BingoItem("pink pendant", ["neck", "jewelry", "necklace", "pendant", "pink", "gold", ], Resources.IMG_GOLDPENDANTPINK),
        new BingoItem("red pendant", ["neck", "jewelry", "necklace", "pendant", "red", "gold", ], Resources.IMG_GOLDPENDANTRED),
        new BingoItem("white pendant", ["neck", "jewelry", "necklace", "pendant", "white", "gold", ], Resources.IMG_GOLDPENDANTWHITE),
        new BingoItem("black pendant", ["neck", "jewelry", "necklace", "pendant", "black", "gold", ], Resources.IMG_GOLDPENDANTBLACK),
        new BingoItem("pearl earrings", ["head", "jewelry", "earrings", "beaded", "white", ], Resources.IMG_PEARLEARRINGS),
        new BingoItem("gemstone earrings", ["head", "jewelry", "earrings", "gem", "color", ], Resources.IMG_GEMEARRINGS),
        new BingoItem("hoop earrings", ["head", "jewelry", "earrings", "hoop", "color", ], Resources.IMG_HOOPEARRINGS),
        new BingoItem("thick hoop earrings", ["head", "jewelry", "earrings", "hoop", "color", ], Resources.IMG_THICKHOOPEARRINGS),
        new BingoItem("bubble earrings", ["head", "jewelry", "earrings", "hoop", "color", ], Resources.IMG_BUBBLEEARRINGS),
        new BingoItem("dangly earrings", ["head", "jewelry", "earrings", "dangly", "pink", ], Resources.IMG_DANGLYEARRINGSPINK),
        new BingoItem("dangly earrings", ["head", "jewelry", "earrings", "dangly", "green", ], Resources.IMG_DANGLYEARRINGSGREEN),
        new BingoItem("chandalier earrings", ["head", "jewelry", "earrings", "dangly", "pink", "gold", ], Resources.IMG_CHANDALIEREARRINGS),
        new BingoItem("basic ring", ["hands", "jewelry", "ring", "color", ], Resources.IMG_BASICRING),
        new BingoItem("gold diamond ring", ["hands", "jewelry", "ring", "gold", "gem", ], Resources.IMG_GOLDRINGDIAMOND),
        new BingoItem("gold ruby ring", ["hands", "jewelry", "ring", "gold", "gem", "red", ], Resources.IMG_GOLDRINGRUBY),
        new BingoItem("gold sapphire ring", ["hands", "jewelry", "ring", "gold", "gem", "blue", ], Resources.IMG_GOLDRINGSAPPHIRE),
        new BingoItem("gold emerald ring", ["hands", "jewelry", "ring", "gold", "gem", "green", ], Resources.IMG_GOLDRINGEMERALD),
        new BingoItem("gold peridot ring", ["hands", "jewelry", "ring", "gold", "gem", "green", ], Resources.IMG_GOLDRINGPERIDOT),
        new BingoItem("silver diamond ring", ["hands", "jewelry", "ring", "silver", "gem", ], Resources.IMG_SILVERRINGDIAMOND),
        new BingoItem("silver amethyst ring", ["hands", "jewelry", "ring", "silver", "gem", "purple", ], Resources.IMG_SILVERRINGAMETHYST),
        new BingoItem("silver zircon ring", ["hands", "jewelry", "ring", "silver", "gem", "pink", ], Resources.IMG_SILVERRINGPINK),
        new BingoItem("silver garnet ring", ["hands", "jewelry", "ring", "silver", "gem", "orange", ], Resources.IMG_SILVERRINGORANGE),
        new BingoItem("red/gold class ring", ["hands", "jewelry", "ring", "gold", "gem", "red", ], Resources.IMG_CLASSRINGRED),
        new BingoItem("purple/gold class ring", ["hands", "jewelry", "ring", "gold", "gem", "purple", ], Resources.IMG_CLASSRINGPURPLE),
        new BingoItem("blue/gold class ring", ["hands", "jewelry", "ring", "gold", "gem", "blue", ], Resources.IMG_CLASSRINGBLUE),
        new BingoItem("green/gold class ring", ["hands", "jewelry", "ring", "gold", "gem", "green", ], Resources.IMG_CLASSRINGGREEN),
        new BingoItem("red/silver class ring", ["hands", "jewelry", "ring", "silver", "gem", "red", ], Resources.IMG_CLASSRINGSILVERRED),
        new BingoItem("purple/silver class ring", ["hands", "jewelry", "ring", "silver", "gem", "purple", ], Resources.IMG_CLASSRINGSILVERPURPLE),
        new BingoItem("blue/silver class ring", ["hands", "jewelry", "ring", "silver", "gem", "blue", ], Resources.IMG_CLASSRINGSILVERBLUE),
        new BingoItem("green/silver class ring", ["hands", "jewelry", "ring", "silver", "gem", "green", ], Resources.IMG_CLASSRINGSILVERGREEN),
        new BingoItem("solid heel", ["feet", "shoes", "heel", "color", ], Resources.IMG_HEELSOLID),
        new BingoItem("patterned heel 1", ["feet", "shoes", "heel", "pattern", ], Resources.IMG_HEELPATTERN01),
        new BingoItem("patterned heel 2", ["feet", "shoes", "heel", "pattern", ], Resources.IMG_HEELPATTERN02),
        new BingoItem("patterned heel 3", ["feet", "shoes", "heel", "pattern", ], Resources.IMG_HEELPATTERN03),
        new BingoItem("patterned heel 4", ["feet", "shoes", "heel", "pattern", ], Resources.IMG_HEELPATTERN04),
        new BingoItem("patterned heel 5", ["feet", "shoes", "heel", "pattern", ], Resources.IMG_HEELPATTERN05),
        new BingoItem("short brown boot", ["feet", "shoes", "boot", "brown", "winter", "heel", ], Resources.IMG_SHORTBOOTBROWN),
        new BingoItem("short pink boot", ["feet", "shoes", "boot", "pink", "winter", "heel", ], Resources.IMG_SHORTBOOTPINK),
        new BingoItem("short blue boot", ["feet", "shoes", "boot", "blue", "winter", "heel", ], Resources.IMG_SHORTBOOTBLUE),
        new BingoItem("short black boot", ["feet", "shoes", "boot", "black", "winter", "heel", ], Resources.IMG_SHORTBOOTBLACK),
        new BingoItem("red boot", ["feet", "shoes", "boot", "red", "winter", ], Resources.IMG_TALLBOOTRED),
        new BingoItem("black boot", ["feet", "shoes", "boot", "black", "winter", ], Resources.IMG_TALLBOOTBLACK),
        new BingoItem("brown boot", ["feet", "shoes", "boot", "brown", "winter", ], Resources.IMG_TALLBOOTBROWN),
        new BingoItem("green boot", ["feet", "shoes", "boot", "green", "winter", ], Resources.IMG_TALLBOOTGREEN),
        new BingoItem("purple boot", ["feet", "shoes", "boot", "purple", "winter", ], Resources.IMG_TALLBOOTPURPLE),
        new BingoItem("silver boot", ["feet", "shoes", "boot", "silver", "winter", ], Resources.IMG_TALLBOOTSILVER),
        new BingoItem("pink fuzzy slipper", ["feet", "shoes", "flat", "pink", ], Resources.IMG_FUZZYSLIPPERPINK),
        new BingoItem("blue fuzzy slipper", ["feet", "shoes", "flat", "blue", ], Resources.IMG_FUZZYSLIPPERBLUE),
        new BingoItem("red fuzzy slipper", ["feet", "shoes", "flat", "red", ], Resources.IMG_FUZZYSLIPPERRED),
        new BingoItem("yellow fuzzy slipper", ["feet", "shoes", "flat", "yellow", ], Resources.IMG_FUZZYSLIPPERYELLOW),
        new BingoItem("black wedge", ["feet", "shoes", "wedge", "black", ], Resources.IMG_WEDGEBLACK),
        new BingoItem("green wedge", ["feet", "shoes", "wedge", "green", ], Resources.IMG_WEDGEGREEN),
        new BingoItem("red wedge", ["feet", "shoes", "wedge", "red", ], Resources.IMG_WEDGERED),
        new BingoItem("blue wedge", ["feet", "shoes", "wedge", "blue", ], Resources.IMG_WEDGEBLUE),
        new BingoItem("black sandal", ["feet", "shoes", "flat", "black", "summer", ], Resources.IMG_SANDALBLACK),
        new BingoItem("blue sandal", ["feet", "shoes", "flat", "blue", "summer", ], Resources.IMG_SANDALBLUE),
        new BingoItem("orange sandal", ["feet", "shoes", "flat", "orange", "summer", ], Resources.IMG_SANDALORANGE),
        new BingoItem("purple sandal", ["feet", "shoes", "flat", "purple", "summer", ], Resources.IMG_SANDALPURPLE),
        new BingoItem("red sandal", ["feet", "shoes", "flat", "red", "summer", ], Resources.IMG_SANDALRED),
        new BingoItem("green sandal", ["feet", "shoes", "flat", "green", "summer", ], Resources.IMG_SANDALSGREEN),
        new BingoItem("pink sandal", ["feet", "shoes", "flat", "pink", "summer", ], Resources.IMG_SANDALSPINK),
        new BingoItem("yellow sandal", ["feet", "shoes", "flat", "yellow", "summer", ], Resources.IMG_SANDALSYELLOW),
        new BingoItem("red flat", ["feet", "shoes", "flat", "red", "summer", ], Resources.IMG_FLATSRED),
        new BingoItem("pink flat", ["feet", "shoes", "flat", "pink", "summer", ], Resources.IMG_FLATSPINK),
        new BingoItem("purple flat", ["feet", "shoes", "flat", "purple", "summer", ], Resources.IMG_FLATSPURPLE),
        new BingoItem("blue flat", ["feet", "shoes", "flat", "blue", "summer", ], Resources.IMG_FLATSBLUE),
        new BingoItem("orange flat", ["feet", "shoes", "flat", "orange", "summer", ], Resources.IMG_FLATSORANGE),
        new BingoItem("green flat", ["feet", "shoes", "flat", "green", "summer", ], Resources.IMG_FLATSGREEN),
        new BingoItem("yellow flat", ["feet", "shoes", "flat", "yellow", "summer", ], Resources.IMG_FLATSYELLOW),
        new BingoItem("patterned flat 1", ["feet", "shoes", "flat", "pattern", "summer", ], Resources.IMG_FLATSPATTERN01),
        new BingoItem("patterned flat 2", ["feet", "shoes", "flat", "pattern", "summer", ], Resources.IMG_FLATSPATTERN02),
        new BingoItem("patterned flat 3", ["feet", "shoes", "flat", "pattern", "summer", ], Resources.IMG_FLATSPATTERN03),
        new BingoItem("patterned flat 4", ["feet", "shoes", "flat", "pattern", "summer", ], Resources.IMG_FLATSPATTERN04),
        new BingoItem("patterned flat 5", ["feet", "shoes", "flat", "pattern", "summer", ], Resources.IMG_FLATSPATTERN05),
        new BingoItem("patterned flat 6", ["feet", "shoes", "flat", "pattern", "summer", ], Resources.IMG_FLATSPATTERN06),
        new BingoItem("patterned flat 7", ["feet", "shoes", "flat", "pattern", "summer", ], Resources.IMG_FLATSPATTERN07),
        new BingoItem("blue sneakers", ["feet", "shoes", "flat", "blue", ], Resources.IMG_SNEAKERSBLUE),
        new BingoItem("green sneakers", ["feet", "shoes", "flat", "green", ], Resources.IMG_SNEAKERSGREEN),
        new BingoItem("orange sneakers", ["feet", "shoes", "flat", "orange", ], Resources.IMG_SNEAKERSORANGE),
        new BingoItem("pink sneakers", ["feet", "shoes", "flat", "pink", ], Resources.IMG_SNEAKERSPINK),
        new BingoItem("purple sneakers", ["feet", "shoes", "flat", "purple", ], Resources.IMG_SNEAKERSPURPLE),
        new BingoItem("red sneakers", ["feet", "shoes", "flat", "red", ], Resources.IMG_SNEAKERSRED),
        new BingoItem("yellow sneakers", ["feet", "shoes", "flat", "yellow", ], Resources.IMG_SNEAKERSYELLOW),
        new BingoItem("bobby pins", ["head", "hair accessory", "gem", "beaded", ], Resources.IMG_BOBBYPINS),
        new BingoItem("patterned barrette 1", ["head", "hair accessory", "pattern", ], Resources.IMG_BARRETTEPATTERN01),
        new BingoItem("patterned barrette 2", ["head", "hair accessory", "pattern", ], Resources.IMG_BARRETTEPATTERN02),
        new BingoItem("patterned barrette 3", ["head", "hair accessory", "pattern", ], Resources.IMG_BARRETTEPATTERN03),
        new BingoItem("black headband", ["head", "hair accessory", "black", ], Resources.IMG_HEADBANDBLACK),
        new BingoItem("blue headband", ["head", "hair accessory", "blue", ], Resources.IMG_HEADBANDBLUE),
        new BingoItem("green headband", ["head", "hair accessory", "green", ], Resources.IMG_HEADBANDGREEN),
        new BingoItem("orange headband", ["head", "hair accessory", "orange", ], Resources.IMG_HEADBANDORANGE),
        new BingoItem("pink headband", ["head", "hair accessory", "pink", ], Resources.IMG_HEADBANDPINK),
        new BingoItem("purple headband", ["head", "hair accessory", "purple", ], Resources.IMG_HEADBANDPURPLE),
        new BingoItem("red headband", ["head", "hair accessory", "red", ], Resources.IMG_HEADBANDRED),
        new BingoItem("yellow headband", ["head", "hair accessory", "yellow", ], Resources.IMG_HEADBANDYELLOW),
        new BingoItem("red double headband", ["head", "hair accessory", "red", ], Resources.IMG_DOUBLEHEADBANDRED),
        new BingoItem("pink double headband", ["head", "hair accessory", "pink", ], Resources.IMG_DOUBLEHEADBANDPINK),
        new BingoItem("purple double headband", ["head", "hair accessory", "purple", ], Resources.IMG_DOUBLEHEADBANDPURPLE),
        new BingoItem("blue double headband", ["head", "hair accessory", "blue", ], Resources.IMG_DOUBLEHEADBANDBLUE),
        new BingoItem("orange double headband", ["head", "hair accessory", "orange", ], Resources.IMG_DOUBLEHEADBANDORANGE),
        new BingoItem("green double headband", ["head", "hair accessory", "green", ], Resources.IMG_DOUBLEHEADBANDGREEN),
        new BingoItem("yellow double headband", ["head", "hair accessory", "yellow", ], Resources.IMG_DOUBLEHEADBANDYELLOW),
        new BingoItem("black double headband", ["head", "hair accessory", "black", ], Resources.IMG_DOUBLEHEADBANDBLACK),
        new BingoItem("fabric headband 1", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND01),
        new BingoItem("fabric headband 2", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND02),
        new BingoItem("fabric headband 3", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND03),
        new BingoItem("fabric headband 4", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND04),
        new BingoItem("fabric headband 5", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND05),
        new BingoItem("fabric headband 6", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND06),
        new BingoItem("fabric headband 7", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND07),
        new BingoItem("fabric headband 8", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND08),
        new BingoItem("fabric headband 9", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND09),
        new BingoItem("fabric headband 10", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND10),
        new BingoItem("fabric headband 11", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND11),
        new BingoItem("fabric headband 12", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND12),
        new BingoItem("fabric headband 13", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND13),
        new BingoItem("fabric headband 14", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND14),
        new BingoItem("fabric headband 15", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND15),
        new BingoItem("fabric headband 16", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND16),
        new BingoItem("fabric headband 17", ["head", "hair accessory", "pattern", ], Resources.IMG_FABRICHEADBAND17),
        new BingoItem("black bow clips", ["head", "hair accessory", "black", "bow", ], Resources.IMG_BOWCLIPSBLACK),
        new BingoItem("blue bow clips", ["head", "hair accessory", "blue", "bow", ], Resources.IMG_BOWCLIPSBLUE),
        new BingoItem("green bow clips", ["head", "hair accessory", "green", "bow", ], Resources.IMG_BOWCLIPSGREEN),
        new BingoItem("orange bow clips", ["head", "hair accessory", "orange", "bow", ], Resources.IMG_BOWCLIPSORANGE),
        new BingoItem("pink bow clips", ["head", "hair accessory", "pink", "bow", ], Resources.IMG_BOWCLIPSPINK),
        new BingoItem("purple bow clips", ["head", "hair accessory", "purple", "bow", ], Resources.IMG_BOWCLIPSPURPLE),
        new BingoItem("red bow clips", ["head", "hair accessory", "red", "bow", ], Resources.IMG_BOWCLIPSRED),
        new BingoItem("white bow clips", ["head", "hair accessory", "white", "bow", ], Resources.IMG_BOWCLIPSWHITE),
        new BingoItem("yellow bow clips", ["head", "hair accessory", "yellow", "bow", ], Resources.IMG_BOWCLIPSYELLOW),
        new BingoItem("patterned bow clips 1", ["head", "hair accessory", "pattern", "bow", ], Resources.IMG_BOWCLIPSPATTERN01),
        new BingoItem("patterned bow clips 2", ["head", "hair accessory", "pattern", "bow", ], Resources.IMG_BOWCLIPSPATTERN02),
        new BingoItem("patterned bow clips 3", ["head", "hair accessory", "pattern", "bow", ], Resources.IMG_BOWCLIPSPATTERN03),
        new BingoItem("patterned bow clips 4", ["head", "hair accessory", "pattern", "bow", ], Resources.IMG_BOWCLIPSPATTERN04),
        new BingoItem("patterned bow clips 5", ["head", "hair accessory", "pattern", "bow", ], Resources.IMG_BOWCLIPSPATTERN05),
        new BingoItem("brown claw", ["head", "hair accessory", "brown", ], Resources.IMG_CLAWBROWN),
        new BingoItem("black claw", ["head", "hair accessory", "black", ], Resources.IMG_CLAWBLACK),
        new BingoItem("red claw", ["head", "hair accessory", "red", ], Resources.IMG_CLAWRED),
        new BingoItem("pink claw", ["head", "hair accessory", "pink", ], Resources.IMG_CLAWPINK),
        new BingoItem("purple claw", ["head", "hair accessory", "purple", ], Resources.IMG_CLAWPURPLE),
        new BingoItem("blue claw", ["head", "hair accessory", "blue", ], Resources.IMG_CLAWBLUE),
        new BingoItem("orange claw", ["head", "hair accessory", "orange", ], Resources.IMG_CLAWORANGE),
        new BingoItem("green claw", ["head", "hair accessory", "green", ], Resources.IMG_CLAWGREEN),
        new BingoItem("yellow claw", ["head", "hair accessory", "yellow", ], Resources.IMG_CLAWYELLOW),
        new BingoItem("red baret", ["head", "hat", "red", ], Resources.IMG_BARET),
        new BingoItem("purple baret", ["head", "hat", "purple", ], Resources.IMG_BARETPURPLE),
        new BingoItem("orange baseball cap", ["head", "hat", "orange", ], Resources.IMG_BASEBALLCAP),
        new BingoItem("blue baseball cap", ["head", "hat", "blue", ], Resources.IMG_BASEBALLCAPBLUE),
        new BingoItem("green baseball cap", ["head", "hat", "green", ], Resources.IMG_BASEBALLCAPGREEN),
        new BingoItem("black cowboy hat", ["head", "hat", "red", "black", ], Resources.IMG_COWBOYHATBLACK),
        new BingoItem("cowboy hat", ["head", "hat", "green", "brown", ], Resources.IMG_COWBOYHAT),
        new BingoItem("'earflap' hat", ["head", "hat", "winter", "blue", ], Resources.IMG_EARFLAPHAT),
        new BingoItem("brown 'earflap' hat", ["head", "hat", "winter", "brown", ], Resources.IMG_EARFLAPHATBROWN),
        new BingoItem("fedora", ["head", "hat", "white", ], Resources.IMG_FEDORA),
        new BingoItem("patterned fedora", ["head", "hat", "white", "black", ], Resources.IMG_FEDORAPATTERN),
        new BingoItem("newsboy hat", ["head", "hat", "blue", ], Resources.IMG_NEWSBOYHAT),
        new BingoItem("patterned newsboy hat", ["head", "hat", "orange", "pink", "purple", "patterned", ], Resources.IMG_NEWSBOYHATPATTERN),
        new BingoItem("blue snow cap", ["head", "hat", "winter", "blue", ], Resources.IMG_SNOWCAPBLUE),
        new BingoItem("snow cap", ["head", "hat", "winter", "pink", ], Resources.IMG_SNOWCAP),
        new BingoItem("straw/sun hat", ["head", "hat", "summer", "red", ], Resources.IMG_STRAWHAT),
        new BingoItem("patterned straw/sun hat", ["head", "hat", "summer", "green", "pattern", ], Resources.IMG_STRAWHATPATTERN),
        new BingoItem("patterned tote 1", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN01),
        new BingoItem("patterned tote 2", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN02),
        new BingoItem("patterned tote 3", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN03),
        new BingoItem("patterned tote 4", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN04),
        new BingoItem("patterned tote 5", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN05),
        new BingoItem("patterned tote 6", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN06),
        new BingoItem("patterned tote 7", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN07),
        new BingoItem("patterned tote 8", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN08),
        new BingoItem("patterned tote 9", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN09),
        new BingoItem("patterned tote 10", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN10),
        new BingoItem("patterned tote 11", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN11),
        new BingoItem("patterned tote 12", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN12),
        new BingoItem("patterned tote 13", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN13),
        new BingoItem("patterned tote 14", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN14),
        new BingoItem("patterned tote 15", ["bag", "tote", "pattern", ], Resources.IMG_TOTEPATTERN15),
        new BingoItem("brown woven tote", ["bag", "tote", "brown", ], Resources.IMG_WOVENTOTEBROWN),
        new BingoItem("orange woven tote", ["bag", "tote", "orange", ], Resources.IMG_WOVENTOTEORANGE),
        new BingoItem("yellow woven tote", ["bag", "tote", "yellow", ], Resources.IMG_WOVENTOTEYELLOW),
        new BingoItem("blue change purse", ["bag", "change purse", "blue", ], Resources.IMG_CHANGEPURSEBLUE),
        new BingoItem("red change purse", ["bag", "change purse", "red", ], Resources.IMG_CHANGEPURSERED),
        new BingoItem("pink change purse", ["bag", "change purse", "pink", ], Resources.IMG_CHANGEPURSEPINK),
        new BingoItem("purple change purse", ["bag", "change purse", "purple", ], Resources.IMG_CHANGEPURSEPURPLE),
        new BingoItem("orange change purse", ["bag", "change purse", "orange", ], Resources.IMG_CHANGEPURSEORANGE),
        new BingoItem("green change purse", ["bag", "change purse", "green", ], Resources.IMG_CHANGEPURSEGREEN),
        new BingoItem("yellow change purse", ["bag", "change purse", "yellow", ], Resources.IMG_CHANGEPURSEYELLOW),
        new BingoItem("clutch", ["bag", "brown", "gold", ], Resources.IMG_CLUTCH),
        new BingoItem("green baguette", ["bag", "green", ], Resources.IMG_BAGUETTEGREEN),
        new BingoItem("purple baguette", ["bag", "purple", ], Resources.IMG_BAGUETTEPURPLE),
        new BingoItem("patterned purse 1", ["bag", "pattern", "green", ], Resources.IMG_PURSEPATTERN01),
        new BingoItem("patterned purse 2", ["bag", "pattern", "blue", ], Resources.IMG_PURSEPATTERN02),
        new BingoItem("patterned purse 3", ["bag", "pattern", "brown", ], Resources.IMG_PURSEPATTERN03),
        new BingoItem("patterned purse 4", ["bag", "pattern", "red", ], Resources.IMG_PURSEPATTERN04),


    ];



    // network bits
    public static const PROP_STATE :String = "state";
    public static const PROP_SCORES :String = "scores";
    public static const MSG_REQUEST_BINGO :String = "r_bingo";

}

}
