package bingo {

import flash.geom.Point;

public class Constants
{
    public static const ALLOW_CHEATS :Boolean = false;
    public static const FORCE_SINGLEPLAYER :Boolean = false;

    // cosmetic bits
    public static const CARD_SCREEN_EDGE_OFFSET :Point = new Point(-460, 240);
    public static const HUD_SCREEN_EDGE_OFFSET :Point = new Point(-150, 240);

    // gameplay bits
    public static const SCORETABLE_MAX_ENTRIES :int = 50;

    public static const CARD_WIDTH :int = 5;
    public static const CARD_HEIGHT :int = 5;
    public static const FREE_SPACE :Point = new Point(2, 2);

    public static const NEW_BALL_DELAY_S :Number = 9;
    public static const NEW_ROUND_DELAY_S :Number = 20;

    public static const USE_ITEM_NAMES_AS_TAGS :Boolean = false;
    public static const CARD_ITEMS_ARE_UNIQUE :Boolean = true;

    public static const MAX_MATCHES_PER_BALL :int = 999;

    // network bits
    public static const PROP_STATE :String = "p_bingoState";
    public static const PROP_SCORES :String = "p_bingoScores";
    public static const MSG_CALLBINGO :String = "m_bingo";
    public static const MSG_WONTROPHIES :String = "m_trophies";
}

}
