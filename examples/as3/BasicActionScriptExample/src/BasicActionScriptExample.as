package
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.List;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.core.CouchSession;
	import com.custardbelly.as3couchdb.core.CouchUser;
	import com.custardbelly.as3couchdb.enum.CouchActionType;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.mediator.CouchDatabaseActionMediator;
	import com.custardbelly.as3couchdb.mediator.CouchDocumentActionMediator;
	import com.custardbelly.as3couchdb.mediator.CouchSessionActionMediator;
	import com.custardbelly.as3couchdb.service.HTTPCouchRequest;
	import com.custardbelly.couchdb.example.model.ContactDatabase;
	import com.custardbelly.couchdb.example.model.ContactDocument;
	import com.custardbelly.couchdb.example.model.ContactSession;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * BasicActionScriptExample is a basic example of using the as3couchdb library within an AS3 project. 
	 * @author toddanderson
	 */
	public class BasicActionScriptExample extends Sprite
	{
		private var _loadDatabaseButton:PushButton;
		private var _loadContactsButton:PushButton;
		private var _list:List;
		private var _firstNameField:InputText;
		private var _lastNameField:InputText;
		private var _emailField:InputText;
		private var _addContactButton:PushButton;
		
		private var _database:ContactDatabase;
		private var _currentState:String = BasicActionScriptExample.STATE_NORMAL;
		
		private static const STATE_LOADING:String = "loadingState";
		private static const STATE_NORMAL:String = "normalState";
		private static const STATE_DB_LOADED:String = "dbLoadedState";
		
		/* Compile in external code not directly referenced within this codebase but used for model entity */
		private var includeHTTPRequest:HTTPCouchRequest; HTTPCouchRequest;
		private var includeCouchDBMediator:CouchDatabaseActionMediator; CouchDatabaseActionMediator;
		private var includeCouchDocMediator:CouchDocumentActionMediator; CouchDocumentActionMediator;
		private var includeCouchSessMediator:CouchSessionActionMediator; CouchSessionActionMediator;
		
		/**
		 * Constructor.
		 */
		public function BasicActionScriptExample()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			createChildren();
			setState( BasicActionScriptExample.STATE_NORMAL );
		}
		
		/**
		 * @private
		 * 
		 * Creates display children.
		 */
		protected function createChildren():void
		{
			/* Database controls */
			new Label( this, 20, 24, "Contact Database:" );
			_loadDatabaseButton = new PushButton( this, 150, 20, "load database", handleLoadDatabase );
			
			_list = new List( this, 20, 50 );
			_list.width = 230;
			_list.height = 200;
			
			_loadContactsButton = new PushButton( this, 20, 260, "load contacts", handleLoadContacts );
			
			/* Contact controls */
			new Label( this, 20, 295, "Add Contact:" );
			new Label( this, 20, 315, "First Name:" );
			_firstNameField = new InputText( this, 90, 315 );
			_firstNameField.width = 160;
			new Label( this, 20, 335, "Last Name:" );
			_lastNameField = new InputText( this, 90, 335 );
			_lastNameField.width = 160;
			new Label( this, 20, 355, "Email: " );
			_emailField = new InputText( this, 90, 355 );
			_emailField.width = 160;
			
			_addContactButton = new PushButton( this, 150, 375, "add contact", handleAddContact );
			
			/* Graphics */
			var shape:Shape = new Shape();
			shape.graphics.lineStyle( 1 );
			shape.graphics.moveTo( 10, 10 );
			shape.graphics.lineTo( 260, 10 );
			shape.graphics.lineTo( 260, 405 );
			shape.graphics.lineTo( 10, 405 );
			shape.graphics.lineTo( 10, 10 );
			shape.graphics.moveTo( 10, 290 );
			shape.graphics.lineTo( 260, 290 );
			addChild( shape );
		}
		
		/**
		 * @private
		 * 
		 * Sets the state of the application. 
		 * @param state String
		 */
		protected function setState( state:String ):void
		{
			_currentState = state;
			switch( state )
			{
				case BasicActionScriptExample.STATE_DB_LOADED:
					_loadDatabaseButton.enabled = false;
					_loadContactsButton.enabled = true;
					_firstNameField.enabled = _lastNameField.enabled = true;
					_emailField.enabled = true;
					_addContactButton.enabled = true;
					break;
				default:
					_loadDatabaseButton.enabled = true;
					_loadContactsButton.enabled = false;
					_firstNameField.enabled = _lastNameField.enabled = false;
					_emailField.enabled = false;
					_addContactButton.enabled = false;
					break;
			}
		}
		
		/**
		 * @private
		 * 
		 * Event handler for request of load for database. 
		 * @param evt Event
		 */
		protected function handleLoadDatabase( evt:Event ):void
		{
			_database = new ContactDatabase();
			_database.addEventListener( CouchActionType.CREATE, handleDatabaseRead, false, 0, true );
			_database.addEventListener( CouchEvent.FAULT, handleDatabaseFault, false, 0, true );
			_database.addEventListener( CouchActionType.READ_DOCUMENTS, handleAllDocumentsRead, false, 0, true );
			_database.createIfNotExist();
		}
		
		/**
		 * @private
		 * 
		 * Event handler to request load of all contact documents from CouchDB instance. 
		 * @param evt CouchEvent
		 */
		protected function handleLoadContacts( evt:MouseEvent ):void
		{
			_database.getAllDocuments("com.custardbelly.couchdb.example.model.ContactDocument");
		}
		
		/**
		 * @private
		 * 
		 * Event handle for request to add contact document to database of CouchDB instance. 
		 * @param evt MouseEvent
		 */
		protected function handleAddContact( evt:MouseEvent ):void
		{
			var contact:ContactDocument = new ContactDocument();
			contact.addEventListener( CouchActionType.CREATE, handleContactCreated );
			contact.firstName = _firstNameField.text;
			contact.lastName = _lastNameField.text;
			contact.email = _emailField.text;
			contact.create();
		}
		
		/**
		 * @private
		 * 
		 * Event handler for successful read in of database from CouchDB instance.
		 * @param evt CouchEvent
		 */
		protected function handleDatabaseRead( evt:CouchEvent ):void
		{
			setState( BasicActionScriptExample.STATE_DB_LOADED );
		}
		
		/**
		 * @private
		 * 
		 * Event handle for fault in read of database from CouchDB instance. 
		 * @param evt CouchEvent
		 */
		protected function handleDatabaseFault( evt:CouchEvent ):void
		{
			var fault:CouchServiceFault = evt.data as CouchServiceFault;
			trace( "[FAULT] " + getQualifiedClassName(this) + " :: " + fault.message );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for success in load of contact documents from database in CouchDB instance. 
		 * @param evt CouchEvent
		 */
		protected function handleAllDocumentsRead( evt:CouchEvent ):void
		{
			var result:CouchServiceResult = evt.data as CouchServiceResult;
			var data:Array = result.data as Array;
			var items:Array = [];
			var i:int;
			var contact:ContactDocument;
			for( i = 0; i < data.length; i++ )
			{
				contact = data[i] as ContactDocument;
				items.push( "Name: " + contact.lastName + ", " + contact.firstName + ". Email: " + contact.email );
			}
			_list.items = items;
		}
		
		/**
		 * @private
		 * 
		 * Event handler for success in creation of new couch document in CouchDB instance. 
		 * @param evt CouchEvent
		 */
		protected function handleContactCreated( evt:CouchEvent ):void
		{
			_firstNameField.text = "";
			_lastNameField.text = "";
			_emailField.text = "";
			handleLoadContacts( null );
		}
	}
}