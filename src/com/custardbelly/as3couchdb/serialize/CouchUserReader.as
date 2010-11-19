/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchUserReader.as</p>
 * <p>Version: 0.7</p>
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
package com.custardbelly.as3couchdb.serialize
{
	import com.custardbelly.as3couchdb.core.CouchUser;
	import com.custardbelly.as3couchdb.net.CouchSessionResponse;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * CouchUserReader interprets the response from a service request related to a CouchUser 
	 * @author toddanderson
	 */
	public class CouchUserReader extends CouchResponseReader implements ICouchUserReader
	{
		/**
		 * Map of reserved properties on a document residing in a CouchDB instance. 
		 */
		protected var reservedProperties:Dictionary;
		
		/**
		 * Constructor.
		 */
		public function CouchUserReader()
		{
			super();
			reservedProperties = new Dictionary( true );
			reservedProperties["_id"] = true;
			reservedProperties["_rev"] = true;
			reservedProperties["_revs_info"] = true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function isResultAnError( result:Object ):Boolean
		{
			if( result is CouchSessionResponse )
			{
				var sessionResponse:CouchSessionResponse = ( result as CouchSessionResponse );
				return sessionResponse.result["error"] != null && sessionResponse.cookie != null;
			}
			return result["error"] != null;
		}
		
		/**
		 * @copy ICouchUserReader#updateFromCreate()
		 */
		public function updateFromCreate( user:CouchUser, result:Object ):void
		{
			user.id = result["id"];
			user.revision = result["rev"];
		}
		
		/**
		 * @copy ICouchUserReader#updateFromLogin()
		 */
		public function updateFromLogin( user:CouchUser, result:Object ):void
		{
			// any updates for login session to user?
			user.roles = result["roles"];
		}
		
		/**
		 * @copy ICouchUserReader#updateFromRead()
		 */
		public function updateFromRead( user:CouchUser, result:Object, userIsAdmin:Boolean = false ):void
		{
			// If the result of read in from login is an error, there may be a case that an _admin is not a record in _users which is OK.
			if( isResultAnError( result ) && userIsAdmin ) return;
			
			user.id = result["_id"];
			user.revision = result["_rev"];
			var attribute:String;
			for( attribute in result )
			{
				try 
				{
					// try an apply the attributes held on the result to the document.
					if( !reservedProperties.hasOwnProperty( attribute ) )
						user[attribute] = result[attribute];
				}
				catch( e:Error )
				{
					// If attribute does not exist, do not throw RTE, but notify in console.
					trace( "WARNING: Document being written to, [" + getQualifiedClassName(user) + "] does not support the following property returned: " + attribute );
				}
			}
		}
		
		/**
		 * @copy ICouchUserReader#updateUserFromResult()
		 */
		public function updateUserFromResult( user:CouchUser, result:Object ):void
		{
			user.revision = result["rev"];
		}
		
		/**
		 * @copy ICouchUserReader#updateFromLogout()
		 */
		public function updateFromLogout( user:CouchUser, result:Object ):void
		{
			// any updates for logout session to user?	
		}
	}
}