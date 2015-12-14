package spades.graphics {

import flash.geom.Point;
import com.whirled.contrib.card.Card;
import com.whirled.contrib.card.Table;
import com.whirled.contrib.card.TurnTimer;
import com.whirled.contrib.card.Hand;
import com.whirled.contrib.card.trick.Scores;
import com.whirled.contrib.card.trick.Bids;
import com.whirled.contrib.card.graphics.CardSprite;
import com.whirled.contrib.card.graphics.TeamSprite;
import com.whirled.contrib.card.graphics.NormalBiddingSprite;
import com.whirled.contrib.card.graphics.PlayerSprite;
import com.whirled.contrib.card.graphics.HandSprite;
import com.whirled.contrib.card.graphics.CardSpriteFactory;

public class Factory
    implements CardSpriteFactory
{
    /** @inheritDoc */
    // from CardSpriteFactory
    public function createCard (card :Card) :CardSprite {
        return new CardSprite(card, DECK, getCardWidth(), getCardHeight());
    }

    /** @inheritDoc */
    // from CardSpriteFactory
    public function getCardWidth () :int {
        return 60;
    }

    /** @inheritDoc */
    // from CardSpriteFactory
    public function getCardHeight () :int {
        return 80;
    }

    /** Create a new bidding ui. */
    public function createNormalBiddingSprite (
        bids :Bids) :NormalBiddingSprite
    {
        var buttonZeroName :String = "button_0";
        var labelColor :uint = 0x264C62;
        var labelBottom :int = -23;
        var fudgeOffset :int = -3;

        return new NormalBiddingSprite(
            bids, NORMAL_BIDDING_MOVIE, buttonZeroName, 
            labelColor, labelBottom, fudgeOffset);
    }

    /** Create a new player graphic. */
    public function createPlayerSprite (
        table :Table,
        id :int, 
        timer :TurnTimer) :PlayerSprite
    {
        var team :int = table.getTeamFromId(id).index;
        var timerMovie :Class = PLAYER_TIMERS[team] as Class;
        var background :Class = PLAYER_IMAGES[team] as Class;
        var colors :Array = PLAYER_TEXT_COLORS[team] as Array;
        var textColor :uint = colors[0] as uint;
        var outlineColor :uint = colors[1] as uint;
        var captionOutlineColor :uint = 
            PLAYER_CAPTION_OUTLINE_COLORS[team] as uint;

        return new PlayerSprite(table, id, PLAYER_WIDTH, PLAYER_HEIGHT, timer, 
            timerMovie, PLAYER_TIMER_POS, background, textColor, outlineColor, 
            PLAYER_WARNING_COLOR, PLAYER_CAPTION_COLOR, captionOutlineColor);
    }

    /** Create a new hand ui. */
    public function createHandSprite (hand :Hand) :HandSprite
    {
        return new HandSprite(hand, this);
    }

    /** Create a new team sprite. */
    public function createTeamSprite (
        scores :Scores,
        team :int,
        lastTrickPos :Point) :TeamSprite
    {
        var background :Class = TEAM_IMAGES[team] as Class;
        var white :uint = 0xFFFFFF;
        var colors :Array = TEAM_TEXT_COLORS[team] as Array;
        var color0 :uint = colors[0] as uint;
        var color1 :uint = colors[1] as uint;

        return new TeamSprite(scores, team, TEAM_HEIGHT, lastTrickPos, 
            background, white, color0, color1, white, white, color0);
    }

    /** Embedded class containing card graphics */
    [Embed(source="../../../rsrc/deck.swf", mimeType="application/octet-stream")]
    protected static const DECK :Class;

    [Embed(source="../../../rsrc/bidding_normal.swf", mimeType="application/octet-stream")]
    protected static const NORMAL_BIDDING_MOVIE :Class;

    protected static const PLAYER_WIDTH :int = 165;
    protected static const PLAYER_HEIGHT :int = 115;

    [Embed(source="../../../rsrc/turn_blue.png", mimeType="application/octet-stream")]
    protected static const PLAYER_IMAGE_TEAM_0 :Class;

    [Embed(source="../../../rsrc/turn_orange.png", mimeType="application/octet-stream")]
    protected static const PLAYER_IMAGE_TEAM_1 :Class;

    [Embed(source="../../../rsrc/clock_blue.swf", mimeType="application/octet-stream")]
    protected static const PLAYER_TIMER_TEAM_0 :Class;

    [Embed(source="../../../rsrc/clock_orange.swf", mimeType="application/octet-stream")]
    protected static const PLAYER_TIMER_TEAM_1 :Class;

    protected static const PLAYER_IMAGES :Array = [
        PLAYER_IMAGE_TEAM_0, PLAYER_IMAGE_TEAM_1];
    protected static const PLAYER_TIMERS :Array = [
        PLAYER_TIMER_TEAM_0, PLAYER_TIMER_TEAM_1];

    protected static const PLAYER_WARNING_COLOR :uint = 0xFF2525;
    protected static const PLAYER_CAPTION_COLOR :uint = 0xFFFFFF;
    protected static const PLAYER_CAPTION_OUTLINE_COLORS :Array = [
        0x4186Af, 0xA86C04];

    protected static const PLAYER_TEXT_COLORS :Array = [
        [0xB7E8Fb, 0x153741], 
        [0xFFD461, 0x382407]];

    protected static const PLAYER_TIMER_POS :Point = new Point(62, 36);

    protected static const TEAM_WIDTH :int = 180;
    protected static const TEAM_HEIGHT :int = 80;

    [Embed(source="../../../rsrc/team_blue.png", mimeType="application/octet-stream")]
    protected static const TEAM_IMAGE_TEAM_0 :Class;

    [Embed(source="../../../rsrc/team_orange.png", mimeType="application/octet-stream")]
    protected static const TEAM_IMAGE_TEAM_1 :Class;

    protected static const TEAM_IMAGES :Array = [
        TEAM_IMAGE_TEAM_0, TEAM_IMAGE_TEAM_1];

    // first index is by team, second is 0 for label outline color, 1 for score text color
    protected static const TEAM_TEXT_COLORS :Array = [
        [0x4186Af, 0x264C62], 
        [0xA86C04, 0x623F26]];

}

}
