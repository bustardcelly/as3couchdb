/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ICouchUserActionMediator.as</p>
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
	/**
	 * ICouchUserActionMediator is a mediattor between the service and client to handle response on change to creation of user and login/logout of session.
	 * @author toddanderson
	 */
	public interface ICouchUserActionMediator extends IServiceMediator
	{
		/**
		 * Creates a new user in the system. *Must be logged in previously as an _admin in order to supply roles. 
		 * @param name String
		 * @param password String
		 * @param roles Array An array of String roles to associated the user with in the instance.
		 */
		function doSignUp( name:String, password:String, roles:Array /* String[] */ = null ):void;
		/**
		 * Logs a user into the system and creates a CouchSession with populated cookie. 
		 * @param name String
		 * @param password String
		 */
		function doLogIn( name:String, password:String ):void;
		/**
		 * Logs a user out of the system.
		 */
		function doLogOut():void;
		/**
		 * Saves an update to the User on the system.
		 */
		function doSave():void;
	}
}