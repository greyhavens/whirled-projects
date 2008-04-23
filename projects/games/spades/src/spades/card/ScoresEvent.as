package spades.card {

import flash.events.Event;

/** 
 * Represents something that happens to scores.
 */
public class ScoresEvent extends Event
{
    /** Tricks changed. For this event, the team property is the Team object that has just won a 
     *  trick and the value property indicates the current total number of tricks for that team. */
    public static const TRICKS_CHANGED :String = "scores.tricksChanged";

    /** The type of event when the scores change. For this type of event, the team property is the
     *  Team object that has just scored some points and the value property is the current score 
     *  total for that team. */
    public static const SCORES_CHANGED :String = "scores.changed";

    /** The type of event when the tricks are reset to 0. For this type of event, no properties 
     *  are used. */
    public static const TRICKS_RESET :String = "scores.tricksReset";

    /** The type of event when the scores are reset to 0. For this type of event, no properties 
     *  are used. */
    public static const SCORES_RESET :String = "scores.reset";

    /** Placeholder function for Scores subclasses to add new event types. */
    public static function newEventType (type :String) :String
    {
        return type;
    }

    /** Create a new ScoresEvent. */
    public function ScoresEvent(
        type :String, 
        team :Team = null, 
        value :int = -1)
    {
        super(type);
        _team = team;
        _value = value;
    }

    /** @inheritDoc */
    // from flash.events.Event
    public override function clone () :Event
    {
        return new ScoresEvent(type, _team, _value);
    }

    /** @inheritDoc */
    // from Object
    public override function toString () :String
    {
        return formatToString("ScoresEvent", "type", "bubbles", "cancelable", 
            "team", "value");
    }

    /** The team that has just won a trick or scored some points. */
    public function get team () :Team
    {
        return _team;
    }

    /** The current total number of tricks or total score the the team. */
    public function get value () :int
    {
        return _value;
    }

    protected var _team :Team;
    protected var _value :int;
}

}
