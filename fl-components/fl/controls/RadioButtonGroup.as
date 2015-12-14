// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {
	
	import fl.controls.RadioButton;
	import flash.utils.Dictionary;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	
    //--------------------------------------
    //  Events
    //--------------------------------------	
	/**
	 * Dispatched when the selected RadioButton instance in a group changes.
     *
     * @includeExample examples/RadioButtonGroup.change.1.as -noswf
     * @eventType flash.events.Event.CHANGE
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * Dispatched when a RadioButton instance is clicked.
     *
     * @eventType flash.events.MouseEvent.CLICK
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="click", type="flash.events.MouseEvent")]


    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The RadioButtonGroup class defines a group of RadioButton components 
	 * to act as a single component. When one radio button is selected, no other
	 * radio buttons from the same group can be selected.
	 *
     * @see RadioButton
     * @see RadioButton#group RadioButton.group
     *
     * @includeExample examples/RadioButtonGroupExample.as
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class RadioButtonGroup extends EventDispatcher {
		
        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var groups:Object;


        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var groupCount:uint = 0;

		/**
		 * Retrieves a reference to the specified radio button group.
		 *
		 * @param name The name of the group for which to retrieve a reference.
		 *
         * @return A reference to the specified RadioButtonGroup.
         *
		 * @includeExample examples/RadioButtonGroup.getGroup.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function getGroup(name:String):RadioButtonGroup {
			if (groups == null) { groups = {}; }
			var group:RadioButtonGroup = groups[name] as RadioButtonGroup;
			if (group == null) {
				group = new RadioButtonGroup(name);
				// every so often, we should clean up old groups:
				if ((++groupCount)%20 == 0) {
					cleanUpGroups();
				}
			}
			return group;
		}

        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static function registerGroup(group:RadioButtonGroup):void {
			if(groups == null){groups = {}}
			groups[group.name] = group;
		}

        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static function cleanUpGroups():void {
			for (var n:String in groups) {
				var group:RadioButtonGroup = groups[n] as RadioButtonGroup;
				if (group.radioButtons.length == 0) {
					delete(groups[n]);
				}
			}
		}
		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var _name:String;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var radioButtons:Array;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var _selection:RadioButton;

		// Should be a private constructor, but not allowed in AS3, 
		// so instead we'll make it work properly if you create a new 
		// RadioButtonGroup manually.
		/**
		 * Creates a new RadioButtonGroup instance.  
		 * This is usually done automatically when a radio button is instantiated.
		 * 
         * @param name The name of the radio button group.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function RadioButtonGroup(name:String) {
			_name = name;
			radioButtons = [];
			registerGroup(this);
		}

		/**
		 * Gets the instance name of the radio button.
         *
         * @default "RadioButtonGroup"
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get name():String {
			return _name;
		}

		/**
		 * Adds a radio button to the internal radio button array for use with 
		 * radio button group indexing, which allows for the selection of a single radio button
		 * in a group of radio buttons.  This method is used automatically by radio buttons, 
		 * but can also be manually used to explicitly add a radio button to a group.
		 *
         * @param radioButton The RadioButton instance to be added to the current radio button group.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function addRadioButton(radioButton:RadioButton):void {
			if (radioButton.groupName != name) {
				radioButton.groupName = name;
				return;
			}
			radioButtons.push(radioButton);
			if (radioButton.selected) { selection = radioButton; }
		}

		/**
		 * Clears the RadioButton instance from the internal list of radio buttons.
		 *
         * @param radioButton The RadioButton instance to remove.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function removeRadioButton(radioButton:RadioButton):void {
			var i:int = getRadioButtonIndex(radioButton);
			if (i != -1) {
				radioButtons.splice(i, 1);
			}
			if (_selection == radioButton) { _selection = null; }
		}
		
		/**
		 * Gets or sets a reference to the radio button that is currently selected 
         * from the radio button group.
         *
         * @includeExample examples/RadioButtonGroup.selection.1.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get selection():RadioButton {
			return _selection;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set selection(value:RadioButton):void {
			if (_selection == value || value == null || getRadioButtonIndex(value) == -1) { return; }
			_selection = value;
			dispatchEvent(new Event(Event.CHANGE, true));
		}
		
		/**
         * Gets or sets the selected radio button's <code>value</code> property.
         * If no radio button is currently selected, this property is <code>null</code>.
         *
         * @includeExample examples/RadioButtonGroup.selectedData.1.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get selectedData():Object {
			var s:RadioButton = _selection;
			return (s==null) ? null : s.value;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set selectedData(value:Object):void {
			for (var i:int = 0; i < radioButtons.length; i++) {
				var rb:RadioButton = radioButtons[i] as RadioButton;
				if (rb.value == value) {
					selection = rb;
					return;
				}
			}
		}
		

		/**
		 * Returns the index of the specified RadioButton instance.
		 *
		 * @param radioButton The RadioButton instance to locate in the current RadioButtonGroup.
		 *
         * @return The index of the specified RadioButton component, or -1 if the specified RadioButton was not found.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function getRadioButtonIndex(radioButton:RadioButton):int {
			for (var i:int = 0; i < radioButtons.length; i++) {
				var rb:RadioButton = radioButtons[i] as RadioButton;
				if(rb == radioButton) {
					return i;
				}
			}
			return -1;
		}

		/**
		 * Retrieves the RadioButton component at the specified index location.
		 *
         * @param index The index of the RadioButton component in the RadioButtonGroup component, 
         *        where the index of the first component is 0. 
		 *
         * @return The specified RadioButton component.
		 *
         * @throws RangeError The specified index is less than 0 or greater than or equal to the length of the data provider.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function getRadioButtonAt(index:int):RadioButton {
			return RadioButton(radioButtons[index]);
		}

		/**
		 * Gets the number of radio buttons in this radio button group.
         *
         * @default 0
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get numRadioButtons():int {
			return radioButtons.length;
		}
	}
}
