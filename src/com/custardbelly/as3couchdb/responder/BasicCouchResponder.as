/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: BasicCouchResponder.as</p>
 * <p>Version: 0.2</p>
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
	 * BasicCouchResponder is a basic responder to service operations with target methods for result and fault responses. 
	 * @author toddanderson
	 */
	public class BasicCouchResponder implements ICouchServiceResponder
	{
		protected var _status:int;
		protected var _resultFunction:Function;
		protected var _faultFunction:Function;
		
		/**
		 * Constructor. 
		 * @param resultFunction Function The target method to handle successful result. CouchServiceResult will be passed in as single argument to method.
		 * @param faultFunction Function The target method to handle unsuccessful result. CouchServiceFault will be passed in as single argument to method.
		 */
		public function BasicCouchResponder( resultFunction:Function, faultFunction:Function )
		{
			_resultFunction = resultFunction;
			_faultFunction = faultFunction;
		}

		/**
		 * Result handler for service operation. Invokes target resultFunction with CouchServiceResult instance.
		 * @param value CouchServiceResult
		 */
		public function handleResult( value:CouchServiceResult ):void
		{
			_resultFunction.apply( null, [value] );
		}
		
		/**
		 * Fault handler for service operation. Invokes target faultFunction with CouchServiceFault instance. 
		 * @param value CouchServiceFault
		 */
		public function handleFault( value:CouchServiceFault ):void
		{
			_faultFunction.apply( null, [value] );
		}
		
		/**
		 * Returns the current HTTP status of the service operation. 
		 * @return int
		 */
		public function get status():int
		{
			return _status;
		}
		public function set status( value:int ):void
		{
			_status = value;
		}
	}
}