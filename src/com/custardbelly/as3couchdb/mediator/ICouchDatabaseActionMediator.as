package com.custardbelly.as3couchdb.mediator
{
	/**
	 * ICouchDatabaseActionMediator is a mediator for invoking service operations relate to a target database. 
	 * @author toddanderson
	 */
	public interface ICouchDatabaseActionMediator extends IServiceMediator
	{
		/**
		 * Invokes service to create a database. If database exists, reads in database information.
		 */
		function handleCreateIfNotExist():void;
		/**
		 * Invokes service to read in database. 
		 * @param action String The resulting action from the operation.
 		 */
		function handleRead( action:String = null ):void;
		/**
		 * Invokes service to delete database.
		 */
		function handleDelete():void;
		/**
		 * Invokes service to request information related to a database.
		 */
		function handleInfo():void;
		/**
		 * Invokes service to request changes related to a database.
		 */
		function handleGetChanges():void;
		/**
		 * Invokes service to compact database and optionally perform cleanup. 
		 * @param cleanup Boolean
		 */
		function handleCompact( cleanup:Boolean ):void;
		/**
		 * Invokes service to request all documents and resolve each document as a type of supplied class. 
		 * @param documentClass String
		 */
		function handleGetAllDocuments( documentClass:String ):void;
	}
}