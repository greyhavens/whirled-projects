package popcraft.util {

public class MyStringUtil
{
    // TODO: move to Narya?
    public static function commafyWords (words :Array, conjunction :String = "and") :String
    {
        var outString :String = "";
        for (var ii :int = 0; ii < words.length; ++ii) {
            if (ii > 0) {
                if (ii == words.length - 1) {
                    outString += " " + conjunction + " ";
                } else {
                    outString += ", ";
                }
            }
            outString += words[ii];
        }

        return outString;
    }
}

}
