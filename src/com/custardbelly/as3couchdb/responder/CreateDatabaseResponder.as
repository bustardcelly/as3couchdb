/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CreateDatabaseResponder.as</p>
 * <p>Version: 0.6</p>
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
package com.custardbelly.as3couchdb.responder
{
	import com.custardbelly.as3couchdb.core.CouchDatabase;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchActionType;
	import com.custardbelly.as3couchdb.enum.CouchFaultType;
	import com.custardbelly.as3couchdb.enum.CouchRequestStatus;
	
	/**
	 * CreateDatabaseResponder is an ICouchServiceResponder implementation to handle result and fault responses from the creation of a database. 
	 * @author toddanderson
	 */
	public class CreateDatabaseResponder extends ReadDatabaseResponder
	{
		/**
		 * Constructor. 
		 * @param database CouchDatabase
		 * @param responder ICouchServiceResponder
		 */
		public function CreateDatabaseResponder( database:CouchDatabase, responder:ICouchServiceResponder)
		{
			super(database, CouchActionType.CREATE, responder);
		}
		
		/**
		 * @inherit
		 */
		override public function handleResult( value:CouchServiceResult ):void
		{
			if( !handleAsResultError( value ) )
			{
				if( _responder ) _responder.handleResult( new CouchServiceResult( _action, _database ) );
			}
		}
		
		/**
		 * Override to check if error in response to specific HTTP status returned from service. If a 412 status is returned, database instance already exists.
		 * @param value CouchServiceFault
		 */
		override public function handleFault( value:CouchServiceFault ):void
		{
			// If a 412 has happened, customize the fault response.
			if( _status == CouchRequestStatus.HTTP_ALREADY_EXISTS )
			{
				var fault:CouchServiceFault = new CouchServiceFault( CouchFaultType.DATABASE_ALREADY_EXISTS, _status, "Database with name [" + _database.databaseName + "] already exists at " + _database.baseUrl + "." );
				super.handleFault( fault );
			}
			// else pass along the super fault handler.
			else super.handleFault( value );
		}
	}
}