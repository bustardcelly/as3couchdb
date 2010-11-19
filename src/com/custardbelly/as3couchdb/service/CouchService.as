/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchService.as</p>
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
// TODO: Get all user docs: http://127.0.0.1:5984/_users/_all_docs
package com.custardbelly.as3couchdb.service
{
	import com.adobe.serialization.json.JSONEncoder;
	import com.custardbelly.as3couchdb.command.CouchRequestCommand;
	import com.custardbelly.as3couchdb.command.IRequestCommand;
	import com.custardbelly.as3couchdb.core.CouchSession;
	import com.custardbelly.as3couchdb.core.CouchUser;
	import com.custardbelly.as3couchdb.enum.CouchContentType;
	import com.custardbelly.as3couchdb.enum.CouchRequestMethod;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.util.SaltedPassword;
	
	import flash.errors.IllegalOperationError;
	import flash.net.URLRequest;

	/**
	 * CouchService is a base service class for communicating with a CouchDB instance. 
	 * @author toddanderson
	 */
	public class CouchService implements ICouchService
	{
		protected var _baseUrl:String;
		protected var _request:ICouchRequest;
		
		private static var session:CouchSession;
		private static var sessionCookieRequired:Boolean;
		
		/**
		 * Constructor. 
		 * @param baseUrl String The url fo the CouchDB instance.
		 * @param request ICouchRequest The ICouchRequest implementations to forward requests through.
		 */
		public function CouchService( baseUrl:String, request:ICouchRequest = null )
		{
			_baseUrl = baseUrl;
			// If no custom request supplied, default to HTTPCouchRequest.
			_request = request || new HTTPCouchRequest();
		}
		
		/**
		 * Creation of basic service to instantiate any other service requests as requiring session.
		 * @param baseUrl String The url of the CouchDB instance.
		 * @param request ICouchRequest The ICouchRequest implementations to forward requests through.
		 * @return ICouchService
		 */
		public static function getSessionService( baseUrl:String, request:ICouchRequest ):ICouchService
		{
			var service:ICouchService = new CouchService( baseUrl, request );
			CouchService.sessionCookieRequired = true;
			
			if( CouchService.session == null ) 
				CouchService.session = new CouchSession();
			
			return service;
		}
		
		/**
		 * @private
		 * 
		 * Verifies that a session is required, and if it is determines if the session needs to be renewed.
		 * If a session is still active and required, appropriate headers are appended onto the request in order
		 * to properly communicate with the service. 
		 * @param request URLRequest
		 * @return IRequestCommand
		 */
		protected function verifySession( request:URLRequest ):IRequestCommand
		{
			if( CouchService.sessionCookieRequired )
			{
				if( CouchService.session == null )
				{
					throw new IllegalOperationError( "Service request require a valid session cookie in order to be perfromed." );
				}
				else if( CouchService.session.hasExpired() )
				{
					// Let session renew with pending command mark.
					return renewSession( CouchService.session );
				}
				else
				{
					// Else concat session headers for the request.
					request.requestHeaders = request.requestHeaders.concat(CouchService.session.headers);
				}
			}
			return null;
		}
		
		/**
		 * Renews a session for the service to use for authentication of requests. 
		 * @param session CouchSession
		 */
		protected function renewSession( session:CouchSession, responder:ICouchServiceResponder = null ):IRequestCommand
		{
			var user:CouchUser = session.user;
			var request:URLRequest = new URLRequest();
			request.url = _baseUrl + "/_session";
			request.contentType = "application/x-www-form-urlencoded";
			request.data = "name=" + user.name + "&password=" + user.password;
			
			return new CouchRequestCommand( _request, request, CouchRequestMethod.POST, responder );
		}
		
		/**
		 * @private
		 * 
		 * Performs request. 
		 * @param request URLRequest
		 * @param responder ICouchServiceResponder
		 */
		protected function makeRequest( request:URLRequest, requestType:String, responder:ICouchServiceResponder = null ):IRequestCommand
		{
			// Verify session. If command returns, then we request for renewal is needed.
			var pendingSessionRequest:IRequestCommand = verifySession( request );
			var requestCommand:IRequestCommand = new CouchRequestCommand( _request, request, requestType, responder );
			// If there is a need to verify session on service, chain pending command.
			if( pendingSessionRequest != null )
			{
				pendingSessionRequest.nextCommand = requestCommand;
				return pendingSessionRequest;
			}
			return requestCommand;
		}
		
		/**
		 * @copy ICouchService#signUp()
		 */
		public function signUp( name:String, password:String, roles:Array /* String[] */ = null, responder:ICouchServiceResponder = null ):IRequestCommand
		{
			// Format of id for couchdb user.
			var id:String = "org.couchdb.user:" + name;
			var saltedPassword:SaltedPassword = SaltedPassword.generate( password );
			var salt:String = saltedPassword.salt;
			var password_sha:String = saltedPassword.password; 
			var request:URLRequest = new URLRequest();
			var rolesArr:Object = new JSONEncoder( {roles:roles} );
			request.url = encodeURI(_baseUrl + "/_users/" + id);
			request.contentType = CouchContentType.JSON;
			request.data = new JSONEncoder( {name:name, _id:id, type:"user", roles:(roles)?roles:[], salt:salt, password_sha:password_sha} ).getString();
			
			return makeRequest( request, CouchRequestMethod.PUT, responder );
		}
		
		/**
		 * @copy ICouchService#logIn()
		 */
		public function logIn( name:String, password:String, responder:ICouchServiceResponder = null ):IRequestCommand
		{
			var request:URLRequest = new URLRequest();
			request.url = _baseUrl + "/_session";
			request.contentType = "application/x-www-form-urlencoded";
			request.data = "name=" + name + "&password=" + password;
			
			return makeRequest( request, CouchRequestMethod.SESSION, responder );
		}
		
		/**
		 * @copy ICouchService#logOut()
		 */
		public function logOut( user:CouchUser, responder:ICouchServiceResponder = null ):IRequestCommand
		{
			var request:URLRequest = new URLRequest();
			request.url = _baseUrl + "/_session";
			return makeRequest( request, CouchRequestMethod.DELETE, responder );
		}
		
		/**
		 * @copy ICouchService#getSession()
		 */
		public function getSession():CouchSession
		{
			return CouchService.session;
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