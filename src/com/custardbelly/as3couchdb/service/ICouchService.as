/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ICouchService.as</p>
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
package com.custardbelly.as3couchdb.service
{
	import com.custardbelly.as3couchdb.command.IRequestCommand;
	import com.custardbelly.as3couchdb.core.CouchSession;
	import com.custardbelly.as3couchdb.core.CouchUser;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;

	/**
	 * ICouchService is a base service for handling communication with a CouchDB instance.  
	 * @author toddanderson
	 * 
	 */
	public interface ICouchService
	{
		/**
		 * Signs a new user up and creates a new authenticated session. 
		 * @param name
		 * @param password
		 * @param roles Array
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function signUp( name:String, password:String, roles:Array /* String[] */ = null, responder:ICouchServiceResponder = null ):IRequestCommand;
		
		/**
		 * Logs a user in an creates a new authenticated session. 
		 * @param name String
		 * @param password String
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function logIn( name:String, password:String, responder:ICouchServiceResponder = null ):IRequestCommand;
		
		/**
		 * Logs a user out of an authenticated session. 
		 * @param user CouchUser
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function logOut( user:CouchUser, responder:ICouchServiceResponder = null ):IRequestCommand;
		
		/**
		 * Returns the instance of the session used for authentication when making document and database requests. 
		 * @return CouchSession
		 */
		function getSession():CouchSession;
		
		/**
		 * Performs any cleanup prior to garbage collection.
		 */
		function dispose():void;
		
		/**
		 * Returns the url of the CouchDB instance. 
		 * @return String
		 */
		function get baseUrl():String;
	}
}