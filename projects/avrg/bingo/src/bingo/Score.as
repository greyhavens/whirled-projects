package bingo {
    
public class Score
{
    public var name :String;
    public var score :int;
    public var date :Date;
    
    public function Score (name :String, score :int, date :Date)
    {
        this.name = name;
        this.score = score;
        this.date = date;
    }
    
    public static function compare (a :Score, b :Score) :int
    {
        // compare scores. higher scores come before lower
        if (a.score > b.score) {
            return -1;
        } else if (a.score < b.score) {
            return 1;
        } else {
            
            // compare dates. newer dates come before older
            var aTime :Number = a.date.time;
            var bTime :Number = b.date.time;

            if (aTime < bTime) {
                return -1;
            } else if (aTime > bTime) {
                return 1;
            } else {
                return 0;
            }
        }
    }
    
    public function isEqual (rhs :Score) :Boolean
    {
        return (this.name == rhs.name && this.score == rhs.score && this.date.time == rhs.date.time);
    }
    
    public function clone () :Score
    {
        return new Score(name, score, date);
    }
}

}