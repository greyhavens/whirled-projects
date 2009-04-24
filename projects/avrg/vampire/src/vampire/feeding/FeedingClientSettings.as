package vampire.feeding {

import vampire.quest.activity.BloodBloomActivityParams;
import vampire.quest.client.PlayerQuestData;
import vampire.quest.client.PlayerQuestStats;

public class FeedingClientSettings
{
    public var spOnly :Boolean;

    public var playerData :PlayerFeedingData;
    public var gameCompleteCallback :Function;
    public var playerQuestData :PlayerQuestData;
    public var playerStats :PlayerQuestStats;
    public var activityParams :BloodBloomActivityParams;

    // Valid only if spOnly is true
    public var spPreyName :String;
    public var spPreyBloodStrain :int;
    public var spVariant :int;

    // Valid only if spOnly is false
    public var mpGameId :int;

    public static function spSettings (preyName :String, preyBloodStrain :int, variant :int,
        playerData :PlayerFeedingData, gameCompleteCallback :Function,
        playerQuestData :PlayerQuestData = null, playerStats :PlayerQuestStats = null,
        activityParams :BloodBloomActivityParams = null) :FeedingClientSettings
    {
        var settings :FeedingClientSettings = new FeedingClientSettings();
        settings.spOnly = true;
        settings.spPreyName = preyName;
        settings.spPreyBloodStrain = preyBloodStrain;
        settings.spVariant = variant;
        settings.playerData = playerData.clone();
        settings.gameCompleteCallback = gameCompleteCallback;
        settings.playerQuestData = playerQuestData;
        settings.playerStats = playerStats;
        settings.activityParams = activityParams;
        return settings;
    }

    public static function mpSettings (gameId :int, playerData :PlayerFeedingData,
        gameCompleteCallback :Function, playerQuestData :PlayerQuestData = null,
        playerStats :PlayerQuestStats = null, activityParams :BloodBloomActivityParams = null)
        :FeedingClientSettings
    {
        var settings :FeedingClientSettings = new FeedingClientSettings();
        settings.spOnly = false;
        settings.mpGameId = gameId;
        settings.playerData = playerData.clone();
        settings.gameCompleteCallback = gameCompleteCallback;
        settings.playerQuestData = playerQuestData;
        settings.playerStats = playerStats;
        settings.activityParams = activityParams;
        return settings;
    }
}

}
