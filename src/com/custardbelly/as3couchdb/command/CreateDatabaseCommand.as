/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CreateDatabaseCommand.as</p>
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
package com.custardbelly.as3couchdb.command
{
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.enum.CouchFaultType;
	import com.custardbelly.as3couchdb.enum.CouchRequestStatus;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.service.ICouchRequest;
	
	import flash.net.URLRequest;
	
	/**
	 * CreateDatabaseCommand is a CouchRequestCommand extensions to properly handle the response of database already existant in CouchDB instance. 
	 * @author toddanderson
	 */
	public class CreateDatabaseCommand extends CouchRequestCommand
	{
		/**
		 * Constructor. 
		 * @param couchRequest ICouchRequest
		 * @param urlRequest URLRequest
		 * @param type String
		 * @param responder ICouchServiceResponder
		 */
		public function CreateDatabaseCommand( couchRequest:ICouchRequest, urlRequest:URLRequest, type:String, responder:ICouchServiceResponder=null )
		{
			super( couchRequest, urlRequest, type, responder );
		}
		
		/**
		 * @private
		 * 
		 * Override to check if fault do to already existant database. If so, move on to any subsewuent chain commands. Most likely it is a read command. 
		 * @param fault CouchServiceFault
		 */
		override protected function handleRequestFault( fault:CouchServiceFault ):void
		{
			// If a 412 has happened, customize the fault response.
			if( fault.status == CouchRequestStatus.HTTP_ALREADY_EXISTS )
			{
				if( _nextCommand != null )
				{
					executeNextCommand();
				}
				else
				{
					var fault:CouchServiceFault = new CouchServiceFault( CouchFaultType.DATABASE_ALREADY_EXISTS, fault.status, "Database already exists." );
					super.handleRequestFault( fault );
				}
			}
			else
			{
				super.handleRequestFault( fault );
			}
		}
	}
}