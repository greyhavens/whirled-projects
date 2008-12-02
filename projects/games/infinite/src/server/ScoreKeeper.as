package server
{
	import com.whirled.game.GameSubControl;
	
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * Simple scorekeeper.
	 * 
	 * - Finishing a level first gets 3 points.
	 * - Finishing a level within 10 seconds of the first player gets 2 points.
	 * - Finishing a level ordinarily gets 1 point. 
	 */
	public class ScoreKeeper
	{
		public function ScoreKeeper(control:GameSubControl)
		{
			_control = control;
			_target = 5;
		}

        public function levelComplete (id:int, level:int) :void
        {
        	var status:int = _levels[level];
        	if (status == INCOMPLETE) {
        		_levels[level] = RECENTLY_COMPLETE;
        		startTimeout(level);
        		addPoints(id, 3);
        	} else if (status == RECENTLY_COMPLETE) {
        		addPoints(id, 2);
        	} else {
        		addPoints(id, 1);
        	}
        }
        
        /**
         * Start a timeout for the given level.  During this timeout, players who leave the given
         * level will score 2 points.  Once the timeout is complete players will receive only 1
         * point for completing that level.
         */ 
        protected function startTimeout (level:int) :void
        {        	
        	const timer:Timer = new Timer(EXIT_DELAY, 1);
        	_timers[timer] = level;
        	timer.addEventListener(TimerEvent.TIMER, handleTimeout);
        }
        
        /**
         * Handle the completion of a level timer.  Set the status of the associated level to
         * completed.
         */
        protected function handleTimeout (event:TimerEvent) :void
        {
        	const level:int = _timers[event.target];
        	_levels[level] = COMPLETED;
        }
        
        public function score (id:int) :int 
        {
        	var score:int = _scores[id] as int;
        	return score;
        }
        
        public function addPoints (id:int, points:int) :void
        {
        	if (_scores[id] == null) {
        		_players.push(id);
        	}
        	const added:int = score(id) + points;        
        	_scores[id] = added;
        	
            if (added >= _target) {
            	endGame();
            }
        }
        
        public function endGame() :void
        {
        	const playerIds:Array = new Array();
        	const scores:Array = new Array();
        	
        	for each (var id:int in _players) {
        		playerIds.push(id);
        		scores.push(score(id));
        	}
        	
        	Log.debug(this + " ending game with scores");
        	_control.endGameWithScores(playerIds, scores, GameSubControl.CASCADING_PAYOUT, MODE);
        	reset();
        }
        
        public function reset () :void
        {
        	_players = new Array();
        	_scores = new Dictionary();
        	_timers = new Dictionary();
        }
        
        protected static const EXIT_DELAY:int = 5000;
        
        protected static const INCOMPLETE:int = 0;
        protected static const RECENTLY_COMPLETE:int = 1;
        protected static const COMPLETED:int = 2;
        
        // Mode 0 is used for this simple scoring system.
        protected const MODE:int = 0;
        
        // The score target before we 'end the game' and payout
        protected var _target:int;
        protected var _control:GameSubControl;
        
        // list of players who have scores
        protected var _players:Array = new Array();
        
        // scores 
        protected var _scores:Dictionary = new Dictionary();
        
        // the status of each level
        protected var _levels:Array = new Array();
        
        // to determine the ways 
        protected var _timers:Dictionary = new Dictionary();
	}
}