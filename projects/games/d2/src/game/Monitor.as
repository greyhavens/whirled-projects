package game {

import flash.events.Event;

import mx.utils.ObjectUtil;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.whirled.FlowAwardedEvent;
import com.whirled.WhirledGameControl;

import units.Tower;

/**
 * Monitors game progress on each client, and updates the main simulation as necessary.
 */
public class Monitor
// implements MessageReceivedListener, StateChangedListener, PropertyChangedListener
{
    // Names of properties set on the distributed object.
    public static const TOWER_SET :String = "TowersProperty";
    public static const START_TIME :String = "StartTimeProperty";
    public static const SCORE_SET :String = "ScoreSetProperty";
    public static const HEALTH_SET :String = "HealthSetProperty";
    public static const MONEY_SET :String = "MoneySetProperty";
    public static const SPAWNGROUPS :String = "SpawnGroupsProperty";  // which units get spawned
    public static const SPAWNERREADY :String = "SpawnReadyProperty";  // which spawners are ready
    // Names of messages
    public static const SPAWNER_DIFFICULTY :String = "SpawnerDifficultyMessage";


    // REST GOES HERE
}
}
