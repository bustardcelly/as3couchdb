/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: HTTPCouchRequest.as</p>
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
	import com.adobe.net.URI;
	import com.adobe.protocols.dict.events.ErrorEvent;
	import com.adobe.serialization.json.JSON;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchContentType;
	import com.custardbelly.as3couchdb.enum.CouchRequestMethod;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.text.engine.ContentElement;
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpClient;
	import org.httpclient.HttpResponse;
	import org.httpclient.events.HttpDataEvent;
	import org.httpclient.events.HttpListener;
	import org.httpclient.events.HttpResponseEvent;
	import org.httpclient.events.HttpStatusEvent;
	
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
				respondToFault( CouchEvent.FAULT, evt.response.message );
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
				message = ( evt as ErrorEvent ).message;
			
			respondToFault( CouchEvent.FAULT, message );
		}
		
		/**
		 * @inherit 
		 */
		override public function execute( request:URLRequest, requestType:String, responder:ICouchServiceResponder ):void
		{
			super.execute( request, requestType, responder );
			
			_responseBytes = new ByteArray();
			
			var uri:URI = new URI( request.url );
			var body:ByteArray = new ByteArray();
			if( request.data != null )
				body.writeUTFBytes(request.data.toString());
			body.position = 0;
			
			switch( requestType )
			{
				case CouchRequestMethod.PUT:	
					_client.put( uri, body, CouchContentType.JSON );
					break;
				case CouchRequestMethod.POST:
					_client.post( uri, body, CouchContentType.JSON );
					break;
				case CouchRequestMethod.GET:
					_client.get( uri );
					break;
				case CouchRequestMethod.DELETE:
					_client.del( uri );
					break;
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