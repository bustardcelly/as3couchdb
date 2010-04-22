/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchSession.as</p>
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
package com.custardbelly.as3couchdb.core
{
	import com.custardbelly.as3couchdb.as3couchdb_internal;
	import com.custardbelly.as3couchdb.command.IRequestCommand;
	import com.custardbelly.as3couchdb.mediator.ICouchSessionActionMediator;
	import com.custardbelly.as3couchdb.mediator.IServiceMediator;
	
	import flash.net.URLRequestHeader;
	
	/**
	 * Dispatched upon successful create of a session for user within CouchDB instance. 
	 */
	[Event(name="sessionCreate", type="com.custardbelly.as3couchdb.enum.CouchActionType")]
	/**
	 * Dispatched upon fault from create of session. 
	 */
	[Event(name="fault", type="com.custardbelly.as3couchdb.event.CouchEvent")]
	/**
	 * CouchSession is a model for data related to a cookie authentication for a session based on a time limit. 
	 * @author toddanderson
	 */
	public class CouchSession extends CouchModel
	{
		protected var _timeLimit:uint = 600000 /* default 10 minutes for couchdb */;
		protected var _startTime:Number;
		protected var _user:CouchUser;
		protected var _cookie:String;
		protected var _headers:Array; // URLRequestHeader[]
		
		protected var _actionMediator:ICouchSessionActionMediator;
		
		/**
		 * Constructor. 
		 * @param cookie The cookie.
		 * @param timeLimit The timelimit set on the cookie. The deault time limit in CouchDB is 10 minutes.
		 */
		public function CouchSession()
		{
			super();
			_actionMediator = _mediator as ICouchSessionActionMediator;
		}
		
		/**
		 * @private 
		 * 
		 * Creates an array of headers associated with the session cookie.
		 */
		protected function createHeaders():void
		{
			_headers = [];
			_headers.push( new URLRequestHeader( "Cookie", _cookie ) );
			_headers.push( new URLRequestHeader( "X-CouchDB-WWW-Authenticate", "Cookie" ) );
		}
		
		/**
		 * @private 
		 * 
		 * Sets the beginning time of the cookie session.
		 */
		protected function setTime():void
		{
			_startTime = new Date().getTime();
		}
		
		/**
		 * @private
		 * 
		 * Renews the cookie for a session.
		 * @param pendingCommand The pending command in chain after renewal.
		 * @return IRequestCommand
		 */
		as3couchdb_internal function renew():IRequestCommand
		{
			return _actionMediator.createRenewRequest( _user );
		}
		
		/**
		 * Creates a new session based on user credentials. 
		 * @param user CouchUser
		 */
		public function create( user:CouchUser ):void
		{
			_user = user;
			_actionMediator.doCreate( _user );
		}
		
		/**
		 * Returns flag of session having ended base on time limit. 
		 * @return Boolean
		 */
		public function hasExpired():Boolean
		{
			return ( new Date().getTime() - _startTime ) > _timeLimit;
		}
		
		/**
		 * Accessor/Modifier for the cookie value. 
		 * @return String 
		 */
		public function get cookie():String
		{
			return _cookie;
		}
		public function set cookie( value:String ):void
		{
			_cookie = value;
			setTime();
			createHeaders();
		}
		
		/**
		 * Accessor/Modifier for time limit of session. Default CouchDB session limit is 10 minutes.
		 * If a nw time limit is set here, you must also ensure that you update the new time limit in your CouchDB instance.
		 * @return uint
		 */
		public function get timeLimit():uint
		{
			return _timeLimit;
		}
		public function set timeLimit( value:uint ):void
		{
			_timeLimit = value;
		}
		
		/**
		 * Returns the list of required headers for the CouchDB session. 
		 * @return Array Array of URLRequestHeaders
		 */
		public function get headers():Array /* URLRequestHeader[] */
		{
			if( _headers == null )
				createHeaders();
			
			return _headers;
		}
	}
}