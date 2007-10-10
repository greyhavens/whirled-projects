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
        this.y = 350;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var count :uint = _board.getPlayerCount();
        var names :Array = _board.getPlayerNames();
        var scores :Array = _board.getPlayerScores();
        
        _title = new Text();
        _title.htmlText = Messages.get("GAME ENDED SCORES:") + "<br><br>";
        addChild(_title);

        for (var ii :int = 0; ii < count; ii++) {
            _title.htmlText += names[ii] + ": " + scores[ii] + "<br>";
        }       

        var buttons :HBox = new HBox();
        addChild(buttons);
        
        var replay :Button = new Button();
        replay.width = 150;
        replay.label = Messages.get("TEMP PLAY AGAIN");
        replay.addEventListener(MouseEvent.CLICK,
                                function (event :MouseEvent) :void { _playFn(); });
        buttons.addChild(replay);

        var quit :Button = new Button();
        quit.width = 150;
        quit.label = Messages.get("TEMP QUIT");
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
