/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchAttachment.as</p>
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
package com.custardbelly.as3couchdb.core
{
	import com.custardbelly.as3couchdb.as3couchdb_internal;
	
	import flash.utils.ByteArray;

	/**
	 * CouchAttachment is a respresentation of the JSON object of an attachment associated with a document. 
	 * @author toddanderson
	 */
	[RemoteClass(alias="com.custardbelly.as3couchdb.core.CouchAttachment")]
	public class CouchAttachment
	{
		protected var _fileName:String;
		protected var _contentType:String;
		protected var _data:*;
		protected var _url:String;
		protected var _revisionPosition:String;
		protected var _stub:Object;
		protected var _document:CouchDocument;
		protected var _isDirty:Boolean;
		protected var _isDeleted:Boolean;
		
		/**
		 * Constructor. 
		 * @param fileName String
		 * @param contentType String
		 */
		public function CouchAttachment( fileName:String = "", contentType:String = "", data:* = null )
		{
			_fileName = fileName;
			_contentType = contentType;
			_data = data;
		}
		
		/**
		 * Returns flag of CouchAttachment instance having changed. 
		 * @return Boolean
		 */
		public function isDirty():Boolean
		{
			return _isDirty || ( _document == null );
		}
		
		/**
		 * Accessor/Modifier of the fileName. 
		 * @return String
		 */
		public function get fileName():String
		{
			return _fileName;
		}
		public function set fileName(value:String):void
		{
			if( _fileName == value ) return;
			
			_fileName = value;
			_isDirty = true;
		}
		
		/**
		 * Accessor/Modifier of the content type for the data. 
		 * @return String
		 */
		public function get contentType():String
		{
			return _contentType;
		}
		public function set contentType(value:String):void
		{
			if( _contentType == value ) return;
			
			_contentType = value;
			_isDirty = true;
		}
		
		/**
		 * Accessor/Modifier for the byte array of data to send to CouchDB. 
		 * @return *
		 */
		public function get data():*
		{
			return _data;
		}
		public function set data(value:*):void
		{
			if( _data == value ) return;
			
			_data = value;
			_isDirty = true;
		}
		
		/**
		 * Accessor/Modifier to the full url of where the attachment exists. 
		 * @return String
		 */
		public function get url():String
		{
			return _url;
		}
		public function set url( value:String ):void
		{
			_url = value;
		}
		
		/**
		 * Accessor/Modifier for the revision position of the document that relates to this attachment. 
		 * @return String
		 */
		public function get revisionPosition():String
		{
			return _revisionPosition;
		}
		public function set revisionPosition( value:String ):void
		{
			_revisionPosition = value;
		}
		
		/**
		 * Accessor/Modifier for the result stub returned from read in of a document with this attachment. This is used in updating the document and maintaining previously held attachments. 
		 * @return Object
		 */
		public function get stub():Object
		{
			return _stub;
		}
		public function set stub( value:Object ):void
		{
			_stub = value;
		}
		
		/**
		 * Accessor/Modifier to denote the attachement as having been deleted from the attachment list of an associated document. 
		 * @return Boolean
		 */
		public function get isDeleted():Boolean
		{
			return ( _isDeleted && _document != null );
		}
		public function set isDeleted( value:Boolean ):void
		{
			_isDeleted = value;
		}

		/**
		 * Internal Accessor/Modifier for related document. This is internal and is only set in parsing JSON object returned from COuchDB.
		 * To add attachments to a CouchDocument instance, use the CouchDocument#attachments modifier. When a CouchDocument is saved,
		 * it will look to see if a correlating CouchDocument is associated with this CouchAttachment. If not it will push the document as well. 
		 * @return CouchDocument
		 */
		as3couchdb_internal function get document():CouchDocument
		{
			return _document;
		}
		as3couchdb_internal function set document( value:CouchDocument ):void
		{
			_document = value;
		}
	}
}