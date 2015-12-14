// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {	

	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ImageCell;
	import fl.controls.listClasses.ListData;
	import fl.controls.listClasses.TileListData;
	import fl.controls.ScrollBar;
	import fl.controls.ScrollBarDirection;
	import fl.controls.ScrollPolicy;
	import fl.controls.SelectableList;
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import fl.data.DataProvider;
	import fl.data.TileListCollectionItem;
	import fl.events.DataChangeEvent;
	import fl.events.DataChangeType;
	import fl.events.ListEvent;
	import fl.events.ScrollEvent;
	import fl.managers.IFocusManagerComponent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	//--------------------------------------
    //  Events
    //--------------------------------------
	
	//--------------------------------------
    //  Styles
    //--------------------------------------
    /**
     * The skin to be used as the background of the TileList component.
     *
     * @default TileList_skin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="skin", type="Class")]

    /**
     * The cell renderer to be used to render each item in the TileList component.
     *
     * @default fl.contols.listClasses.ImageCell
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="cellRenderer", type="Class")]
	
	
    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The TileList class provides a grid of rows and columns that is typically used
	 * to format and display images in a "tiled" format. The default cell renderer for
	 * this component is the ImageCell class. An ImageCell cell renderer displays a
	 * thumbnail image and a single-line label. To render a list-based cell in a
	 * TileList component, use the CellRenderer class.
	 *
	 * <p>To modify the padding that separates the cell border from the image, you
	 * can globally set the <code>imagePadding</code> style, or set it on the ImageCell 
	 * class. Like other cell styles, the <code>imagePadding</code> style cannot be
	 * set on the TileList component instance.</p>
     *
     * @see fl.controls.listClasses.CellRenderer
     * @see fl.controls.listClasses.ImageCell
     *
     * @includeExample examples/TileListExample.as
	 *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class TileList extends SelectableList implements IFocusManagerComponent{
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _rowHeight:Number = 50;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _columnWidth:Number = 50;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _scrollDirection:String = ScrollBarDirection.HORIZONTAL;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _scrollPolicy:String = ScrollPolicy.AUTO;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _cellRenderer:Object;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var oldLength:uint = 0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _labelField:String = "label";
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _labelFunction:Function;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _iconField:String = "icon";
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _iconFunction:Function;
		
		/**
		 * @private (protected)
		 */
		protected var _sourceField:String = "source";
		/**
		 * @private (protected)
		 */
		protected var _sourceFunction:Function;
		
		/**
		 * @private (protected)
		 */
		protected var __rowCount:uint = 0;
		/**
		 * @private (protected)
		 */
		protected var __columnCount:uint = 0;
		
		/**
		 * @private
		 */
		private var collectionItemImport:TileListCollectionItem;

        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var defaultStyles:Object = {
			cellRenderer:ImageCell,
			focusRectSkin:null,
			focusRectPadding:null,
			skin:"TileList_skin"
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
			return mergeStyles(defaultStyles, SelectableList.getStyleDefinition(), ScrollBar.getStyleDefinition());
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
		public function TileList() {
			super();
		}

		[Collection(collectionClass="fl.data.DataProvider", collectionItem="fl.data.TileListCollectionItem", identifier="item")]
		/**
         * @copy fl.controls.SelectableList#dataProvider
         *
         * @includeExample examples/TileList.dataProvider.1.as -noswf
         * @includeExample examples/TileList.dataProvider.2.as -noswf
         * @includeExample examples/TileList.dataProvider.3.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get dataProvider():DataProvider {
			return super.dataProvider;	
		}
		/**
		 * @private (setter)
		 */
		override public function set dataProvider(value:DataProvider):void {
			super.dataProvider = value;
		}
		
		/**
         * Gets or sets a field in each item that contains a label for each tile.
         * 
         * <p><strong>Note:</strong> The <code>labelField</code> is not used if 
		 * the <code>labelFunction</code> property is set to a callback function.</p>
		 *
         * @default "label"
         *
         * @includeExample examples/TileList.labelField.1.as -noswf
         *
         * @see #labelFunction
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get labelField():String {
			return _labelField;
		}
		/**
         * @private (setter)
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
		 * Gets a function that indicates the fields of an item that provide the label text for a tile.
         *
         * <p><strong>Note:</strong> The <code>labelField</code> is not used if 
		 * the <code>labelFunction</code> property is set to a callback function.</p>
         *
         * @default null
         *
         * @includeExample examples/TileList.labelFunction.1.as -noswf
         *
         * @see #labelField
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get labelFunction():Function {
			return _labelFunction;
		}

		/**
         * @private (setter)
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
         * <p>Icons can be classes or they can be symbols from the library that have a class name.</p>
         *
         * @default null
         *
         * @includeExample examples/TileList.iconField.1.as -noswf
         *
         * @see #iconFunction
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get iconField():String {
			return _iconField;
		}
		/**
         * @private (setter)
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
         * <p><strong>Note:</strong> The <code>iconField</code> is not used if the 
		 * <code>iconFunction</code> property is set to a callback function.</p>
         *
         * <p>Icons can be classes, or they can be library items that have class names.</p>
         *
         * @default null
         *
         * @includeExample examples/TileList.iconFunction.1.as -noswf
         *
         * @see #iconField
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get iconFunction():Function {
			return _iconFunction;
		}
		/**
         * @private (setter)
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
		 * Gets or sets the item field that provides the source path for a tile.
         *
         * <p><strong>Note:</strong> The <code>sourceField</code> is not used if the 
		 * <code>sourceFunction</code> property is set to a callback function.</p>
		 *
         * @default "source"
         *
         * @includeExample examples/TileList.sourceField.1.as -noswf
         *
         * @see #sourceFunction
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 * 
		 */
		public function get sourceField():String { 
			return _sourceField;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set sourceField(value:String):void {
			_sourceField = value;
			invalidate(InvalidationType.DATA);
		}
		
		/**
         * Gets or sets the function to be used to obtain the source path for a tile.
         *
         * <p><strong>Note:</strong> The <code>sourceField</code> is not used if the 
		 * <code>sourceFunction</code> property is set to a callback function.</p>
         *
         * @default null
         *
         * @includeExample examples/TileList.sourceFunction.1.as -noswf
         *
         * @see #sourceField
         *
         * @internal [peter] Check with Metaliq that this is still accurate.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get sourceFunction():Function {
			return _sourceFunction;	
		}
		/**
		 * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set sourceFunction(value:Function):void {
			_sourceFunction = value;
			invalidate(InvalidationType.DATA);	
		}
		
		
		[Inspectable(defaultValue=0, type="Number")]
		/**
		 * Gets or sets the number of rows that are at least partially visible 
		 * in the list.
		 *
         * <p>Setting the <code>rowCount</code> property changes the height of the 
         * list, but the TileList component does not maintain this value. It 
         * is important to set the <code>rowCount</code> value <em>after</em> setting the  
         * <code>dataProvider</code> and <code>rowHeight</code> values. The only 
         * exception is if the <code>rowCount</code> is set with the Property 
         * inspector; in this case, the property is maintained until the component
		 * is first drawn.</p>
         *
		 * @default 0
         *
         * @includeExample examples/TileList.rowCount.1.as -noswf
         *
         * @see #columnCount
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get rowCount():uint {
			var pad:Number = Number(getStyleValue("contentPadding"));
			var cols:uint = Math.max(1,(_width-2*pad)/_columnWidth<<0);
			var rows:uint = Math.max(1,(_height-2*pad)/_rowHeight<<0);
			if (_scrollDirection == ScrollBarDirection.HORIZONTAL) {
				if (_scrollPolicy == ScrollPolicy.ON || (_scrollPolicy == ScrollPolicy.AUTO && length > cols*rows)) {
					// account for horizontal scrollbar:
					rows = Math.max(1,(_height-2*pad-15)/_rowHeight<<0);
				}
				// else use the default rows value from above.
			} else {
				// we might have a partial row visible:
				rows = Math.max(1,Math.ceil((_height-2*pad)/_rowHeight));
			}
			return rows;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set rowCount(value:uint):void {
			if (value == 0) { return; }
			if (componentInspectorSetting) { 
				__rowCount = value; 
				return;
			}
			__rowCount = 0;
			
			var pad:Number = Number(getStyleValue("contentPadding"));
			var showScroll = (Math.ceil(length/value) > (width/columnWidth)>>0 && _scrollPolicy == ScrollPolicy.AUTO) || _scrollPolicy == ScrollPolicy.ON;
			height = rowHeight * value + 2*pad + ((_scrollDirection == ScrollBarDirection.HORIZONTAL && showScroll) ? ScrollBar.WIDTH : 0);
		}
		
		[Inspectable(defaultValue=50)]
		/**
		 * Gets or sets the height that is applied to each row in the list, in pixels.
         *
		 * @default 50
         *
         * @includeExample examples/TileList.rowHeight.1.as -noswf
         * 
         * @see #columnWidth
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get rowHeight():Number {
			return _rowHeight;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set rowHeight(value:Number):void {
			if (_rowHeight == value) { return; }
			_rowHeight = value;
			invalidate(InvalidationType.SIZE);
		}

		[Inspectable(defaultValue=0, type="Number")]
		/**
		 * Gets or sets the number of columns that are at least partially visible in the 
		 * list. Setting the <code>columnCount</code> property changes the width of the list,
		 * but the TileList component does not maintain this value. It is important to set the 
		 * <code>columnCount</code> value <em>after</em> setting the <code>dataProvider</code>
		 * and <code>rowHeight</code> values. The only exception is if the <code>rowCount</code>
		 * is set with the Property inspector; in this case, the property is maintained until the 
		 * component is first drawn.
         *
		 * @default 0
         *
         * @includeExample examples/TileList.columnCount.1.as -noswf
         *
         * @see #rowCount
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get columnCount():uint {
			var pad:Number = Number(getStyleValue("contentPadding"));
			var cols:uint = Math.max(1,(_width-2*pad)/_columnWidth<<0);
			var rows:uint = Math.max(1,(_height-2*pad)/_rowHeight<<0);
			if (_scrollDirection != ScrollBarDirection.HORIZONTAL) {
				if (_scrollPolicy == ScrollPolicy.ON || (_scrollPolicy == ScrollPolicy.AUTO && length > cols*rows)) {
					// account for vertical scrollbar:
					cols = Math.max(1,(_width-2*pad-15)/_columnWidth<<0);
				}
				// else we just use the default cols value from above.
			} else {
				// we might have a partial column visible:
				cols = Math.max(1,Math.ceil((_width-2*pad)/_columnWidth));
			}
			return cols;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set columnCount(value:uint):void {
			if (value == 0) { return; }
			if (componentInspectorSetting) { 
				__columnCount = value; 
				return;
			}
			__columnCount = 0;
			
			var pad:Number = Number(getStyleValue("contentPadding"));
			var showScroll:Boolean = (Math.ceil(length/value) > (height/rowHeight)>>0 && _scrollPolicy == ScrollPolicy.AUTO) || _scrollPolicy == ScrollPolicy.ON;
			width = columnWidth*value+2*pad+(_scrollDirection == ScrollBarDirection.VERTICAL && showScroll ? 15 : 0);
		}
		
		[Inspectable(defaultValue=50)]
		/**
		 * Gets or sets the width that is applied to a column in the list, in pixels.
         *
		 * @default 50
         *
         * @includeExample examples/TileList.columnWidth.1.as -noswf
         *
         * @see #rowHeight
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get columnWidth():Number {
			return _columnWidth;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set columnWidth(value:Number):void {
			if (_columnWidth == value) { return; }
			_columnWidth = value;
			invalidate(InvalidationType.SIZE);
		}
		
		/**
         * Gets the width of the content area, in pixels. This value is the component width
         * minus the combined width of the <code>contentPadding</code> value and vertical scroll bar, 
		 * if the vertical scroll bar is visible.
         *
         * @includeExample examples/TileList.innerWidth.1.as -noswf
         *
         * @see #innerHeight
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get innerWidth():Number {
			drawNow();
			var contentPadding:Number = getStyleValue("contentPadding") as Number;
			return width - contentPadding*2 - (_verticalScrollBar.visible ? _verticalScrollBar.width : 0);
		}
		
		/**
         * Gets the height of the content area, in pixels. This value is the component height
		 * minus the combined height of the <code>contentPadding</code> value and horizontal
		 * scroll bar height, if the horizontal scroll bar is visible. 
         *
         * @see #innerWidth
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get innerHeight():Number {
			drawNow();
			var contentPadding:Number = getStyleValue("contentPadding") as Number;
			return height - contentPadding*2 - (_horizontalScrollBar.visible ? _horizontalScrollBar.height : 0);
		}
		
		[Inspectable(enumeration="horizontal,vertical", defaultValue="horizontal")]
		/**
         * Gets or sets a value that indicates whether the TileList component scrolls 
		 * horizontally or vertically. A value of <code>ScrollBarDirection.HORIZONTAL</code>
		 * indicates that the TileList component scrolls horizontally; a value of 
		 * <code>ScrollBarDirection.VERTICAL</code> indicates that the TileList component scrolls vertically.
         *
		 * @default ScrollBarDirection.VERTICAL
         *
         * @includeExample examples/TileList.direction.1.as -noswf
		 *
         * @see ScrollBarDirection
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get direction():String {
			return _scrollDirection;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set direction(value:String):void {
			if (_scrollDirection == value) { return; }
			_scrollDirection = value;
			invalidate(InvalidationType.SIZE);
		}
		
		[Inspectable(enumeration="auto,on,off", defaultValue="auto")]
		/**
		 * Gets or sets the scroll policy for the TileList component. This
		 * value is used to specify the scroll policy for the scroll bar that
		 * is set by the <code>direction</code> property.
         *
		 * <p><strong>Note:</strong> The TileList component supports scrolling only in 
		 * one direction. Tiles are adjusted to fit into the viewable area of
		 * the component, so that tiles are hidden in only one direction.</p>
         *
         * <p>The TileList component resizes to fit tiles only when the user 
		 * manually sets the size or when the user sets the <code>rowCount</code> 
		 * or <code>columnCount</code> properties.</p>
		 *
         * <p>When this value is set to <code>ScrollPolicy.AUTO</code>, the 
		 * scroll bar is visible only when the TileList component must scroll 
		 * to show all the items.</p>
         *
		 * @default ScrollPolicy.AUTO
         *
         * @includeExample examples/TileList.scrollPolicy.1.as -noswf
         * 
         * @see #columnCount
         * @see #rowCount
         * @see ScrollPolicy
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get scrollPolicy():String {
			return _scrollPolicy;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set scrollPolicy(value:String):void {
			if (!componentInspectorSetting && _scrollPolicy == value) { return; }
			_scrollPolicy = value;
			if (direction == ScrollBarDirection.HORIZONTAL) {
				_horizontalScrollPolicy = value;
				_verticalScrollPolicy = ScrollPolicy.OFF;
			} else {
				_verticalScrollPolicy = value;
				_horizontalScrollPolicy = ScrollPolicy.OFF;
			}
			invalidate(InvalidationType.SIZE);
		}

		/**
         * @copy fl.controls.SelectableList#scrollToIndex()
         *
         * @includeExample examples/TileList.scrollToIndex.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function scrollToIndex(newCaretIndex:int):void {
			drawNow(); // Force validation.
			
			var totalCols:uint = Math.max(1, (contentWidth/_columnWidth<<0));
			if (_scrollDirection == ScrollBarDirection.VERTICAL) {
				if (rowHeight > availableHeight) {
					return; // nothing: don't scroll if the item is bigger than the viewable area)
				}
				var itemY:Number = (newCaretIndex/totalCols>>0) * rowHeight;
				if (itemY < verticalScrollPosition) {
					verticalScrollPosition = itemY;
				} else if (itemY > verticalScrollPosition + availableHeight - rowHeight) {
					verticalScrollPosition = itemY + rowHeight - availableHeight;
				}
			} else {
				if (columnWidth > availableWidth) {
					return;
				}
				var itemX:Number = newCaretIndex % totalCols * columnWidth;
				if (itemX < horizontalScrollPosition) {
					horizontalScrollPosition = itemX;	
				} else if (itemX > horizontalScrollPosition + availableWidth - columnWidth) {
					horizontalScrollPosition = itemX + columnWidth - availableWidth;
				}
			}
		}
		

		/**
		 * Retrieves the string that the renderer displays for a given data object
         * based on the <code>labelField</code> and <code>labelFunction</code> properties.
		 *
		 * @param item The Object to be rendered.
		 *
         * @return The string to be displayed based on the data.
         *
         * @internal <code>var label:String = myTileList.itemToLabel(data);</code>
         *
         * @see #labelField
         * @see #labelFunction
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function itemToLabel(item:Object):String {
			if (_labelFunction != null) {
				return String(_labelFunction(item));
			} else {
				if (item[_labelField] == null) { return ""; }
				return String(item[_labelField]);
			}
		}


		// Hide these from the Property inspector and from users.
		/**
         * @private (hidden)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get verticalScrollPolicy():String {
			return null;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set verticalScrollPolicy(value:String):void {}

		/**
         * @private (hidden)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get horizontalScrollPolicy():String {
			return null;
		}		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set horizontalScrollPolicy(value:String):void {}

		/**
		 * Gets the maximum horizontal scroll position for the current content, in pixels.
         *
         * @see fl.containers.BaseScrollPane#horizontalScrollPosition
         * @see fl.containers.BaseScrollPane#maxVerticalScrollPosition
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get maxHorizontalScrollPosition():Number {
			drawNow();
			return _maxHorizontalScrollPosition;
		}
		
		/**
		 * @private (setter)
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set maxHorizontalScrollPosition(value:Number):void {}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function configUI():void {
			super.configUI();
			_horizontalScrollPolicy = scrollPolicy;
			_verticalScrollPolicy = ScrollPolicy.OFF;
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function setHorizontalScrollPosition(scroll:Number,fireEvent:Boolean=false):void {
			invalidate(InvalidationType.SCROLL);
			super.setHorizontalScrollPosition(scroll, true);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function setVerticalScrollPosition(scroll:Number,fireEvent:Boolean=false):void {
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
			// We need to draw the row and column count that are set by component parameters on the first draw.
			if (direction == ScrollBarDirection.VERTICAL) {
				if (__rowCount > 0) { rowCount = __rowCount; }
				if (__columnCount > 0) { columnCount = __columnCount; }
			} else {
				if (__columnCount > 0) { columnCount = __columnCount; }
				if (__rowCount > 0) { rowCount = __rowCount; }
			}
			
			var lengthChanged:Boolean = (oldLength != length);
			oldLength = length;

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
			if (isInvalid(InvalidationType.SIZE, InvalidationType.STATE) || lengthChanged) {
				drawLayout();
			}

			// Apply updatedStyles
			if (isInvalid(InvalidationType.RENDERER_STYLES)) {
				updateRendererStyles();
			}
			
			if (isInvalid(InvalidationType.STYLES,InvalidationType.SIZE,InvalidationType.DATA,InvalidationType.SCROLL,InvalidationType.SELECTED)) {
				drawList();
				_maxHorizontalScrollPosition = Math.max(0, contentWidth - availableWidth);
			}
			

			// Call drawNow on nested components to get around problems with nested render events:
			updateChildren();

			// not calling super.draw, because we're handling everything here. Instead we'll just call validate();
			validate();
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function drawLayout():void {
			// figure out our scrolling situation:
			_horizontalScrollPolicy = (_scrollDirection == ScrollBarDirection.HORIZONTAL) ? _scrollPolicy : ScrollPolicy.OFF;
			_verticalScrollPolicy = (_scrollDirection != ScrollBarDirection.HORIZONTAL) ? _scrollPolicy : ScrollPolicy.OFF;
			if (_scrollDirection == ScrollBarDirection.HORIZONTAL) {
				var rows:uint = rowCount;
				contentHeight = rows*_rowHeight;
				contentWidth = _columnWidth*Math.ceil(length/rows);
			} else {
				var cols:uint = columnCount;
				contentWidth = cols*_columnWidth;
				contentHeight = _rowHeight*Math.ceil(length/cols);
			}
			// hand off drawing the layout to BaseScrollPane:
			super.drawLayout();
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function drawList():void {
			// these vars get reused in different loops:
			var i:uint;
			var itemIndex:uint;
			var item:Object;
			var renderer:ICellRenderer;
			var rows:uint = rowCount;
			var cols:uint = columnCount;
			var colW:Number = columnWidth;
			var rowH:Number = rowHeight;
			var baseCol:Number = 0;
			var baseRow:Number = 0;
			var col:uint;
			var row:uint;

			listHolder.x = listHolder.y = contentPadding;

			// set horizontal scroll:
			contentScrollRect = listHolder.scrollRect;
			contentScrollRect.x = Math.floor(_horizontalScrollPosition)%colW;

			// set pixel scroll:
			contentScrollRect.y = Math.floor(_verticalScrollPosition)%rowH;
			listHolder.scrollRect = contentScrollRect;
			
			listHolder.cacheAsBitmap = useBitmapScrolling;
			
			// figure out what we have to render, and where:
			var items:Array = [];
			if (_scrollDirection == ScrollBarDirection.HORIZONTAL) {
				// horizontal scrolling is trickier if we want to keep tiles going left to right, then top to bottom.
				// we can use availableWidth / availableHeight from BaseScrollPane here, because we've just called drawLayout, so we know they are accurate.
				var fullCols:uint = availableWidth/colW<<0;
				var rowLength:uint = Math.max(fullCols,Math.ceil(length/rows));
				baseCol = _horizontalScrollPosition/colW<<0;
				cols = Math.max(fullCols,Math.min(rowLength-baseCol,cols+1));//(horizontalScrollBar.visible ? 1 : -1))); // need to draw an extra two cols for scrolling.
				//rowLength = Math.max(cols-(horizontalScrollBar.visible ? -1 : 0),rowLength);
				for (row=0; row<rows; row++) {
					for (col=0; col<cols; col++) {
						itemIndex = row*rowLength+baseCol+col;
						if (itemIndex >= length) { break; }
						items.push(itemIndex);
					}
				}
			} else {
				rows++; // need to draw an extra row for scrolling.
				baseRow = _verticalScrollPosition/rowH<<0;
				var startIndex:uint = Math.floor(baseRow*cols);
				var endIndex:uint = Math.min(length,startIndex+rows*cols);
				for (i=startIndex; i<endIndex; i++) {
					items.push(i);
				}
			}

			// create a dictionary for looking up the new "displayed" items:
			var itemHash:Dictionary = renderedItems = new Dictionary(true);
			for each (itemIndex in items) {
				itemHash[_dataProvider.getItemAt(itemIndex)] = true;
			}

			// find cell renderers that are still active, and make those that aren't active available:
			var itemToRendererHash:Dictionary = new Dictionary(true);
			while (activeCellRenderers.length > 0) {
				renderer = activeCellRenderers.pop();
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

			i = 0; // count of items placed.
			// draw cell renderers:
			for each (itemIndex in items) {
				col = i%cols;
				row = i/cols<<0;

				var reused:Boolean = false;
				item = _dataProvider.getItemAt(itemIndex);
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

				renderer.y = rowH*row;
				renderer.x = colW*col;
				renderer.setSize(columnWidth,rowHeight);

				var label:String = itemToLabel(item);
				
				var icon:Object = null;
				if (_iconFunction != null) {
					icon = _iconFunction(item);
				} else if (_iconField != null) {
					icon = item[_iconField];
				}
				
				var source:Object = null;
				if (_sourceFunction != null) {
					source = _sourceFunction(item);	
				} else if (_sourceField != null) {
					source = item[_sourceField];
				}

				if (!reused) {
					renderer.data = item;
				}
				
				renderer.listData = new TileListData(label,icon,source,this,itemIndex,baseRow+row,baseCol+col) as ListData;

				renderer.selected = (_selectedIndices.indexOf(itemIndex) != -1);

				// force an immediate draw (because render event will not be called on the renderer):
				if (renderer is UIComponent) {
					var rendererUIC:UIComponent = renderer as UIComponent;
					rendererUIC.drawNow();
				}
				i++;
			}
		}

		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void {
			event.stopPropagation();
			if (!selectable) { return; }
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.DOWN:
					moveSelectionVertically(event.keyCode, event.shiftKey && _allowMultipleSelection, event.ctrlKey && _allowMultipleSelection);
					break;
				case Keyboard.PAGE_UP:
				case Keyboard.PAGE_DOWN:
				case Keyboard.END:
				case Keyboard.HOME:
					if (_scrollDirection == ScrollBarDirection.HORIZONTAL) {
						moveSelectionHorizontally(event.keyCode, event.shiftKey && _allowMultipleSelection, event.ctrlKey && _allowMultipleSelection);
					} else {
						moveSelectionVertically(event.keyCode, event.shiftKey && _allowMultipleSelection, event.ctrlKey && _allowMultipleSelection);
					}
					break;
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					moveSelectionHorizontally(event.keyCode, event.shiftKey && _allowMultipleSelection, event.ctrlKey && _allowMultipleSelection);
					break;
				default:
					var nextIndex:int = getNextIndexAtLetter(String.fromCharCode(event.keyCode), selectedIndex);
					if (nextIndex > -1) {
						selectedIndex = nextIndex;
						scrollToSelected();
					}
					break;
			}
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
         *        the keyboard key was pressed
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function moveSelectionVertically(code:uint, shiftKey:Boolean, ctrlKey:Boolean):void {
			var totalRows:uint = Math.max(1, (Math.max(contentHeight,availableHeight)/_rowHeight<<0));
			var perRow:uint = Math.ceil(Math.max(columnCount*rowCount,length) / totalRows); // This is wrong.
			var totalContentRows:uint = Math.ceil(length / perRow);
			
			var index:int;
			var newIndex:int;
			switch (code) {
				case Keyboard.UP:
					index = selectedIndex - perRow; break;
				case Keyboard.DOWN:
					index = selectedIndex + perRow; break;
				case Keyboard.HOME:
					index = 0; break;
				case Keyboard.END:
					index = length-1; break;					
				case Keyboard.PAGE_DOWN:
					newIndex = selectedIndex + perRow * (totalContentRows-1);
					if (newIndex >= length) { newIndex -= perRow; }
					index = Math.min(length-1, newIndex); 
					break;
				case Keyboard.PAGE_UP:
					newIndex = selectedIndex - perRow * (totalContentRows-1);
					if (newIndex < 0) { newIndex += perRow; }
					index = Math.max(0, newIndex); 
					break;
			}
			
			doKeySelection(index, shiftKey, ctrlKey);			
			scrollToSelected();
		}

		/**
         * @private (protected)
		 * Moves the selection in a horizontal direction in response
		 * to the user selecting items using the left-arrow or right-arrow
		 * keys and modifiers such as  the Shift and Ctrl keys.
		 *
		 * <p>Not implemented in List because the default list
		 * is single column and does not scroll horizontally.</p>
		 *
		 * @param code The key that was pressed (e.g. Keyboard.LEFT)
         *
		 * @param shiftKey <code>true</code> if the shift key was held down when
		 *        the keyboard key was pressed.
         *
		 * @param ctrlKey <code>true</code> if the ctrl key was held down when
         *        the keyboard key was pressed
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function moveSelectionHorizontally(code:uint, shiftKey:Boolean, ctrlKey:Boolean):void {
			var totalCols:uint = Math.ceil(Math.max(rowCount*columnCount,length) / rowCount);
			
			var index:int;
			switch(code) {
				case Keyboard.LEFT:
					index = Math.max(0, selectedIndex - 1); break;
				case Keyboard.RIGHT:
					index = Math.min(length-1, selectedIndex + 1); break;
				case Keyboard.HOME:
					index = 0; break;
				case Keyboard.END:
					index = length-1; break;					
				case Keyboard.PAGE_UP:
					var firstIndex:int = selectedIndex - selectedIndex%totalCols;
					index = Math.max(0, Math.max(firstIndex, selectedIndex - columnCount));
					break;
				case Keyboard.PAGE_DOWN:
					var lastIndex = selectedIndex - selectedIndex%totalCols + totalCols-1;
					index = Math.min(length-1, Math.min(lastIndex, selectedIndex + totalCols)); break;
			}
	
			doKeySelection(index, shiftKey, ctrlKey);
			scrollToSelected();
		}

		/**
		 * @private (protected)
		 * Changes the selected index, or adds or subtracts the index and
		 * all indices between when the shift key is used.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function doKeySelection(newCaretIndex:uint, shiftKey:Boolean, ctrlKey:Boolean):void {	
			var indices:Array = selectedIndices;
			var selChanged:Boolean = false;
			
			if (newCaretIndex < 0 || newCaretIndex > length-1) {
				// The index is out of range, do nothing.
			} else if (shiftKey && indices.length > 0 && newCaretIndex != indices[0]) {
				var firstIndex:uint = indices[0];
				indices = [];
				var i:int;
				if (newCaretIndex < firstIndex) {
					for (i=firstIndex; i>=newCaretIndex; i--) {
						indices.push(i);	
					}
				} else {
					for (i=firstIndex; i<=newCaretIndex; i++) {
						indices.push(i);	
					}
				}
				selChanged = true;
			} else {
				indices = [newCaretIndex];
				caretIndex = newCaretIndex;
				selChanged = true;
			}			
			selectedIndices = indices;
			
			
			if(selChanged) {
				dispatchEvent(new Event(Event.CHANGE));
			}
			invalidate(InvalidationType.DATA);
		}
		
		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function initializeAccessibility():void {
			if (TileList.createAccessibilityImplementation != null) {
				TileList.createAccessibilityImplementation(this);
			}
		}

	}
}
