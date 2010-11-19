/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchUserService.as</p>
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
	import com.custardbelly.as3couchdb.command.IRequestCommand;
	import com.custardbelly.as3couchdb.core.CouchUser;
	import com.custardbelly.as3couchdb.enum.CouchContentType;
	import com.custardbelly.as3couchdb.enum.CouchRequestMethod;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.serialize.CouchDocumentWriter;
	import com.custardbelly.as3couchdb.serialize.CouchUserWriter;
	import com.custardbelly.as3couchdb.serialize.ICouchDocumentWriter;
	
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	/**
	 * CouchUserService is an ICouchUserService implementation that  communicates with a CouchDB instance to perform any actions related to a user. 
	 * @author toddanderson
	 */
	public class CouchUserService extends CouchService implements ICouchUserService
	{
		protected var _writer:ICouchDocumentWriter;
		
		/**
		 * @private
		 * Holds a map of instances from which you can gain access based on base url of CouchDB instance. 
		 */
		protected static var instances:Dictionary = new Dictionary(true);
		
		/**
		 * Constructor. 
		 * @param baseUrl String
		 * @param request ICouchRequest
		 */
		public function CouchUserService(baseUrl:String, request:ICouchRequest=null)
		{
			super(baseUrl, request);
			_writer = new CouchUserWriter();
		}
		
		/**
		 * @copy ICouchUserService#readUser()
		 */
		public function readUser( user:CouchUser, responder:ICouchServiceResponder = null ):IRequestCommand
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = encodeURI(_baseUrl + "/_users/" + "org.couchdb.user:" + user.name + "?revs_info=true");
			return makeRequest( request, CouchRequestMethod.GET, responder );
		}
		
		/**
		 * @copy ICouchUserService#updateUser()
		 */
		public function updateUser( user:CouchUser, responder:ICouchServiceResponder = null ):IRequestCommand
		{
			var data:Object = _writer.serializeDocumentForUpdate( user );
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.data = data;
			request.url = encodeURI(_baseUrl + "/_users/" + "org.couchdb.user:" + user.name);
			return makeRequest( request, CouchRequestMethod.PUT, responder );
		}
		
		/**
		 * Access an instance of a ICouchUserService based on the url and database held in the CouchDb instance. 
		 * @param baseUrl String
		 * @return ICouchUserService
		 */
		public static function getUserService( baseUrl:String, request:ICouchRequest = null ):ICouchUserService
		{
			if( CouchUserService.instances[baseUrl] == null )
			{
				CouchUserService.instances[baseUrl] = new CouchUserService( baseUrl, request );
			}
			return CouchUserService.instances[baseUrl];
		}
	}
}