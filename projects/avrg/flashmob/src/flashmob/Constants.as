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
}

}
