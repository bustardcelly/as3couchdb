/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ICouchServiceResponder.as</p>
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
package com.custardbelly.as3couchdb.responder
{
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;

	/**
	 * ICouchServiceResponder is a general responder to service operations that handle success, fault and current HTTP status. 
	 * @author toddanderson
	 */
	public interface ICouchServiceResponder
	{
		/**
		 * Responds to a successful result from a service operation. 
		 * @param value CouchServiceResult
		 */
		function handleResult( value:CouchServiceResult ):void;
		/**
		 * Responds to an unsuccessfuil result from a service operation. 
		 * @param value CouchServiceFault
		 */
		function handleFault( value:CouchServiceFault ):void;
		
		/**
		 * Returns the current HTTP status of the service operation. 
		 * @return int
		 */
		function get status():int;
		function set status( value:int ):void;
	}
}