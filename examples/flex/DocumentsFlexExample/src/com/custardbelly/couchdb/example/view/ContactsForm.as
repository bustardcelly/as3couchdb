package com.custardbelly.couchdb.example.view
{
	import com.custardbelly.as3couchdb.core.CouchDatabase;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchActionType;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.couchdb.example.event.ContactEvent;
	import com.custardbelly.couchdb.example.model.ContactDatabase;
	import com.custardbelly.couchdb.example.model.ContactDocument;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.events.StateChangeEvent;
	import mx.managers.PopUpManager;
	import mx.states.State;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.VGroup;
	
	/**
	 * ContactsForm is a main view controller for working with Database and Documents of a CouchDB instance using the contact models. 
	 * @author toddanderson
	 */
	public class ContactsForm extends VGroup
	{
		public var loadDatabaseButton:Button;
		public var deleteDatabaseButton:Button;
		public var infoDatabaseButton:Button;
		
		public var contactList:List;
		public var addContactButton:Button;
		
		protected var database:CouchDatabase;
		
		protected var contactPanel:ContactEditPanel;
		protected var deletePanel:ContactDeletePanel;
		
		[Bindable] public var contacts:ArrayCollection;
		
		public static const AVAILABLE_STATE:String = "availableState";
		public static const UNAVAILABLE_STATE:String = "unavailableState";
		
		/**
		 * Constructor.
		 */
		public function ContactsForm() 
		{
			super();
			contacts = new ArrayCollection();
			
			var availableState:State = new State();
			availableState.name = ContactsForm.AVAILABLE_STATE;
			var unavailableState:State = new State();
			unavailableState.name = ContactsForm.UNAVAILABLE_STATE;
			states = [availableState, unavailableState];
			
			addEventListener( StateChangeEvent.CURRENT_STATE_CHANGE, handleStateChange, false, 0, true );
			currentState = ContactsForm.UNAVAILABLE_STATE;
		}
		
		/**
		 * @inherit
		 */
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			loadDatabaseButton.addEventListener( MouseEvent.CLICK, loadDatabase, false, 1, true );
			deleteDatabaseButton.addEventListener( MouseEvent.CLICK, deleteDatabase, false, 0, true );
			infoDatabaseButton.addEventListener( MouseEvent.CLICK, infoDatabase, false, 0, true );
			
			contactList.addEventListener( ContactEvent.DELETE, handleDeleteContact );
			contactList.addEventListener( ContactEvent.EDIT, handleEditContact );
			
			addContactButton.addEventListener( MouseEvent.CLICK, handleAddClick, false, 0, true );
			
			BindingUtils.bindProperty( contactList, "dataProvider", this, "contacts" );
		}
		
		/**
		 * @private
		 * 
		 * Loads a new database based on contact database model. 
		 * @param evt Event
		 */
		protected function loadDatabase( evt:Event = null ):void
		{
			database = new ContactDatabase();
			database.addEventListener( CouchActionType.CREATE, handleCouchDatabaseReady, false, 0, true );
			database.addEventListener( CouchActionType.DELETE, handleCouchDatabaseDelete, false, 0, true );
			database.addEventListener( CouchEvent.RESULT, handleServiceResult, false, 0, true );
			database.addEventListener( CouchEvent.FAULT, handleServiceFault, false, 0, true );
			database.createIfNotExist();
		}
		
		/**
		 * @private
		 * 
		 * Deletes a database. 
		 * @param evt Event
		 */
		protected function deleteDatabase( evt:Event = null ):void
		{
			database.remove();
		}
		
		/**
		 * @private
		 * 
		 * Queries info about a database. 
		 * @param evt Event
		 */
		protected function infoDatabase( evt:Event = null ):void
		{
			database.info();
		}
		
		/**
		 * @private
		 * 
		 * Loads all documents from a database and resolves them to a contact document. 
		 * @param evt Event
		 */
		protected function loadContacts( evt:Event = null ):void
		{
			database.addEventListener( CouchActionType.READ_DOCUMENTS, handleReadAllDocuments );
			// Grab all the documents.
			database.getAllDocuments( "com.custardbelly.couchdb.example.model.ContactDocument" );
			// Access by design view.
			// For example, a this design doc resides in the contacts DB:
//			{
//				"_id" : "_design/contacts",
//				"views" : {
//					"all" : {
//						"map" : "function(doc){ emit(doc._id, doc) }"
//					},
//					"lastNames" : {
//						"map" : "function(doc){ emit(doc.lastName, doc) }"
//					}
//				}
//			}
//			The following request will return a list of contacts only with the lastName property equal to Anderson by hitting this url:
//			http://127.0.0.1:5984/contacts/_design/contacts/_view/lastNames?key="Anderson"
//			database.getDocumentsFromView( "com.custardbelly.couchdb.model.ContactDocument", "contacts", "lastNames", "Anderson" );
		}
		
		/**
		 * @private
		 * 
		 * Adds the edit panel to the PopUpManager for editing a new or exisiting contact. 
		 * @param contact ContactDocument
		 * @param title String
		 */
		protected function showEditPanel( contact:ContactDocument, title:String ):void
		{
			if( contactPanel == null )
			{
				contactPanel = new ContactEditPanel();
				contactPanel.addEventListener( ContactEvent.SAVE, handleContactSave, false, 0, true );
				contactPanel.addEventListener( ContactEvent.CANCEL, handleCancelEditContact, false, 0, true );
			}
			contactPanel.title = title;
			contactPanel.contact = contact;
			PopUpManager.addPopUp( contactPanel, Sprite(FlexGlobals.topLevelApplication), true );
			PopUpManager.centerPopUp( contactPanel );
		}
		
		/**
		 * @private 
		 * 
		 * Removes the edit panel from the PopUpManager.
		 */
		protected function hideEditPanel():void
		{
			PopUpManager.removePopUp( contactPanel );
		}
		
		/**
		 * @private
		 * 
		 * Adds the delete panel to the PopUpManager for deleting an existing contact. 
		 * @param contact ContactDocument
		 */
		protected function showDeletePanel( contact:ContactDocument ):void
		{
			if( deletePanel == null )
			{
				deletePanel = new ContactDeletePanel();
				deletePanel.addEventListener( ContactEvent.DELETE, handleContactDelete, false, 0, true );
				deletePanel.addEventListener( ContactEvent.CANCEL, handleCancelDeleteContact, false, 0, true );
			}
			deletePanel.contact = contact;
			PopUpManager.addPopUp( deletePanel, Sprite(FlexGlobals.topLevelApplication), true );
			PopUpManager.centerPopUp( deletePanel );
		}
		
		/**
		 * @private 
		 * 
		 * Removes the delete panel from the PopUpManager.
		 */
		protected function hideDeletePanel():void
		{
			PopUpManager.removePopUp( deletePanel );
		}
		
		protected function handleStateChange( evt:StateChangeEvent ):void
		{
			addContactButton.enabled = currentState == ContactsForm.AVAILABLE_STATE;
			deleteDatabaseButton.enabled = currentState == ContactsForm.AVAILABLE_STATE;
			infoDatabaseButton.enabled = currentState == ContactsForm.AVAILABLE_STATE;
			loadDatabaseButton.enabled = currentState != ContactsForm.AVAILABLE_STATE;
			
			if( currentState == ContactsForm.AVAILABLE_STATE )
				loadContacts();
			else
				contacts = new ArrayCollection();
		}
		
		/**
		 * @private
		 * 
		 * Event handler for read in of database, whether existant or newly created. 
		 * @param evt CouchEvent
		 */
		protected function handleCouchDatabaseReady( evt:CouchEvent ):void
		{
			currentState = ContactsForm.AVAILABLE_STATE;
		}
		
		/**
		 * @private
		 * 
		 * Event handle for delete of database. 
		 * @param evt CouchEvent
		 */
		protected function handleCouchDatabaseDelete( evt:CouchEvent ):void
		{
			currentState = ContactsForm.UNAVAILABLE_STATE;
		}
		
		/**
		 * @private
		 * 
		 * Eevnt handler for generic service result. 
		 * @param evt CouchEvent
		 */
		protected function handleServiceResult( evt:CouchEvent ):void
		{
			trace( evt.data );	
		}
		/**
		 * @private
		 * 
		 * Event handler for generic service fault. 
		 * @param evt CouchEvent
		 */
		protected function handleServiceFault( evt:CouchEvent ):void
		{
			trace( evt.data );	
		}
		
		/**
		 * @private
		 * 
		 * Event handler for success of read in all documents related to a database. 
		 * @param evt CouchEvent
		 */
		protected function handleReadAllDocuments( evt:CouchEvent ):void
		{
			database.removeEventListener( CouchActionType.READ_DOCUMENTS, handleReadAllDocuments, false );
			
			contacts = new ArrayCollection();
			var contactList:Array = ( evt.data as CouchServiceResult ).data as Array;
			var i:int = contactList.length;
			var contact:ContactDocument;
			while( --i > -1 )
			{
				contact = contactList[i] as ContactDocument;
				contact.addEventListener( CouchActionType.CREATE, handleContactSaveResult, false, 0, true );
				contact.addEventListener( CouchActionType.UPDATE, handleContactSaveResult, false, 0, true );
				contact.addEventListener( CouchActionType.DELETE, handleContactDeleteResult, false, 0, true );
				contact.addEventListener( CouchEvent.FAULT, handleContactFault, false, 0, true );
				contacts.addItem( contact );
			}
		}
		
		/**
		 * @private
		 * 
		 * Event handler for add request of a new contact.
		 * @param evt MouseEvent
		 */
		protected function handleAddClick( evt:MouseEvent ):void
		{
			var contact:ContactDocument = new ContactDocument();
			contact.addEventListener( CouchActionType.CREATE, handleContactSaveResult, false, 0, true );
			contact.addEventListener( CouchEvent.FAULT, handleContactFault, false, 0, true );
			showEditPanel( contact, "Add Contact:" );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for delete request of contact. 
		 * @param evt ContactEvent
		 */
		protected function handleDeleteContact( evt:ContactEvent ):void
		{
			var contact:ContactDocument = evt.contact;
			showDeletePanel( contact );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for edit request of a contact. 
		 * @param evt ContactEvent
		 */
		protected function handleEditContact( evt:ContactEvent ):void
		{
			var contact:ContactDocument = evt.contact;
			showEditPanel( contact, "Edit Contact:" );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for save request of a contact. 
		 * @param evt ContactEvent
		 */
		protected function handleContactSave( evt:ContactEvent ):void
		{
			var contact:ContactDocument = evt.contact;
			contact.addEventListener( CouchActionType.CREATE, handleContactSaveResult );
			contact.addEventListener( CouchActionType.UPDATE, handleContactSaveResult );
			contact.update();
			hideEditPanel();
		}
		
		/**
		 * @private
		 * 
		 * Event handler for cancel of edit/save of contact. 
		 * @param evt ContactEvent
		 */
		protected function handleCancelEditContact( evt:ContactEvent ):void
		{
			hideEditPanel();
		}
		
		/**
		 * @private
		 * 
		 * Event handle for delete request of contact. 
		 * @param evt ContactEvent
		 */
		protected function handleContactDelete( evt:ContactEvent ):void
		{
			var contact:ContactDocument = evt.contact;
			contact.remove();
		}
		
		/**
		 * @private
		 * 
		 * Event handler for cancel of delete of contact. 
		 * @param evt ContactEvent
		 */
		protected function handleCancelDeleteContact( evt:ContactEvent ):void
		{
			hideDeletePanel();
		}
		
		/**
		 * @private
		 * 
		 * Event handler for successful save of contact document. 
		 * @param evt CouchEvent
		 */
		protected function handleContactSaveResult( evt:CouchEvent ):void
		{
			loadContacts();
		}
		
		/**
		 * @private
		 * 
		 * Event handler for successful delete of contact document. 
		 * @param evt CouchEvent
		 */
		protected function handleContactDeleteResult( evt:CouchEvent ):void
		{
			hideDeletePanel();
			var result:CouchServiceResult = evt.data as CouchServiceResult;
			var data:ContactDocument = result.data as ContactDocument;
			var i:int = contacts.length;
			while( --i > -1 )
			{
				if( contacts.getItemAt( i ) == data )
					break;
			}
			contacts.removeItemAt( i );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for generic fault in couch request related to a contact document. 
		 * @param evt CouchEvent
		 */
		protected function handleContactFault( evt:CouchEvent ):void
		{
			trace( evt.type );
		}
	}
}