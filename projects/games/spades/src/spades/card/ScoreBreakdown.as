package spades.card {

/** Holds the transient breakdown of the scores for a trick taking or other team card game. A 
 *  score breakdown encapsualtes the details of all the contributions to a team's total score 
 *  for a round. The breakdown can them be converted to text for local feedback. */
public class ScoreBreakdown
{
    /** Create a new score breakdown.
     *  @param table the table for the game
     *  @param team the index of the team being scored. */
    public function ScoreBreakdown (table :Table, team :int)
    {
        _table = table;
        _team = table.getTeam(team);
    }

    /** Adds a new achivement for the team that contributes to the overall score for the round.
     *  If the value is less than zero, it is implied that the team did not achieve the achievement
     *  and hence a "not" is prefixed to the text conversion for the item. If value is zero,
     *  the achievement is not recorded. 
     *  @param value the contribution of the achievement to the overall score
     *  @param achievement text describing the achievement, e.g. "winning all their tricks" */
    public function addTeamAchievement (value :int, achievement :String) :void
    {
        if (value != 0) {
            var elem :Element = new Element();
            elem.amount = value;
            elem.achievement = achievement;
            _elements.push(elem);
        }
    }

    /** Adds a new failure for the team that contributes to the overall score for the round.
     *  If the value is greater than zero, it is implied that the team did not fail
     *  and hence a "not" is prefixed to the text conversion for the item. If the value is zero,
     *  the achievement is not recorded. 
     *  @param value numeric contribution of the failure to the score, usually less than 0
     *  @param failure text describing the failure, e.g. "taking too many tricks" */
    public function addTeamFailure (value :int, action :String) :void
    {
        if (value != 0) {
            var elem :Element = new Element();
            elem.amount = value;
            elem.achievement = action;
            elem.inverted = true;
            _elements.push(elem);
        }
    }

    /** Adds a new achievement for the team that was orchestrated by one player in particular.
     *  When converting to text, this causes a possessive form of the player's name to prefix
     *  the achievement text. 
     *  @param value the contribution to the team's score of the achievement
     *  @param playerIdx the index of the player within the team that has achieved
     *  @param achievement text describing the achievement, e.g. "refraining from taking any 
     *  tricks" */
    public function addPlayerAchievement (value :int, playerIdx :int, achievement :String) :void
    {
        if (value != 0) {
            var elem :Element = new Element();
            elem.amount = value;
            elem.achievement = achievement;
            elem.playerIdx = playerIdx;
            _elements.push(elem);
        }
    }

    /** Access the total score for the breakdown. This is a sum of all the values given in the add 
     *  functions above. */
    public function get total () :int
    {
        var total :int = 0;
        _elements.forEach(function (e :Element, ...x) :void {
            total += e.amount;
        });
        return total;
    }

    /** Get an array of String's, each describing one breakdown item added by the add functions 
     *  above, suitable for the (English speaking) user's consumption. */
    public function describe () :Array
    {
        var current :* = this;
        var desc :Array = _elements.map(function (e :Element, ...x) :String {
            return e.describe(current);
        });

        return desc;
    }

    /** Access the name of the team for this breakdown. Assumes there are 2 players on a team.
     *  TODO: allow for more than 2 players */
    public function get teamName () :String
    {
        return getPlayerName(0) + " and " + getPlayerName(1);
    }

    /** Get the name of a given player. 
     *  @param idx the index of the player within the team */
    public function getPlayerName (idx :int) :String
    {
        return _table.getNameFromAbsolute(_team.players[idx]);
    }

    protected var _table :Table;
    protected var _team :Team;
    protected var _elements :Array = new Array();
}


}

import spades.card.ScoreBreakdown;

/** Represents one item in a score breakdown. Has optional fields that will be set depending on 
 *  which version of the ScoreBreakdown.add* function creates the instance. */
class Element
{
    /** Amount contributed to the overall score */
    public var amount :int;

    /** Text describing the action that generated the score. */
    public var achievement :String = "";

    /** Index of the player associated with the item, -1 if none */
    public var playerIdx :int = -1;

    /** Whether the item is a reversal, i.e. the achievement is acually a failure. */
    public var inverted :Boolean;
    
    /** Create a text description of the item. Generally has the form: 
     *  Player1 and Player2 win/lose N point/points for [not] achieving something. */
    public function describe (scores :ScoreBreakdown) :String
    {
        var points :String = "points";
        if (abs == 1) {
            points = "point";
        }
        var desc :String = scores.teamName + " " + winLose + " " + abs + " " + 
            points + " for ";
        if (playerIdx >= 0) {
            desc += scores.getPlayerName(playerIdx) + "'s ";
        }
        desc += prefixAchievement();
        return desc;
    }

    protected function get winLose () :String
    {
        if (amount >= 0) {
            return "win";
        }
        else {
            return "lose";
        }
    }

    protected function get abs () :int
    {
        return Math.abs(amount);
    }

    protected function prefixAchievement () :String
    {
        if ((!inverted && amount < 0) || ((inverted && amount > 0))) {
            return "not " + achievement;
        }
        return achievement;
    }
}
