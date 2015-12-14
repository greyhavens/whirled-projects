// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {
	
	import fl.data.DataProvider;
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ListData;
	import fl.controls.ScrollPolicy;
	import fl.controls.SelectableList;
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import fl.events.DataChangeType;
	import fl.events.DataChangeEvent;
	import fl.events.ListEvent;
	import fl.events.ScrollEvent;
	import fl.managers.IFocusManagerComponent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;		
	import flash.geom.Rectangle;
	
	/**
	 * The List component displays list-based information and is ideally suited 
	 * for the display of arrays of information.  
	 *
	 * <p>The List component consists of items, rows, and a data provider, which are 
	 * described as follows:</p>
	 * <ul>
	 * <li>Item: An ActionScript object that usually contains a descriptive <code>label</code> 
	 *           property and a <code>data</code> property that stores the data associated with that item. </li>
	 * <li>Row: A component that is used to display the item. </li>
	 * <li>Data provider: A component that models the items that the List component displays.</li>
	 * </ul>
	 *
	 * <p>By default, the List component uses the CellRenderer class to supply the rows in 
	 * which list items are displayed. You can create these rows programmatically; this 
	 * is usually done by subclassing the CellRenderer class. The CellRenderer class 
	 * implements the ICellRenderer interface, which provides the set of properties and 
	 * methods that the List component uses to manipulate its rows and to send data and state information 
	 * to each row for display. This includes information about data sizing and selection.</p>
	 *
	 * <p>The List component provides methods that act on its data provider--for example, the
	 * <code>addItem()</code> and <code>removeItem()</code> methods. You can use these and 
	 * other methods to manipulate the data of any array that exists in the same frame as 
	 * a List component and then broadcast the changes to multiple views. If a List component 
	 * is not provided with an external data provider, these methods automatically create an 
	 * instance of a data provider and expose it through the <code>List.dataProvider</code> 
	 * property. The List component renders each row by using a Sprite that implements the 
	 * ICellRenderer interface. To specify this renderer, use the <code>List.cellRenderer</code> 
	 * property. You can also build an Array instance or get one from a server and use it as a 
	 * data model for multiple lists, combo boxes, data grids, and so on. </p> 
	 *
     * @includeExample examples/ListExample.as
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class List extends SelectableList implements IFocusManagerComponent{

		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _rowHeight:Number = 20;
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _cellRenderer:Object;
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _labelField:String="label";
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _labelFunction:Function;
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _iconField:String = "icon";
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _iconFunction:Function;
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var defaultStyles:Object = {
													focusRectSkin:null,
													focusRectPadding:null
													};
        /**
         * @copy fl.core.UIComponent#getStyleDefinition()
         *
		 * @includeExample ../core/examples/UIComponent.getStyleDefinition.1.as -noswf
		 *
         * @see fl.core.UIComponent#getStyle()
         * @see fl.core.UIComponent#setStyle()
         * @see fl.managers.StyleManager
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public static function getStyleDefinition():Object { 
			return mergeStyles(defaultStyles, SelectableList.getStyleDefinition());
		}
		/**
		 *  @private
		 *  Method for creating the Accessibility class.
         *  This method is called from UIComponent.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static var createAccessibilityImplementation:Function;
		

		/**
         * Creates a new List component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function List() {
			super();
		}
		
		/**
         * Gets or sets the name of the field in the <code>dataProvider</code> object 
         * to be displayed as the label for the TextInput field and drop-down list. 
		 *
         * <p>By default, the component displays the <code>label</code> property 
		 * of each <code>dataProvider</code> item. If the <code>dataProvider</code> 
		 * items do not contain a <code>label</code> property, you can set the 
		 * <code>labelField</code> property to use a different property.</p>
         *
         * <p><strong>Note:</strong> The <code>labelField</code> property is not used 
         * if the <code>labelFunction</code> property is set to a callback function.</p>
         * 
         * @default "label"
         *
         * @see #labelFunction 
         *
		 * @includeExample examples/List.labelField.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get labelField():String {
			return _labelField;
		}
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set labelField(value:String):void {
			if (value == _labelField) { return; }
			_labelField = value;
			invalidate(InvalidationType.DATA);
		}

        /**
         * Gets or sets the function to be used to obtain the label for the item.
		 *
         * <p>By default, the component displays the <code>label</code> property
		 * for a <code>dataProvider</code> item. But some data sets may not have 
		 * a <code>label</code> field or may not have a field whose value
		 * can be used as a label without modification. For example, a given data 
		 * set might store full names but maintain them in <code>lastName</code> and  
		 * <code>firstName</code> fields. In such a case, this property could be
		 * used to set a callback function that concatenates the values of the 
		 * <code>lastName</code> and <code>firstName</code> fields into a full 
		 * name string to be displayed.</p>
		 *
         * <p><strong>Note:</strong> The <code>labelField</code> property is not used 
         * if the <code>labelFunction</code> property is set to a callback function.</p>
         *
         * @default null
         *
		 * @includeExample examples/List.labelFunction.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get labelFunction():Function {
			return _labelFunction;
		}
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set labelFunction(value:Function):void {
			if (_labelFunction == value) { return; }
			_labelFunction = value;
			invalidate(InvalidationType.DATA);
		}
		
		/**
         * Gets or sets the item field that provides the icon for the item.
         *
         * <p><strong>Note:</strong> The <code>iconField</code> is not used 
         * if the <code>iconFunction</code> property is set to a callback function.</p>
         *
         * @default "icon"
         *
		 * @includeExample examples/List.iconField.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get iconField():String {
			return _iconField;
		}
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set iconField(value:String):void {
			if (value == _iconField) { return; }
			_iconField = value;
			invalidate(InvalidationType.DATA);
		}
		
		/**
		 * Gets or sets the function to be used to obtain the icon for the item.
         *
         * <p><strong>Note:</strong> The <code>iconField</code> is not used 
         * if the <code>iconFunction</code> property is set to a callback function.</p>
         *
         * @default null
         *
		 * @includeExample examples/List.iconFunction.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get iconFunction():Function {
			return _iconFunction;
		}
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set iconFunction(value:Function):void {
			if (_iconFunction == value) { return; }
			_iconFunction = value;
			invalidate(InvalidationType.DATA);
		}
		/**
		 * Gets or sets the number of rows that are at least partially visible in the 
         * list.
         *
         * @includeExample examples/SelectableList.rowCount.1.as -noswf
         * @includeExample examples/List.rowCount.2.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get rowCount():uint {
			//This is low right now (ie. doesn't count two half items as a whole):
			return Math.ceil(calculateAvailableHeight()/rowHeight);
		}
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set rowCount(value:uint):void {
			var pad:Number = Number(getStyleValue("contentPadding"));
			var scrollBarHeight:Number = (_horizontalScrollPolicy == ScrollPolicy.ON || (_horizontalScrollPolicy == ScrollPolicy.AUTO && _maxHorizontalScrollPosition > 0)) ? 15 : 0;
			height = rowHeight*value+2*pad+scrollBarHeight;
		}
		
		/**
		 * Gets or sets the height of each row in the list, in pixels.
         *
         * @default 20
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get rowHeight():Number {
			return _rowHeight;
		}
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set rowHeight(value:Number):void {
			_rowHeight = value;
			invalidate(InvalidationType.SIZE);
		}
		
		/**
         * @copy fl.controls.SelectableList#scrollToIndex()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function scrollToIndex(newCaretIndex:int):void {
			drawNow();
			
			var lastVisibleItemIndex:uint = Math.floor((_verticalScrollPosition + availableHeight) / rowHeight) - 1;
			var firstVisibleItemIndex:uint = Math.ceil(_verticalScrollPosition / rowHeight);
			if(newCaretIndex < firstVisibleItemIndex) {
				verticalScrollPosition = newCaretIndex * rowHeight;
			} else if(newCaretIndex > lastVisibleItemIndex) {
				verticalScrollPosition = (newCaretIndex + 1) * rowHeight - availableHeight;
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function configUI():void {
			useFixedHorizontalScrolling = true;
			_horizontalScrollPolicy = ScrollPolicy.AUTO;
			_verticalScrollPolicy = ScrollPolicy.AUTO;
			
			super.configUI();
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function calculateAvailableHeight():Number {
			var pad:Number = Number(getStyleValue("contentPadding"));
			return height-pad*2-((_horizontalScrollPolicy == ScrollPolicy.ON || (_horizontalScrollPolicy == ScrollPolicy.AUTO && _maxHorizontalScrollPosition > 0)) ? 15 : 0);
		}
		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function setHorizontalScrollPosition(value:Number,fireEvent:Boolean=false):void {
			list.x = -value;
			super.setHorizontalScrollPosition(value, true);
		}
		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function setVerticalScrollPosition(scroll:Number,fireEvent:Boolean=false):void {
			// This causes problems. It seems like the render event can get "blocked" if it's called from within a callLater
			invalidate(InvalidationType.SCROLL);
			super.setVerticalScrollPosition(scroll, true);
		}
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {
			var contentHeightChanged:Boolean = (contentHeight != rowHeight*length);
			contentHeight = rowHeight*length;
			
			if (isInvalid(InvalidationType.STYLES)) {
				setStyles();
				drawBackground();
				// drawLayout is expensive, so only do it if padding has changed:
				if (contentPadding != getStyleValue("contentPadding")) {
					invalidate(InvalidationType.SIZE,false);
				}
				// redrawing all the cell renderers is even more expensive, so we really only want to do it if necessary:
				if (_cellRenderer != getStyleValue("cellRenderer")) {
					// remove all the existing renderers:
					_invalidateList();
					_cellRenderer = getStyleValue("cellRenderer");
				}
			}
			if (isInvalid(InvalidationType.SIZE, InvalidationType.STATE) || contentHeightChanged) {
				drawLayout();
			}
			
			if (isInvalid(InvalidationType.RENDERER_STYLES)) {
				updateRendererStyles();	
			}
			
			if (isInvalid(InvalidationType.STYLES,InvalidationType.SIZE,InvalidationType.DATA,InvalidationType.SCROLL,InvalidationType.SELECTED)) {
				drawList();
			}
			
			// Call drawNow on nested components to get around problems with nested render events:
			updateChildren();
			
			// Not calling super.draw, because we're handling everything here. Instead we'll just call validate();
			validate();
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function drawList():void {
			// List is very environmentally friendly, it reuses existing 
			// renderers for old data, and recycles old renderers for new data.

			// set horizontal scroll:
			listHolder.x = listHolder.y = contentPadding;
			
			var rect:Rectangle = listHolder.scrollRect;
			rect.x = _horizontalScrollPosition;
			
			// set pixel scroll:
			rect.y = Math.floor(_verticalScrollPosition)%rowHeight;
			listHolder.scrollRect = rect;
			
			listHolder.cacheAsBitmap = useBitmapScrolling;
			
			// figure out what we have to render:
			var startIndex:uint = Math.floor(_verticalScrollPosition/rowHeight);
			var endIndex:uint = Math.min(length,startIndex + rowCount+1);
			
			
			// these vars get reused in different loops:
			var i:uint;
			var item:Object;
			var renderer:ICellRenderer;
			
			// create a dictionary for looking up the new "displayed" items:
			var itemHash:Dictionary = renderedItems = new Dictionary(true);
			for (i=startIndex; i<endIndex; i++) {
				itemHash[_dataProvider.getItemAt(i)] = true;
			}
			
			// find cell renderers that are still active, and make those that aren't active available:
			var itemToRendererHash:Dictionary = new Dictionary(true);
			while (activeCellRenderers.length > 0) {
				renderer = activeCellRenderers.pop() as ICellRenderer;
				item = renderer.data;
				if (itemHash[item] == null || invalidItems[item] == true) {
					availableCellRenderers.push(renderer);
				} else {
					itemToRendererHash[item] = renderer;
					// prevent problems with duplicate objects:
					invalidItems[item] = true;
				}
				list.removeChild(renderer as DisplayObject);
			}
			invalidItems = new Dictionary(true);
			
			// draw cell renderers:
			for (i=startIndex; i<endIndex; i++) {
				var reused:Boolean = false;
				item = _dataProvider.getItemAt(i);
				if (itemToRendererHash[item] != null) {
					// existing renderer for this item we can reuse:
					
					reused = true;
					renderer = itemToRendererHash[item];
					delete(itemToRendererHash[item]);
				} else if (availableCellRenderers.length > 0) {
					
					// recycle an old renderer:
					renderer = availableCellRenderers.pop() as ICellRenderer;
				} else {
					
					// out of renderers, create a new one:
					renderer = getDisplayObjectInstance(getStyleValue("cellRenderer")) as ICellRenderer;
					var rendererSprite:Sprite = renderer as Sprite;
					if (rendererSprite != null) {
						rendererSprite.addEventListener(MouseEvent.CLICK,handleCellRendererClick,false,0,true);
						rendererSprite.addEventListener(MouseEvent.ROLL_OVER,handleCellRendererMouseEvent,false,0,true);
						rendererSprite.addEventListener(MouseEvent.ROLL_OUT,handleCellRendererMouseEvent,false,0,true);
						rendererSprite.addEventListener(Event.CHANGE,handleCellRendererChange,false,0,true);
						rendererSprite.doubleClickEnabled = true;
						rendererSprite.addEventListener(MouseEvent.DOUBLE_CLICK,handleCellRendererDoubleClick,false,0,true);
						
						if (rendererSprite["setStyle"] != null) {
							for (var n:String in rendererStyles) {
								rendererSprite["setStyle"](n, rendererStyles[n])
							}
						}
					}
				}
				list.addChild(renderer as Sprite);
				activeCellRenderers.push(renderer);
				
				renderer.y = rowHeight*(i-startIndex);
				renderer.setSize(availableWidth+_maxHorizontalScrollPosition,rowHeight);
				
				var label:String = itemToLabel(item);
				
				var icon:Object = null;
				if (_iconFunction != null) {
					icon = _iconFunction(item);
				} else if (_iconField != null) {
					icon = item[_iconField];
				}
				
				if (!reused) {
					renderer.data = item;
				}
				renderer.listData = new ListData(label,icon,this,i,i,0);
				renderer.selected = (_selectedIndices.indexOf(i) != -1);
				
				// force an immediate draw (because render event will not be called on the renderer):
				if (renderer is UIComponent) {
					(renderer as UIComponent).drawNow();
				}
			}
		}
		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void {
			if (!selectable) { return; }
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.DOWN:
				case Keyboard.END:
				case Keyboard.HOME:
				case Keyboard.PAGE_UP:
				case Keyboard.PAGE_DOWN:
					moveSelectionVertically(event.keyCode, event.shiftKey && _allowMultipleSelection, event.ctrlKey && _allowMultipleSelection);
					break;
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					moveSelectionHorizontally(event.keyCode, event.shiftKey && _allowMultipleSelection, event.ctrlKey && _allowMultipleSelection);
					break;
				case Keyboard.SPACE:
					if(caretIndex == -1) {
						caretIndex = 0;
					}
					doKeySelection(caretIndex, event.shiftKey, event.ctrlKey);
					scrollToSelected();
					break;
				default:
					var nextIndex:int = getNextIndexAtLetter(String.fromCharCode(event.keyCode), selectedIndex);
					if (nextIndex > -1) {
						selectedIndex = nextIndex;
						scrollToSelected();
					}
					break;
			}
			event.stopPropagation();
			
			
			
		}

		/**
         * @private (protected)
		 * Moves the selection in a horizontal direction in response
		 * to the user selecting items using the left-arrow or right-arrow
		 * keys and modifiers such as  the Shift and Ctrl keys.
		 *
		 * <p>Not implemented in List because the default list
		 * is single column and therefore doesn't scroll horizontally.</p>
		 *
		 * @param code The key that was pressed (e.g. Keyboard.LEFT)
         *
		 * @param shiftKey <code>true</code> if the shift key was held down when
		 *        the keyboard key was pressed.
         *
		 * @param ctrlKey <code>true</code> if the ctrl key was held down when
         *        the keyboard key was pressed.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function moveSelectionHorizontally(code:uint, shiftKey:Boolean, ctrlKey:Boolean):void {}
		
		/**
         * @private (protected)
		 * Moves the selection in a vertical direction in response
		 * to the user selecting items using the up-arrow or down-arrow
		 * Keys and modifiers such as the Shift and Ctrl keys.
		 *
		 * @param code The key that was pressed (e.g. Keyboard.DOWN)
         *
		 * @param shiftKey <code>true</code> if the shift key was held down when
		 *        the keyboard key was pressed.
         *
		 * @param ctrlKey <code>true</code> if the ctrl key was held down when
         *        the keyboard key was pressed.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function moveSelectionVertically(code:uint, shiftKey:Boolean, ctrlKey:Boolean):void {
			var pageSize:int = Math.max(Math.floor(calculateAvailableHeight() / rowHeight), 1);
			var newCaretIndex:int = -1;
			var dir:int = 0;
			switch(code) {
				case Keyboard.UP:
					if (caretIndex > 0) {
						newCaretIndex = caretIndex - 1;
					}
					break;
				case Keyboard.DOWN:
					if (caretIndex < length - 1) {
						newCaretIndex = caretIndex + 1;
					}
					break;
				case Keyboard.PAGE_UP:
					if (caretIndex > 0) {
						newCaretIndex = Math.max(caretIndex - pageSize, 0);
					}
					break;
				case Keyboard.PAGE_DOWN:
					if (caretIndex < length - 1) {
						newCaretIndex = Math.min(caretIndex + pageSize, length - 1);
					}
					break;
				case Keyboard.HOME:
					if (caretIndex > 0) {
						newCaretIndex = 0;
					}
					break;
				case Keyboard.END:
					if (caretIndex < length - 1) {
						newCaretIndex = length - 1;
					}
					break;
			}
			if(newCaretIndex >= 0) {
				doKeySelection(newCaretIndex, shiftKey, ctrlKey);
				scrollToSelected();
			}
		}
		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		protected function doKeySelection(newCaretIndex:int, shiftKey:Boolean, ctrlKey:Boolean):void {
			var selChanged:Boolean = false;
			if(shiftKey) {
				var i:int;
				var selIndices:Array = [];
				var startIndex:int = lastCaretIndex;
				var endIndex:int = newCaretIndex;
				if(startIndex == -1) {
					startIndex = caretIndex != -1 ? caretIndex : newCaretIndex;
				}
				if(startIndex > endIndex) {
					endIndex = startIndex;
					startIndex = newCaretIndex;
				}
				for(i = startIndex; i <= endIndex; i++) {
					selIndices.push(i);
				}
				selectedIndices = selIndices;
				caretIndex = newCaretIndex;
				selChanged = true;
			} else {
				selectedIndex = newCaretIndex;
				caretIndex = lastCaretIndex = newCaretIndex;
				selChanged = true;
			}
			if(selChanged) {
				dispatchEvent(new Event(Event.CHANGE));
			}
			invalidate(InvalidationType.DATA);
		}
		
		/**
		 * Retrieves the string that the renderer displays for the given data object 
         * based on the <code>labelField</code> and <code>labelFunction</code> properties.
         *
         * <p><strong>Note:</strong> The <code>labelField</code> is not used  
         * if the <code>labelFunction</code> property is set to a callback function.</p>
		 *
		 * @param item The object to be rendered.
		 *
         * @return The string to be displayed based on the data.
         *
         * @internal <code>var label:String = myList.itemToLabel(data);</code>
         *
		 * @includeExample examples/List.itemToLabel.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function itemToLabel(item:Object):String {
			if (_labelFunction != null) {
				return String(_labelFunction(item));
			} else  {
				return (item[_labelField]!=null) ? String(item[_labelField]) : "";
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function initializeAccessibility():void {
			if (List.createAccessibilityImplementation != null) {
				List.createAccessibilityImplementation(this);
			}
		}
	}
}
