package com.custardbelly.as3couchdb.mediator
{
	/**
	 * ICouchDocumentActionMediator is a mediator for invoking service operations in relation to a target document.
	 * @author toddanderson
	 */
	public interface ICouchDocumentActionMediator extends IServiceMediator
	{
		/**
		 * Invokes service to read in document. 
		 * @param id String The unique id of the document held in the database.
		 */
		function handleRead( id:String ):void;
		/**
		 * Invokes service to save/update the document.
		 */
		function handleSave():void;
		/**
		 * Invokes service to delete the document.
		 */
		function handleDelete():void;
	}
}