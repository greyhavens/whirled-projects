package bingo {
    
import flash.geom.Point;
    
public class Constants
{
    public static const CARD_LOC :Point = new Point(10, 10);
    public static const BALL_LOC :Point = new Point(400, 150);
    
    public static const CARD_WIDTH :int = 5;
    public static const CARD_HEIGHT :int = 5;
    
    public static const SECONDS_BETWEEN_BINGO_BALLS :Number = 5;
    
    public static const FREE_SPACE :Point = new Point(2, 2);
    
    public static const ITEMS :Array = [
    
        new BingoItem("elephant", [ "elephant", "big", "mammal", "grey" ]),
        
        new BingoItem("osprey", [ "osprey", "bird", "predator" ]),
        new BingoItem("chickadee", [ "chickadee", "bird", "songbird", "small" ]),
        new BingoItem("seagull", [ "seagull", "bird", "scavenger" ]),
        
        new BingoItem("chihuahua", [ "chihuahua", "dog", "small", "mammal", "domestic", ]),
        new BingoItem("labrador", [ "labrador", "dog", "mammal", "domestic" ]),
        
        new BingoItem("siamese", [ "siamese", "cat", "mammal", "domestic", "predator" ]),
        new BingoItem("tiger", [ "tiger", "cat", "mammal", "predator" ]),
        
        new BingoItem("goldfish", [ "goldfish", "fish", "aquarium", "domestic", "small" ]),
        
        new BingoItem("albacore", [ "albacore", "tuna", "fish", "ocean", "large", "human food" ]),
        new BingoItem("blackfin", [ "blackfin", "tuna", "fish", "ocean", "small" ]),
        
        new BingoItem("bottlenose", [ "bottlenose", "dolphin", "mammal", "ocean", "large" ]),
        new BingoItem("orca", [ "orca", "dolphin", "mammal", "ocean", "large", "predator" ]),
        
    ];
    
    public static const PROP_ROUNDID :String = "roundId";
    public static const PROP_BALLINPLAY :String = "ballInPlay";

}

}