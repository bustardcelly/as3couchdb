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

## as3couchdb-0.6

- Added constructor argument to core models to take a optional custom CouchModelEntity.

This allows for customization and removes the metadata annotations as being a "requirement".

## as3couchdb-0.7

- Tested against CouchDB release 1.0.1.
- Removed CouchSession core model as being a service enabled DAO. Now it is just a model that represents a session.
- Upgraded CouchUser as a core DAO model.
- Created service and action mediator for CouchUser.
- Slight changes to CouchDatabase and CouchDocument (and/or their respective service and mediators) with regards to changes in CouchDB since v0.10

The previous versions of as3couchdb were tested against the CouchDB release of 0.10. With the latest release of CouchDB (1.0.1)
significant changes have been made (for the better!). Particularly, the concept of users and admins has been flesh out and the
previous way that developers dealt with users (and which as3couchdb employed) was no longer a valid solution.

As such, as3couchdb-0.7 addressed these changes in the CouchDB REST API. A session once relied on CouchSession with a related user. Now,
CouchUser is the star and a session is stored in the service to be used upon any subsequent service calls after a CouchUsr has logged in.   