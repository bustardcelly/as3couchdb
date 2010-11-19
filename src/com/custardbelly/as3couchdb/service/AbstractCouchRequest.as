/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: AbstractCouchRequest.as</p>
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
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	
	import flash.net.URLRequest;
	
	/**
	 * AbstractCouchRequest is an ICouchRequest implementation with abstract and stubbed methods. 
	 * @author toddanderson
	 */
	public class AbstractCouchRequest implements ICouchRequest
	{
		protected var _isInactive:Boolean;
		protected var _responder:ICouchServiceResponder;
		
		/**
		 * Constructor.
		 */
		public function AbstractCouchRequest() {}
		
		/**
		 * @private
		 * 
		 * Responds to status code of service request. 
		 * @param statusCode int
		 */
		protected function respondToStatus( statusCode:int ):void
		{
			if( _isInactive || _responder == null ) return;
			
			_responder.status = statusCode;
		}
		
		/**
		 * @private
		 * 
		 * Responds the result from service request. 
		 * @param type String
		 * @param result Object
		 */
		protected function respondToResult( type:String, result:Object ):void
		{
			if( _isInactive || _responder == null ) return;
			
			_responder.handleResult( new CouchServiceResult( type, result ) );
		}
		
		/**
		 * @private
		 * 
		 * Responds to a fault in service request. 
		 * @param type String
		 * @param message String
		 */
		protected function respondToFault( type:String, status:int, message:String ):void
		{
			if( _isInactive || _responder == null ) return;
			
			_responder.handleFault( new CouchServiceFault( type, status, message ) );
		}
		
		/**
		 * Executes a request on the service. 
		 * @param request URLRequest
		 * @param requestType String
		 * @param responder ICouchServiceResponder
		 */
		public function execute(request:URLRequest, requestType:String, responder:ICouchServiceResponder):void
		{
			_responder = responder;
			// abstract.
		}
		
		/**
		 * Performs any cleanup.
		 */
		public function dispose():void
		{
			_isInactive = true;
		}
	}
}