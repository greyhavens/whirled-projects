package flashmob {

public class Constants
{
    public static const GAME_SIZE_ANY :int = -1;
    public static const GAME_SIZE_SMALL :int = 0;
    public static const GAME_SIZE_LARGE :int = 1;

    // Min players, Max players
    public static const GAME_SIZE_PARAMS :Array = [
        [ 2, 6 ],       // Small
        [ 7, 999 ],     // Large
    ];

    public static const MIN_SPECTACLE_PATTERNS :int = 2;
    public static const MAX_SPECTACLE_PATTERNS :int = 10;

    // Game states
    public static const STATE_INIT :int = 0;
    public static const STATE_SPECTACLE_CHOOSER :int = 1;
    public static const STATE_SPECTACLE_CREATOR :int = 2;
    public static const STATE_SPECTACLE_PLAY :int = 3;

    // Prop names
    public static const PROP_GAMESTATE :String = "gs";
}

}
