/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: HTTPCouchRequest.as</p>
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
package com.custardbelly.as3couchdb.service
{
	import com.adobe.net.URI;
	import com.adobe.serialization.json.JSON;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchContentType;
	import com.custardbelly.as3couchdb.enum.CouchRequestMethod;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.text.engine.ContentElement;
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpClient;
	import org.httpclient.HttpRequest;
	import org.httpclient.HttpResponse;
	import org.httpclient.events.HttpDataEvent;
	import org.httpclient.events.HttpListener;
	import org.httpclient.events.HttpResponseEvent;
	import org.httpclient.events.HttpStatusEvent;
	import org.httpclient.http.Delete;
	import org.httpclient.http.Get;
	import org.httpclient.http.Post;
	import org.httpclient.http.Put;
	
	/**
	 * HTTPCouchRequest is an ICouchRequest implememntation that uses as3httpclient to communicate with a CouchDB instance.
	 * Please see http://code.google.com/p/as3httpclientlib for more details about the as3httpclient library.
	 * @author toddanderson
	 */
	public class HTTPCouchRequest extends AbstractCouchRequest
	{
		protected var _client:HttpClient;
		protected var _responseBytes:ByteArray;
		
		/**
		 * Constructor.
		 */
		public function HTTPCouchRequest()
		{
			_client = new HttpClient();
			// Resolve client listener handlers.
			var listener:HttpListener = new HttpListener();
			listener.onStatus = handleStatus;
			listener.onData = handleData;
			listener.onComplete = handleComplete;
			listener.onError = handleError;
			_client.listener = listener;
		}
		
		/**
		 * @private
		 * 
		 * Adds headers to HttpRequest instance from an array of URLRequestHeader items. 
		 * @param request HttpRequest
		 * @param headers Array List of URLRequestHeader instances.
		 */
		protected function addHeadersToRequest( request:HttpRequest, headers:Array /*URLRequestHeader[]*/ ):void
		{
			// If not headers, move on.
			if( headers == null ) return;
			// Else loop through a add shifted headers to HttpRequest.
			var header:URLRequestHeader;
			while( headers.length > 0 )
			{
				header = headers.shift() as URLRequestHeader;
				request.addHeader( header.name, header.value );
			}	
		}
		
		/* HttpListener implmementations */
		/**
		 * @private
		 * 
		 * Event handler for status from as3httpclient. 
		 * @param evt HttpStatusEvent
		 */
		protected function handleStatus( evt:HttpStatusEvent ):void
		{
			respondToStatus( int(evt.code) );
		}
		
		/**
		 * @private
		 * 
		 * Event handle for data from as3httpclient. 
		 * @param evt HttpDataEvent
		 */
		protected function handleData( evt:HttpDataEvent ):void
		{
			if( evt.bytes.bytesAvailable > 0 )
			{
				evt.bytes.position = 0;
				_responseBytes.writeBytes( evt.bytes, 0, evt.bytes.bytesAvailable );
			}
		}
		
		/**
		 * @private
		 * 
		 * Event handle for complete of service request from as3httpclient. 
		 * @param evt HttpResponseEvent
		 */
		protected function handleComplete( evt:HttpResponseEvent ):void
		{
			var response:HttpResponse = evt.response;
			var isSuccess:Boolean = response.isSuccess;
			
			if( isSuccess )
			{
				_responseBytes.position = 0;
				var jsonResult:Object = JSON.decode( _responseBytes.readUTFBytes( _responseBytes.bytesAvailable ) );
				respondToResult( CouchEvent.RESULT, jsonResult );
			}
			else
			{
				respondToFault( CouchEvent.FAULT, int(response.code), evt.response.message );
			}
			
			_responseBytes = new ByteArray();
		}
		
		/**
		 * @private
		 * 
		 * Event handler for error in service request from as3httpclient. 
		 * @param evt Event
		 */
		protected function handleError( evt:Event ):void
		{
			// Security and Error Events.
			var message:String = "Unknown error occured.";
			if( evt is ErrorEvent )
				message = ( evt as ErrorEvent ).text;
			
			respondToFault( CouchEvent.FAULT, 0, message );
		}
		
		/**
		 * @inherit 
		 */
		override public function execute( urlRequest:URLRequest, requestType:String, responder:ICouchServiceResponder ):void
		{
			super.execute( urlRequest, requestType, responder );
			
			_responseBytes = new ByteArray();
			
			var request:HttpRequest;
			var uri:URI = new URI( urlRequest.url );
			var body:ByteArray = new ByteArray();
			// If the requets data is not serialized into bytes, do so.
			if( urlRequest.data != null )
			{
				// Serialize as UTF string.
				if( !( urlRequest.data is ByteArray ) )
				{
					body.writeUTFBytes(urlRequest.data.toString());
				}
				else
				// If the there is data available it probably is already serialized in the correct format. 
				{
					body = urlRequest.data as ByteArray;
				}
				body.position = 0;
			}
			
			switch( requestType )
			{
				case CouchRequestMethod.PUT:
					request = new Put();
					request.contentType = urlRequest.contentType;
					request.body = body;
					break;
				case CouchRequestMethod.POST:
					request = new Post();
					request.contentType = urlRequest.contentType;
					request.body = body;
					break;
				case CouchRequestMethod.GET:
					request = new Get();
					break;
				case CouchRequestMethod.DELETE:
					request = new Delete();
					break;
			}
			
			// If a request has been established...
			if( request )
			{
				addHeadersToRequest( request, urlRequest.requestHeaders );
				_client.request( uri, request );
			}
		}
		
		/**
		 * @inherit
		 */
		override public function dispose():void
		{
			super.dispose();
			_client.listener = null;
			_client = null;
		}
	}
}