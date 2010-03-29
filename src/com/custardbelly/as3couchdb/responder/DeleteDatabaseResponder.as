/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: DeleteDatabaseResponder.as</p>
 * <p>Version: 0.3</p>
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
	
	/**
	 * DeleteDatabaseResponder is an ICouchServiceResponder impementation to handle service response with regards to the deletion of a database.
	 * @author toddanderson
	 * 
	 */
	public class DeleteDatabaseResponder extends ReadDatabaseResponder
	{
		/**
		 * Constructor. 
		 * @param database CouchDatabase
		 * @param responder ICouchServiceResponder
		 */
		public function DeleteDatabaseResponder( database:CouchDatabase, responder:ICouchServiceResponder )
		{
			// Instruct super of the action type.
			super( database, CouchActionType.DELETE, responder );
		}
		
		/**
		 * @inherit.
		 */
		override public function handleResult( value:CouchServiceResult ):void
		{
			var result:Object = value.data;
			if( _reader.isResultAnError( result ) )
			{
				handleFault( new CouchServiceFault( result["error"], result["reason"] ) );
			}
			else
			{
				// Mark the database target as being deleted.
				_database.isDeleted = true;
				if( _responder ) _responder.handleResult( new CouchServiceResult( _action, _database ) );
			}
		}
	}
}