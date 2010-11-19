/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ICouchSessionActionMediator.as</p>
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
package com.custardbelly.as3couchdb.mediator
{
	import com.custardbelly.as3couchdb.command.IRequestCommand;
	import com.custardbelly.as3couchdb.core.CouchUser;

	/**
	 * ICouchSessionActionMediator is a service mediator for handling sessions. 
	 * @author toddanderson
	 */
	public interface ICouchSessionActionMediator extends IServiceMediator
	{
		/**
		 * Invokes service to renew session and complete pending request. 
		 * @param user CouchUser
		 * @return IRequestCommand
		 */
		function createRenewRequest( user:CouchUser ):IRequestCommand;
		/**
		 * Invokes service to create a new session based on user credentials. 
		 * @param user CouchUser
		 */
		function doCreate( user:CouchUser ):void;
		/**
		 * Invokes service to create a new user and log in. 
		 * @param user CouchUser
		 * @param roles Array An array of roles assigned to the user.
		 */
		function doSignUp( user:CouchUser, roles:Array /* String[] */ = null ):void;		
		/**
		 * Logs the user in and creates an authenticated session. 
		 * @param user CouchUser
		 */
		function doLogIn( user:CouchUser ):void;
		/**
		 * Logs the user out of an authenticated session. 
		 * @param user CouchUser
		 */
		function doLogOut( user:CouchUser ):void;
	}
}