package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import com.threerings.flash.Vector2;

import spades.Model;
import spades.card.CardArray;
import spades.card.CardArrayEvent;
import spades.card.Trick;
import spades.card.TrickEvent
import spades.card.Table;
import spades.card.Bids;
import spades.card.BidEvent;
import spades.card.Hand;
import spades.card.Scores;
import spades.card.Team;

/**
 * Display object for drawing a spades game.
 */
public class TableSprite extends Sprite
{
    /** Seat value to indicate no seat. */
    public static const NO_SEAT :int = -1;

    /** Positions of other players' on the table (relative to the local player). */
    public static const PLAYER_POSITIONS :Array = [
        new Vector2(350, 350),  // me
        new Vector2(145, 200),  // my left
        new Vector2(350, 60),  // opposite
        new Vector2(555, 200)   // my right
    ];

    /** Position of the center of the local player's hand. */
    public static const HAND_POSITION :Vector2 = new Vector2(350, 455);

    /** Position of the center of the bid slider */
    public static const SLIDER_POSITION :Vector2 = new Vector2(350, 255);

    /** Position of the center of the trick pile */
    public static const TRICK_POSITION :Vector2 = new Vector2(350, 205);

    /** Position of the left-hand team */
    public static const LEFT_TEAM_POSITION :Vector2 = new Vector2(95, 45);

    /** Position of the right-hand team */
    public static const RIGHT_TEAM_POSITION :Vector2 = new Vector2(605, 45);

    /** Offset of the last trick, relative to the team. */
    public static const LAST_TRICK_OFFSET :Number = 130;

    /** Create a new table.
     *  @param playerNames the names of the players, in seat order
     *  @param localSeat the seat that the local player is sitting in */
    public function TableSprite (model :Model)
    {
        _model = model;

        _players = new Array(table.numPlayers);
        for (var seat :int = 0; seat < table.numPlayers; ++seat) {
            var name :String = table.getNameFromRelative(seat);
            var p :PlayerSprite = new PlayerSprite(name);
            addChild(p);
            _players[seat] = p;
        }
        
        _hand = new HandSprite(_model.hand);
        addChild(_hand);

        _trick = new MainTrickSprite(_model.trick, table, _players, _hand);
        addChild(_trick);

        _teams[0] = new TeamSprite(_model.scores, 0, 
            TRICK_POSITION, new Vector2(LAST_TRICK_OFFSET, 0));
        addChild(_teams[0] as TeamSprite);

        _teams[1] = new TeamSprite(_model.scores, 1, 
            TRICK_POSITION, new Vector2(-LAST_TRICK_OFFSET, 0));
        addChild(_teams[1] as TeamSprite);

        _bid = new BidSprite(_model.bids);
        addChild(_bid);

        // listen for the trick changing
        _model.trick.addEventListener(TrickEvent.COMPLETED, trickListener);

        // listen for our removal to prevent stranded listeners
        addEventListener(Event.REMOVED, removedListener);

        layout();
    }

    /** Retrieve a callback to set a player's head shot. */
    public function getHeadShotCallback (seat :int) :Function
    {
        return getPlayer(table.getRelativeFromAbsolute(seat)).setHeadShot;
    }

    /** Highlight a player to show it is his turn. Also unhighlights any previous.
     *  If NO_SEAT is given, then all players are unhighlighted. */
    public function setPlayerTurn (seat :int) :void
    {
        seat = table.getRelativeFromAbsolute(seat);
        _players.forEach(setTurn);

        function setTurn (p :PlayerSprite, index :int, array :Array) :void
        {
            p.setTurn(index == seat);
        }
    }

    protected function positionChild (child :DisplayObject, pos :Vector2) :void
    {
        child.x = pos.x;
        child.y = pos.y;
    }

    /** Position all the children. */
    protected function layout () :void
    {
        positionChild(_hand, HAND_POSITION);
        positionChild(_trick, TRICK_POSITION);
        positionChild(_teams[0] as TeamSprite, LEFT_TEAM_POSITION);
        positionChild(_teams[1] as TeamSprite, RIGHT_TEAM_POSITION);
        positionChild(_bid, SLIDER_POSITION);
        _players.forEach(positionPlayer);

        function positionPlayer (p :PlayerSprite, seat :int, a :Array) :void {
            positionChild(p, PLAYER_POSITIONS[seat] as Vector2);
        }
    }

    protected function trickListener (event :TrickEvent) :void
    {
        if (event.type == TrickEvent.COMPLETED) {
            var trick :Trick = event.target as Trick;
            var teamIdx :int = table.getTeamFromId(event.player).index;
            TeamSprite(_teams[teamIdx]).takeTrick(_trick.orphanCards());
            TeamSprite(_teams[(teamIdx + 1) % 2]).clearLastTrick();
        }
    }

    protected function removedListener (event :Event) :void
    {
        if (event.target == this) {
            removeChild(_trick);
            removeChild(_hand);
            removeChild(_teams[0] as TeamSprite);
            removeChild(_teams[1] as TeamSprite);
        }
    }

    protected function getPlayer (seat :int) :PlayerSprite
    {
        return _players[seat] as PlayerSprite;
    }

    protected function get table () :Table
    {
        return _model.table;
    }

    protected var _model :Model;
    protected var _players :Array;
    protected var _bid :BidSprite;
    protected var _hand :HandSprite;
    protected var _trick :MainTrickSprite;
    protected var _teams :Array = [null, null];
}

}
