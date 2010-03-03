/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchDatabaseActionMediator.as</p>
 * <p>Version: 0.1</p>
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
	import com.custardbelly.as3couchdb.core.CouchDatabase;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchActionType;
	import com.custardbelly.as3couchdb.enum.CouchFaultType;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.responder.BasicCouchResponder;
	import com.custardbelly.as3couchdb.responder.CreateDatabaseResponder;
	import com.custardbelly.as3couchdb.responder.DeleteDatabaseResponder;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.responder.ReadDatabaseResponder;
	import com.custardbelly.as3couchdb.service.ICouchDatabaseService;

	/**
	 * CouchDatabaseActionMediator is an ICouchDatabaseActionMediator implementation that handles invoking operations on a service related to a given CouchDatabase instance. 
	 * @author toddanderson
	 */
	public class CouchDatabaseActionMediator implements ICouchDatabaseActionMediator
	{
		protected var _database:CouchDatabase;
		protected var _service:ICouchDatabaseService;
		/**
		 * @private
		 * A basic responder to handle result and fault from service operations. 
		 */
		protected var _responder:BasicCouchResponder;
		
		/**
		 * Constructor. 
		 * @param database CouchDatabase The target database to perform service operations on.
		 * @param service ICouchDatabaseService The ICouchDatabaseService implementation to invoke operations on.
		 */
		public function CouchDatabaseActionMediator( database:CouchDatabase, service:ICouchDatabaseService )
		{
			_database = database;
			_service = service;
			_responder = new BasicCouchResponder( handleServiceResult, handleServiceFault );
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
		 * @private
		 * 
		 * Responder method for the sucess of database creation. Forwards on to reading in values for the database. 
		 * @param result CouchServiceResult
		 */
		protected function handleCreateResult( result:CouchServiceResult ):void
		{
			handleRead( CouchActionType.CREATE );
		}
		
		/**
		 * @private
		 * 
		 * Responder method for fault in database creation. Could return in CouchFaulttype.DATABASE_ALREADY_EXISTS. IF so, read in the database. 
		 * @param fault
		 * 
		 */
		protected function handleCreateFault( fault:CouchServiceFault ):void
		{
			if( fault.type == CouchFaultType.DATABASE_ALREADY_EXISTS )
			{
				handleRead( CouchActionType.CREATE );
			}
		}
		
		/**
		 * Invokes the ICouchDatabaseService to create a database based on current CouchDatabase target.
		 */
		public function handleCreateIfNotExist():void
		{
			// Create internal responder for creation operation.
			var createResponder:ICouchServiceResponder = new BasicCouchResponder( handleCreateResult, handleCreateFault );
			// Create responder for creation operation with basic responder.
			var serviceResponder:ICouchServiceResponder = new CreateDatabaseResponder( _database, createResponder );
			// Invoke service to create database.
			_service.createDatabase( _database.db_name, serviceResponder );
		}
		
		/**
		 * Invokes the ICouchDatabaseService to read in database properties to target CouchDatabase target. 
		 * @param action String The action associated with reading in values. Default CouchAction.READ.
		 */
		public function handleRead( action:String = CouchActionType.READ ):void
		{
			var serviceResponder:ICouchServiceResponder = new ReadDatabaseResponder( _database, action, _responder );
			_service.readDatabase( _database.db_name, serviceResponder );
		}
		
		/**
		 * Invokes the ICouchDatabaseService to delete the database from the CouchDB instance.
		 */
		public function handleDelete():void
		{
			var serviceResponder:ICouchServiceResponder = new DeleteDatabaseResponder( _database, _responder );
			_service.deleteDatabase( _database.db_name, serviceResponder );
		}
		
		/**
		 * Invokes the ICouchDatabaseService to request information related to target CouchDatabase.
		 */
		public function handleInfo():void
		{
			_service.getDatabaseInfo( _database.db_name, _responder );
		}
		
		/**
		 * Invokes the ICouchDatabaseService to request changes related to the target CouchDatabase.
		 */
		public function handleGetChanges():void
		{
			_service.getDatabaseChanges( _database.db_name, _responder );
		}
		
		/**
		 * Invokes the ICouchDatabaseService to compact the target CouchDatabase and perform optional cleanup. 
		 * @param cleanup Boolean
		 */
		public function handleCompact( cleanup:Boolean ):void
		{
			_service.compactDatabase( _database.db_name, cleanup, _responder );
		}
	}
}