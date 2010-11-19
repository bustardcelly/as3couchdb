/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchUserWriter.as</p>
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
package com.custardbelly.as3couchdb.serialize
{
	/**
	 * CouchUserWriter manages updating a CouchUser JSON object to be sent over the wire for updates. 
	 * @author toddanderson
	 */
	public class CouchUserWriter extends CouchDocumentWriter
	{
		/**
		 * Constructor. 
		 * 
		 */
		public function CouchUserWriter()
		{
			super();
		}
		
		/**
		 * @inheritDoc 
		 * 
		 * Override to specify transient properties not being sent along in the JSON object during a transaction.
		 */
		override protected function assignTransientProperties():void
		{
			transientProperties["id"] = true;
			transientProperties["revision"] = true;
			transientProperties["isDeleted"] = true;
			transientProperties["baseUrl"] = true;
			transientProperties["databaseName"] = true;
			transientProperties["entity"] = true;
		}
	}
}