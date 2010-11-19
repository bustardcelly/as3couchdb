/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchServiceFault.as</p>
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
package com.custardbelly.as3couchdb.core
{
	/**
	 * CouchServiceFault is a base fault object describing any errors in performing service operations. 
	 * @author toddanderson
	 */
	public class CouchServiceFault
	{
		protected var _type:String;
		protected var _status:int;
		protected var _message:String;
		
		/**
		 * Constructor. Assigns attribute values to supplied arguments. 
		 * @param type String
		 * @param message String
		 */
		public function CouchServiceFault( type:String, status:int, message:String )
		{
			_type = type;
			_status = status;
			_message = message;
		}
		/**
		 * Returns the type of fault encountered. 
		 * @return String
		 */
		public function get type():String
		{
			return _type;
		}
		/**
		 * Returns the status code related to the fault. 
		 * @return int
		 */
		public function get status():int
		{
			return _status;
		}
		/**
		 * Returns a description of the fault encountered. 
		 * @return String
		 */
		public function get message():String
		{
			return _message;
		}
	}
}