/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ICouchUserReader.as</p>
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

	/**
	 * ICouchUserReader interprets the response from a service request related to a CouchUser. 
	 * @author toddanderson
	 */
	public interface ICouchUserReader extends ICouchResponseReader
	{
		/**
		 * Updates the user based on successfull response of creation (signup) of a new user. 
		 * @param user CouchUser
		 * @param result Object
		 */
		function updateFromCreate( user:CouchUser, result:Object ):void;
		/**
		 * Updates the user based on successful login. 
		 * @param user CouchUser
		 * @param result Object
		 */
		function updateFromLogin( user:CouchUser, result:Object ):void;
		/**
		 * Updates the user based on result of successful read. 
		 * @param user CouchUser
		 * @param result Object
		 * @param userIsAdmin Boolean
		 */
		function updateFromRead( user:CouchUser, result:Object, userIsAdmin:Boolean = false ):void;
		/**
		 * Updates the document from a generic result from a service operation. 
		 * @param document User
		 * @param result Object
		 */
		function updateUserFromResult( user:CouchUser, result:Object ):void;
		/**
		 * Updates the user based on successful logout. 
		 * @param user CouchUser
		 * @param result Object
		 */
		function updateFromLogout( user:CouchUser, result:Object ):void;
	}
}