package com.custardbelly.couchdb.example.serialize
{
	import com.custardbelly.as3couchdb.core.CouchDocument;
	import com.custardbelly.as3couchdb.serialize.CouchDocumentReader;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ContactDocumentReader is an extension of CouchDocumentReader to provide custom handling for reading in and resolving documents from ContactDatabase. 
	 * @author toddanderson
	 */
	public class ContactDocumentReader extends CouchDocumentReader
	{
		/**
		 * Constructor.
		 */
		public function ContactDocumentReader()
		{
			super();
		}
		
		/**
		* Updates the target CouchDocument and its attributes based on the result object. 
		* @param document CouchDocument
		* @param result Object
		*/
		override public function updateDocumentFromRead( document:CouchDocument, result:Object ):void
		{
			document.revision = result["_rev"];
			document.attachments = createAssociatedAttachments( document, result["_attachments"] );
			var attribute:String;
			for( attribute in result )
			{
				try 
				{
					// try an apply the attributes held on the result to the document.
					if( !reservedProperties.hasOwnProperty( attribute ) )
						document[attribute] = result[attribute];
				}
				catch( e:Error )
				{
					// If attribute does not exist, throw RTE.
				 	throw new IllegalOperationError( "Document being written to, [" + getQualifiedClassName(document) + "] does not support the following property returned: " + attribute );
				}
			}
		}
	}
}