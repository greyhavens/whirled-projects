package com.threerings.defense.ui {

import flash.events.MouseEvent;

import mx.containers.HBox;
import mx.containers.TitleWindow;
import mx.controls.Button;
import mx.controls.Text;

import com.threerings.defense.Board;
import com.threerings.defense.Controller;
import com.threerings.defense.tuning.Messages;


public class SummaryPanel extends TitleWindow
{
    public function SummaryPanel (board :Board, playFn :Function, quitFn :Function)
    {
        _board = board;
        _playFn = playFn;
        _quitFn = quitFn;
        
        this.showCloseButton = false;
        this.x = 200;
        this.y = 150;
    }

    public function addFlowScore (amount :Number) :void
    {
        var text :String = _title.htmlText;
        text += "<br><br>" + Messages.get("you_won") + amount + " " + Messages.get("flow");
        _title.htmlText = text;
    }
    
    override protected function createChildren () :void
    {
        super.createChildren();

        var count :uint = _board.getPlayerCount();
        var names :Array = _board.getPlayerNames();
        var scores :Array = _board.getPlayerScores();
        
        _title = new Text();
        addChild(_title);

        var text :String = Messages.get("game_ended") + "<br><br>";
        for (var ii :int = 0; ii < count; ii++) {
            text += names[ii] + ": " + scores[ii] + "<br>";
        }       
        _title.htmlText = text;
        
        var buttons :HBox = new HBox();
        addChild(buttons);
        
        var replay :Button = new Button();
        replay.width = 150;
        replay.label = Messages.get("play_again");
        replay.addEventListener(MouseEvent.CLICK,
                                function (event :MouseEvent) :void { _playFn(); });
        buttons.addChild(replay);

        var quit :Button = new Button();
        quit.width = 150;
        quit.label = Messages.get("quit");
        quit.addEventListener(MouseEvent.CLICK,
                              function (event :MouseEvent) :void { _quitFn(); });
        buttons.addChild(quit);
    }

    protected var _board :Board;
    protected var _playFn :Function;
    protected var _quitFn :Function;
    protected var _title :Text;
}
}
