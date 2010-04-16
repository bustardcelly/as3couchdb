/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: HTTPSessionRequest.as</p>
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
package com.custardbelly.as3couchdb.service
{
	import com.adobe.net.URI;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	
	import flash.errors.IllegalOperationError;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpRequest;
	import org.httpclient.HttpResponse;
	import org.httpclient.events.HttpResponseEvent;
	import org.httpclient.http.Post;

	/**
	 * HTTPSessionRequest is an ICouchRequest implementation that handles creating a session for other requests. 
	 * @author toddanderson
	 */
	public class HTTPSessionRequest extends HTTPCouchRequest
	{
		/**
		 * Constructor.
		 */
		public function HTTPSessionRequest() { super(); }
		
		/**
		 * @inherit
		 */
		override protected function handleComplete( evt:HttpResponseEvent ):void
		{
			var response:HttpResponse = evt.response;
			var isSuccess:Boolean = response.isSuccess;
			if( isSuccess )
			{
				// Grab cookie from header and notify client.
				var cookie:String = response.header.getValue( "Set-Cookie" );
				respondToResult( CouchEvent.RESULT, cookie );
			}
			else
			{
				respondToFault( CouchEvent.FAULT, int(response.code), evt.response.message );
			}
			
			_responseBytes = new ByteArray();
		}
		
		/**
		 * @inherit 
		 */
		override public function execute( urlRequest:URLRequest, requestType:String, responder:ICouchServiceResponder ):void
		{
			_responder = responder;
			_responseBytes = new ByteArray();
			
			var request:HttpRequest;
			var uri:URI = new URI( urlRequest.url );
			var body:ByteArray = new ByteArray();
			try
			{
				body.writeUTFBytes(urlRequest.data.toString());	
			}
			catch( e:Error )
			{
				// Most likely they have not supplied user credentials.
				throw new IllegalOperationError( "In order to properly start a session, user credentials must be given.", e.errorID );
			}	
			body.position = 0;
			
			request = new Post();
			request.contentType = urlRequest.contentType;
			request.body = body;
			addHeadersToRequest( request, urlRequest.requestHeaders );
			_client.request( uri, request );
		}
	}
}