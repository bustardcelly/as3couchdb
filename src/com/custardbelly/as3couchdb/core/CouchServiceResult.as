/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchServiceResult.as</p>
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
package com.custardbelly.as3couchdb.core
{
	/**
	 * CouchServiceResult is a base result object describing the successful result from a service operation.
	 * @author toddanderson
	 */
	public class CouchServiceResult
	{
		protected var _action:String;
		protected var _data:*;
		
		/**
		 * Constructor. Assigns attribute values to supplied arguments. 
		 * @param action String The action performed that resulted in success.
		 * @param data * Wildcard designation to provide any type of result.
		 */
		public function CouchServiceResult( action:String, data:* = null )
		{
			_action = action;
			_data = data;
		}
		
		/**
		 * Returns the action performed on the service that resulted in a successful operation.
		 * @return String
		 */
		public function get action():String
		{
			return _action;
		}
		/**
		 * Returns the associated result data for the success of a service operation. 
		 * @return * Wildcard designation to provide any type of result.
		 */
		public function get data():*
		{
			return _data;
		}
	}
}