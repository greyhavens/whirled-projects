package vampire.feeding {

import vampire.quest.activity.BloodBloomActivityParams;
import vampire.quest.client.PlayerQuestData;
import vampire.quest.client.PlayerQuestProps;

public class FeedingClientSettings
{
    public var spOnly :Boolean;

    public var playerData :PlayerFeedingData;
    public var gameCompleteCallback :Function;
    public var playerQuestData :PlayerQuestData;
    public var playerQuestProps :PlayerQuestProps;

    // valid only if spOnly is true
    public var spActivityParams :BloodBloomActivityParams;

    // Valid only if spOnly is false
    public var mpGameId :int;

    public static function spSettings (
        playerData :PlayerFeedingData, gameCompleteCallback :Function,
        activityParams :BloodBloomActivityParams, playerQuestData :PlayerQuestData = null,
        playerQuestProps :PlayerQuestProps = null) :FeedingClientSettings
    {
        var settings :FeedingClientSettings = new FeedingClientSettings();
        settings.spOnly = true;
        settings.playerData = playerData.clone();
        settings.gameCompleteCallback = gameCompleteCallback;
        settings.spActivityParams = activityParams;
        settings.playerQuestData = playerQuestData;
        settings.playerQuestProps = playerQuestProps;
        return settings;
    }

    public static function mpSettings (gameId :int, playerData :PlayerFeedingData,
        gameCompleteCallback :Function, playerQuestData :PlayerQuestData = null,
        playerQuestProps :PlayerQuestProps = null) :FeedingClientSettings
    {
        var settings :FeedingClientSettings = new FeedingClientSettings();
        settings.spOnly = false;
        settings.mpGameId = gameId;
        settings.playerData = playerData.clone();
        settings.gameCompleteCallback = gameCompleteCallback;
        settings.playerQuestData = playerQuestData;
        settings.playerQuestProps = playerQuestProps;
        return settings;
    }
}

}
