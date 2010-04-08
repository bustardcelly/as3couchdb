/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchDocumentActionMediator.as</p>
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
package com.custardbelly.as3couchdb.mediator
{
	import com.custardbelly.as3couchdb.core.CouchAttachment;
	import com.custardbelly.as3couchdb.core.CouchDocument;
	import com.custardbelly.as3couchdb.core.CouchModel;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchActionType;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.mediator.helper.AttachmentRequestQueue;
	import com.custardbelly.as3couchdb.responder.BasicCouchResponder;
	import com.custardbelly.as3couchdb.responder.CreateDocumentResponder;
	import com.custardbelly.as3couchdb.responder.DeleteDocumentResponder;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.responder.ReadDocumentResponder;
	import com.custardbelly.as3couchdb.responder.UpdateDocumentResponder;
	import com.custardbelly.as3couchdb.service.CouchDocumentService;
	import com.custardbelly.as3couchdb.service.ICouchDocumentService;
	import com.custardbelly.as3couchdb.service.ICouchRequest;

	/**
	 * CouchDocumentActionMediator is an ICouchDocumentActionMediator implementation that do service operations in relation to a target CouchDocument instance.
	 * @author toddanderson
	 */
	public class CouchDocumentActionMediator implements ICouchDocumentActionMediator
	{
		protected var _document:CouchDocument;
		protected var _service:ICouchDocumentService;
		protected var _documentUpdateResponder:ICouchServiceResponder;
		protected var _serviceResponder:BasicCouchResponder;
		protected var _attachmentRequestQueue:AttachmentRequestQueue;
		
		/**
		 * Constructor.
		 */
		public function CouchDocumentActionMediator()
		{
			// empty.
		}
		
		/**
		 * Initializes the mediator to establish the service in which to communicate actions related to the target model. 
		 * @param target CouchModel
		 * @param baseUrl String
		 * @param databaseName String
		 * @param request ICouchRequest The ICouchRequest implmementation to forward requests through.
		 */
		public function initialize( target:CouchModel, baseUrl:String, databaseName:String, request:ICouchRequest = null ):void
		{
			_document = target as CouchDocument;
			_service = CouchDocumentService.getDocumentService( baseUrl, databaseName, request );
			// Create document update responder to handle success of modification of document, so as to continue with attachments.
			_documentUpdateResponder = new BasicCouchResponder( handleDocumentUpdateResult, handleServiceFault );
			// Create basic responder to handle result and fault from service.
			_serviceResponder = new BasicCouchResponder( handleServiceResult, handleServiceFault );	
		}
		
		/**
		 * @private
		 * 
		 * Responder method to do a successful result from a service operation. 
		 * @param result CouchServiceResult
		 */
		protected function handleServiceResult( result:CouchServiceResult ):void
		{
			// Dispatch event through target document.
			_document.dispatchEvent( new CouchEvent( result.action, result ) );
		}
		
		/**
		 * @private
		 * 
		 * Responder method to do a fault from a service operation. 
		 * @param fault CouchServiceFault
		 */
		protected function handleServiceFault( fault:CouchServiceFault ):void
		{
			// Dispatch event through target document.
			_document.dispatchEvent( new CouchEvent( CouchEvent.FAULT, fault ) );
		}
		
		/**
		 * @private
		 * 
		 * Responder method for update or create of document. Forwards on with attachment updates. 
		 * @param result CouchServiceResult
		 */
		protected function handleDocumentUpdateResult( result:CouchServiceResult ):void
		{
			doSaveAttachments( result.action );
		}
		
		/**
		 * Invokes the ICouchDocumentService to read in and apply attributes to the target document. 
		 * @param id String
		 */
		public function doRead( id:String ):void
		{
			_document.id = id;
			var responder:ICouchServiceResponder = new ReadDocumentResponder( _document, CouchActionType.READ, _serviceResponder );
			_service.readDocument( id, responder ).execute();
		}
		
		/**
		 * Invokes the ICouchDocumentService to save the document to the database in CouchDB. Used for creation and update to document.
		 */
		public function doSave():void
		{
			// Create the appropriate service responder based on document id.
			// If the document id is null, it is a new document instance and should instruct the service to create the document first.
			// Resolve respondse handler to documentUpdateResponder in order to queue up any attachments associated with document.
			var responder:ICouchServiceResponder = ( _document.id )
													? new UpdateDocumentResponder( _document, CouchActionType.UPDATE, _documentUpdateResponder )
													: new CreateDocumentResponder( _document, _documentUpdateResponder );
			
			_service.saveDocument( _document, responder ).execute();
		}
		
		/**
		 * Invokes the ICouchDocumentService to delete the document from the database in CouchDB.
		 */
		public function doDelete():void
		{
			var responder:ICouchServiceResponder = new DeleteDocumentResponder( _document, _serviceResponder )
			_service.deleteDocument( _document.id, _document.revision, responder ).execute();
		}
		
		/**
		 * Invokes service to save changed, unsaved, or deleted attachments associate with the document.
		 * @param documentAction String The related action to notify responders with in association with saving attachments of a document.
		 */
		public function doSaveAttachments( documentAction:String = CouchActionType.UPDATE ):void
		{
			// Create attachment request queue if not already existant.
			if( _attachmentRequestQueue == null )
			{
				_attachmentRequestQueue = new AttachmentRequestQueue( _document, _service, _serviceResponder );
			}
			_attachmentRequestQueue.documentAction = documentAction;
			
			// Run through attachments and mark those needed requests.
			var attachments:Vector.<CouchAttachment> = new Vector.<CouchAttachment>();
			var i:int;
			var attachment:CouchAttachment;
			for( i = 0; i < _document.attachments.length; i++ )
			{
				attachment = _document.attachments[i];
				if( attachment.isDirty() || attachment.isDeleted )
				{
					_attachmentRequestQueue.addAttachment( attachment );
				}
			}
			// Start request queue.
			_attachmentRequestQueue.start();
		}					   
	}
}