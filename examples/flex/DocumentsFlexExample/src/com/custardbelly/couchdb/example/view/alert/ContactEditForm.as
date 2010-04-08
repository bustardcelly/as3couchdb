package com.custardbelly.couchdb.example.view.alert
{
	import com.custardbelly.couchdb.example.event.ContactEvent;
	import com.custardbelly.couchdb.example.model.ContactDocument;
	
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.Panel;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	
	[Event(name="save", type="com.custardbelly.couchdb.example.event.ContactEvent")]
	[Event(name="cancel", type="com.custardbelly.couchdb.example.event.ContactEvent")]
	
	[DefaultProperty("contact")]
	
	/**
	 * ContactEditForm is a view controller for a user form to submit an update or creation of a ContactDocument. 
	 * @author toddanderson
	 */
	public class ContactEditForm extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var firstNameField:TextInput;
		
		[SkinPart(required="true")]
		public var lastNameField:TextInput;
		
		[SkinPart(required="true")]
		public var emailField:TextInput;
		
		[SkinPart(required="true")]
		public var saveButton:Button;
		
		[SkinPart(required="false")]
		public var cancelButton:Button;
		
		protected var _contact:ContactDocument;
		
		/**
		 * Constructor.
		 */
		public function ContactEditForm()
		{
			super();
		}
		
		/**
		 * @inherit
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			if( firstNameField )
				firstNameField.text = _contact.firstName;
			if( lastNameField )
				lastNameField.text = _contact.lastName;
			if( emailField )
				emailField.text = _contact.email;
		}
		
		/**
		 * @inherit
		 */
		override protected function partAdded( partName:String, instance:Object ):void
		{
			super.partAdded( partName, instance );
			if( instance == saveButton )
			{
				saveButton.addEventListener( MouseEvent.CLICK, handleSaveClick, false, 0, true );
			}
			else if( instance == cancelButton )
			{
				cancelButton.addEventListener( MouseEvent.CLICK, handleCancelClick, false, 0, true );
			}
		}
		
		/**
		 * @inherit
		 */
		override protected function partRemoved( partName:String, instance:Object ):void
		{
			super.partRemoved( partName, instance );
			
			if( instance == saveButton )
			{
				saveButton.removeEventListener( MouseEvent.CLICK, handleSaveClick, false );
			}
			else if( instance == cancelButton )
			{
				cancelButton.removeEventListener( MouseEvent.CLICK, handleCancelClick, false );
			}
		}
		
		/**
		 * @private
		 * 
		 * Event handler for confirmation of save to ContactDocument. 
		 * @param evt MouseEvent
		 */
		protected function handleSaveClick( evt:MouseEvent ):void
		{
			_contact.firstName = firstNameField.text;
			_contact.lastName = lastNameField.text;
			_contact.email = emailField.text;
			dispatchEvent( new ContactEvent( ContactEvent.SAVE, _contact ) );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for cancel of save for ContactDocument. 
		 * @param evt MouseEvent
		 */
		protected function handleCancelClick( evt:MouseEvent ):void
		{
			dispatchEvent( new ContactEvent( ContactEvent.CANCEL, _contact ) );
		}
		
		[Bindable]
		/**
		 * Accessor/Modifier for the ContactDocument in question to be saved. 
		 * @return ContactDocument
		 */
		public function get contact():ContactDocument
		{
			return _contact;
		}
		public function set contact( value:ContactDocument ):void
		{
			_contact = value;
		}
	}
}