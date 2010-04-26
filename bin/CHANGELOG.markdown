# Revision Change Log

The purpose of this document is to document changes committed between revisions of the as3couchdb Library.

## as3couchdb-0.5

- Removed class type argument from CouchDatabase:getAllDocuments.

Resolving request response for documents from _all_docs was removed as the result returns all documents 
related to a database including any _design documents. As such, the result from CouchDatabase:getAllDocuments
now returns a list of generic deserialized JSON objects. The responsibility as to verifying the results is now
left to the client developer.

To resolve results to a target model, use CouchDatabase:getDocumentsFromView. It is the assumption that 
requests to a specific view contains map/reduce rules implemented on the CouchDB instance that will return 
documents based on a certain type. Therefore, casting is now handed to that request and removed from the
request for _all_docs which return all documents related to a database without mapping.