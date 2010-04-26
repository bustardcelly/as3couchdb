/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchDatabaseActionMediator.as</p>
 * <p>Version: 0.5</p>
 *
 * <p>Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:</p>
 *
 * <p>The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.</p>
 *
 * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.</p>
 *
 * <p>Licensed under The MIT License</p>
 * <p>Redistributions of files must retain the above copyright notice.</p>
 */
package com.custardbelly.as3couchdb.mediator
{
	import com.custardbelly.as3couchdb.command.IRequestCommand;
	import com.custardbelly.as3couchdb.core.CouchDatabase;
	import com.custardbelly.as3couchdb.core.CouchModel;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchActionType;
	import com.custardbelly.as3couchdb.enum.CouchFaultType;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.responder.BasicCouchResponder;
	import com.custardbelly.as3couchdb.responder.CreateDatabaseResponder;
	import com.custardbelly.as3couchdb.responder.DeleteDatabaseResponder;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.responder.ReadAllDocumentsResponder;
	import com.custardbelly.as3couchdb.responder.ReadDatabaseResponder;
	import com.custardbelly.as3couchdb.responder.ReadDocumentsFromViewResponder;
	import com.custardbelly.as3couchdb.service.CouchDatabaseService;
	import com.custardbelly.as3couchdb.service.ICouchDatabaseService;
	import com.custardbelly.as3couchdb.service.ICouchRequest;

	/**
	 * CouchDatabaseActionMediator is an ICouchDatabaseActionMediator implementation that dos invoking operations on a service related to a given CouchDatabase instance. 
	 * @author toddanderson
	 */
	public class CouchDatabaseActionMediator implements ICouchDatabaseActionMediator
	{
		protected var _database:CouchDatabase;
		protected var _service:ICouchDatabaseService;
		/**
		 * @private
		 * A basic responder to do result and fault from service operations. 
		 */
		protected var _serviceResponder:BasicCouchResponder;
		
		/**
		 * Constructor.
		 */
		public function CouchDatabaseActionMediator()
		{
			// empty.
		}
		
		/**
		 * Initializes the mediator to establish the service in which to communicate actions related to the target model. 
		 * @param target CouchModel
		 * @param baseUrl String
		 * @param databaseName String
		 * @param request ICouchRequest The ICouchRequest implmementation to forward requests through.
		 */
		public function initialize( target:CouchModel, baseUrl:String, databaseName:String, request:ICouchRequest = null ):void
		{
			_database = target as CouchDatabase;
			_service = CouchDatabaseService.getDatabaseService( baseUrl, request );
			_serviceResponder = new BasicCouchResponder( handleServiceResult, handleServiceFault );
		}
		
		/**
		 * @private
		 * 
		 * Responder method for a successful service operation. 
		 * @param result CouchServiceResult
		 */
		protected function handleServiceResult( result:CouchServiceResult ):void
		{
			// Dispatch the event through the database instance.
			_database.dispatchEvent( new CouchEvent( result.action, result ) );
		}
		
		/**
		 * @private
		 * 
		 * Responder method for a fault in service operation. 
		 * @param fault CouchServiceFault
		 */
		protected function handleServiceFault( fault:CouchServiceFault ):void
		{
			// Dispatch the event through the database instance.
			_database.dispatchEvent( new CouchEvent( CouchEvent.FAULT, fault ) );
		}
		
		/**
		 * Invokes the ICouchDatabaseService to create a database based on current CouchDatabase target.
		 */
		public function doCreateIfNotExist():void
		{
			// Create responder for creation operation with basic responder.
			var readResponder:ICouchServiceResponder = new ReadDatabaseResponder( _database, CouchActionType.CREATE, _serviceResponder )
			// Invoke service to create database.
			var createRequestCommand:IRequestCommand = _service.createDatabase( _database.db_name );
			var readRequestCommand:IRequestCommand = _service.readDatabase( _database.db_name, readResponder );
			createRequestCommand.nextCommand = readRequestCommand;
			createRequestCommand.execute();
		}
		
		/**
		 * Invokes the ICouchDatabaseService to read in database properties to target CouchDatabase target. 
		 * @param action String The action associated with reading in values. Default CouchAction.READ.
		 */
		public function doRead( action:String = CouchActionType.READ ):void
		{
			var serviceResponder:ICouchServiceResponder = new ReadDatabaseResponder( _database, action, _serviceResponder );
			_service.readDatabase( _database.db_name, serviceResponder ).execute();
		}
		
		/**
		 * Invokes the ICouchDatabaseService to delete the database from the CouchDB instance.
		 */
		public function doDelete():void
		{
			var serviceResponder:ICouchServiceResponder = new DeleteDatabaseResponder( _database, _serviceResponder );
			_service.deleteDatabase( _database.db_name, serviceResponder ).execute();
		}
		
		/**
		 * Invokes the ICouchDatabaseService to request information related to target CouchDatabase.
		 */
		public function doInfo():void
		{
			_service.getDatabaseInfo( _database.db_name, _serviceResponder ).execute();
		}
		
		/**
		 * Invokes the ICouchDatabaseService to request changes related to the target CouchDatabase.
		 */
		public function doGetChanges():void
		{
			_service.getDatabaseChanges( _database.db_name, _serviceResponder ).execute();
		}
		
		/**
		 * Invokes the ICouchDatabaseService to compact the target CouchDatabase and perform optional cleanup. 
		 * @param cleanup Boolean
		 */
		public function doCompact( cleanup:Boolean ):void
		{
			_service.compactDatabase( _database.db_name, cleanup, _serviceResponder ).execute();
		}
		
		/**
		 * Invokes action mediator to return all documents related to database.
		 * Documents are returned as generic objects as _all_docs returns a list of all documents from a database, including _design docs.
		 * To return resolved documents to a model, see #getDocumentsFromView.
		 */
		public function doGetAllDocuments():void
		{
			var serviceResponder:ReadAllDocumentsResponder = new ReadAllDocumentsResponder( _serviceResponder );
			_service.getAllDocuments( _database.db_name, true, serviceResponder ).execute();
		}
		
		/**
		 * Invokes service to request documents based on design view map/reduce with optional key value filter. 
		 * @param documentClass String The fully qualified Class name. This is used to resolve results to a specific model type.
		 * @param designDocumentName String
		 * @param viewName String
		 * @param keyValue String
		 */
		public function doGetDocumentsFromView( documentClass:String, designDocumentName:String, viewName:String, keyValue:String ):void
		{
			var serviceResponder:ReadDocumentsFromViewResponder = new ReadDocumentsFromViewResponder( documentClass, _serviceResponder );
			_service.getDocumentsFromView( _database.db_name, designDocumentName, viewName, keyValue, serviceResponder ).execute();
		}
	}
}