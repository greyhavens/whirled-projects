package bingo {
    
import flash.geom.Point;
    
public class Constants
{
    public static const ALLOW_CHEATS :Boolean = true;
    
    // cosmetic bits
    public static const CARD_LOC :Point = new Point(10, 10);
    public static const BALL_LOC :Point = new Point(400, 150);
    public static const BINGO_BUTTON_LOC :Point = new Point(400, 300);
    public static const WINNER_TEXT_LOC :Point = new Point(50, 400);
    
    // gameplay bits
    public static const CARD_WIDTH :int = 5;
    public static const CARD_HEIGHT :int = 5;
    public static const FREE_SPACE :Point = new Point(2, 2);
    
    public static const NEW_BALL_DELAY_S :Number = 7;
    public static const NEW_ROUND_DELAY_S :Number = 5;
    
    public static const ITEMS :Array = [
    
        new BingoItem("chickadee", [ "chickadee", "bird", "songbird", "forest" ]),
        new BingoItem("seagull", [ "seagull", "bird", "scavenger", "ocean" ]),
        new BingoItem("chihuahua", [ "chihuahua", "dog", "mammal", "domestic" ]),
        new BingoItem("labrador", [ "labrador", "dog", "mammal", "domestic" ]),
        new BingoItem("siamese", [ "siamese", "cat", "mammal", "domestic", "predator" ]),
        new BingoItem("tiger", [ "tiger", "cat", "mammal", "predator" ]),
        new BingoItem("goldfish", [ "goldfish", "fish", "aquarium", "domestic" ]),
        new BingoItem("albacore", [ "albacore", "tuna", "fish", "ocean" ]),
        new BingoItem("blackfin", [ "blackfin", "tuna", "fish", "ocean" ]),
        new BingoItem("bottlenose", [ "bottlenose", "dolphin", "mammal", "ocean" ]),
        new BingoItem("orca", [ "orca", "dolphin", "mammal", "ocean", "predator" ]),
        new BingoItem("beetle", [ "beetle", "insect", "soil" ]),
        new BingoItem("giraffe", [ "giraffe", "mammal", "tundra" ]),
        new BingoItem("hippopotamus", ["hippopotamus", "mammal", "river" ]),
        new BingoItem("gecko", [ "gecko", "reptile", "tree" ]),
        new BingoItem("rabbit", [ "rabbit", "mammal", "domestic" ]),
        new BingoItem("mouse", [ "mouse", "mammal", "domestic" ]),
        new BingoItem("seal", [ "seal", "mammal", "ocean" ]),
        new BingoItem("cricket", [ "cricket", "insect", "soil" ]),
        new BingoItem("hawk", [ "hawk", "bird", "predator" ]),
        new BingoItem("red squirrel", [ "red squirrel", "mammal", "forest" ]),
        new BingoItem("butterfly", [ "butterfly", "insect", "forest" ]),
        new BingoItem("salamander", [ "salamander", "amphibian", "river" ]),
        new BingoItem("buffalo", [ "buffalo", "mammal", "plain" ]),
        new BingoItem("shark", [ "shark", "fish", "ocean" ]),
        new BingoItem("skate", [ "skate", "fish", "ocean" ]),
        new BingoItem("starfish", [ "starfish", "fish", "ocean" ]),
        new BingoItem("rattlesnake", [ "rattlesnake", "reptile", "forest" ]),
        new BingoItem("egret", [ "egret", "bird", "river" ]),
        new BingoItem("bat", [ "bat", "mammal", "cave" ]),
        new BingoItem("ant", [ "ant", "insect", "soil" ]),
        new BingoItem("armadillo", [ "armadillo", "mammal", "forest" ]),
        new BingoItem("catfish", [ "catfish", "fish", "river" ]),
        new BingoItem("chinchilla", [ "chinchilla", "mammal", "burrow" ]),
        new BingoItem("fox", [ "fox", "mammal", "burrow" ]),
        new BingoItem("black Bear", [ "black bear", "mammal", "forest" ]),
        new BingoItem("mink", [ "mink", "mammal", "forest" ]),
        new BingoItem("otter", [ "otter", "mammal", "river" ]),
        new BingoItem("mole", [ "mole", "mammal", "soil" ]),
        new BingoItem("possum", [ "possum", "mammal", "forest" ]),
        new BingoItem("stallion", [ "stallion", "mammal", "plain" ]),
        new BingoItem("plankton", [ "plankton", "ocean" ]),
        new BingoItem("bee", [ "bee", "insect", "forest" ]),
        new BingoItem("woodpecker", [ "woodpecker", "bird", "forest" ]),
        new BingoItem("rat", [ "rat", "mammal", "domestic" ]),
        new BingoItem("sea turtle", [ "sea turtle", "reptile", "ocean" ]),
        new BingoItem("jellyfish", [ "jellyfish", "invertebrate", "ocean" ]),
        new BingoItem("squid", [ "squid", "cephalopod", "ocean" ]),
        new BingoItem("octopus", [ "octopus", "cephalopod", "ocean" ]),
        new BingoItem("crab", [ "crab", "crustacean", "ocean" ]),
        new BingoItem("clam", [ "clam", "mollusk", "ocean" ]),
        new BingoItem("unicorn", [ "unicorn", "mammal", "imaginary" ]),
        new BingoItem("crow", [ "crow", "bird", "forest" ]),
        new BingoItem("spider", [ "spider", "arachnid", "web" ]),
        new BingoItem("moth", [ "moth", "insect", "forest" ]),
        new BingoItem("pig", [ "pig", "mammal", "domestic" ]),
        new BingoItem("cow", [ "cow", "mammal", "domestic" ]),
        new BingoItem("slug", [ "slug", "mollusk", "garden" ]),
        new BingoItem("praying mantis", [ "praying mantis", "insect", "forest" ]),
        new BingoItem("cicada", [ "cicada", "insect" ]),
        new BingoItem("pigeon", [ "pigeon", "bird", "city" ]),
        new BingoItem("ferret", [ "ferret", "mammal", "domestic" ]),
        new BingoItem("kangaroo", [ "kangaroo", "mammal", "outback" ]),
        new BingoItem("racoon", [ "racoon", "mammal", "suburban" ]),
        new BingoItem("whale", [ "whale", "mammal", "ocean" ]),
        new BingoItem("eel", [ "eel", "fish", "ocean" ]),
        new BingoItem("koala", [ "koala", "mammal", "bamboo forest" ]),
        new BingoItem("koi", [ "koi", "fish", "fresh water" ]),
        new BingoItem("booby", [ "booby", "bird", "beach" ]),
        new BingoItem("alligator", [ "alligator", "reptile", "river" ]),
        new BingoItem("hyena", [ "hyena", "mammal", "savannah" ]),
        new BingoItem("baboon", [ "baboon", "mammal", "forest" ]),
        new BingoItem("bison", [ "bison", "mammal", "plain" ]),
        new BingoItem("dromedary", [ "dromedary", "mammal", "desert" ]),
        new BingoItem("lobster", [ "lobster", "crustacean", "ocean" ]),
        new BingoItem("earwig", [ "earwig", "insect", "soil" ]),
        new BingoItem("burro", [ "burro", "mammal", "domestic" ]),
        new BingoItem("sheep", [ "Sheep", "mammal", "domestic" ]),
        new BingoItem("tiger", [ "tiger", "mammal", "forest" ]),
        new BingoItem("lemur", [ "lemur", "mammal", "rain forest" ]),
        new BingoItem("sloth", [ "sloth", "mammal", "rain forest" ]),
        
    ];
    
    // network bits
    public static const PROP_STATE :String = "state";
    public static const MSG_REQUEST_BINGO :String = "r_bingo";

}

}