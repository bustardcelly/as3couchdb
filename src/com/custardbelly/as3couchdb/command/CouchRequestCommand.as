/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchRequestCommand.as</p>
 * <p>Version: 0.4</p>
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
/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchService.as</p>
 * <p>Version: 0.4</p>
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
package com.custardbelly.as3couchdb.command
{
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.responder.BasicCouchResponder;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.service.ICouchRequest;
	
	import flash.net.URLRequest;

	/**
	 * CouchRequestCommand is generic wrapper for invoking a ICouchRequest with held arguments.  
	 * @author toddanderson
	 */
	public class CouchRequestCommand implements IRequestCommand
	{
		protected var _couchRequest:ICouchRequest;
		protected var _urlRequest:URLRequest;
		protected var _requestType:String;
		protected var _responder:ICouchServiceResponder;
		
		protected var _nextCommand:IRequestCommand;
		
		/**
		 * Constructor. 
		 * @param couchRequest ICouchRequest
		 * @param urlRequest URLRequest
		 * @param type String
		 * @param responder ICouchServiceResponder
		 */
		public function CouchRequestCommand( couchRequest:ICouchRequest, urlRequest:URLRequest, type:String, responder:ICouchServiceResponder = null )
		{
			_couchRequest = couchRequest;
			_urlRequest = urlRequest;
			_requestType = type;
			_responder = responder;
		}
		
		/**
		 * @private 
		 * 
		 * Executes the next command (if available)in the chain.
		 */
		protected function executeNextCommand():void
		{
			if( _nextCommand ) _nextCommand.execute();
		}
		
		/**
		 * @private
		 * 
		 * Responder method for successful result in service request. 
		 * @param result CouchServiceResult
		 */
		protected function handleRequestResult( result:CouchServiceResult ):void
		{
			if( _responder ) _responder.handleResult( result );
			executeNextCommand();
		}
		
		/**
		 * @private
		 * 
		 * Responder method for fault in service request. 
		 * @param fault CouchServiceFault
		 */
		protected function handleRequestFault( fault:CouchServiceFault ):void
		{
			if( _responder ) _responder.handleFault( fault );
			executeNextCommand();
		}
		
		/**
		 * Accessor/Modifier to optional next command in chain. 
		 * @return IRequestCommand
		 */
		public function get nextCommand():IRequestCommand
		{
			return _nextCommand;
		}
		public function set nextCommand( value:IRequestCommand ):void
		{
			_nextCommand = value;
		}
		
		/**
		 * Invokes wrapped ICouchRequest with passed arguments.
		 */
		public function execute():void
		{
			_couchRequest.execute( _urlRequest, _requestType, new BasicCouchResponder( handleRequestResult, handleRequestFault ) );
		}
	}
}