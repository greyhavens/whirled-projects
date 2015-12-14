// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.accessibility {
	import flash.events.Event;
	import flash.accessibility.Accessibility;
	import fl.events.DataGridEvent;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.SelectableList;
	import fl.controls.DataGrid;
	import fl.core.UIComponent;

	/**
	 *  The DataGridAccImpl class, also called the DataGrid Accessibility Implementation class,
     *  is used to make a DataGrid component accessible.
	 * 
	 * <p>The DataGridAccImpl class supports system roles, object-based events, and states.</p>
	 * 
	 * <p>A DataGrid reports the role <code>ROLE_SYSTEM_LIST</code> (0x21) to a screen 
	 * reader. Items of a DataGrid report the role <code>ROLE_SYSTEM_LISTITEM</code> (0x22).</p>
     *
	 * <p>A DataGrid reports the following states to a screen reader:</p>
	 * <ul>
     *     <li><code>STATE_SYSTEM_NORMAL</code> (0x00000000)</li>
     *     <li><code>STATE_SYSTEM_UNAVAILABLE</code> (0x00000001)</li>
     *     <li><code>STATE_SYSTEM_FOCUSED</code> (0x00000004)</li>
     *     <li><code>STATE_SYSTEM_FOCUSABLE</code> (0x00100000)</li>
	 * </ul>
	 * 
	 * <p>Additionally, items of a DataGrid report the following states:</p>
	 * <ul>
     *     <li><code>STATE_SYSTEM_SELECTED</code> (0x00000002)</li>
     *     <li><code>STATE_SYSTEM_FOCUSED</code> (0x00000004)</li>
     *     <li><code>STATE_SYSTEM_INVISIBLE</code> (0x00008000)</li>
     *     <li><code>STATE_SYSTEM_OFFSCREEN</code> (0x00010000)</li>
     *     <li><code>STATE_SYSTEM_SELECTABLE</code> (0x00200000)</li>
	 * </ul>
     *
	 * <p>A DataGrid dispatches the following events to a screen reader:</p>
	 * <ul>
     *     <li><code>EVENT_OBJECT_FOCUS</code> (0x8005)</li>
     *     <li><code>EVENT_OBJECT_SELECTION</code> (0x8006)</li>
     *     <li><code>EVENT_OBJECT_STATECHANGE</code> (0x800A)</li>
     *     <li><code>EVENT_OBJECT_NAMECHANGE</code> (0x800C)</li>
	 * </ul>
     *
     * @see fl.controls.DataGrid DataGrid
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class DataGridAccImpl extends SelectableListAccImpl {
		/**
		 *  @private
         *  Static variable triggering the <code>hookAccessibility()</code> method.
		 *  This is used for initializing DataGridAccImpl class to hook its
         *  <code>createAccessibilityImplementation()</code> method to DataGrid class 
         *  before it gets called from UIComponent.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static var accessibilityHooked:Boolean = hookAccessibility();
		
		/**
		 *  @private
         *  Static method for swapping the <code>createAccessibilityImplementation()</code>
         *  method of DataGrid with the DataGridAccImpl class.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static function hookAccessibility():Boolean {
			DataGrid.createAccessibilityImplementation = createAccessibilityImplementation;
			return true;
		}

		//--------------------------------------------------------------------------
		//  Class constants
		//--------------------------------------------------------------------------

		/**
		 *  @private
         *  Role of listItem.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static const ROLE_SYSTEM_LISTITEM:uint = 0x22; 
		
		/**
         *  @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static const STATE_SYSTEM_FOCUSED:uint = 0x00000004;
		
		/**
         *  @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static const STATE_SYSTEM_INVISIBLE:uint = 0x00008000;
		
		/**
         *  @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static const STATE_SYSTEM_OFFSCREEN:uint = 0x00010000;
		
		/**
         *  @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static const STATE_SYSTEM_SELECTABLE:uint = 0x00200000;
		
		/**
         *  @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static const STATE_SYSTEM_SELECTED:uint = 0x00000002;
		
		/**
		 *  @private
         *  Event emitted if 1 item is selected.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static const EVENT_OBJECT_FOCUS:uint = 0x8005; 
		
		/**
		 *  @private
         *  Event emitted if 1 item is selected.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static const EVENT_OBJECT_SELECTION:uint = 0x8006; 
		
		//--------------------------------------------------------------------------
		//  Class methods
		//--------------------------------------------------------------------------

		/**
		 *  @private
		 *  Method for creating the Accessibility class.
		 *  This method is called from UIComponent.
		 * 
		 *  @param component The UIComponent instance that this AccImpl instance
         *  is making accessible.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function createAccessibilityImplementation(component:UIComponent):void {
			component.accessibilityImplementation = new DataGridAccImpl(component);
		}

		/**
		 *  Enables accessibility for a DataGrid component. 
		 *  This method is required for the compiler to activate
         *  the accessibility classes for a component.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function enableAccessibility():void {
		}

		//--------------------------------------------------------------------------
		//  Constructor
		//--------------------------------------------------------------------------

        /**
         * @private
         * @internal Nivesh says: I don't think we should document the constructors 
         *           for the accessibility classes.  End-users just have to call the 
         *           static enableAccessibility method.  They don't really create an 
         *           instance of the classes.
         *
		 *  Creates a new List Accessibility Implementation.
		 *
		 *  @param master The UIComponent instance that this AccImpl instance
         *  is making accessible.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function DataGridAccImpl(master:UIComponent) {
			super(master);
		}

		//--------------------------------------------------------------------------
		//  Overridden properties: AccImpl
		//--------------------------------------------------------------------------

		/**
		 *  @private
         *  Array of events that we should listen for from the master component.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function get eventsToHandle():Array {
			return super.eventsToHandle.concat([ DataGridEvent.ITEM_FOCUS_IN ]);
		}
		
		//--------------------------------------------------------------------------
		//  Overridden methods: AccessibilityImplementation
		//--------------------------------------------------------------------------

		/**
		 *  @private
		 *  Gets the role for the component.
		 *
         *  @param childID Children of the component
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get_accRole(childID:uint):uint {
			if (childID == 0) {
				return role;
			}
			return ROLE_SYSTEM_LISTITEM;
		}

		/**
		 *  @private
		 *  IAccessible method for returning the value of the ListItem/DataGrid
		 *  which is spoken out by the screen reader
		 *  The DataGrid should return the name of the currently selected item
		 *  with m of n string as value when focus moves to DataGrid.
		 *
		 *  @param childID
		 *
         *  @return Name
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get_accValue(childID:uint):String {
			var accValue:String;
			var dataGrid:DataGrid = DataGrid(master);
			if (childID == 0) {
				var row:int;
				var item:Object;
				var columns:Array;
				var n:int;
				var i:int;
				if (!dataGrid.editable) {
					row = dataGrid.selectedIndex;
					if (row > -1) {
						item = getItemAt(row);
						if (item is String) {
							accValue = "Row " + (row + 1) + " of " + dataGrid.dataProvider.length + " " + item;
						} else {
							accValue = "Row " + (row + 1)  + " of " + dataGrid.dataProvider.length;
							columns = dataGrid.columns;
							n = columns.length;
							for (i = 0; i < n; i++) {
								accValue += " " + columns[i].headerText + " " + columns[i].itemToLabel(item);
							}
						}
					}
				} else {
					var coord:Object = dataGrid.editedItemPosition;
					if (coord) {
						row = coord.rowIndex;
						var col:int = coord.columnIndex;
						item = getItemAt(row);
						if (item is String) {
							accValue = "Row " + (row + 1) + " of " + dataGrid.dataProvider.length + " " + item;
						} else {
							columns = dataGrid.columns;
							var itemName:String = columns[col].itemToLabel(item);
							var headerText:String = columns[col].headerText;
							accValue = "Row " + (row + 1) + " of " + dataGrid.dataProvider.length;
							n = columns.length;
							for (i = 0; i < n; i++) {
								accValue += " " + columns[i].headerText + " " + columns[i].itemToLabel(item);
							}
							accValue += ", Editing " + headerText + " " + itemName;
						}
					}
				}
			}
			return accValue;
		}

		/**
		 *  @private
		 *  IAccessible method for returning the state of the grid item.
		 *  States are predefined for all the components in MSAA.
		 *  Values are assigned to each state.
		 *  Depending upon the GridItem being Selected, Selectable, Invisible,
		 *  Offscreen, a value is returned.
		 *
		 *  @param childID uint
		 *
         *  @return State uint
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get_accState(childID:uint):uint {
			var dataGrid:DataGrid = DataGrid(master);
			var accState:uint = getState(childID);
			var row:int;
			var col:int;
			if (childID > 0) {
				var index:int = childID - 1;
				if (!dataGrid.editable) {
					row = index;
					if (row < dataGrid.verticalScrollPosition || row >= dataGrid.verticalScrollPosition + dataGrid.rowCount) {
						accState |= (STATE_SYSTEM_OFFSCREEN | STATE_SYSTEM_INVISIBLE);
					} else {
						accState |= STATE_SYSTEM_SELECTABLE;
						var item:Object = dataGrid.getItemAt(row);
						var selItems:Array = dataGrid.selectedIndices;
						for(var i:int = 0; i < selItems.length; i++) {
							if(selItems[i] == row) {
								accState |= STATE_SYSTEM_SELECTED | STATE_SYSTEM_FOCUSED;
								break;
							}
						}
					}
				} else {
					row = Math.floor(index / dataGrid.columns.length);
					col = index % dataGrid.columns.length;
					if (row < dataGrid.verticalScrollPosition || row >= dataGrid.verticalScrollPosition + dataGrid.rowCount) {
						accState |= (STATE_SYSTEM_OFFSCREEN | STATE_SYSTEM_INVISIBLE);
					} else if (dataGrid.columns[col].editable) {
						accState |= STATE_SYSTEM_SELECTABLE;
						var coord:Object = dataGrid.editedItemPosition;
						if (coord && coord.rowIndex == row && coord.columnIndex == col) {
							accState |= STATE_SYSTEM_SELECTED | STATE_SYSTEM_FOCUSED;
						}
					}
				}
			}
			return accState;
		}

		/**
		 *  @private
		 *  IAccessible method for executing the Default Action.
		 *
         *  @param childID uint
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function accDoDefaultAction(childID:uint):void {
			var dataGrid:DataGrid = DataGrid(master);
			if (childID > 0) {
				// Assuming childID is always ItemID + 1
				// because getChildIDArray may not always be invoked.
				var index:int = childID - 1;
				// index is the (0 based) index of the elements after the headers
				if (!dataGrid.editable) {
					// index is the row id
					dataGrid.selectedIndex = index;
				} else {
					var row:int = Math.floor(index / dataGrid.columns.length);
					var col:int = index % dataGrid.columns.length;
					dataGrid.editedItemPosition = { rowIndex: row, columnIndex: col };
				}
			}
		}

		/**
		 *  @private
		 *  Method to return an array of childIDs.
		 *
         *  @return Array
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function getChildIDArray():Array {
			var childIDs:Array = [];
			var dataGrid:DataGrid = DataGrid(master);
			if (dataGrid.dataProvider) {
				// 0 is DataGrid, 1 to columnCount * Rows -> ItemRenderers
				var n:int = 0;
				if (!dataGrid.editable) {
					// non editable case (itemRenderers)
					n = dataGrid.dataProvider.length;
				} else {
					// editable case (rows)
					n = dataGrid.columns.length * dataGrid.dataProvider.length;
				}
				for (var i:int = 0; i < n; i++) {
					childIDs[i] = i + 1;
				}
			}
			return childIDs;
		}

		/**
		 *  @private
		 *  IAccessible method for returning the bounding box of the GridItem.
		 *
		 *  @param childID uint
		 *
         *  @return Location Object
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function accLocation(childID:uint):* {
			var dataGrid:DataGrid = DataGrid(master);
			if(childID > 0) {
				var index:int = childID - 1;
				var row:int;
				var col:int;
				var item:Object;
				if (!dataGrid.editable) {
					row = index
					if (row < dataGrid.verticalScrollPosition || row >= dataGrid.verticalScrollPosition + dataGrid.rowCount) {
						return null;
					}
					item = dataGrid.getItemAt(row);
					return dataGrid.itemToCellRenderer(item);
				} else {
					row = Math.floor(index / dataGrid.columns.length);
					col = index % dataGrid.columns.length;
					if (row < dataGrid.verticalScrollPosition || row >= dataGrid.verticalScrollPosition + dataGrid.rowCount) {
						return null;
					}
					item = dataGrid.getItemAt(row);
					return dataGrid.itemToCellRenderer(item);
				}
			}
			return dataGrid;
		}

		/**
		 *  @private
		 *  IAccessible method for returning the childFocus of the DataGrid.
		 *
		 *  @param childID uint
		 *
         *  @return focused childID.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get_accFocus():uint {
			var dataGrid:DataGrid = DataGrid(master);
			if (!dataGrid.editable) {
				var index:uint = dataGrid.selectedIndex;
				return (index >= 0) ? index + 1 : 0;
			} else {
				var coord:Object = dataGrid.editedItemPosition;
				if (!coord) {
					return 0;
				}
				var row:int = coord.rowIndex;
				var col:int = coord.columnIndex;
				return dataGrid.columns.length * row + col + 1;
			}
		}

		//--------------------------------------------------------------------------
		//  Overridden methods: AccImpl
		//--------------------------------------------------------------------------

		/**
		 *  @private
		 *  method for returning the name of the DataGrid/ListItem
		 *  which is spoken out by the screen reader
		 *  The ListItem should return the label as the name with m of n string and
		 *  DataGrid should return the name specified in the AccessibilityProperties.
		 *
		 *  @param childID uint
		 *
         *  @return Name
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function getName(childID:uint):String {
			// 0 -> DataGrid
			if (childID == 0) {
				return "";
			}
			var name:String;
			var dataGrid:DataGrid = DataGrid(master);
			// 1 to columnCount * Rows -> ItemRenderers
			if (childID > 0) {
				// assuming childID is always ItemID + 1
				// because getChildIDArray may not always be invoked.
				var index:int = childID - 1;
				// index is the (0 based) index of the elements after the headers
				var row:int
				var item:Object;
				var columns:Array;
				var n:int;
				var i:int;
				if (!dataGrid.editable) {
					// index is the row id
					row = index;
					item = getItemAt(index);
					if (item is String) {
						name = "Row " + (row + 1) + " of " + dataGrid.dataProvider.length + " " + item;
					} else {
						name = "Row " + (row + 1)  + " of " + dataGrid.dataProvider.length;
						columns = dataGrid.columns;
						n = columns.length;
						for (i = 0; i < n; i++) {
							name += " " + columns[i].headerText + " " + columns[i].itemToLabel(item);
						}
					}
				} else {
					row = Math.floor(index / dataGrid.columns.length);
					var col:int = index % dataGrid.columns.length;
					item = getItemAt(row);
					if (item is String) {
						name = "Row " + (row + 1) + " of " + dataGrid.dataProvider.length + " " + item;
					} else {
						columns = dataGrid.columns;
						var itemName:String = columns[col].itemToLabel(item);
						var headerText:String = columns[col].headerText;
						name = "Row " + (row + 1) + " of " + dataGrid.dataProvider.length;
						n = columns.length;
						for (i = 0; i < columns.length; i++) {
							name += " " + columns[i].headerText + " " + columns[i].itemToLabel(item);
						}
						name += ", Editing " + headerText + " " + itemName;
					}
				}
			}
			return name;
		}

		//--------------------------------------------------------------------------
		//  Overridden event handlers: AccImpl
		//--------------------------------------------------------------------------

		/**
		 *  @private
		 *  Override the generic event handler.
		 *  All AccImpl must implement this to listen
         *  for events from its master component.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function eventHandler(event:Event):void {
			var dataGrid:DataGrid = DataGrid(master);
			switch (event.type) {
				case "change":
					if (Accessibility.active && !dataGrid.editable) {
						var index:int = dataGrid.selectedIndex;
						if (index >= 0) {
							var childID:uint = index + 1;
							Accessibility.sendEvent(dataGrid, childID, EVENT_OBJECT_FOCUS);
							Accessibility.sendEvent(dataGrid, childID, EVENT_OBJECT_SELECTION);
						}
					}
					break;
				case DataGridEvent.ITEM_FOCUS_IN:
					if (Accessibility.active && dataGrid.editable) {
						var item:int = int(DataGridEvent(event).rowIndex);
						var col:int = DataGridEvent(event).columnIndex;
						Accessibility.sendEvent(dataGrid, dataGrid.columns.length * item + col + 1, EVENT_OBJECT_FOCUS);
						Accessibility.sendEvent(dataGrid, dataGrid.columns.length * item + col + 1, EVENT_OBJECT_SELECTION);
					}
					break;
			}
		}

		//--------------------------------------------------------------------------
		//  Methods
		//--------------------------------------------------------------------------

		/**
         *  @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private function getItemAt(index:int):Object {
			var dataGrid:DataGrid = DataGrid(master);
			return dataGrid.getItemAt(index);
		}

	}
}
