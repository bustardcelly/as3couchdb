/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: AttachmentRequestQueue.as</p>
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
package com.custardbelly.as3couchdb.mediator.helper
{
	import com.custardbelly.as3couchdb.as3couchdb_internal;
	import com.custardbelly.as3couchdb.command.IRequestCommand;
	import com.custardbelly.as3couchdb.core.CouchAttachment;
	import com.custardbelly.as3couchdb.core.CouchDocument;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchActionType;
	import com.custardbelly.as3couchdb.responder.BasicCouchResponder;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.serialize.CouchDocumentReader;
	import com.custardbelly.as3couchdb.serialize.ICouchDocumentReader;
	import com.custardbelly.as3couchdb.service.ICouchDocumentService;
	
	/**
	 * AttachmentRequestQueue is a request queue for saving and deleting attachments related to a document. 
	 * @author toddanderson
	 */
	public class AttachmentRequestQueue
	{
		protected var _document:CouchDocument;
		protected var _service:ICouchDocumentService;
		protected var _faultIsFatal:Boolean;
		protected var _finalResponder:ICouchServiceResponder;
		protected var _requestResponder:ICouchServiceResponder;
		
		protected var _reader:ICouchDocumentReader;
		protected var _attachments:Vector.<CouchAttachment>;
		protected var _isRunning:Boolean;
		protected var _currentAttachment:CouchAttachment;
		
		/**
		 * Constructor. 
		 * @param document CouchDocument
		 * @param service ICouchDocumentService
		 * @param faultIsFatal Boolean Optional lag to stop queue request if a fault is receieved. 
		 * @param responder ICouchServiceResponder
		 */
		public function AttachmentRequestQueue( document:CouchDocument, service:ICouchDocumentService, responder:ICouchServiceResponder = null, faultIsFatal:Boolean = false ):void
		{
			_document = document;
			_service = service;
			_finalResponder = responder;
			_faultIsFatal = faultIsFatal;
			
			_requestResponder = new BasicCouchResponder( handleAttachmentRequestResult, handleAttachmentRequestFault );
			_reader = new CouchDocumentReader();
			_attachments = new Vector.<CouchAttachment>();
		}
		
		/**
		 * @private 
		 * 
		 * Performs request on next attachment in queue if available. If empty, notifies optional responder.
		 */
		protected function loadNext():void
		{
			// If we have attachments left in queue, begin new request.
			if( _attachments.length > 0 )
			{
				var request:IRequestCommand;
				_isRunning = true;
				_currentAttachment = _attachments.shift();
				if( _currentAttachment.isDirty() )
				{
					request = _service.saveAttachment( _document.id, _document.revision, _currentAttachment.fileName, _currentAttachment.data, _currentAttachment.contentType, _requestResponder );
					request.execute();
				}
				else if( _currentAttachment.isDeleted )
				{
					request = _service.deleteAttachment( _document.id, _document.revision, _currentAttachment.fileName, _requestResponder );
					request.execute();
				}
				else loadNext();
			}
			// Else we are done.
			else
			{
				_isRunning = false;
				_currentAttachment = null;
				notifyOfResult();
			}
		}
		
		/**
		 * @private 
		 * 
		 * Notifies final responder of result if available.
		 */
		protected function notifyOfResult():void
		{
			if( _finalResponder )
				_finalResponder.handleResult( new CouchServiceResult( CouchActionType.UPDATE, _document ) );
		}
		
		/**
		 * @private
		 * 
		 * Notifies final responder of fault if available. Only invoked if determined as fault being fatal.
		 * @param errorType String
		 * @param status int
		 * @param message String
		 */
		protected function notifyOfFault( errorType:String, status:int, message:String ):void
		{
			// Clear.
			_isRunning = false;
			_currentAttachment = null;
			_attachments = new Vector.<CouchAttachment>();
			// Notify responder.
			if( _finalResponder )
			{
				_finalResponder.handleFault( new CouchServiceFault( errorType, status, message ) );
			}
		}
		
		/**
		 * @private
		 * 
		 * Returns flag of successful result containing an error. Notifies final responder if necessary. 
		 * @param value CouchServiceResult
		 * @return Boolean
		 */
		protected function handleResultAsError( value:CouchServiceResult ):Boolean
		{
			var result:Object = value.data;
			// If we find data related to error and we are told to treat faults as fatal to queue.
			if( _reader.isResultAnError( result ) && _faultIsFatal )
			{
				notifyOfFault( result["error"], 0, result["reason"] );
				return true;
			}
			return false;
		}
		
		/**
		 * @private
		 * 
		 * Responder method for result in attachment request. 
		 * @param result CouchServiceResult
		 */
		protected function handleAttachmentRequestResult( result:CouchServiceResult ):void
		{
			if( !handleResultAsError( result ) )
			{
				use namespace as3couchdb_internal;
				// Update document based on result.
				var data:Object = result.data;
				_reader.updateDocumentFromResult( _document, data );
				
				// Update attachment in relation to document.
				_currentAttachment.document = _document;
				_currentAttachment.revisionPosition = _document.revision;
				
				// Remove attachment from list on document if delete.
				if( _currentAttachment.isDeleted )
					_document.attachments.splice( _document.attachments.indexOf( _currentAttachment ), 1 );
			}
			loadNext();
		}
		
		/**
		 * @private
		 * 
		 * Responder method for fault in attachment request. 
		 * @param fault CouchServiceFault
		 */
		protected function handleAttachmentRequestFault( fault:CouchServiceFault ):void
		{
			// If we aren't using a fault as fatal to the request queue, move on.
			if( !_faultIsFatal )
			{
				loadNext();
			}
			// Else notify of fault if responder available.
			else
			{
				notifyOfFault( fault.type, fault.status, fault.message );
			}
		}
		
		/**
		 * Adds a attachment to the request queue and optionally begins the request process. 
		 * @param attachment CouchAttachment
		 * @param autostart Boolean Optional flag to start the request queue.
		 */
		public function addAttachment( attachment:CouchAttachment, autostart:Boolean = false ):void
		{
			_attachments.push( attachment );
			if( !_isRunning && autostart )
				loadNext();
		}
		
		/**
		 * Starts the request queue.
		 */
		public function start():void
		{
			if( !_isRunning ) loadNext();
		}
	}
}