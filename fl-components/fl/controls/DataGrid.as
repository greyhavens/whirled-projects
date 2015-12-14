// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {
	
	import fl.controls.dataGridClasses.DataGridColumn;
	import fl.controls.dataGridClasses.HeaderRenderer;
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ListData;
	import fl.controls.ScrollPolicy;
	import fl.controls.SelectableList;
	import fl.controls.TextInput;
	import fl.core.UIComponent;
	import fl.core.InvalidationType;
	import fl.data.DataProvider;
	import fl.events.ScrollEvent;
	import fl.events.ListEvent;
	import fl.events.DataGridEvent;
	import fl.events.DataGridEventReason;
	import fl.events.DataChangeType;
	import fl.events.DataChangeEvent;
	import fl.managers.IFocusManager;
	import fl.managers.IFocusManagerComponent;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.DisplayObjectContainer
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.geom.Point;
	import flash.system.IME;

	/**
	 * Dispatched after the user clicks a header cell.
     *
     * @includeExample examples/DataGrid.headerRelease.1.as -noswf
     *
     * @eventType fl.events.DataGridEvent.HEADER_RELEASE
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="headerRelease", type="fl.events.DataGridEvent")]

	/**
	 * Dispatched after a user expands a column horizontally.
     *
     * @includeExample examples/DataGrid.columnStretch.1.as -noswf
     *
     * @eventType fl.events.DataGridEvent.COLUMN_STRETCH
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="columnStretch", type="fl.events.DataGridEvent")]

	/**
	 * Dispatched after a user prepares to edit an item, for example,
	 * by releasing the mouse button over the item.
     *
     * @eventType fl.events.DataGridEvent.ITEM_EDIT_BEGINNING
     *
     * @see #event:itemEditBegin
     * @see #event:itemEditEnd
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="itemEditBeginning", type="fl.events.DataGridEvent")]

	/**
	 *  Dispatched after the <code>editedItemPosition</code> property is set
	 *  and the item can be edited.
     *
     *  @eventType fl.events.DataGridEvent.ITEM_EDIT_BEGIN
     *
     * @see #event:itemEditBeginning
     * @see #event:itemEditEnd
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="itemEditBegin", type="fl.events.DataGridEvent")]

	/**
	 *  Dispatched when an item editing session ends for any reason.
     *
     *  @eventType fl.events.DataGridEvent.ITEM_EDIT_END
     *
     * @see #event:itemEditBegin
     * @see #event:itemEditBeginning
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="itemEditEnd", type="fl.events.DataGridEvent")]

	/**
	 *  Dispatched after an item receives focus.
     *
     *  @eventType fl.events.DataGridEvent.ITEM_FOCUS_IN
     *
     * @see #event:itemFocusOut
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="itemFocusIn", type="fl.events.DataGridEvent")]

	/**
	 *  Dispatched after an item loses focus.
     *
     *  @eventType fl.events.DataGridEvent.ITEM_FOCUS_OUT
     *
     * @see #event:itemFocusIn
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="itemFocusOut", type="fl.events.DataGridEvent")]


	//--------------------------------------
	//  Styles
	//--------------------------------------
    /**
     * The name of the class that provides the cursor that is used when 
	 * the mouse is between two column headers and the <code>resizableColumns</code> 
	 * property is set to <code>true</code>.
     *
     * @default DataGrid_columnStretchCursorSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="columnStretchCursorSkin", type="Class")]

    /**
     * The name of the class that provides the divider that appears
	 * between columns.
     *
     * @default DataGrid_columnDividerSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="columnDividerSkin", type="Class")]

    /**
     * The name of the class that provides the background for each column header.
     *
     * @default HeaderRenderer_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="headerUpSkin", type="Class")]

    /**
     * The name of the class that provides the background for each column header
	 * when the mouse is over it.
     *
     * @default HeaderRenderer_overSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="headerOverSkin", type="Class")]

    /**
     * The name of the class that provides the background for each column header
	 * when the mouse is down.
     *
     * @default HeaderRenderer_downSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="headerDownSkin", type="Class")]

    /**
     * The name of the class that provides the background for each column header
	 * when the component is disabled.
     *
     * @default HeaderRenderer_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="headerDisabledSkin", type="Class")]

    /**
     * The name of the class that provides the sort arrow when the sorted
	 * column is in descending order.
     *
     * @default HeaderSortArrow_descIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="headerSortArrowDescSkin", type="Class")]

    /**
     * The name of the class that provides the sort arrow when the sorted
	 * column is in ascending order.
     *
     * @default HeaderSortArrow_ascIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="headerSortArrowAscSkin", type="Class")]

    /**
     * The format to be applied to the text contained in each column header.
     *
     * @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="headerTextFormat", type="flash.text.TextFormat")]

    /**
     * The format to be applied to the text contained in each column header 
	 * when the component is disabled.
     *
     * @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="headerDisabledTextFormat", type="flash.text.TextFormat")]

    /**
     * The padding that separates the column header border from the column header 
	 * text, in pixels.
     *
     * @default 5
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="headerTextPadding", type="Number", format="Length")]

    /**
     * The name of the class that provides each column header.
     *
     * @default fl.controls.dataGridClasses.HeaderRenderer
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="headerRenderer", type="Class")]


	[InspectableList("allowMultipleSelection","editable","headerHeight","horizontalLineScrollSize","horizontalPageScrollSize","horizontalScrollPolicy","resizableColumns","rowHeight","showHeaders","sortableColumns","verticalLineScrollSize","verticalPageScrollSize","verticalScrollPolicy")]
    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The DataGrid class is a list-based component that provides a grid of
	 * rows and columns. You can specify an optional header row at the top 
	 * of the component that shows all the property names. Each row consists 
	 * of one or more columns, each of which represents a property that belongs
	 * to the specified data object. The DataGrid component is used to view data; 
	 * it is not intended to be used as a layout tool like an HTML table.
	 *
	 * <p>A DataGrid component is well suited for the display of objects that contain
	 * multiple properties. The data that a DataGrid component displays can
	 * be contained in a DataProvider object or as an array of objects. The columns of a DataGrid
	 * component can be represented by a list of DataGridColumn objects, 
	 * each of which contains information that is specific to the column.</p>
	 *
	 * <p>The DataGrid component provides the following features:</p>
     * <ul>
	 *     <li>Columns of different widths or identical fixed widths</li>
	 * 	   <li>Columns that the user can resize at run time</li>
	 * 	   <li>Columns that the user can reorder at run time by using ActionScript</li>
	 * 	   <li>Optional customizable column headers</li>
	 * 	   <li>Support for custom item renderers to display data other than text
	 *         in any column</li>
	 *     <li>Support for sorting data by clicking on the column that contains it</li>
     * </ul>
	 *
	 * <p>The DataGrid component is composed of subcomponents including ScrollBar,
	 * HeaderRenderer, CellRenderer, DataGridCellEditor, and ColumnDivider components, all of which 
	 * can be skinned during authoring or at run time.</p>
	 *
	 * <p>The DataGrid component uses the following classes that can be found in the dataGridClasses package:</p>
     * <ul>
	 *     <li>DataGridColumn: Describes a column in a DataGrid component. Contains the indexes, 
	 *         widths, and other properties of the column. Does not contain cell data.</li>
	 *     <li>HeaderRenderer: Displays the column header for the current DataGrid column. Contains
	 *         the label and other properties of the column header.</li>
	 *     <li>DataGridCellEditor: Manages the editing of the data for each cell.</li>
     * </ul>
	 *
     * @includeExample examples/DataGridExample.as
     *
     * @see fl.controls.dataGridClasses.DataGridCellEditor DataGridCellEditor
     * @see fl.controls.dataGridClasses.DataGridColumn DataGridColumn
     * @see fl.controls.dataGridClasses.HeaderRenderer HeaderRenderer
     * @see fl.controls.listClasses.CellRenderer CellRenderer
     * @see fl.events.DataGridEvent DataGridEvent
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class DataGrid extends SelectableList implements IFocusManagerComponent {
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _rowHeight:Number = 20;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _headerHeight:Number = 25;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _showHeaders:Boolean = true;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _columns:Array;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _minColumnWidth:Number;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var header:Sprite;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var headerMask:Sprite;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var headerSortArrow:Sprite;

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
		protected var _headerRenderer:Object;

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
		protected var visibleColumns:Array;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var displayableColumns:Array;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var columnsInvalid:Boolean = true;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var minColumnWidthInvalid:Boolean = false;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var activeCellRenderersMap:Dictionary;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var availableCellRenderersMap:Dictionary;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var dragHandlesMap:Dictionary;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var columnStretchIndex:Number = -1;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var columnStretchStartX:Number;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var columnStretchStartWidth:Number;

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var columnStretchCursor:Sprite;

		/**
		 *  @private (protected)
         *  The index of the column being sorted.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _sortIndex:int = -1;

		/**
		 *  @private (protected)
         *  The index of the last column being sorted on.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var lastSortIndex:int = -1;

		/**
		 *  @private (protected)
         *  The direction of the current sort.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _sortDescending:Boolean = false;

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _editedItemPosition:Object;

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var editedItemPositionChanged:Boolean = false;

		/**
		 *  @private (protected)
         *  <code>undefined</code> means we've processed it, <code>null</code> means don't put up an editor
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var proposedEditedItemPosition:*;

		/**
		 *  @private (protected)
         *  Last known position of item editor instance
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var actualRowIndex:int;

		/**
		 *  @private (protected)
         *  Last known position of item editor instance
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var actualColIndex:int;

		/**
		 *  @private (protected)
         *  Whether the mouse button is pressed.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var isPressed:Boolean = false;

		/**
		 *  @private (protected)
         *  True if we want to block editing on mouseUp.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var losingFocus:Boolean = false;
		
		/**
		 *  @private (protected)
         *  Stores the user set headerheight (we modify header height when dg is resized down) 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var maxHeaderHeight:Number = 25;
		
		/**
		 *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var currentHoveredRow:int = -1;
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static var defaultStyles:Object = {
			headerUpSkin: "HeaderRenderer_upSkin",
			headerDownSkin: "HeaderRenderer_downSkin",
			headerOverSkin: "HeaderRenderer_overSkin",
			headerDisabledSkin: "HeaderRenderer_disabledSkin",
			headerSortArrowDescSkin:"HeaderSortArrow_descIcon",
			headerSortArrowAscSkin:"HeaderSortArrow_ascIcon",
			columnStretchCursorSkin:"ColumnStretch_cursor",
			columnDividerSkin:null,
			headerTextFormat:null,
			headerDisabledTextFormat:null,
			headerTextPadding:5,
			headerRenderer:HeaderRenderer,
			focusRectSkin:null,
			focusRectPadding:null,
			skin:"DataGrid_skin"
		};

        /**
         * @copy fl.core.UIComponent#getStyleDefinition()
         *
		 * @includeExample ../core/examples/UIComponent.getStyleDefinition.1.as -noswf
		 *
         * @see fl.core.UIComponent#getStyle() UIComponent.getStyle()
         * @see fl.core.UIComponent#setStyle() UIComponent.setStyle()
         * @see fl.managers.StyleManager StyleManager
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function getStyleDefinition():Object {
			return mergeStyles(defaultStyles, SelectableList.getStyleDefinition(), ScrollBar.getStyleDefinition());
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected static const HEADER_STYLES:Object = {
			disabledSkin:"headerDisabledSkin",
			downSkin:"headerDownSkin",
			overSkin:"headerOverSkin",
			upSkin:"headerUpSkin",
			textFormat: "headerTextFormat",
			disabledTextFormat: "headerDisabledTextFormat",
			textPadding: "headerTextPadding"
		};

		/**
		 *  @private
		 *  Creates the Accessibility class.
         *  This method is called from UIComponent.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static var createAccessibilityImplementation:Function;


		/**
         * Creates a new DataGrid component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function DataGrid() {
			super();
			if (_columns == null) { _columns = []; }
			_horizontalScrollPolicy = ScrollPolicy.OFF;
			activeCellRenderersMap = new Dictionary(true);
			availableCellRenderersMap = new Dictionary(true);
			addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, itemEditorItemEditBeginningHandler, false, -50);
			addEventListener(DataGridEvent.ITEM_EDIT_BEGIN, itemEditorItemEditBeginHandler, false, -50);
			addEventListener(DataGridEvent.ITEM_EDIT_END, itemEditorItemEditEndHandler, false, -50);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set dataProvider(dataSource:DataProvider):void {
			super.dataProvider = dataSource;
			// if not already created, create columns from dataprovider
			if (_columns == null) { _columns = []; }
			if (_columns.length == 0) { createColumnsFromDataProvider(); }
			// remove all existing cellrenderers
			removeCellRenderers();
		}

		[Inspectable(defaultValue=true, verbose=1)]
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			header.mouseChildren = _enabled;
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function setSize(w:Number, h:Number):void {
			super.setSize(w, h);
			columnsInvalid = true;
		}

		[Inspectable(defaultValue="off",enumeration="on,off,auto")]
		/**
		 * Gets or sets a Boolean value that indicates whether the 
		 * horizontal scroll bar is always on. The following list describes
		 * the valid values:
		 *
		 * <ul>
		 *   <li><code>ScrollPolicy.ON</code>: The scroll bar is always on.</li>
		 *   <li><code>ScrollPolicy.OFF</code>: The scroll bar is always off.</li>
		 *   <li><code>ScrollPolicy.AUTO</code>: The state of the scroll bar changes 
		 *        based on the parameters that are passed to the <code>setScrollBarProperties()</code> 
		 *        method.</li>
		 * </ul> 
		 * 
		 * <p><strong>Note:</strong> If the combined width of the visible columns in the DataGrid 
		 * component is smaller than the available width of the DataGrid component, the columns may not expand to fill
		 * the available space of the DataGrid component, depending on the value of the 
		 * <code>horizontalScrollPolicy</code> property. The following list describes
		 * these values and their effects:</p>
		 *
		 * <ul>
		 *   <li><code>ScrollPolicy.ON</code>: The horizontal scroll bar is disabled. The columns do not expand
		 *         to fill the available space of the DataGrid component.</li>
		 *   <li><code>ScrollPolicy.AUTO</code>: The horizontal scroll bar is not visible. The columns do not expand
		 *         to fill the available space of the DataGrid component.</li>
		 * </ul>
		 *
		 * @default ScrollPolicy.OFF
         *
         * @see fl.containers.BaseScrollPane#verticalScrollPolicy BaseScrollPane.verticalScrollPolicy
         * @see ScrollPolicy
         *
		 * @includeExample examples/DataGrid.horizontalScrollPolicy.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override public function get horizontalScrollPolicy():String {
			return _horizontalScrollPolicy;
		}
		/**
         * @private (protected)
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set horizontalScrollPolicy(policy:String):void {
			super.horizontalScrollPolicy = policy;
			columnsInvalid = true;
		}

		/**
		 * Gets or sets an array of DataGridColumn objects, one for each column that can be displayed.
		 * If not explicitly set, the DataGrid component examines the first item in the
		 * data provider, locates its properties, and then displays those properties
		 * in alphabetic order.
         *
		 * <p>You can make changes to the columns and to their order in this DataGridColumn 
		 * array. After the changes are made, however, you must explicitly assign the 
		 * changed array to the <code>columns</code> property. If an explicit assignment
		 * is not made, the set of columns that was used before will continue to be used.</p>
		 *
         * @default []
         *
         * @includeExample examples/DataGrid.columns.1.as -noswf
         * @includeExample examples/DataGrid.columns.2.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get columns():Array {
			return _columns.slice(0);
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set columns(value:Array):void {
			// remove all existing cellrenderers
			removeCellRenderers();
			// add columns
			_columns = [];
			for (var i:uint = 0; i < value.length; i++) {
				addColumn(value[i]);
			}
		}

		/**
         * Gets or sets the minimum width of a DataGrid column, in pixels. 
		 * If this value is set to <code>NaN</code>, the minimum column
		 * width can be individually set for each column of the DataGrid component.
		 *
         * @default NaN
         *
         * @includeExample examples/DataGrid.minColumnWidth.1.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get minColumnWidth():Number {
			return _minColumnWidth;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set minColumnWidth(value:Number):void {
			_minColumnWidth = value;
			columnsInvalid = true;
			minColumnWidthInvalid = true;
			invalidate(InvalidationType.SIZE);
		}

		/**
		 * Gets or sets a function that determines which fields of each 
		 * item to use for the label text.
         *
         * @default null
         *
         * @includeExample examples/DataGrid.labelFunction.1.as -noswf
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
		 * Gets or sets the number of rows that are at least partially visible in the
         * list.
         *
         * @includeExample examples/DataGrid.rowCount.1.as -noswf
         *
         * @see SelectableList#length SelectableList.length
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get rowCount():uint {
			// This is low right now (ie. doesn't count two half items as a whole):
			return Math.ceil(calculateAvailableHeight() / rowHeight);
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set rowCount(value:uint):void {
			var pad:Number = Number(getStyleValue("contentPadding"));
			var scrollBarHeight:Number = (_horizontalScrollPolicy == ScrollPolicy.ON || (_horizontalScrollPolicy == ScrollPolicy.AUTO && hScrollBar)) ? 15 : 0;
			height = rowHeight * value + 2 * pad + scrollBarHeight + (showHeaders ? headerHeight : 0);
		}

		[Inspectable(defaultValue=20)]
		/**
		 * Gets or sets the height of each row in the DataGrid component, in pixels.
         *
         * @default 20
         *
         * @includeExample examples/DataGrid.rowHeight.1.as -noswf
         *
         * @see #headerHeight
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
			_rowHeight = Math.max(0, value);
			invalidate(InvalidationType.SIZE);
		}

		[Inspectable(defaultValue=25)]
		/**
		 * Gets or sets the height of the DataGrid header, in pixels.
         *
         * @default 25
         *
         * @includeExample examples/DataGrid.headerHeight.1.as -noswf
         *
         * @see #rowHeight
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */

		public function get headerHeight():Number {
			return _headerHeight;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set headerHeight(value:Number):void {
			maxHeaderHeight = value;
			_headerHeight = Math.max(0, value);
			invalidate(InvalidationType.SIZE);
		}

		[Inspectable(defaultValue=true)]
		/**
         * Gets or sets a Boolean value that indicates whether the DataGrid component shows column headers. 
		 * A value of <code>true</code> indicates that the DataGrid component shows column headers; a value 
		 * of <code>false</code> indicates that it does not.
         *
         * @default true
         *
         * @includeExample examples/DataGrid.showHeaders.1.as -noswf
		 *
		 * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get showHeaders():Boolean {
			return _showHeaders;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set showHeaders(value:Boolean):void {
			_showHeaders = value;
			invalidate(InvalidationType.SIZE);
		}

		/**
         * Gets the index of the column to be sorted.
         *
         * @default -1
         *
         * @see #sortDescending
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get sortIndex():int {
			return _sortIndex;
		}

		/**
		 * Gets the order in which a column is sorted when 
		 * the user clicks its header. A value of <code>true</code> 
		 * indicates that the column is sorted in descending order; a 
		 * value of <code>false</code> indicates that the column is 
		 * sorted in ascending order. 
		 *
		 * <p>The <code>sortDescending</code> property does not affect
		 * how the sort method completes the sort operation. By default, 
		 * the sort operation involves a case-sensitive string sort. 
		 * To change this behavior, modify the <code>sortOptions</code> 
		 * and <code>sortCompareFunction</code> properties of the DataGridColumn
		 * class.</p>
		 *
		 * <p><strong>Note:</strong> If you query this property from an event 
		 * listener for the <code>headerRelease</code> event, the property value 
		 * identifies the sort order for the previous sort operation. This 
		 * is because the next sort has not yet occurred.</p>
		 *
		 * 
         *
		 * @default false
         *
         * @includeExample examples/DataGrid.sortDescending.1.as -noswf
         *
         * @see fl.controls.dataGridClasses.DataGridColumn#sortOptions DataGridColumn.sortOptions
         * @see fl.controls.dataGridClasses.DataGridColumn#sortCompareFunction DataGridColumn.sortCompareFunction
		 * @see Array#sort() Array.sort()
         * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get sortDescending():Boolean {
			return _sortDescending;
		}

        /**
         * @copy fl.controls.TextArea#imeMode
         *
         * @see flash.system.IMEConversionMode IMEConversionMode
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get imeMode():String {
			return _imeMode;
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set imeMode(value:String):void {
			_imeMode = value;
		}

		[Inspectable(defaultValue=false)]
		/**
		 *  Indicates whether or not the user can edit items in the data provider.
		 *  A value of <code>true</code> indicates that the user can edit items in the
		 *  data provider; a value of <code>false</code> indicates that the user cannot.
		 *
		 *  <p>If this value is <code>true</code>, the item renderers in the component 
		 *  are editable. The user can click on an item renderer to open an editor.</p>
		 *
		 *  <p>You can turn off editing for individual columns of the DataGrid component  
		 *  by using the <code>DataGridColumn.editable</code> property, or by handling 
		 *  the <code>itemEditBeginning</code> and <code>itemEditBegin</code> events.</p>
		 *
         *  @default false
         *
         * @see #event:itemEditBegin
         * @see #event:itemEditBeginning
         * @see fl.controls.dataGridClasses.DataGridColumn#editable DataGridColumn.editable
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var editable:Boolean = false;


		[Inspectable(defaultValue=true)]
		/**
		 *  Indicates whether the user can change the size of the
         *  columns. A value of <code>true</code> indicates that the user can
		 *  change the column size; a value of <code>false</code> indicates that 
		 *  column size is fixed.
		 *
		 *  <p>If this value is <code>true</code>, the user can stretch or shrink 
		 *  the columns of the DataGrid component by dragging the grid lines between 
		 *  the header cells. Additionally, if this value is <code>true</code>,
		 *  the user can change the size of the columns unless the <code>resizeable</code> 
		 *  properties of individual columns are set to <code>false</code>.</p>
		 *
         *  @default true
         *
         * @includeExamples examples/DataGrid.resizableColumns.1.as -noswf
         *
         * @see fl.controls.dataGridClasses.DataGridColumn#resizable DataGridColumn.resizable
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var resizableColumns:Boolean = true;

		[Inspectable(defaultValue=true)]
		/**
		 * Indicates whether the user can sort the items in the data provider 
		 * by clicking on a column header cell. If this value is <code>true</code>, 
		 * the user can sort the data provider items by clicking on a column header cell;
		 * if this value is <code>false</code>, the user cannot.
		 * 
		 * <p>If this value is <code>true</code>, to prevent an individual column
		 * from responding to a user mouse click on a header cell, set the 
		 * <code>sortable</code> property of that column to <code>false</code>.</p>
		 *
		 * <p>The sort field of a column is either the <code>dataField</code> or 
		 * <code>sortCompareFunction</code> property of the DataGridColumn component.
		 * If the user clicks a column more than one time, the sort operation
		 * alternates between ascending and descending order.</p>
		 * 
		 * <p>If both this property and the <code>sortable</code> property of a
		 * column are set to <code>true</code>, the DataGrid component dispatches
		 * a <code>headerRelease</code> event after the user releases the mouse
		 * button of the column header cell. If a call is not made to the <code>preventDefault()</code>
		 * method from a handler method of the <code>headerRelease</code> event, 
		 * the DataGrid component performs a sort based on the values of the <code>dataField</code>  
		 * or <code>sortCompareFunction</code> properties.</p>
		 *
         * @default true
         *
         * @includeExample examples/DataGrid.sortableColumns.1.as -noswf
         *
         * @see fl.controls.dataGridClasses.DataGridColumn#sortable DataGridColumn.sortable
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var sortableColumns:Boolean = true;

		/**
		 *  A reference to the currently active instance of the item editor,
		 *  if one exists.
		 *
		 *  <p>To access the item editor instance and the new item value when an
		 *  item is being edited, use the <code>itemEditorInstance</code>
		 *  property. The <code>itemEditorInstance</code> property is not valid 
		 *  until after the event listener for the <code>itemEditBegin</code> 
		 *  event executes. For this reason, the <code>itemEditorInstance</code> property 
		 *  is typically accessed from the event listener for the <code>itemEditEnd</code> 
		 *  event.</p>
		 *
		 *  <p>The <code>DataGridColumn.itemEditor</code> property defines the
		 *  class of the item editor, and therefore, the data type of the
         *  item editor instance.</p>
         *
         * @includeExample examples/DataGrid.itemEditorInstance.1.as -noswf
         *
         * @see #event:itemEditBegin
         * @see #event:itemEditEnd
         * @see fl.controls.dataGridClasses.DataGridColumn#itemEditor DataGridColumn.itemEditor
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var itemEditorInstance:Object;

		/**
		 * Gets a reference to the item renderer in the DataGrid component whose item is currently being  
		 * edited. If no item is being edited, this property contains a value of <code>null</code>.
		 *
		 * <p>You can obtain the current value of the item that is being edited by using the
		 * <code>editedItemRenderer.data</code> property from an event listener for the  
		 * <code>itemEditBegin</code> event or the <code>itemEditEnd</code> event.</p>
		 *
		 * <p>This is a read-only property. To set a custom item editor, use the <code>itemEditor</code>  
		 * property of the class that represents the relevant column.</p>
         *
		 * @see fl.controls.dataGridClasses.DataGridColumn#itemEditor DataGridColumn.itemEditor
         *
         * @includeExample examples/DataGrid.editedItemPosition.1.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get editedItemRenderer():ICellRenderer {
			if (!itemEditorInstance) { return null; }
			return getCellRendererAt(actualRowIndex, actualColIndex);
		}

		/**
		 * Gets or sets the column and row index of the item renderer for 
		 * the data provider item that is being edited. If no item is being
		 * edited, this property is <code>null</code>.
		 *
		 * <p>This object has two fields:</p>
		 *
		 * <ul>
		 *     <li><code>columnIndex</code>: The zero-based column index of the current item</li>
		 *     <li><code>rowIndex</code>: The zero-based row index of the current item</li>
		 * </ul>
		 * 
		 * <p>For example: <code>{ columnIndex:2, rowIndex:3 }</code></p>
		 *
		 * <p>Setting this property scrolls the item into view and dispatches the 
		 * <code>itemEditBegin</code> event to open an item editor on the specified 
		 * item renderer.</p>
		 *
         * @default null
         *
         * @includeExample examples/DataGrid.editedItemPosition.1.as -noswf
         *
         * @see #event:itemEditBegin
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get editedItemPosition():Object {
			if (_editedItemPosition) {
				return {
					rowIndex: _editedItemPosition.rowIndex,
					columnIndex: _editedItemPosition.columnIndex
				};
			} else {
				return _editedItemPosition;
			}
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set editedItemPosition(value:Object):void {
			var newValue:Object = {
				rowIndex: value.rowIndex,
				columnIndex: value.columnIndex
			};
			setEditedItemPosition(newValue);
		}


		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function calculateAvailableHeight():Number {
			var pad:Number = Number(getStyleValue("contentPadding"));
			var scrollBarHeight:Number = (_horizontalScrollPolicy == ScrollPolicy.ON || (_horizontalScrollPolicy == ScrollPolicy.AUTO && _maxHorizontalScrollPosition > 0)) ? 15 : 0;
			return height - pad * 2 - scrollBarHeight - (showHeaders ? headerHeight : 0);
		}

		/**
         * Adds a column to the end of the <code>columns</code> array.
		 *
		 * @param column A String or a DataGridColumn object.
		 *
         * @return The DataGridColumn object that was added.
         *
         * @see #addColumnAt()
         *
         * @includeExample examples/DataGrid.addColumn.2.as -noswf
         * @includeExample examples/DataGrid.addColumn.3.as -noswf
         * @includeExample examples/DataGrid.addColumn.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function addColumn(column:*):DataGridColumn {
			return addColumnAt(column, _columns.length);
		}

		/**
         * Inserts a column at the specified index in the <code>columns</code> array.
		 *
		 * @param column The string or DataGridColumn object that represents the column to be inserted.
		 * @param index The array index that identifies the location at which the column is to be inserted.
         *
         * @return The DataGridColumn object that was inserted into the array of columns.
         *
         * @see #addColumn()
         *
         * @includeExample examples/DataGrid.addColumn.1.as -noswf		 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function addColumnAt(column:*, index:uint):DataGridColumn {
			var dataGridColumn:DataGridColumn;
			if (index < _columns.length) {
				// insert placeholder for new column
				_columns.splice(index, 0, "");
				// adjust colNums
				for(var i:uint = index + 1; i < _columns.length; i++) {
					dataGridColumn = _columns[i] as DataGridColumn;
					dataGridColumn.colNum = i;
				}
			}
			var col:* = column;
			if(!(col is DataGridColumn)) {
				if (col is String) {
					col = new DataGridColumn(col);
				} else {
					col = new DataGridColumn();
				}
			}
			dataGridColumn = col as DataGridColumn;
			dataGridColumn.owner = this;
			dataGridColumn.colNum = index;
			_columns[index] = dataGridColumn;
			invalidate(InvalidationType.SIZE);
			columnsInvalid = true;
			return dataGridColumn;
		}

		/**
         * Removes the column that is located at the specified index of the <code>columns</code> array.
		 *
		 * @param index The index of the column to be removed.
         *
         * @return The DataGridColumn object that was removed. This method returns <code>null</code> 
		 * if a column is not found at the specified index.
         *
         * @see #removeAllColumns()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function removeColumnAt(index:uint):DataGridColumn {
			var col:DataGridColumn = _columns[index] as DataGridColumn;
			if(col != null) {
				removeCellRenderersByColumn(col);
				_columns.splice(index, 1);
				for(var i:uint = index; i < _columns.length; i++) {
					col = _columns[i] as DataGridColumn;
					if(col) {
						col.colNum = i;
					}
				}
				invalidate(InvalidationType.SIZE);
				columnsInvalid = true;
			}
			return col;
		}

		/**
         * Removes all columns from the DataGrid component.
         *
         * @see #removeColumnAt()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function removeAllColumns():void {
			if(_columns.length > 0) {
				removeCellRenderers();
				_columns = [];
				invalidate(InvalidationType.SIZE);
				columnsInvalid = true;
			}
		}

		/**
         * Retrieves the column that is located at the specified index of the <code>columns</code> array.
		 *
		 * @param index The index of the column to be retrieved, or <code>null</code> 
         *        if a column is not found.
         *
         * @return The DataGridColumn object that was found at the specified index.
         *
         * @see #getColumnIndex()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function getColumnAt(index:uint):DataGridColumn {
			return _columns[index] as DataGridColumn;
		}

		/**
		 * Retrieves the index of the column of the specified name,
		 * or -1 if no match is found.
		 *
		 * @param name The data field of the column to be located.
		 *
         * @return The index of the location at which the column of the 
		 *         specified name is found.
         *
         * @see #getColumnAt()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function getColumnIndex(name:String):int {
			for (var i:uint = 0; i < _columns.length; i++) {
				var column:DataGridColumn = _columns[i] as DataGridColumn;
				if(column.dataField == name) {
					return i;
				}
			}
			return -1;
		}

		/**
		 * Retrieves the number of columns in the DataGrid component.
		 *
         * @return The number of columns contained in the DataGrid component.
         *
         * @includeExample examples/DataGrid.columns.2.as -noswf
         * @includeExample examples/DataGrid.columns.3.as -noswf
         *
         * @see #rowCount
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function getColumnCount():uint {
			return _columns.length;
		}

		/**
         * Resets the widths of the visible columns to the same size.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function spaceColumnsEqually():void {
			drawNow(); // Force a redraw in case this is called before validation.
			if(displayableColumns.length > 0) {
				var newWidth:Number = availableWidth / displayableColumns.length;
				for (var i:int = 0; i < displayableColumns.length; i++) {
					var displayableColumn:DataGridColumn = displayableColumns[i] as DataGridColumn;
					displayableColumn.width = newWidth;
				}
				invalidate(InvalidationType.SIZE);
				columnsInvalid = true;
			}
		}

		/**
		 * Edits a given field or property in the DataGrid component.
         *
         * @param index The index of the data provider item to be edited.
         *
         * @param dataField The name of the field or property in the data provider item to be edited.
         *
         * @param data The new data value.
		 *
         * @throws RangeError The specified index is less than 0 or greater than or equal to the 
		 *         length of the data provider.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function editField(index:uint, dataField:String, data:Object):void {
			var item:Object = getItemAt(index);
			item[dataField] = data;
			replaceItemAt(item, index);
		}
		
		/** 
		 * The DataGrid component has multiple cells for any given item, so the <code>itemToCellRenderer</code>
		 * method always returns <code>null</code>.
         *
         * @param item The item in the data provider.
         *
         * @return <code>null</code>.
         *
		 * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function itemToCellRenderer(item:Object):ICellRenderer {
			return null;
		}
		
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function configUI():void {
			useFixedHorizontalScrolling = false;

			super.configUI();

			headerMask = new Sprite();
			var g:Graphics = headerMask.graphics;
			g.beginFill(0, 0.3);
			g.drawRect(0, 0, 100, 100);
			g.endFill();
			headerMask.visible = false;
			addChild(headerMask);

			header = new Sprite();
			addChild(header);
			header.mask = headerMask;

			_horizontalScrollPolicy = ScrollPolicy.OFF;
			_verticalScrollPolicy = ScrollPolicy.AUTO;
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {
			var contentHeightChanged:Boolean = (contentHeight != rowHeight * length);
			contentHeight = rowHeight * length;

			if (isInvalid(InvalidationType.STYLES)) {
				setStyles();
				drawBackground();
				// drawLayout is expensive, so only do it if padding has changed:
				if (contentPadding != getStyleValue("contentPadding")) {
					invalidate(InvalidationType.SIZE, false);
				}
				// redrawing all the cell renderers is even more expensive, so we really only want to do it if necessary:
				if (_cellRenderer != getStyleValue("cellRenderer") || _headerRenderer != getStyleValue("headerRenderer")) {
					// remove all the existing renderers:
					_invalidateList();
					_cellRenderer = getStyleValue("cellRenderer");
					_headerRenderer = getStyleValue("headerRenderer");
				}
			}
			if (isInvalid(InvalidationType.SIZE)) {
				columnsInvalid = true;
			}
			if (isInvalid(InvalidationType.SIZE, InvalidationType.STATE) || contentHeightChanged) {
				drawLayout();
				drawDisabledOverlay();
			}

			if (isInvalid(InvalidationType.RENDERER_STYLES)) {
				updateRendererStyles();	
			}
			
			if (isInvalid(InvalidationType.STYLES,InvalidationType.SIZE,InvalidationType.DATA,InvalidationType.SCROLL,InvalidationType.SELECTED)) {
				drawList();
			}

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
			vOffset = showHeaders ? headerHeight : 0;
			super.drawLayout();
			// if header is present, adjust masks
			contentScrollRect = listHolder.scrollRect;
			if(showHeaders) {
				headerHeight = maxHeaderHeight;
				if(Math.floor(availableHeight - headerHeight) <= 0) {
					_headerHeight = availableHeight;
				}		
				
				list.y = headerHeight;
				// adjust the content mask to take header into account
				contentScrollRect = listHolder.scrollRect;
				contentScrollRect.y = contentPadding + headerHeight;
				contentScrollRect.height = availableHeight-headerHeight;
				
				listHolder.y = contentPadding + headerHeight;
				// position and size the header mask
				headerMask.x = contentPadding;
				headerMask.y = contentPadding;
				headerMask.width = availableWidth;
				headerMask.height = headerHeight;
			} else {
				contentScrollRect.y = contentPadding;
				listHolder.y = 0;
			}
			listHolder.scrollRect = contentScrollRect
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function drawList():void {
			if(showHeaders) {
				header.visible = true;
				header.x = contentPadding - _horizontalScrollPosition;
				header.y = contentPadding;
				listHolder.y = contentPadding + headerHeight;
				// adjust vertical scroller parameters to take header into account
				var availHeight:Number = Math.floor(availableHeight - headerHeight);
				_verticalScrollBar.setScrollProperties(availHeight, 0, contentHeight - availHeight, _verticalScrollBar.pageScrollSize);
			} else {
				header.visible = false;
				listHolder.y = contentPadding;
			}

			listHolder.x = contentPadding;
			contentScrollRect = listHolder.scrollRect;
			contentScrollRect.x = _horizontalScrollPosition;
			
			contentScrollRect.y = vOffset + Math.floor(_verticalScrollPosition) % rowHeight;
			listHolder.scrollRect = contentScrollRect;
			listHolder.cacheAsBitmap = useBitmapScrolling;
			// figure out which rows we have to render:
			var rowStartIndex:uint = Math.min(Math.max(length - 1, 0), Math.floor(_verticalScrollPosition / rowHeight));
			var rowEndIndex:uint = Math.min(Math.max(length - 1, 0), rowStartIndex + rowCount + 1);

			var x:Number;
			var lastColWidth:Number;
			var i:uint;
			var item:Object;
			var renderer:ICellRenderer;
			var activeRenderers:Array;
			var col:DataGridColumn;
			var listHovered:Boolean = list.hitTestPoint(stage.mouseX, stage.mouseY);

			calculateColumnSizes();

			// create a dictionary for looking up the new "displayed" items:
			var itemHash:Dictionary = renderedItems = new Dictionary(true);
			if(length > 0) {
				for (i = rowStartIndex; i <= rowEndIndex; i++) {
					itemHash[_dataProvider.getItemAt(i)] = true;
				}
			}

			// calculate x coordinate of first visible column
			x = 0;
			var firstVisibleColumn:DataGridColumn = visibleColumns[0] as DataGridColumn;
			for(i = 0; i < displayableColumns.length; i++) {
				var displayableColumn:DataGridColumn = displayableColumns[i] as DataGridColumn;
				if(displayableColumn != firstVisibleColumn) {
					x += displayableColumn.width;
				} else {
					break;
				}
			}

			while(header.numChildren > 0) { header.removeChildAt(0); }

			dragHandlesMap = new Dictionary(true);

			var rendererSprite:Sprite;
			var rendererUIC:UIComponent;

			var visibleColumnsIndices:Array = [];
			var visibleColumnsLen:uint = visibleColumns.length;
			for (var ci:uint = 0; ci < visibleColumnsLen; ci++)
			{
				col = visibleColumns[ci] as DataGridColumn;

				visibleColumnsIndices.push(col.colNum);

				if(showHeaders) {
					var headerRendererSkin:Object = (col.headerRenderer != null) ? col.headerRenderer : _headerRenderer;
					var headerRenderer:HeaderRenderer = getDisplayObjectInstance(headerRendererSkin) as HeaderRenderer;
					if (headerRenderer != null) {
						headerRenderer.addEventListener(MouseEvent.CLICK, handleHeaderRendererClick, false, 0, true);
						headerRenderer.x = x;
						headerRenderer.y = 0;
						
						headerRenderer.setSize(col.width, headerHeight);
						headerRenderer.column = col.colNum;
						headerRenderer.label = col.headerText;
						header.addChildAt(headerRenderer, ci);
						// set styles
						copyStylesToChild(headerRenderer, HEADER_STYLES);
						// set sort arrow
						if((sortIndex == -1 && lastSortIndex == -1) || (col.colNum != sortIndex)) {
							headerRenderer.setStyle("icon", null);
						} else {
							headerRenderer.setStyle("icon", sortDescending ? getStyleValue("headerSortArrowAscSkin") : getStyleValue("headerSortArrowDescSkin"));
						}
						// add resize drag handles
						if(ci < visibleColumnsLen - 1 && resizableColumns && col.resizable) {
							var dragHandle:Sprite = new Sprite();
							var g:Graphics = dragHandle.graphics;
							g.beginFill(0, 0);
							g.drawRect(0, 0, 3, headerHeight);
							g.endFill();
							dragHandle.x = x + col.width - 2;
							dragHandle.y = 0;
							dragHandle.alpha = 0;
							dragHandle.addEventListener(MouseEvent.MOUSE_OVER, handleHeaderResizeOver, false, 0, true);
							dragHandle.addEventListener(MouseEvent.MOUSE_OUT, handleHeaderResizeOut, false, 0, true);
							dragHandle.addEventListener(MouseEvent.MOUSE_DOWN, handleHeaderResizeDown, false, 0, true);
							header.addChild(dragHandle);
							dragHandlesMap[dragHandle] = col.colNum;
						}
						if(ci == visibleColumnsLen - 1 && _horizontalScrollPosition == 0 && availableWidth > x + col.width) {
							// adjust width of rightmost column in case it doesn't 
							// fill the available width of the grid
							lastColWidth = Math.floor(availableWidth - x);
							headerRenderer.setSize(lastColWidth, headerHeight);
						} else {
							lastColWidth = col.width;
						}
						// force an immediate draw (because render event will not be called on the renderer):
						headerRenderer.drawNow();
					}
				}

				var colCellRenderer:Object = (col.cellRenderer != null) ? col.cellRenderer : _cellRenderer;
				var availableRenderers:Array = availableCellRenderersMap[col];
				activeRenderers = activeCellRenderersMap[col];
				if(activeRenderers == null) {
					activeCellRenderersMap[col] = activeRenderers = [];
				}
				if(availableRenderers == null) {
					availableCellRenderersMap[col] = availableRenderers = [];
				}

				// find cell renderers that are still active, and make those that aren't active available:
				var itemToRendererHash:Dictionary = new Dictionary(true);
				while (activeRenderers.length > 0) {
					renderer = activeRenderers.pop();
					item = renderer.data;
					if (itemHash[item] == null || invalidItems[item] == true) {
						availableRenderers.push(renderer);
					} else {
						itemToRendererHash[item] = renderer;
						// prevent problems with duplicate objects:
						invalidItems[item] = true;
					}
					list.removeChild(renderer as DisplayObject);
				}

				// draw cell renderers:
				if(length > 0) {
					for (i = rowStartIndex; i <= rowEndIndex; i++) {
						var reused:Boolean = false;
						item = _dataProvider.getItemAt(i);
						if (itemToRendererHash[item] != null) {
							// existing renderer for this item we can reuse:
							reused = true;
							renderer = itemToRendererHash[item];
							delete(itemToRendererHash[item]);
						} else if (availableRenderers.length > 0) {
							// recycle an old renderer:
							renderer = availableRenderers.pop() as ICellRenderer;
						} else {
							// out of renderers, create a new one:
							renderer = getDisplayObjectInstance(colCellRenderer) as ICellRenderer;
							rendererSprite = renderer as Sprite;
							if (rendererSprite != null) {
								rendererSprite.addEventListener(MouseEvent.CLICK,handleCellRendererClick,false,0,true);
								rendererSprite.addEventListener(MouseEvent.ROLL_OVER,handleCellRendererMouseEvent,false,0,true);
								rendererSprite.addEventListener(MouseEvent.ROLL_OUT,handleCellRendererMouseEvent,false,0,true);
								rendererSprite.addEventListener(Event.CHANGE,handleCellRendererChange,false,0,true);
								rendererSprite.doubleClickEnabled = true;
								rendererSprite.addEventListener(MouseEvent.DOUBLE_CLICK,handleCellRendererDoubleClick,false,0,true);
								
								if (rendererSprite["setStyle"] != null) {
									for (var n:String in rendererStyles) {
										rendererSprite["setStyle"](n, rendererStyles[n]);	
									}
								}
								
							}
						}
						list.addChild(renderer as Sprite);
						activeRenderers.push(renderer);

						renderer.x = x;
						renderer.y = rowHeight * (i - rowStartIndex);
						renderer.setSize((ci == visibleColumnsLen - 1) ? lastColWidth : col.width, rowHeight);

						if (!reused) {
							renderer.data = item;
						}
						renderer.listData = new ListData(columnItemToLabel(col.colNum, item), null, this, i, i, ci);
						
						if(listHovered && isHovered(renderer)) {
							renderer.setMouseState("over");
							currentHoveredRow = i;
						} else {
							renderer.setMouseState("up");
						}
						
						renderer.selected = (_selectedIndices.indexOf(i) != -1);

						// force an immediate draw (because render event will not be called on the renderer):
						if (renderer is UIComponent) {
							rendererUIC = renderer as UIComponent;
							rendererUIC.drawNow();
						}
					}
				}

				x += col.width;
			}

			// remove renderers for columns that are no longer visible
			for (i = 0; i < _columns.length; i++) {
				if(visibleColumnsIndices.indexOf(i) == -1) {
					removeCellRenderersByColumn(_columns[i] as DataGridColumn);
				}
			}

			if (editedItemPositionChanged) {
				editedItemPositionChanged = false;
				commitEditedItemPosition(proposedEditedItemPosition);
				proposedEditedItemPosition = undefined;
			}

			invalidItems = new Dictionary(true);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function updateRendererStyles():void {
			var renderers:Array = [];
			for (var n:Object in availableCellRenderersMap) {
				renderers = renderers.concat(availableCellRenderersMap[n]);
			}			
			for (n in activeCellRenderersMap) {
				renderers = renderers.concat(activeCellRenderersMap[n]);
			}
			
			var l:uint = renderers.length;
			for (var i:uint=0; i<l; i++) {
				if (renderers[i]["setStyle"] == null) { continue; }
				for (var m:String in updatedRendererStyles) {
					renderers[i].setStyle(m, updatedRendererStyles[m]);
				}
				renderers[i].drawNow();
			}
			updatedRendererStyles = {};
		}


		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function removeCellRenderers():void {
			for (var i:uint = 0; i < _columns.length; i++) {
				removeCellRenderersByColumn(_columns[i] as DataGridColumn);
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function removeCellRenderersByColumn(col:DataGridColumn):void {
			if(col == null) { return; }
			var activeRenderers:Array = activeCellRenderersMap[col];
			if(activeRenderers != null) {
				while (activeRenderers.length > 0) {
					list.removeChild(activeRenderers.pop() as DisplayObject);
				}
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function handleCellRendererMouseEvent(event:MouseEvent):void {
			var renderer:ICellRenderer = event.target as ICellRenderer;
			if(renderer) {
				var row:int = renderer.listData.row;
				var mouseMode:String;
				if(event.type == MouseEvent.ROLL_OVER) {
					mouseMode = "over";
				} else if(event.type == MouseEvent.ROLL_OUT) {
					mouseMode = "up";
				}
				if(mouseMode) {
					for(var i:uint = 0; i < visibleColumns.length; i++) {
						var col:DataGridColumn = visibleColumns[i] as DataGridColumn;
						var cellRenderer:ICellRenderer = getCellRendererAt(row, col.colNum);
						if(cellRenderer) {
							cellRenderer.setMouseState(mouseMode);
						}
						if(row != currentHoveredRow) {
							cellRenderer = getCellRendererAt(currentHoveredRow, col.colNum);
							if(cellRenderer) {
								cellRenderer.setMouseState("up");
							}
						}
					}
				}
			}
			super.handleCellRendererMouseEvent(event);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function isHovered(renderer:ICellRenderer):Boolean {
			var rowStartIndex:uint = Math.min(Math.max(length - 1, 0), Math.floor(_verticalScrollPosition / rowHeight));
			var rowYPos:Number = (renderer.listData.row - rowStartIndex) * rowHeight;
			var pt:Point = list.globalToLocal(new Point(0, stage.mouseY));
			return (pt.y > rowYPos) && (pt.y < rowYPos + rowHeight);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function setHorizontalScrollPosition(scroll:Number, fireEvent:Boolean = false):void {
			if (scroll == _horizontalScrollPosition) { return; }
			contentScrollRect = listHolder.scrollRect;
			contentScrollRect.x = scroll;
			listHolder.scrollRect = contentScrollRect;
			list.x = 0;
			header.x = -scroll;
			super.setHorizontalScrollPosition(scroll, true);
			invalidate(InvalidationType.SCROLL);
			columnsInvalid = true;
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function setVerticalScrollPosition(scroll:Number,fireEvent:Boolean=false):void {
			if (itemEditorInstance) { endEdit(DataGridEventReason.OTHER); }
			invalidate(InvalidationType.SCROLL);
			super.setVerticalScrollPosition(scroll, true);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function columnItemToLabel(columnIndex:uint, item:Object):String {
			var col:DataGridColumn = _columns[columnIndex] as DataGridColumn;
			if(col != null) {
				return col.itemToLabel(item);
			}
			return " ";
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function calculateColumnSizes():void {
			var delta:Number;
			var n:int;
			var i:int;
			var totalWidth:Number = 0;
			var col:DataGridColumn;
			if (_columns.length == 0) {
				visibleColumns = [];
				displayableColumns = [];
				return;
			}
			if (columnsInvalid) {
				columnsInvalid = false;
				visibleColumns = [];
				if (minColumnWidthInvalid) {
					n = _columns.length;
					for (i = 0; i < n; i++) {
						_columns[i].minWidth = minColumnWidth;
					}
					minColumnWidthInvalid = false;
				}
				displayableColumns = null;
				n = _columns.length;
				for (i = 0; i < n; i++) {
					if (displayableColumns && _columns[i].visible) {
						displayableColumns.push(_columns[i]);
					} else if (!displayableColumns && !_columns[i].visible) {
						displayableColumns = new Array(i);
						for (var k:int = 0; k < i; k++) {
							displayableColumns[k] = _columns[k];
						}
					}
				}
				// If there are no hidden columns, displayableColumns points to
				// _columns (we don't need a duplicate copy of _columns).
				if (!displayableColumns) {
					displayableColumns = _columns;
				}
				if (horizontalScrollPolicy == ScrollPolicy.OFF) {
					// if no hscroll, then pack all columns in available space
					n = displayableColumns.length;
					for (i = 0; i < n; i++) {
						visibleColumns.push(displayableColumns[i]);
					}
				} else {
					// check which of the displayable columns are actually visible
					n = displayableColumns.length;
					var xCol:Number = 0;
					for (i = 0; i < n; i++) {
						col = displayableColumns[i] as DataGridColumn;
						if(xCol + col.width > _horizontalScrollPosition && xCol < _horizontalScrollPosition + availableWidth) {
							visibleColumns.push(col);
						}
						xCol += col.width;
					}
				}
			}

			var lastColumn:DataGridColumn;
			var newSize:Number;

			if (horizontalScrollPolicy == ScrollPolicy.OFF) {
				// if no hscroll, then pack all columns in available space
				var numResizable:int = 0;
				var fixedWidth:Number = 0;
				// count how many resizable columns and how wide they are
				n = visibleColumns.length;
				for (i = 0; i < n; i++) {
					col = visibleColumns[i] as DataGridColumn;
					if (col.resizable) {
						if (!isNaN(col.explicitWidth)) {
							// explicit width
							fixedWidth += col.width;
						} else {
							// implicitly resizable
							numResizable++;
							fixedWidth += col.minWidth;
						}
					} else {
						// not resizable
						fixedWidth += col.width;
					}
					totalWidth += col.width;
				}
				var ratio:Number;
				var newTotal:Number = availableWidth;
				var minWidth:Number;
				if ((availableWidth > fixedWidth) && numResizable) {
					// we have flexible columns and room to honor minwidths and non-resizable
					// divide and distribute the excess among the resizable
					n = visibleColumns.length;
					for (i = 0; i < n; i++) {
						col = visibleColumns[i] as DataGridColumn;
						if (col.resizable && isNaN(col.explicitWidth)) {
							lastColumn = col;
							if (totalWidth > availableWidth) {
								ratio = (lastColumn.width - lastColumn.minWidth) / (totalWidth - fixedWidth);
							} else {
								ratio = lastColumn.width / totalWidth;
							}
							newSize = lastColumn.width - (totalWidth - availableWidth) * ratio;
							minWidth = col.minWidth;
							col.setWidth(Math.max(newSize, minWidth));
						}
						newTotal -= col.width;
					}
					if (newTotal && lastColumn) {
						lastColumn.setWidth(lastColumn.width + newTotal);
					}
				} else {
					// can't honor minwidth and non-resizables so just scale everybody
					n = visibleColumns.length;
					for (i = 0; i < n; i++) {
						lastColumn = visibleColumns[i] as DataGridColumn;
						ratio = lastColumn.width / totalWidth;
						newSize = availableWidth * ratio;
						lastColumn.setWidth(newSize);
						lastColumn.explicitWidth = NaN;
						newTotal -= newSize;
					}
					if (newTotal && lastColumn) {
						lastColumn.setWidth(lastColumn.width + newTotal);
					}
				}
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function calculateContentWidth():void {
			var n:int;
			var i:int;
			var col:DataGridColumn;
			if (_columns.length == 0) {
				contentWidth = 0;
				return;
			}
			if (minColumnWidthInvalid) {
				n = _columns.length;
				for (i = 0; i < n; i++) {
					col = _columns[i] as DataGridColumn;
					col.minWidth = minColumnWidth;
				}
				minColumnWidthInvalid = false;
			}
			if(horizontalScrollPolicy == ScrollPolicy.OFF) {
				contentWidth = availableWidth;
			} else {
				contentWidth = 0;
				n = _columns.length;
				for (i = 0; i < n; i++) {
					col = _columns[i] as DataGridColumn;
					if (col.visible) {
						contentWidth += col.width;
					}
				}
				if(!isNaN(_horizontalScrollPosition) && _horizontalScrollPosition + availableWidth > contentWidth) {
					setHorizontalScrollPosition(contentWidth - availableWidth);
				}
			}
		}


		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleHeaderRendererClick(event:MouseEvent):void {
			if (!_enabled) { return; }
			var headerRenderer:HeaderRenderer = event.currentTarget as HeaderRenderer;
			var columnIndex:uint = headerRenderer.column;
			var column:DataGridColumn = _columns[columnIndex] as DataGridColumn;
			if(sortableColumns && column.sortable) {
				var lastSortIndexTmp:uint = _sortIndex;
				_sortIndex = columnIndex;
				// this event is cancellable:
				var dataGridEvent:DataGridEvent = new DataGridEvent(
					DataGridEvent.HEADER_RELEASE,
					false,
					true,
					columnIndex,
					-1,
					headerRenderer,
					column ? column.dataField : null
				);
				if (!dispatchEvent(dataGridEvent) || !_selectable) {
					_sortIndex = lastSortIndex;
					return;
				}
				lastSortIndex = lastSortIndexTmp;
				// sort
				sortByColumn(columnIndex);
				invalidate(InvalidationType.DATA);
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function resizeColumn(columnIndex:int, w:Number):void {
			if(_columns.length == 0) { return; }
			var column:DataGridColumn = _columns[columnIndex] as DataGridColumn;
			if(!column) { return; }
			if (!visibleColumns || visibleColumns.length == 0) {
				column.setWidth(w);
				return;
			}
			if (w < column.minWidth) {
				w = column.minWidth;
			}
			if (_horizontalScrollPolicy == ScrollPolicy.ON || _horizontalScrollPolicy == ScrollPolicy.AUTO) {
				// hScrollBar is present, adjust the column's width
				column.setWidth(w);
				column.explicitWidth = w;
			} else {
				var index:int = getVisibleColumnIndex(column);
				if(index != -1) {
					// we want all cols's new widths to the right of this to be in proportion
					// to what they were before the stretch.

					// get the original space to the right not taken up by the column
					var totalSpace:Number = 0;
					var n:int = visibleColumns.length;
					var visibleColumn:DataGridColumn;
					var lastColumn:DataGridColumn;
					var i:int;
					var newWidth:Number;

					// non-resizable columns don't count though
					for (i = index + 1; i < n; i++) {
						visibleColumn = visibleColumns[i] as DataGridColumn;
						if (visibleColumn && visibleColumn.resizable) {
							totalSpace += visibleColumn.width;
						}
					}

					var newTotalSpace:Number = column.width - w + totalSpace;
					if (totalSpace) {
						column.setWidth(w);
						column.explicitWidth = w;
					}

					var totX:Number = 0;
					// resize the columns to the right proportionally to what they were
					for (i = index + 1; i < n; i++) {
						visibleColumn = visibleColumns[i] as DataGridColumn;
						if (visibleColumn.resizable) {
							newWidth = visibleColumn.width * newTotalSpace / totalSpace;
							if (newWidth < visibleColumn.minWidth) {
								newWidth = visibleColumn.minWidth;
							}
							visibleColumn.setWidth(newWidth);
							totX += visibleColumn.width;
							lastColumn = visibleColumn;
						}
					}

					if (totX > newTotalSpace) {
						// if excess then should be taken out only from changing column
						// cause others would have already gone to their minimum
						newWidth = column.width - totX + newTotalSpace;
						if (newWidth < column.minWidth) {
							newWidth = column.minWidth;
						}
						column.setWidth(newWidth);
					} else if (lastColumn) {
						// if less then should be added in last column
						// dont need to check for minWidth as we are adding
						lastColumn.setWidth(lastColumn.width - totX + newTotalSpace);
					}
				} else {
					column.setWidth(w);
					column.explicitWidth = w;
				}
			}
			columnsInvalid = true;
			invalidate(InvalidationType.SIZE);
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function sortByColumn(index:int):void {
			var col:DataGridColumn = columns[index] as DataGridColumn;
			if (!enabled || !col || !col.sortable) { return };
			var desc:Boolean = col.sortDescending;
			// prepare sort options
			var sortOptions:uint = col.sortOptions;
			if(desc) {
				sortOptions |= Array.DESCENDING;
			} else {
				sortOptions &= ~Array.DESCENDING;
			}
			// do the sort
			if(col.sortCompareFunction != null) {
				sortItems(col.sortCompareFunction, sortOptions);
			} else {
				sortItemsOn(col.dataField, sortOptions);
			}
			// inverse the sort order for next sort
			_sortDescending = col.sortDescending = !desc;
			// reset the sort order for last sorted column
			if(lastSortIndex >= 0 && lastSortIndex != sortIndex) {
				col = columns[lastSortIndex] as DataGridColumn;
				if(col != null) {
					col.sortDescending = false;
				}
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function createColumnsFromDataProvider():void {
			_columns = [];
			if(length > 0) {
				var item:Object = _dataProvider.getItemAt(0);
				for(var dataField:String in item) {
					addColumn(dataField);
				}
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function getVisibleColumnIndex(column:DataGridColumn):int {
			for(var i:uint = 0; i < visibleColumns.length; i++) {
				if(column == visibleColumns[i]) {
					return i;
				}
			}
			return -1;
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleHeaderResizeOver(event:MouseEvent):void {
			if(columnStretchIndex == -1) {
				showColumnStretchCursor();
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleHeaderResizeOut(event:MouseEvent):void {
			if(columnStretchIndex == -1) {
				showColumnStretchCursor(false);
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleHeaderResizeDown(event:MouseEvent):void {
			var dragHandle:Sprite = event.currentTarget as Sprite;
			var colNum:Number = dragHandlesMap[dragHandle];
			var col:DataGridColumn = getColumnAt(colNum);
			columnStretchIndex = colNum;
			columnStretchStartX = event.stageX;
			columnStretchStartWidth = col.width;
			UIComponent.stageAlias.addEventListener(MouseEvent.MOUSE_MOVE, handleHeaderResizeMove, false, 0, true);
			UIComponent.stageAlias.addEventListener(MouseEvent.MOUSE_UP, handleHeaderResizeUp, false, 0, true);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleHeaderResizeMove(event:MouseEvent):void {
			var delta:Number = event.stageX - columnStretchStartX;
			var newWidth:Number = columnStretchStartWidth + delta;
			resizeColumn(columnStretchIndex, newWidth);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleHeaderResizeUp(event:MouseEvent):void {
			var dragHandle:Sprite = event.currentTarget as Sprite;
			var column:DataGridColumn = _columns[columnStretchIndex] as DataGridColumn;
			var headerRenderer:HeaderRenderer;
			for(var i:uint = 0; i < header.numChildren; i++) {
				headerRenderer = header.getChildAt(i) as HeaderRenderer;
				if(headerRenderer && headerRenderer.column == columnStretchIndex) {
					break;
				}
			}
			var dataGridEvent:DataGridEvent = new DataGridEvent(
				DataGridEvent.COLUMN_STRETCH,
				false,
				true,
				columnStretchIndex,
				-1,
				headerRenderer,
				column ? column.dataField : null
			);
			dispatchEvent(dataGridEvent);
			columnStretchIndex = -1;
			showColumnStretchCursor(false);
			UIComponent.stageAlias.removeEventListener(MouseEvent.MOUSE_MOVE, handleHeaderResizeMove, false);
			UIComponent.stageAlias.removeEventListener(MouseEvent.MOUSE_UP, handleHeaderResizeUp, false);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function showColumnStretchCursor(show:Boolean = true):void {
			if(columnStretchCursor == null) {
				// create custom cursor
				columnStretchCursor = getDisplayObjectInstance(getStyleValue("columnStretchCursorSkin")) as Sprite;
				columnStretchCursor.mouseEnabled = false;
			}
			if(show) {
				Mouse.hide();
				UIComponent.stageAlias.addChild(columnStretchCursor);
				UIComponent.stageAlias.addEventListener(MouseEvent.MOUSE_MOVE, positionColumnStretchCursor, false, 0, true);
				columnStretchCursor.x = stage.mouseX;
				columnStretchCursor.y = stage.mouseY;
			} else {
				UIComponent.stageAlias.removeEventListener(MouseEvent.MOUSE_MOVE, positionColumnStretchCursor, false);
				if(UIComponent.stageAlias.contains(columnStretchCursor)) {
					UIComponent.stageAlias.removeChild(columnStretchCursor);
				}
				Mouse.show();
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function positionColumnStretchCursor(event:MouseEvent):void {
			columnStretchCursor.x = event.stageX;
			columnStretchCursor.y = event.stageY;
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setEditedItemPosition(coord:Object):void {
			editedItemPositionChanged = true;
			proposedEditedItemPosition = coord;
			if (coord && coord.rowIndex != selectedIndex) { selectedIndex = coord.rowIndex; }
			invalidate(InvalidationType.DATA);
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function commitEditedItemPosition(coord:Object):void {
			if (!enabled || !editable) {
				return;
			}
			// check if there already is an itemEditorInstance for this position
			if (itemEditorInstance && coord && itemEditorInstance is IFocusManagerComponent &&
					_editedItemPosition.rowIndex == coord.rowIndex &&
					_editedItemPosition.columnIndex == coord.columnIndex) {
				// just give focus back to the itemEditorInstance
				IFocusManagerComponent(itemEditorInstance).setFocus();
				return;
			}
			// dispose of any existing editor, saving away its data first
			if (itemEditorInstance) {
				var reason:String;
				if (!coord) {
					reason = DataGridEventReason.OTHER;
				} else {
					if(!editedItemPosition || coord.rowIndex == editedItemPosition.rowIndex) {
						reason = DataGridEventReason.NEW_COLUMN;
					} else {
						reason = DataGridEventReason.NEW_ROW;
					}
				}
				if (!endEdit(reason) && reason != DataGridEventReason.OTHER) {
					return;
				}
			}
			// store the value
			_editedItemPosition = coord;
			// allow setting of undefined to dispose item editor instance
			if (!coord) {
				return;
			}
			actualRowIndex = coord.rowIndex;
			actualColIndex = coord.columnIndex;
			if (displayableColumns.length != _columns.length) {
				for (var i:int = 0; i < displayableColumns.length; i++) {
					if (displayableColumns[i].colNum >= actualColIndex) {
						actualColIndex = displayableColumns[i].colNum;
						break;
					}
				}
				if (i == displayableColumns.length) {
					actualColIndex = 0;
				}
			}
			// scroll item into view
			scrollToPosition(actualRowIndex, actualColIndex);
			// get the actual references for the column, row, and item
			var renderer:ICellRenderer = getCellRendererAt(actualRowIndex, actualColIndex);
			var event:DataGridEvent = new DataGridEvent(
				DataGridEvent.ITEM_EDIT_BEGIN,
				false,
				true,
				actualColIndex,
				actualRowIndex,
				renderer);
			dispatchEvent(event);
			// user may be trying to change the focused item renderer
			if (editedItemPositionChanged) {
				editedItemPositionChanged = false;
				commitEditedItemPosition(proposedEditedItemPosition);
				proposedEditedItemPosition = undefined;
			}
			if (!itemEditorInstance) {
				// assume that editing was cancelled
				commitEditedItemPosition(null);
			}
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function itemEditorItemEditBeginningHandler(event:DataGridEvent):void {
			if (!event.isDefaultPrevented()) {
				setEditedItemPosition( {columnIndex: event.columnIndex, rowIndex: uint(event.rowIndex) } );
			} else if (!itemEditorInstance) {
				_editedItemPosition = null;
				// return focus to the grid w/o selecting an item
				editable = false;
				setFocus();
				editable = true;
			}
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function itemEditorItemEditBeginHandler(event:DataGridEvent):void {
			if (stage) {
				// weak reference for deactivation
				UIComponent.stageAlias.addEventListener(Event.DEACTIVATE, deactivateHandler, false, 0, true);
			}
			if (!event.isDefaultPrevented()) {
				createItemEditor(event.columnIndex, uint(event.rowIndex));
				ICellRenderer(itemEditorInstance).listData = ICellRenderer(editedItemRenderer).listData;
				ICellRenderer(itemEditorInstance).data = editedItemRenderer.data;
				itemEditorInstance.imeMode = (columns[event.columnIndex].imeMode == null) ? _imeMode : columns[event.columnIndex].imeMode;
				var fm:IFocusManager = focusManager;
				if (itemEditorInstance is IFocusManagerComponent) {
					fm.setFocus(InteractiveObject(itemEditorInstance));
				}
				fm.defaultButtonEnabled = false;
				var event:DataGridEvent = new DataGridEvent(
					DataGridEvent.ITEM_FOCUS_IN,
					false,
					false,
					_editedItemPosition.columnIndex,
					_editedItemPosition.rowIndex,
					itemEditorInstance);
				dispatchEvent(event);
			}
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function itemEditorItemEditEndHandler(event:DataGridEvent):void {
			if (!event.isDefaultPrevented()) {
				var bChanged:Boolean = false;
				if (itemEditorInstance && event.reason != DataGridEventReason.CANCELLED) {
					var newData:Object = itemEditorInstance[_columns[event.columnIndex].editorDataField];
					var property:String = _columns[event.columnIndex].dataField;
					var data:Object = event.itemRenderer.data;
					var typeInfo:String = "";
					for each(var variable:XML in describeType(data).variable) {
						if (property == variable.@name.toString()) {
							typeInfo = variable.@type.toString();
							break;
						}
					}
					switch(typeInfo) {
						case "String":
							if (!(newData is String)) { newData = newData.toString(); }
							break;
						case "uint":
							if (!(newData is uint)) { newData = uint(newData); }
							break;
						case "int":
							if (!(newData is int)) { newData = int(newData); }
							break;
						case "Number":
							if (!(newData is Number)) { newData = Number(newData); }
							break;
					}
					if (data[property] != newData) {
						bChanged = true;
						data[property] = newData;
					}
					event.itemRenderer.data = data;
				}
			} else {
				if (event.reason != DataGridEventReason.OTHER) {
					if (itemEditorInstance && _editedItemPosition) {
						// edit session is continued so restore focus and selection
						if (selectedIndex != _editedItemPosition.rowIndex) {
							selectedIndex = _editedItemPosition.rowIndex;
						}
						var fm:IFocusManager = focusManager;
						if (itemEditorInstance is IFocusManagerComponent) {
							fm.setFocus(InteractiveObject(itemEditorInstance));
						}
					}
				}
			}
			if (event.reason == DataGridEventReason.OTHER || !event.isDefaultPrevented()) {
				destroyItemEditor();
			}
		}

		/**
		 *  @private (protected)
         *  When we get focus, focus an item renderer.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function focusInHandler(event:FocusEvent):void {
			if (event.target != this) {
				return;
			}
			if (losingFocus) {
				losingFocus = false;
				return;
			}
			setIMEMode(true);
			
			super.focusInHandler(event);
			// don't do this if we're mouse focused
			if (editable && !isPressed) {
				var foundOne:Boolean = (editedItemPosition != null);
				// start somewhere
				if (!_editedItemPosition) {
					_editedItemPosition = { rowIndex: 0, columnIndex: 0 };
					for (; _editedItemPosition.columnIndex < _columns.length; _editedItemPosition.columnIndex++) {
						// If the editedItemPosition is valid, focus it, otherwise find one.
						var col:DataGridColumn = _columns[_editedItemPosition.columnIndex] as DataGridColumn;
						if (col.editable && col.visible) {
							foundOne = true;
							break;
						}
					}
				}
				if (foundOne) {
					setEditedItemPosition(_editedItemPosition);
				}
			}
			if (editable) {
				addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
				addEventListener(MouseEvent.MOUSE_DOWN, mouseFocusChangeHandler);
			}
		}

		/**
		 *  @private (protected)
         *  When we lose focus, close the editor.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function focusOutHandler(event:FocusEvent):void {
			setIMEMode(false);
			if (event.target == this) {
				super.focusOutHandler(event);
			}
			// just leave if item editor is losing focus back to grid.  Usually happens
			// when someone clicks out of the editor onto a new item renderer.
			if (event.relatedObject == this && itemRendererContains(itemEditorInstance, DisplayObject(event.target))) {
				return;
			}
			// just leave if the cell renderer is losing focus to nothing while its editor exists.
			// this happens when we make the cell renderer invisible as we put up the editor
			// if the renderer can have focus.
			if (event.relatedObject == null && itemRendererContains(editedItemRenderer, DisplayObject(event.target))) {
				return;
			}
			// just leave if item editor is losing focus to nothing.  Usually happens
			// when someone clicks out of the textfield
			if (event.relatedObject == null && itemRendererContains(itemEditorInstance, DisplayObject(event.target))) {
				return;
			}
			// however, if we're losing focus to anything other than the editor or the grid
			// hide the editor;
			if (itemEditorInstance && (!event.relatedObject || !itemRendererContains(itemEditorInstance, event.relatedObject))) {
				endEdit(DataGridEventReason.OTHER);
				removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseFocusChangeHandler);
			}
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function editorMouseDownHandler(event:MouseEvent):void {
			if (!itemRendererContains(itemEditorInstance, DisplayObject(event.target))) {
				if(event.target is ICellRenderer && contains(DisplayObject(event.target))) {
					var cr:ICellRenderer = event.target as ICellRenderer;
					var row:uint = cr.listData.row;
					if(_editedItemPosition.rowIndex == row) {
						endEdit(DataGridEventReason.NEW_COLUMN);
					} else {
						endEdit(DataGridEventReason.NEW_ROW);
					}
				} else {
					endEdit(DataGridEventReason.OTHER);
				}
			}
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function editorKeyDownHandler(event:KeyboardEvent):void {
			// ESC just kills the editor, no new data
			if (event.keyCode == Keyboard.ESCAPE) {
				endEdit(DataGridEventReason.CANCELLED);
			} else if (event.ctrlKey && event.charCode == 46) {
				// Check for Ctrl-.
				endEdit(DataGridEventReason.CANCELLED);
			} else if (event.charCode == Keyboard.ENTER && event.keyCode != 229) {
				// Enter edits the item, moves down a row
				// The 229 keyCode is for IME compatability. When entering an IME expression,
				// the enter key is down, but the keyCode is 229 instead of the enter key code.
				if (endEdit(DataGridEventReason.NEW_ROW)) {
					findNextEnterItemRenderer(event);
				}
			}
		}

		/**
		 *  @private (protected)
		 *  Determines the next item renderer to navigate to using the Tab key.
		 *  If the item renderer to be focused falls out of range (the end or beginning
         *  of the grid) then move focus outside the grid.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function findNextItemRenderer(shiftKey:Boolean):Boolean {
			if (!_editedItemPosition) {
				return false;
			}
			// some other thing like a collection change has changed the
			// position, so bail and wait for commit to reset the editor.
			if (proposedEditedItemPosition !== undefined) {
				return false;
			}
			var rowIndex:int = _editedItemPosition.rowIndex;
			var colIndex:int = _editedItemPosition.columnIndex;
			var found:Boolean = false;
			var incr:int = shiftKey ? -1 : 1;
			var maxIndex:int = length - 1;
			// cycle till we find something worth focusing, or the end of the grid
			while (!found) {
				// go to next column
				colIndex += incr;
				if (colIndex < 0 || colIndex >= _columns.length) {
					// if we fall off the end of the columns, wrap around
					colIndex = (colIndex < 0) ? _columns.length - 1 : 0;
					// and increment/decrement the row index
					rowIndex += incr;
					if (rowIndex < 0 || rowIndex > maxIndex) {
						// if we've fallen off the rows, we need to leave the grid. get rid of the editor
						setEditedItemPosition(null);
						// set focus back to the grid so default handler will move it to the next component
						losingFocus = true;
						setFocus();
						return false;
					}
				}
				// if we find a visible and editable column, move to it
				if (_columns[colIndex].editable && _columns[colIndex].visible) {
					found = true;
					// kill the old edit session
					var reason:String;
					if(rowIndex == _editedItemPosition.rowIndex) {
						reason = DataGridEventReason.NEW_COLUMN
					} else {
						reason = DataGridEventReason.NEW_ROW
					}
					if (!itemEditorInstance || endEdit(reason)) {
						// send event to create the new one
						var dataGridEvent:DataGridEvent = new DataGridEvent(
							DataGridEvent.ITEM_EDIT_BEGINNING,
							false,
							true,
							colIndex,
							rowIndex);
						dataGridEvent.dataField = _columns[colIndex].dataField;
						dispatchEvent(dataGridEvent);
					}
				}
			}
			return found;
		}

		/**
		 *  @private (protected)
         *  Find the next item renderer down from the currently edited item renderer, and focus it.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function findNextEnterItemRenderer(event:KeyboardEvent):void {
			if (proposedEditedItemPosition !== undefined) {
				// some other thing has changed the position, so bail
				// and wait for commit to reset the editor.
				return;
			}
			var rowIndex:int = _editedItemPosition.rowIndex;
			var colIndex:int = _editedItemPosition.columnIndex;
			// modify direction with SHIFT (up or down)
			var newIndex:int = _editedItemPosition.rowIndex + (event.shiftKey ? -1 : 1);
			// only move if we're within range
			if (newIndex >= 0 && newIndex < length) {
				rowIndex = newIndex;
			}
			// send event to create the new one
			var dataGridEvent:DataGridEvent = new DataGridEvent(
				DataGridEvent.ITEM_EDIT_BEGINNING,
				false,
				true,
				colIndex,
				rowIndex);
			dataGridEvent.dataField = _columns[colIndex].dataField;
			dispatchEvent(dataGridEvent);
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function mouseFocusChangeHandler(event:MouseEvent):void {
			if (itemEditorInstance &&
				!event.isDefaultPrevented() &&
				itemRendererContains(itemEditorInstance, DisplayObject(event.target)))
			{
				event.preventDefault();
			}
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function keyFocusChangeHandler(event:FocusEvent):void {
			if (event.keyCode == Keyboard.TAB && !event.isDefaultPrevented() && findNextItemRenderer(event.shiftKey)) {
				event.preventDefault();
			}
		}

		/**
		 *  @private
         *  Hides the itemEditorInstance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private function itemEditorFocusOutHandler(event:FocusEvent):void {
			if (event.relatedObject && contains(event.relatedObject)) {
				return;
			}
			// ignore textfields losing focus on mousedowns
			if (!event.relatedObject) {
				return;
			}
			if (itemEditorInstance) {
				endEdit(DataGridEventReason.OTHER);
			}
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function deactivateHandler(event:Event):void {
			// if stage losing activation, set focus to DG so when we get it back
			// we popup an editor again
			if (itemEditorInstance) {
				endEdit(DataGridEventReason.OTHER);
				losingFocus = true;
				setFocus();
			}
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function mouseDownHandler(event:MouseEvent):void {
			if (!enabled || !selectable) { return; }
			isPressed = true;
		}

		/**
         *  @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function mouseUpHandler(event:MouseEvent):void {
			if (!enabled || !selectable) { return; }
			isPressed = false;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function handleCellRendererClick(event:MouseEvent):void {
			super.handleCellRendererClick(event);
			var renderer:ICellRenderer = event.currentTarget as ICellRenderer;
			if (renderer && renderer.data && renderer != itemEditorInstance /*&& lastItemDown == r*/) {
				var col:DataGridColumn = _columns[renderer.listData.column] as DataGridColumn;
				if (editable && col && col.editable /*&& !dontEdit*/) {
					var dgEvent:DataGridEvent = new DataGridEvent(
						DataGridEvent.ITEM_EDIT_BEGINNING,
						false,
						true,
						renderer.listData.column,
						renderer.listData.row,
						renderer,
						col.dataField);
					dispatchEvent(dgEvent);
				}
			}
		}

		/**
		 *  Uses the editor specified by the <code>itemEditor</code> property to 
		 *  create an item editor for the item renderer at the column and row index 
		 *  identified by the <code>editedItemPosition</code> property.
		 *
		 *  <p>This method sets the editor instance as the <code>itemEditorInstance</code> 
		 *  property.</p>
		 *
		 *  <p>You can call this method from the event listener for the <code>itemEditBegin</code> 
		 *  event. To create an editor from other code, set the <code>editedItemPosition</code> 
		 *  property to generate the <code>itemEditBegin</code> event.</p>
		 *
		 *  @param colIndex The column index of the item to be edited in the data provider.
         *  @param rowIndex The row index of the item to be edited in the data provider.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function createItemEditor(colIndex:uint, rowIndex:uint):void {
			if (displayableColumns.length != _columns.length) {
				for (var i:int = 0; i < displayableColumns.length; i++) {
					if (displayableColumns[i].colNum >= colIndex) {
						colIndex = displayableColumns[i].colNum;
						break;
					}
				}
				if (i == displayableColumns.length) {
					colIndex = 0;
				}
			}
			var col:DataGridColumn = _columns[colIndex] as DataGridColumn;
			var renderer:ICellRenderer = getCellRendererAt(rowIndex, colIndex);
			// if this isn't implemented, use an input control as editor
			if (!itemEditorInstance) {
				itemEditorInstance = getDisplayObjectInstance(col.itemEditor);
				itemEditorInstance.tabEnabled = false;
				list.addChild(DisplayObject(itemEditorInstance));
			}
			list.setChildIndex(DisplayObject(itemEditorInstance), list.numChildren - 1);
			// give it the right size, look and placement
			var rendererSprite:Sprite = renderer as Sprite;
			itemEditorInstance.visible = true;
			itemEditorInstance.move(rendererSprite.x, rendererSprite.y);
			itemEditorInstance.setSize(col.width, rowHeight);
			itemEditorInstance.drawNow();
			DisplayObject(itemEditorInstance).addEventListener(FocusEvent.FOCUS_OUT, itemEditorFocusOutHandler);
			rendererSprite.visible = false;
			// listen for keyStrokes on the itemEditorInstance (which lets the grid supervise for ESC/ENTER)
			DisplayObject(itemEditorInstance).addEventListener(KeyboardEvent.KEY_DOWN, editorKeyDownHandler);
			// we disappear on any mouse down outside the editor
			UIComponent.stageAlias.addEventListener(MouseEvent.MOUSE_DOWN, editorMouseDownHandler, true, 0, true);
		}

		/**
		 *  Closes an item editor that is currently open on an item renderer. This method is 
		 *  typically called from the event listener for the <code>itemEditEnd</code> event, 
		 *  after a call is made to the <code>preventDefault()</code> method to prevent the 
		 *  default event listener from executing.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function destroyItemEditor():void {
			if (itemEditorInstance) {
				DisplayObject(itemEditorInstance).removeEventListener(KeyboardEvent.KEY_DOWN, editorKeyDownHandler);
				UIComponent.stageAlias.removeEventListener(MouseEvent.MOUSE_DOWN, editorMouseDownHandler, true);
				var event:DataGridEvent = new DataGridEvent(
					DataGridEvent.ITEM_FOCUS_OUT,
					false,
					false,
					_editedItemPosition.columnIndex,
					_editedItemPosition.rowIndex,
					itemEditorInstance);
				dispatchEvent(event);
				// FocusManager.removeHandler() does not find
				// itemEditors in focusableObjects[] array
				// and hence does not remove the focusRectangle
				if (itemEditorInstance && itemEditorInstance is UIComponent) {
					UIComponent(itemEditorInstance).drawFocus(false);
				}
				// must call removeChild() so FocusManager.lastFocus becomes null
				list.removeChild(DisplayObject(itemEditorInstance));
				DisplayObject(editedItemRenderer).visible = true;
				itemEditorInstance = null;
			}
		}

		/**
		 *  @private (protected)
		 *  This method is called after the user finishes editing an item.
         *  It dispatches the <code>itemEditEnd</code> event to start the process
		 *  of copying the edited data from
         *  the <code>itemEditorInstance</code> to the data provider and hiding the <code>itemEditorInstance</code>.
         *  returns <code>true</code> if nobody called the <code>preventDefault()</code> method.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function endEdit(reason:String):Boolean {
			if (!editedItemRenderer) {
				return true;
			}
			//inEndEdit = true;
			var event:DataGridEvent = new DataGridEvent(
				DataGridEvent.ITEM_EDIT_END,
				false,
				true,
				editedItemPosition.columnIndex,
				editedItemPosition.rowIndex,
				editedItemRenderer,
				_columns[editedItemPosition.columnIndex].dataField,
				reason
			);
			dispatchEvent(event);
			return !event.isDefaultPrevented();
		}

        /**
         * Get the instance of a cell renderer at the specified position
         * in the DataGrid.
         *
         * <p><strong>Note:</strong> This method returns <code>null</code>
         * for positions that are not visible (i.e. scrolled out of the
         * view).</p>
         *
         * @param row A row index.
         * @param column A column index.
         *
         * @return The ICellRenderer object at the specified position, or
         * <code>null</code> if no cell renderer exists at that position.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function getCellRendererAt(row:uint, column:uint):ICellRenderer {
			// get the column
			var col:DataGridColumn = _columns[column] as DataGridColumn;
			if(col != null) {
				// get the active renderers for that column
				var activeRenderers:Array = activeCellRenderersMap[col] as Array;
				if(activeRenderers != null) {
					for(var i:uint = 0; i < activeRenderers.length; i++) {
						var renderer:ICellRenderer = activeRenderers[i] as ICellRenderer;
						// if the row matches, return the renderer
						if(renderer.listData.row == row) {
							return renderer;
						}
					}
				}
			}
			return null;
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function itemRendererContains(renderer:Object, object:DisplayObject):Boolean {
			if (!object || !renderer || !(renderer is DisplayObjectContainer)) { return false; }
			return DisplayObjectContainer(renderer).contains(object);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function handleDataChange(event:DataChangeEvent):void {
			super.handleDataChange(event);
			// if not already created, create columns from dataprovider
			if (_columns == null) { _columns = []; }
			if (_columns.length == 0) { createColumnsFromDataProvider(); }
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void {
			if (!selectable || itemEditorInstance) { return; }
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
					scrollToIndex(caretIndex);
					doKeySelection(caretIndex, event.shiftKey, event.ctrlKey);
					break;
				default:
					break;
			}
			event.stopPropagation();
		}

		/**
         * @private (protected)
		 *  Moves the selection in a horizontal direction in response
		 *  to the user selecting items using the left-arrow or right-arrow
		 *  keys and modifiers such as  the Shift and Ctrl keys.
		 *
		 *  <p>Not implemented in List because the default list
		 *  is single column and therefore doesn't scroll horizontally.</p>
		 *
		 *  @param code The key that was pressed (e.g. Keyboard.LEFT)
		 *  @param shiftKey <code>true</code> if the shift key was held down when
		 *  the keyboard key was pressed.
		 *  @param ctrlKey <code>true</code> if the ctrl key was held down when
         *  the keyboard key was pressed.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function moveSelectionHorizontally(code:uint, shiftKey:Boolean, ctrlKey:Boolean):void {}

		/**
         * @private (protected)
		 *  Moves the selection in a vertical direction in response
		 *  to the user selecting items using the up-arrow or down-arrow
		 *  Keys and modifiers such as the Shift and Ctrl keys.
		 *
		 *  @param code The key that was pressed (e.g. Keyboard.DOWN)
		 *  @param shiftKey <code>true</code> if the shift key was held down when
		 *  the keyboard key was pressed.
		 *  @param ctrlKey <code>true</code> if the ctrl key was held down when
         *  the keyboard key was pressed.
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
         * @copy fl.controls.SelectableList#scrollToIndex()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function scrollToIndex(newCaretIndex:int):void {
			drawNow();
			var lastVisibleItemIndex:int = Math.floor((_verticalScrollPosition + availableHeight) / rowHeight) - 1;
			var firstVisibleItemIndex:int = Math.ceil(_verticalScrollPosition / rowHeight);
			if(newCaretIndex < firstVisibleItemIndex) {
				verticalScrollPosition = newCaretIndex * rowHeight;
			} else if(newCaretIndex >= lastVisibleItemIndex) {
				var scrollBarHeight:Number = (_horizontalScrollPolicy == ScrollPolicy.ON || (_horizontalScrollPolicy == ScrollPolicy.AUTO && hScrollBar)) ? 15 : 0;
				verticalScrollPosition = (newCaretIndex + 1) * rowHeight - availableHeight + scrollBarHeight + (showHeaders ? headerHeight : 0);
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function scrollToPosition(rowIndex:int, columnIndex:int):void {
			var oldVerticalScrollPos:Number = verticalScrollPosition;
			var oldHorizontalScrollPos:Number = horizontalScrollPosition;
			
			// adjust vertical scroll if necessary
			scrollToIndex(rowIndex);

			// adjust horizontal scroll if necessary
			var i:uint;
			var x:Number = 0;
			var col:DataGridColumn = _columns[columnIndex] as DataGridColumn;
			for(i = 0; i < displayableColumns.length; i++) {
				var displayableColumn:DataGridColumn = displayableColumns[i] as DataGridColumn;
				if(displayableColumn != col) {
					x += displayableColumn.width;
				} else {
					break;
				}
			}
			if(horizontalScrollPosition > x) {
				horizontalScrollPosition = x;
			} else if(horizontalScrollPosition + availableWidth < x + col.width) {
				horizontalScrollPosition = -(availableWidth - (x + col.width));
			}

			if(oldVerticalScrollPos != verticalScrollPosition || oldHorizontalScrollPos != horizontalScrollPosition) {
				drawNow();
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
			} else if(ctrlKey) {
				// only moves the caret
				caretIndex = newCaretIndex;
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
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function initializeAccessibility():void {
			if (DataGrid.createAccessibilityImplementation != null) {
				DataGrid.createAccessibilityImplementation(this);
			}
		}
	}
}

