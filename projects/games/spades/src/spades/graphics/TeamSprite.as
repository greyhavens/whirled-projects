package spades.graphics {

import flash.display.Sprite;
import flash.display.Bitmap;

import com.threerings.flash.Vector2;
import com.threerings.util.MultiLoader;

import caurina.transitions.Tweener;

import spades.card.Bids;
import spades.card.BidEvent;
import spades.card.Table;
import spades.card.Scores;
import spades.card.ScoresEvent;
import spades.card.Team;


/** Represents a team display. Includes a placeholder box and last trick display. 
 *  TODO: names, score and trick totals. */
public class TeamSprite extends Sprite
{
    /** Create a new team sprite. Long names will be truncated with an ellipsis.
     *  @param scores the scores object for the game. Also used to access the Table and Bids
     *  @param team the index of the team that this sprite is for
     *  @param mainTrickPos the global coordinates of the main trick - used for animating the 
     *  taking of a trick.
     *  @param lastTrickPos the relative position of the scaled down last trick icon */
    public function TeamSprite (
        scores :Scores,
        team :int,
        mainTrickPos :Vector2,
        lastTrickPos :Vector2)
    {
        MultiLoader.getContents(TEAM_IMAGES[team] as Class, gotBackground);

        _table = scores.table;
        _team = _table.getTeam(team);
        _bids = scores.bids;
        _scores = scores;
        _mainTrickPos = mainTrickPos.clone();
        _lastTrickPos = lastTrickPos.clone();

        _lastTrick = new LastTrickSprite();
        addChild(_lastTrick);

        var nameField :Text = new Text(Text.SMALL);
        nameField.centerY = -HEIGHT / 3;
        nameField.text = makeNameString(
            _table.getNameFromAbsolute(_team.players[0]), 
            _table.getNameFromAbsolute(_team.players[1]));
        addChild(nameField);

        _score = new ScoreBar("Score:", [-30, 10, 15, 20], 0x000000);
        _score.x = 0;
        _score.y = -5;
        addChild(_score);

        _tricks = new ScoreBar("Tricks:", [-15, 10, 15, 20], 0x000000);
        _tricks.x = 0;
        _tricks.y = HEIGHT / 2 - 20;
        addChild(_tricks);

        updateTricks();

        _bids.addEventListener(BidEvent.RESET, bidListener);
        _bids.addEventListener(BidEvent.PLACED, bidListener);

        _scores.addEventListener(ScoresEvent.TRICKS_CHANGED, scoresListener);
        _scores.addEventListener(ScoresEvent.SCORES_CHANGED, scoresListener);

        function gotBackground (background :Bitmap) :void
        {
            addChildAt(background, 0);

            background.x = -background.width / 2;
            background.y = -background.height / 2;
        }
    }

    /** Take the array of card sprites and animate them to this team's last trick slot. The 
     *  animation includes x,y position and scale. */
    public function takeTrick (cards :Array) :void
    {
        var localStartPos :Vector2 = Vector2.fromPoint(
            globalToLocal(_mainTrickPos.toPoint()));

        _lastTrick.setCards(cards);
        _lastTrick.x = localStartPos.x;
        _lastTrick.y = localStartPos.y;
        _lastTrick.scaleX = 1.0;
        _lastTrick.scaleY = 1.0;

        var tween :Object = {
            x: _lastTrickPos.x,
            y: _lastTrickPos.y,
            scaleX: TRICK_SCALE,
            scaleY: TRICK_SCALE,
            time: TRICK_DURATION
        };

        Tweener.addTween(_lastTrick, tween);
    }

    /** Clear the card sprites. */
    public function clearLastTrick () :void
    {
        _lastTrick.clear();
    }

    /** Set the team's score display. */
    protected function setScore (current :int, target :int) :void
    {
        _score.setValues(current, target);
    }

    /** Update the tricks/bid status text. */
    protected function updateTricks () :void
    {
        var tricks :int = _scores.getTricks(_team.index);
        var seats :Array = _team.players;

        if (!_bids.hasBid(seats[0]) || !_bids.hasBid(seats[1])) {
            _tricks.setValues(tricks, "?");
        }
        else {
            var bid :int = _bids.getBid(seats[0]) + _bids.getBid(seats[1]);
            _tricks.setValues(tricks, bid);
        }
    }

    protected function bidListener (event :BidEvent) :void
    {
        if (event.type == BidEvent.RESET) {
            updateTricks();
        }
        else if (event.type == BidEvent.PLACED) {
            updateTricks();
        }
    }

    protected function scoresListener (event :ScoresEvent) :void
    {
        if (event.team == _team) {
            if (event.type == ScoresEvent.TRICKS_CHANGED) {
                updateTricks();
            }
            else if (event.type == ScoresEvent.SCORES_CHANGED) {
                setScore(event.value, _scores.target);
            }
        }
    }

    /** Utility function to truncate and concatenate two names. */
    protected static function makeNameString (
        name1: String, 
        name2 :String) :String
    {
        name1 = Text.truncName(name1);
        name2 = Text.truncName(name2);
        return name1 + "/" + name2;
    }

    /** The table we are sitting at */
    protected var _table :Table;

    /** The seats of our team members */
    protected var _team :Team;

    /** The bids for the game */
    protected var _bids :Bids;

    /** The scores for the game */
    protected var _scores :Scores;

    /** Sprite for the last trick display */
    protected var _lastTrick :LastTrickSprite;

    /** Position of main trick, in global coordinates */
    protected var _mainTrickPos :Vector2;

    /** Static position of our last trick display */
    protected var _lastTrickPos :Vector2;

    /** Tricks score, e.g. "1/5" */
    protected var _tricks :ScoreBar;

    /** Score score, e.g. "172/300" */
    protected var _score :ScoreBar;

    protected static const TRICK_SCALE :Number = 0.5;
    protected static const TRICK_DURATION :int = 1.0;

    protected static const WIDTH :int = 180;
    protected static const HEIGHT :int = 80;

    [Embed(source="../../../rsrc/team_blue.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_0 :Class;

    [Embed(source="../../../rsrc/team_orange.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_1 :Class;

    protected static const TEAM_IMAGES :Array = [IMAGE_TEAM_0, IMAGE_TEAM_1];
}

}

import flash.display.Sprite;
import spades.graphics.Text;

class ScoreBar extends Sprite
{
    public function ScoreBar (
        label :String, 
        xpositions :Array, 
        color :uint)
    {
        var text :Text;

        text = new Text(Text.HUGE, color, 0xFFFFFF);
        text.centerY = 0;
        text.x = xpositions[1];
        text.text = "";
        text.rightJustify();
        addChild(_score = text);

        text = new Text(Text.HUGE, color, 0xFFFFFF);
        text.centerY = 0;
        text.x = xpositions[2];
        text.text = "/";
        addChild(text);

        text = new Text(Text.HUGE, color, 0xFFFFFF);
        text.centerY = 0;
        text.x = xpositions[3];
        text.text = "";
        text.leftJustify();
        addChild(_target = text);

        text = new Text(Text.SMALL, 0xFFFFFF, color, true);
        text.bottomY = _score.bottomY;
        text.x = xpositions[0];
        text.text = label;
        text.rightJustify();
        addChild(text);
    }

    public function setValues (score :int, target :Object) :void
    {
        _score.text = "" + score;
        _target.text = "" + target;
    }

    protected var _score :Text;
    protected var _target :Text;
}
