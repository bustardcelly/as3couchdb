/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchService.as</p>
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
package com.custardbelly.as3couchdb.service
{
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * CouchService is a base service class for communicating with a CouchDB instance. 
	 * @author toddanderson
	 */
	public class CouchService implements ICouchService
	{
		protected var _baseUrl:String;
		protected var _request:ICouchRequest;
		
		/**
		 * Constructor. 
		 * @param baseUrl String The url fo the CouchDB instance.
		 * @param request ICouchRequest The ICouchRequest implementations to forward requests through.
		 */
		public function CouchService( baseUrl:String, request:ICouchRequest = null )
		{
			_baseUrl = baseUrl;
			// If no custom request supplied, default to CouchRequest.
			_request = request || new CouchRequest();
		}
		
		/**
		 * @private
		 * 
		 * Performs request. 
		 * @param request URLRequest
		 * @param responder ICouchServiceResponder
		 */
		protected function makeRequest( request:URLRequest, requestType:String, responder:ICouchServiceResponder = null ):void
		{
			// TODO: Push to queue.
			_request.execute( request, requestType, responder );
		}
		
		/**
		 * Performs any cleanup.
		 */
		public function dispose():void
		{
			_request.dispose();
		}
		
		/**
		 * Returns the base url of the CouchDB instance. 
		 * @return String
		 */
		public function get baseUrl():String
		{
			return _baseUrl;
		}
	}
}