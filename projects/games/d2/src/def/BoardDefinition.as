package def {

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Point;

import mx.utils.ObjectUtil;

import com.threerings.util.EmbeddedSwfLoader;

/**
 * Board definition from an xml settings file, with extra info retrieval, and typesafe variables.
 */
public class BoardDefinition
{
    public var pack :PackDefinition;
    public var swf :EmbeddedSwfLoader;
    
    public var name :String;
    public var background :DisplayObject;
    public var button :DisplayObject;
    
    public var squares :Point;
    public var pixelsize :Point;
    public var topleft :Point;

    public var startingHealth :int;
    public var startingMoney :int;

    public var availableTowers :Array; // of String, i.e. typeName of each tower
    public var enemies :Array; // of WaveDefinition
    public var allies :Array; // of WaveDefinition

    public var computerPath :Endpoints;
    public var player1Path :Endpoints;
    public var player2Path :Endpoints;
    
    public var towers :Array; // of TowerDef
    
    public function BoardDefinition (swf :EmbeddedSwfLoader, pack :PackDefinition, board :XML)
    {
        this.pack = pack;
        this.swf = swf;
        
        this.name = board.@name;

        // resolve display object references
        
        var bgclass :Class = this.swf.getClass(board.@background);
        this.background = (new bgclass()) as DisplayObject;

        var bclass :Class = this.swf.getClass(board.@button);
        this.button = (new bclass()) as DisplayObject;

        // copy over simple properties
        
        this.squares = new Point(int(board.squares.@cols), int(board.squares.@rows));
        this.pixelsize = new Point(int(board.pixelsize.@width), int(board.pixelsize.@height));
        this.topleft = new Point(int(board.topleft.@x), int(board.topleft.@y));

        this.startingHealth = board.@startingHealth;
        this.startingMoney = board.@startingMoney;

        // copy over endpoints

        var makeEndpoints :Function = function (p :XMLList) :Endpoints {
            trace(p);
            return new Endpoints(p.@startx, p.@starty, p.@endx, p.@endy);
        }
        this.computerPath = makeEndpoints(board.endpoints.pc);
        this.player1Path = makeEndpoints(board.endpoints.p1);
        this.player2Path = makeEndpoints(board.endpoints.p2);
        trace(this.computerPath);
        
        // figure out which towers are available

        this.availableTowers = new Array();
        for each (var tower :XML in board.availableTowers.tower) {
                availableTowers.push(tower.@id);
            }
        
        // unpack enemy and ally wave definitions

        this.enemies = new Array();
        for each (var wave :XML in board.singlePlayerEnemyWaves.wave) {
            var elts :Array = new Array();
            for each (var enemy :* in wave.enemy) {
                elts.push(new WaveElementDefinition(enemy.@id, int(enemy.@count)));
            }
            enemies.push(elts);
        }

        this.allies = new Array();
        for each (wave in board.twoPlayerAllies.wave) {
            elts = new Array();
            for each (enemy in wave.enemy) {
                elts.push(new WaveElementDefinition(enemy.@id, int(enemy.@count)));
            }
            allies.push(elts);
        }

    }

    public function get guid () :String
    {
        return pack.name + ": " + name; 
    }
    
    public function toString () :String
    {
        return "[Board guid=" + guid + ", swf=" + swf + "]";
    }
}
}
