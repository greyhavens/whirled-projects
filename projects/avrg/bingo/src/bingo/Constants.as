package bingo {
    
import flash.geom.Point;
    
public class Constants
{
    public static const ALLOW_CHEATS :Boolean = false;
    
    // cosmetic bits
    public static const CARD_LOC :Point = new Point(10, 10);
    public static const BALL_LOC :Point = new Point(400, 150);
    public static const BINGO_BUTTON_LOC :Point = new Point(400, 300);
    public static const QUIT_BUTTON_LOC :Point = new Point(400, 400);
    public static const WINNER_TEXT_LOC :Point = new Point(50, 400);
    
    // gameplay bits
    public static const CARD_WIDTH :int = 5;
    public static const CARD_HEIGHT :int = 5;
    public static const FREE_SPACE :Point = new Point(2, 2);
    
    public static const NEW_BALL_DELAY_S :Number = 7;
    public static const NEW_ROUND_DELAY_S :Number = 5;
    
    public static const USE_ITEM_NAMES_AS_TAGS :Boolean = false;
    
    public static const ITEMS :Array = [
    
        new BingoItem("chickadee", [ "bird", "songbird", "forest" ]),
        new BingoItem("seagull", [ "bird", "scavenger", "ocean" ]),
        new BingoItem("chihuahua", [ "dog", "mammal", "domestic" ]),
        new BingoItem("labrador", [ "dog", "mammal", "domestic" ]),
        new BingoItem("siamese", [ "cat", "mammal", "domestic", "predator" ]),
        new BingoItem("tiger", [ "cat", "mammal", "predator" ]),
        new BingoItem("goldfish", [ "fish", "aquarium", "domestic" ]),
        new BingoItem("albacore", [ "tuna", "fish", "ocean" ]),
        new BingoItem("blackfin", [ "tuna", "fish", "ocean" ]),
        new BingoItem("bottlenose", [ "dolphin", "mammal", "ocean" ]),
        new BingoItem("orca", [ "dolphin", "mammal", "ocean", "predator" ]),
        new BingoItem("beetle", [ "insect", "soil" ]),
        new BingoItem("giraffe", [ "mammal", "tundra" ]),
        new BingoItem("hippopotamus", [ "mammal", "river" ]),
        new BingoItem("gecko", [ "reptile", "tree" ]),
        new BingoItem("rabbit", [ "mammal", "domestic" ]),
        new BingoItem("mouse", [ "mammal", "domestic" ]),
        new BingoItem("seal", [ "mammal", "ocean" ]),
        new BingoItem("cricket", [ "insect", "soil" ]),
        new BingoItem("hawk", [ "bird", "predator" ]),
        new BingoItem("red squirrel", [ "mammal", "forest" ]),
        new BingoItem("butterfly", [ "insect", "forest" ]),
        new BingoItem("salamander", [ "amphibian", "river" ]),
        new BingoItem("buffalo", [ "mammal", "plain" ]),
        new BingoItem("shark", [ "fish", "ocean" ]),
        new BingoItem("skate", [ "fish", "ocean" ]),
        new BingoItem("starfish", [ "fish", "ocean" ]),
        new BingoItem("rattlesnake", [ "reptile", "forest" ]),
        new BingoItem("egret", [ "bird", "river" ]),
        new BingoItem("bat", [ "mammal", "cave" ]),
        new BingoItem("ant", [ "insect", "soil" ]),
        new BingoItem("armadillo", [ "mammal", "forest" ]),
        new BingoItem("catfish", [ "fish", "river" ]),
        new BingoItem("chinchilla", [ "mammal", "burrow" ]),
        new BingoItem("fox", [ "mammal", "burrow" ]),
        new BingoItem("black Bear", [ "black bear", "mammal", "forest" ]),
        new BingoItem("mink", [ "mammal", "forest" ]),
        new BingoItem("otter", [ "mammal", "river" ]),
        new BingoItem("mole", [ "mammal", "soil" ]),
        new BingoItem("possum", [ "mammal", "forest" ]),
        new BingoItem("stallion", [ "mammal", "plain" ]),
        new BingoItem("plankton", [ "ocean" ]),
        new BingoItem("bee", [ "insect", "forest" ]),
        new BingoItem("woodpecker", [ "bird", "forest" ]),
        new BingoItem("rat", [ "mammal", "domestic" ]),
        new BingoItem("sea turtle", [ "reptile", "ocean" ]),
        new BingoItem("jellyfish", [ "invertebrate", "ocean" ]),
        new BingoItem("squid", [ "cephalopod", "ocean" ]),
        new BingoItem("octopus", [ "cephalopod", "ocean" ]),
        new BingoItem("crab", [ "crustacean", "ocean" ]),
        new BingoItem("clam", [ "mollusk", "ocean" ]),
        new BingoItem("unicorn", [ "mammal", "imaginary" ]),
        new BingoItem("crow", [ "bird", "forest" ]),
        new BingoItem("spider", [ "arachnid", "web" ]),
        new BingoItem("moth", [ "insect", "forest" ]),
        new BingoItem("pig", [ "mammal", "domestic" ]),
        new BingoItem("cow", [ "mammal", "domestic" ]),
        new BingoItem("slug", [ "mollusk", "garden" ]),
        new BingoItem("praying mantis", [ "insect", "forest" ]),
        new BingoItem("cicada", [ "insect" ]),
        new BingoItem("pigeon", [ "bird", "city" ]),
        new BingoItem("ferret", [ "mammal", "domestic" ]),
        new BingoItem("kangaroo", [ "mammal", "outback" ]),
        new BingoItem("racoon", [ "mammal", "suburban" ]),
        new BingoItem("whale", [ "mammal", "ocean" ]),
        new BingoItem("eel", [ "fish", "ocean" ]),
        new BingoItem("koala", [ "mammal", "bamboo forest" ]),
        new BingoItem("koi", [ "fish", "fresh water" ]),
        new BingoItem("booby", [ "bird", "beach" ]),
        new BingoItem("alligator", [ "reptile", "river" ]),
        new BingoItem("hyena", [ "mammal", "savannah" ]),
        new BingoItem("baboon", [ "mammal", "forest" ]),
        new BingoItem("bison", [ "mammal", "plain" ]),
        new BingoItem("dromedary", [ "mammal", "desert" ]),
        new BingoItem("lobster", [ "crustacean", "ocean" ]),
        new BingoItem("earwig", [ "insect", "soil" ]),
        new BingoItem("burro", [ "mammal", "domestic" ]),
        new BingoItem("sheep", [ "mammal", "domestic" ]),
        new BingoItem("tiger", [ "mammal", "forest" ]),
        new BingoItem("lemur", [ "mammal", "rain forest" ]),
        new BingoItem("sloth", [ "mammal", "rain forest" ]),
        
    ];
    
    // network bits
    public static const PROP_STATE :String = "state";
    public static const MSG_REQUEST_BINGO :String = "r_bingo";

}

}