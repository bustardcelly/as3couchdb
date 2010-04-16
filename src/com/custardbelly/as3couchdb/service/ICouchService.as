/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ICouchService.as</p>
 * <p>Version: 0.4.1</p>
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
		 * Creates a session for the service to use for authentication of requests. 
		 * @param user CouchUser
		 */
		function createSession( user:CouchUser, responder:ICouchServiceResponder = null ):IRequestCommand;
		
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