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

        // birds
        new BingoItem("chickadee",      [ "bird", "flying", /*"eggs",*/ /*"forest"*/ ]),
        new BingoItem("seagull",        [ "bird", "flying", /*"eggs",*/ /*"ocean"*/ ]),
        new BingoItem("egret",          [ "bird", "flying", /*"eggs",*/ /*"river"*/ ]),
        new BingoItem("woodpecker",     [ "bird", "flying", /*"eggs",*/ /*"forest"*/ ]),
        new BingoItem("pigeon",         [ "bird", "flying", /*"eggs",*/ /*"city"*/ ]),
        new BingoItem("crow",           [ "bird", "flying", /*"eggs",*/ /*"forest"*/ ]),
        new BingoItem("booby",          [ "bird", "flying", /*"eggs",*/ /*"beach"*/ ]),
        new BingoItem("canada goose",   [ "bird", "flying", "migratory", ]),

        new BingoItem("hawk",           [ "bird", "flying", /*"eggs",*/ "predator" ]),
        new BingoItem("owl",            [ "bird", "flying", /*"eggs",*/ "predator", "nocturnal", ]),

        new BingoItem("parrot",         [ "bird", "flying", /*"eggs",*/ "domestic" ]),

        new BingoItem("penguin",        [ "bird", /*"eggs"*/ ]),
        new BingoItem("ostrich",        [ "bird", /*"eggs"*/ ]),

        // insects
        new BingoItem("cricket",        [ "insect", "flying", /*"eggs",*/ /*"soil"*/ ]),
        new BingoItem("ant",            [ "insect", "flying", /*"eggs",*/ /*"soil"*/ ]),
        new BingoItem("bee",            [ "insect", "flying", /*"eggs",*/ /*"forest"*/ ]),
        new BingoItem("cicada",         [ "insect", "flying", /*"eggs"*/ ]),
        new BingoItem("earwig",         [ "insect", "flying", "nocturnal", /*"eggs",*/ /*"soil"*/ ]),
        new BingoItem("moth",           [ "insect", "flying", "nocturnal", /*"eggs",*/ /*"forest"*/ "migratory", ]),
        new BingoItem("butterfly",      [ "insect", "flying", /*"eggs",*/ /*"forest"*/ "migratory", ]),

        new BingoItem("praying mantis", [ "insect", "flying", /*"eggs",*/ "predator", /*"forest"*/ ]),

        new BingoItem("mayfly",         [ "insect", "flying", /*"eggs",*/ "aquatic", "predator" ]),
        new BingoItem("dragonfly",      [ "insect", "flying", /*"eggs",*/ "aquatic", "predator" ]),

        new BingoItem("cockroach",      [ "insect", "nocturnal", ]),

        // fish
        new BingoItem("goldfish",       [ "fish", "aquatic", /*"eggs",*/ "domestic" ]),
        new BingoItem("skate",          [ "fish", "aquatic", /*"eggs",*/ /*"ocean"*/ ]),
        new BingoItem("catfish",        [ "fish", "aquatic", "nocturnal", /*"eggs",*/ /*"river"*/ ]),
        new BingoItem("eel",            [ "fish", "aquatic", /*"eggs",*/ "predator", /*"ocean"*/ ]),
        new BingoItem("bluefin",        [ "fish", "aquatic", /*"eggs",*/ "predator", "migratory", /*"ocean"*/ ]),
        new BingoItem("great white",    [ "fish", "aquatic", /*"eggs",*/ "predator", /*"ocean"*/ ]),
        new BingoItem("salmon",         [ "fish", "aquatic", /*"eggs",*/ "migratory" ]),

        // rodent
        new BingoItem("capybara",       [ "rodent", "mammal", "aquatic" ]),
        new BingoItem("squirrel",       [ "rodent", "mammal", /*"forest"*/ ]),
        new BingoItem("mole",           [ "rodent", "mammal", /*"soil"*/ ]),
        new BingoItem("rat",            [ "rodent", "mammal", "domestic" ]),
        new BingoItem("ferret",         [ "rodent", "mammal", "domestic" ]),
        new BingoItem("rabbit",         [ "rodent", "mammal", "domestic" ]),
        new BingoItem("mouse",          [ "rodent", "mammal", "domestic" ]),
        new BingoItem("chinchilla",     [ "rodent", "mammal", "domestic", /*"burrow"*/ ]),

        // reptile
        new BingoItem("gecko",          [ "reptile", /*"eggs",*/ /*"tree"*/ ]),
        new BingoItem("sea turtle",     [ "reptile", /*"eggs",*/ "aquatic", /*"ocean"*/ ]),
        new BingoItem("alligator",      [ "reptile", /*"eggs",*/ "aquatic", "predator", /*"river"*/ ]),
        new BingoItem("rattlesnake",    [ "reptile", /*"eggs",*/ "predator", /*"forest"*/ ]),

        // other - mammal
        new BingoItem("giraffe",        [ "mammal", /*"tundra"*/ ]),
        new BingoItem("hippopotamus",   [ "mammal", /*"river"*/ ]),
        new BingoItem("buffalo",        [ "mammal", /*"plain"*/ ]),
        new BingoItem("armadillo",      [ "mammal", /*"forest"*/ ]),
        new BingoItem("mink",           [ "mammal", /*"forest"*/ ]),
        new BingoItem("otter",          [ "mammal", /*"river"*/ ]),
        new BingoItem("possum",         [ "mammal", "nocturnal", /*"forest"*/ ]),
        new BingoItem("stallion",       [ "mammal", /*"plain"*/ ]),
        //new BingoItem("unicorn",        [ "mammal", "imaginary" ]),
        new BingoItem("kangaroo",       [ "mammal", /*"outback"*/ ]),
        new BingoItem("racoon",         [ "mammal", "nocturnal", /*"suburban"*/ ]),
        new BingoItem("koala",          [ "mammal", /*"bamboo forest"*/ ]),
        new BingoItem("baboon",         [ "mammal", /*"forest"*/ ]),
        new BingoItem("bison",          [ "mammal", /*"plain"*/ ]),
        new BingoItem("dromedary",      [ "mammal", /*"desert"*/ ]),
        new BingoItem("lemur",          [ "mammal", "nocturnal", /*"rain forest"*/ ]),
        new BingoItem("sloth",          [ "mammal", /*"rain forest"*/ ]),

        new BingoItem("burro",          [ "mammal", "domestic" ]),
        new BingoItem("sheep",          [ "mammal", "domestic" ]),
        new BingoItem("pig",            [ "mammal", "domestic" ]),
        new BingoItem("cow",            [ "mammal", "domestic" ]),
        new BingoItem("chihuahua",      [ "mammal", "domestic" ]),

        new BingoItem("tiger",          [ "mammal", "predator" ]),
        new BingoItem("hyena",          [ "mammal", "predator", /*"savannah"*/ ]),
        new BingoItem("tiger",          [ "mammal", "predator", /*"forest"*/ ]),
        new BingoItem("fox",            [ "mammal", "predator", /*"burrow"*/ ]),
        new BingoItem("black bear",     [ "mammal", "predator", /*"forest"*/ ]),

        new BingoItem("bat",            [ "mammal", "flying", "predator", "nocturnal", /*"cave"*/ ]),

        new BingoItem("blue whale",     [ "mammal", "aquatic", "predator", /*"ocean"*/ ]),
        new BingoItem("orca",           [ "mammal", "aquatic", "predator", /*"ocean"*/ ]),
        new BingoItem("seal",           [ "mammal", "aquatic", "predator", /*"ocean"*/ ]),

        // other
        //new BingoItem("plankton",       [ /*"ocean"*/ ]),
        //new BingoItem("jellyfish",      [ "invertebrate", /*"ocean"*/ ]),
        //new BingoItem("squid",          [ "cephalopod", /*"ocean"*/ ]),
        //new BingoItem("octopus",        [ "cephalopod", /*"ocean"*/ ]),
        //new BingoItem("crab",           [ "crustacean", /*"ocean"*/ ]),
        //new BingoItem("lobster",        [ "crustacean", /*"ocean"*/ ]),
        //new BingoItem("salamander",     [ "amphibian", /*"river"*/ ]),
        //new BingoItem("starfish",       [ "aquatic", /*"eggs",*/ /*"ocean"*/ ]),

    ];

    // network bits
    public static const PROP_STATE :String = "state";
    public static const PROP_SCORES :String = "scores";
    public static const MSG_REQUEST_BINGO :String = "r_bingo";

}

}