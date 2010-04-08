package com.custardbelly.couchdb.example.view.alert
{	
	import com.custardbelly.couchdb.example.event.ContactEvent;
	import com.custardbelly.couchdb.example.model.ContactDocument;
	
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	[Event(name="cancel", type="com.custardbelly.couchdb.example.event.ContactEvent")]
	[Event(name="delete", type="com.custardbelly.couchdb.example.event.ContactEvent")]
	
	[DefaultProperty("contact")]
	
	/**
	 * ContactDeleteForm is the view controller for a delete form involving a ContactDocument. 
	 * @author toddanderson
	 */
	public class ContactDeleteForm extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var alertField:spark.components.Label;
		
		[SkinPart(required="true")]
		public var submitButton:Button;
		
		[SkinPart(required="false")]
		public var cancelButton:Button;
		
		protected var _contact:ContactDocument;
		
		/**
		 * Constructor.
		 */
		public function ContactDeleteForm()
		{
			super();
		}
		
		/**
		 * @inherit
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			if( alertField )
				alertField.text = "Are you sure you want to delete: " + _contact.lastName + ", " + _contact.firstName + "?";
		}
		
		/**
		 * @inherit
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded( partName, instance );
			if( instance == submitButton )
			{
				submitButton.addEventListener( MouseEvent.CLICK, handleSubmitClick, false, 0, true );
			}
			else if( instance == cancelButton )
			{
				cancelButton.addEventListener( MouseEvent.CLICK, handleCancelClick, false, 0, true );
			}
		}
		
		/**
		 * @inherit
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved( partName, instance );
			if( instance == submitButton )
			{
				submitButton.removeEventListener( MouseEvent.CLICK, handleSubmitClick, false );
			}
			else if( instance == cancelButton )
			{
				cancelButton.removeEventListener( MouseEvent.CLICK, handleCancelClick, false );
			}
		}
		
		/**
		 * @private
		 * 
		 * Event handler for submittal of deletion of contact. 
		 * @param evt MouseEvent
		 */
		protected function handleSubmitClick( evt:MouseEvent ):void
		{
			dispatchEvent( new ContactEvent( ContactEvent.DELETE, _contact ) );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for cancel of deletion of contact. 
		 * @param evt MouseEvent
		 */
		protected function handleCancelClick( evt:MouseEvent ):void
		{
			dispatchEvent( new ContactEvent( ContactEvent.CANCEL, _contact ) );
		}
		
		/**
		 * Accessor/Modifier of the ContactDocument instance in question for delete. 
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