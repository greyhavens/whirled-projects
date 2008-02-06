﻿package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

import lawsanddisorder.Context;

/**
 * Area containing details on a single player
 */
public class Opponent extends Player
{
    /**
     * Constructor
     * @param id Identifier for this player according to the game context
     */
    public function Opponent (ctx :Context, id :int, serverId :int, name :String)
    {
        addEventListener(MouseEvent.CLICK, ctx.state.opponentClick);
        super(ctx, id, serverId, name);
    }

    /**
     * Opponent jobs are not displayed; override and do not make it a child
     */
    override public function set job (job :Job) :void
    {
        _job = job;
        //_job.player = this;
        updateDisplay();
    }
    
    /**
     * Initialize the static display
     */
    override protected function initDisplay () :void
    {
    	// position hand but do not display it
        _hand.x = -550;
        _hand.y = 0;
        
        // draw the bg
        graphics.clear();
        graphics.beginFill(0x8888FF);
        graphics.drawRect(0, 0, 120, 60);
        graphics.endFill();
        
        title.height = 80;
    }

    /**
     * Update the changing display
     */
    override protected function updateDisplay () :void
    {
        title.text = playerName + "\nJob: " + job + "\nMonies: " + monies + "\nCards: " + hand.numCards;
        
        // draw a border, highlighted or not
        if (_highlighted) {
            graphics.lineStyle(5, 0xFFFF00);
        }
        else {
            graphics.lineStyle(5, 0x8888FF);
        }
        graphics.drawRect(5, 5, 110, 50);
        
        if (job != null) {
	        var symbol :Sprite = job.getSymbol();
	        symbol.width = symbol.width / 3;
	        symbol.height = symbol.height / 3;
	        symbol.x = 90;
	        symbol.y = 30;
	        var colorTransform :ColorTransform = new ColorTransform();
	        colorTransform.color = 0x000066;
	        symbol.transform.colorTransform = colorTransform;
	        symbol.alpha = 0.15;
	        addChild(symbol);
        }
    }
    
    /** Is this opponent selected? */
    public function get highlighted () :Boolean {
        return _highlighted;
    }
    
    /** Indicate that the opponent is selected */
    public function set highlighted (value :Boolean) :void {
        _highlighted = value;
        updateDisplay();
    }
    
    /** Is the opponent highlighted? */
    private var _highlighted :Boolean = false;
}
}