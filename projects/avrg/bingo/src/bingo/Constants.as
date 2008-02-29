package bingo {
    
import flash.geom.Point;
    
public class Constants
{
    // cosmetic bits
    public static const CARD_LOC :Point = new Point(10, 10);
    public static const BALL_LOC :Point = new Point(400, 150);
    
    // gameplay bits
    public static const CARD_WIDTH :int = 4;
    public static const CARD_HEIGHT :int = 4;
    public static const FREE_SPACE :Point = new Point(-1, -1);
    
    public static const SECONDS_BETWEEN_BINGO_BALLS :Number = 5;
    
    public static const ITEMS :Array = [
    
        new BingoItem("elephant", [ "elephant", "big", "mammal" ]),
        
        new BingoItem("osprey", [ "osprey", "bird", "predator" ]),
        new BingoItem("chickadee", [ "chickadee", "bird", "songbird", "small" ]),
        new BingoItem("seagull", [ "seagull", "bird", "scavenger" ]),
        
        new BingoItem("chihuahua", [ "chihuahua", "dog", "small", "mammal", "domestic", ]),
        new BingoItem("labrador", [ "labrador", "dog", "mammal", "domestic" ]),
        
        new BingoItem("siamese", [ "siamese", "cat", "mammal", "domestic", "predator" ]),
        new BingoItem("tiger", [ "tiger", "cat", "mammal", "predator" ]),
        
        new BingoItem("goldfish", [ "goldfish", "fish", "aquarium", "domestic", "small" ]),
        
        new BingoItem("albacore", [ "albacore", "tuna", "fish", "ocean", "large", "tasty" ]),
        new BingoItem("blackfin", [ "blackfin", "tuna", "fish", "ocean", "small" ]),
        
        new BingoItem("bottlenose", [ "bottlenose", "dolphin", "mammal", "ocean", "large" ]),
        new BingoItem("orca", [ "orca", "dolphin", "mammal", "ocean", "large", "predator" ]),

        new BingoItem("Beetle", [ "beetle", "insect", "soil" ]),
        new BingoItem("Giraffe", [ "giraffe", "mammal", "tundra" ]),
        new BingoItem("Hippopotamus", ["hippopotamus", "mammal", "river" ]),
        new BingoItem("Gecko", [ "gecko", "reptile", "tree" ]),
        new BingoItem("Rabbit", [ "rabbit", "mammal", "domestic" ]),
        new BingoItem("Mouse", [ "mouse", "mammal", "domestic" ]),
        new BingoItem("Seal", [ "seal", "mammal", "ocean" ]),
        new BingoItem("Cricket", [ "cricket", "insect", "soil" ]),
        new BingoItem("Hawk", [ "hawk", "bird", "predator" ]),
        new BingoItem("Red Squirrel", [ "red squirrel", "mammal", "forest" ]),
        new BingoItem("Butterfly", [ "butterfly", "insect", "forest" ]),
        new BingoItem("Salamander", [ "salamander", "amphibian", "river" ]),
        new BingoItem("Buffalo", [ "buffalo", "mammal", "plain" ]),
        new BingoItem("Shark", [ "shark", "fish", "ocean" ]),
        new BingoItem("Skate", [ "skate", "fish", "ocean" ]),
        new BingoItem("Starfish", [ "starfish", "fish", "ocean" ]),
        new BingoItem("Rattlesnake", [ "rattlesnake", "reptile", "forest" ]),
        new BingoItem("Egret", [ "egret", "bird", "river" ]),
        new BingoItem("Bat", [ "bat", "mammal", "cave" ]),
        new BingoItem("Ant", [ "ant", "insect", "earth" ]),
        new BingoItem("Armadillo", [ "armadillo", "mammal", "forest" ]),
        new BingoItem("Catfish", [ "catfish", "fish", "river" ]),
        new BingoItem("Chinchilla", [ "chinchilla", "mammal", "burrow" ]),
        new BingoItem("Fox", [ "fox", "mammal", "burrow" ]),
        new BingoItem("Black Bear", [ "black bear", "mammal", "forest" ]),
        new BingoItem("Mink", [ "mink", "mammal", "forest" ]),
        new BingoItem("Otter", [ "otter", "mammal", "river" ]),
        new BingoItem("Mole", [ "mole", "mammal", "earth" ]),
        new BingoItem("Possum", [ "possum", "mammal", "forest" ]),
        new BingoItem("Stallion", [ "stallion", "mammal", "plain" ]),
        new BingoItem("Plankton", [ "plankton", "organism", "ocean" ]),
        new BingoItem("Bee", [ "bee", "insect", "forest" ]),
        new BingoItem("Woodpecker", [ "woodpecker", "bird", "forest" ]),
        new BingoItem("Rat", [ "rat", "mammal", "domestic" ]),
        new BingoItem("Sea Turtle", [ "sea turtle", "reptile", "ocean" ]),
        new BingoItem("Jellyfish", [ "jellyfish", "invertebrate", "ocean" ]),
        new BingoItem("Squid", [ "squid", "cephalopod", "ocean" ]),
        new BingoItem("Octopus", [ "octopus", "cephalopod", "ocean" ]),
        new BingoItem("Crab", [ "crab", "crustacean", "ocean" ]),
        new BingoItem("Clam", [ "clam", "mollusk", "ocean" ]),
        new BingoItem("Unicorn", [ "unicorn", "mammal", "imaginary" ]),
        new BingoItem("Crow", [ "crow", "bird", "forest" ]),
        new BingoItem("Spider", [ "spider", "arachnid", "web" ]),
        new BingoItem("Moth", [ "moth", "insect", "forest" ]),
        new BingoItem("Pig", [ "pig", "mammal", "domestic" ]),
        new BingoItem("Cow", [ "cow", "mammal", "domestic" ]),
        new BingoItem("Slug", [ "slug", "mollusk", "garden" ]),
        new BingoItem("Praying Mantis", [ "praying mantis", "insect", "forest" ]),
        new BingoItem("Cicada", [ "cicada", "insect", "small" ]), 
        
    ];
    
    // network bits
    public static const PROP_STATE :String = "state";
    public static const MSG_REQUEST_BINGO :String = "r_bingo";

}

}