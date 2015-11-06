# MendeleySDK Changelog

## v2.1

_Released November 6, 2015_

- _renamed_ `MDLObject` (now part of ModelIO) to `MDLMendeleyAPIObject`, fix #21


## v2.0

_Released April 16, 2015_

**Major release, incompatible with previous versions**

- Migrate to new Mendeley API


## v1.5.1

_Released October 22, 2014_

- Bug fixes


## v1.5

_Released May 5, 2014_

### MDLMendeleyAPIClient

- OAuth 2.0 support

### MDLDocument

- _updated_ `uploadFileAtURL:success:failure:`

### MDLGroup

- _added_ `fetchFoldersSuccess:failure:`


## v1.4

_Released March 19, 2014_

### MDLUser

- _removed_ `fetchContactsSuccess:failure:`
- _removed_ `sendContactRequestSuccess:failure:`


## v1.3.2

_Released January 24, 2014_

### MDLDocument

- _fixed_ `abstract`

### MDLMendeleyAPIClient

- _added_ `fixedTimestamp`


## v1.3.1

_Released October 14, 2013_

- bug fixes


## v1.3

_Released September 2, 2013_

### MDLAuthor

- _added_ `forename`
- _added_ `surname`
- _added_ `authorWithForename:surname:`

### MDLDocument

- _removed_ `URL`
- _added_ `URLs`
- _added_ `citationKey`
- _added_ `createDocument:success:failure:`
- _added_ `updateDetailsSuccess:failure:`
- _updated_ `uploadFileAtURL:success:failure:`

### MDLMendeleyAPIClient

- _updated_ `getPath:requiresAuthentication:parameters:success:failure:`
- _updated_ `postPath:bodyKey:bodyContent:success:failure:`
- _updated_ `deletePath:parameters:success:failure:`
- _updated_ `putPath:fileAtURL:success:failure:`


## v1.2

_Released June 25, 2013_

### MDLDocument

- _added_ `importToUserLibrarySuccess:failure:` [API documentation:  ‎User Library Create Document‎ > ‎By Canonical ID](http://apidocs.mendeley.com/home/user-specific-methods/user-library-create-document/by-canonical-id)

### MDLFile

- _removed_ `downloadToFileAtPath:success:failure:`
- _added_ `downloadToFileAtPath:progress:success:failure:`

### MDLMendeleyAPIClient

- _removed_ `getPath:requiresAuthentication:parameters:outputStreamToFileAtPath:success:failure:`
- _added_ `getPath:requiresAuthentication:parameters:outputStreamToFileAtPath:progress:success:failure:`


## v1.1

_Released April 30, 2013_

### MDLDocument

- _added_ `addedDate`
- _added_ `modifiedDate`
- _added_ `identifiers`
- _added_ `canonicalIdentifier`
- _added_ `PubMedIdentifier`
- _added_ `deletionPending`
- _added_ `foldersIdentifiers`
- _added_ `issue`
- _added_ `discipline`
- _added_ `subdiscipline`
- _added_ `institution`
- _added_ `notes`
- _added_ `cast`
- _added_ `editors`
- _added_ `producers`
- _added_ `translators`
- _added_ `keywords`
- _added_ `pages`
- _added_ `authored`
- _added_ `read`
- _added_ `starred`
- _added_ `openAccess`
- _added_ `tags`
- _added_ `publicationOutlet`
- _added_ `publisher`
- _added_ `URL`
- _added_ `version`
- _added_ `volume`
- _added_ `markAsRead:success:failure:` [User Library Update Document](http://apidocs.mendeley.com/home/user-specific-methods/user-library-update-document)
- _added_ `markAsStarred:success:failure:` [User Library Update Document](http://apidocs.mendeley.com/home/user-specific-methods/user-library-update-document)
- _added_ `moveToTrashSuccess:failure:` [User Library Update Document](http://apidocs.mendeley.com/home/user-specific-methods/user-library-update-document)
- _renamed_ `kMDLDocumentTypeGeneric` to `MDLDocumentTypeGeneric`

### MDLMendeleyAPIClient

- _added_ `authenticateWithSuccess:failure:`
- _added_ `authenticateWithWebAuthorizationCallback:success:failure:`
- _added_ `resetSharedClient`
- _renamed_ `kMDLConsumerKey` to `MDLConsumerKey`
- _renamed_ `kMDLConsumerSecret` to `MDLConsumerSecret`
- _renamed_ `kMDLURLScheme` to `MDLURLScheme`

### MDLUser

- _added_ `contactAddress`
- _added_ `contactEmail`
- _added_ `contactFax`
- _added_ `contactMobile`
- _added_ `contactPhone`
- _added_ `contactWebpage`
- _added_ `contactZIPCode`


## v1.0

_Released January 22, 2013_


## v0.4

_Released November 21, 2012_

### MDLDocument

- _added_ `group`
- _updated_ `fetchDetailsSuccess:failure:` [Group Document Details](http://apidocs.mendeley.com/home/user-specific-methods/group-document-details)

### MDLFolder

- _added_ `createFolderWithName:parent:success:failure:` [Create Folder](http://apidocs.mendeley.com/user-library-create-folder)
- _added_ `fetchFoldersInUserLibrarySuccess:failure:` [Folders](http://apidocs.mendeley.com/home/user-specific-methods/user-library-folder)
- _added_ `fetchDocumentsAtPage:count:success:failure:` [User Library Folder Documents](http://apidocs.mendeley.com/user-library-folder-documents)
- _added_ `addDocument:success:failure:` [User Library Add document to folder](http://apidocs.mendeley.com/user-library-add-document-to-folder)
- _added_ `deleteSuccess:failure:` [Delete Folder](http://apidocs.mendeley.com/user-library-delete-folder)
- _added_ `removeDocument:success:failure:` [Delete document from folder](http://apidocs.mendeley.com/user-library-delete-document-from-folder)

### MDLGroup

- _added_ `type`
- _added_ `fetchGroupsInUserLibrarySuccess:failure:` [User Library Groups](http://apidocs.mendeley.com/home/user-specific-methods/user-library-groups)
- _added_ `fetchDocumentsAtPage:count:success:failure:` [Public Groups Documents](http://apidocs.mendeley.com/home/public-resources/public-groups-documents), [User Library Group Documents](http://apidocs.mendeley.com/home/user-specific-methods/user-library-group-documents)
- _added_ `createGroupWithName:type:success:failure:` [User Library Create Document](http://apidocs.mendeley.com/home/user-specific-methods/user-library-create-document)
- _added_ `deleteSuccess:failure:` [Delete Group](http://apidocs.mendeley.com/home/user-specific-methods/user-library-delete-group)
- _added_ `leaveSuccess:failure:` [Delete Group](http://apidocs.mendeley.com/home/user-specific-methods/user-library-delete-group)
- _added_ `unfollowSuccess:failure:` [Delete Group](http://apidocs.mendeley.com/home/user-specific-methods/user-library-delete-group)
- _updated_ `fetchPeopleSuccess:failure:` [User Library Group People](http://apidocs.mendeley.com/home/user-specific-methods/user-library-group-people)

### MDLUser

- _added_ `fetchContactsSuccess:failure:` [User Profile Contacts](http://apidocs.mendeley.com/home/user-specific-methods/user-profile-contacts)
- _added_ `sendContactRequestSuccess:failure:` [User Profile Add Contact](http://apidocs.mendeley.com/home/user-specific-methods/user-profile-add-contact)


## v0.3

_Released November 15, 2012_

### MDLDocument

- _added_ `files`
- _added_ `isInUserLibrary`
- _added_ `fetchDocumentsInUserLibraryAtPage:count:success:failure:` [User Library](http://apidocs.mendeley.com/home/user-specific-methods/user-library)
- _added_ `fetchAuthoredDocumentsInUserLibraryAtPage:count:success:failure:` [User Authored](http://apidocs.mendeley.com/home/user-specific-methods/user-authored)
- _added_ `deleteSuccess:failure:` [Delete Document](http://apidocs.mendeley.com/home/user-specific-methods/user-library-remove-document)
- _updated_ `fetchDetailsSuccess:failure:` [User Library Document Details](http://apidocs.mendeley.com/home/user-specific-methods/user-library-document-details)

### MDLFile

- _added_ `fileWithDateAdded:extension:hash:size:document:`
- _added_ `downloadToFileAtPath:success:failure:` [Download file](http://apidocs.mendeley.com/home/user-specific-methods/download-file)

### MDLMendeleyAPIClient

- _added_ `getPath:requiresAuthentication:parameters:success:failure:`
- _added_ `getPath:requiresAuthentication:parameters:outputStreamToFileAtPath:success:failure:`
- _added_ `deletePrivatePath:parameters:success:failure:`
- _removed_ `getPublicPath:parameters:success:failure:`
- _removed_ `getPrivatePath:success:failure:`


## v0.2

_Released November 8, 2012_

### MDLAuthor

- _added_ `topAuthorsInUserLibrarySuccess:failure:` [User Authors Stats](http://apidocs.mendeley.com/home/user-specific-methods/user-authors-stats)

### MDLPublication

- _added_ `topPublicationsInUserLibrarySuccess:failure:` [User Publication Outlets Stats](http://apidocs.mendeley.com/home/user-specific-methods/user-publication-outlets-stats)

### MDLTag

- _added_ `lastTagsInUserLibrarySuccess:failure:` [User Tags Stats](http://apidocs.mendeley.com/home/user-specific-methods/user-tags-stats)


## v0.1

_Released October 29, 2012_

### MDLAuthor

- _added_ `authorWithName:`
- _added_ `topAuthorsInPublicLibraryForCategory:upAndComing:success:failure:` [Stats Authors](http://apidocs.mendeley.com/home/public-resources/stats-authors)

### MDLCategory

- _added_ `categoryWithI- dentifier:name:slug:`
- _added_ `fetchCategoriesSuccess:failure:` [Search Categories](http://apidocs.mendeley.com/home/public-resources/search-categories)
- _added_ `subcategoriesSuccess:failure:` [Search Subcategories](http://apidocs.mendeley.com/home/public-resources/search-subcategories)
- _added_ `lastTagsInPublicLibrarSuccess:failure:` [Stats Tags](http://apidocs.mendeley.com/home/public-resources/stats-tags)

### MDLDocument

- _added_ `documentWithTitle:success:failure:` [User Library Create Document](http://apidocs.mendeley.com/home/user-specific-methods/user-library-create-document)
- _added_ `searchWithTerms:atPage:count:success:failure:` [Search Terms](http://apidocs.mendeley.com/home/public-resources/search-terms)
- _added_ `searchWithGenericTerms:authors:title:year:tags:atPage:count:success:failure:` [Search Terms](http://apidocs.mendeley.com/home/public-resources/search-terms)
- _added_ `searchTagged:category:subcategory:atPage:count:success:failure:` [Search Tagged](http://apidocs.mendeley.com/home/public-resources/search-tagged)
- _added_ `searchAuthoredWithName:year:atPage:count:success:failure:` [Search Authored](http://apidocs.mendeley.com/home/public-resources/search-authored)
- _added_ `topDocumentsInPublicLibraryForCategory:upAndComing:success:failure:` [Stats Papers](http://apidocs.mendeley.com/home/public-resources/stats-papers)
- _added_ `uploadFileAtURL:success:failure:` [File Upload](http://apidocs.mendeley.com/home/user-specific-methods/file-upload)
- _added_ `fetchDetailsSuccess:failure:` [Search details](http://apidocs.mendeley.com/home/public-resources/search-details)
- _added_ `fetchRelatedDocumentsAtPage:count:success:failure:` [Search Related](http://apidocs.mendeley.com/home/public-resources/search-related)

### MDLGroup

- _added_ `groupWithIdentifier:name:ownerName:category:`
- _added_ `topGroupsInPublicLibraryForCategory:atPage:count:success:failure:` [Search Public Groups](http://apidocs.mendeley.com/home/public-resources/search-public-groups)
- _added_ `fetchDetailsSuccess:failure:` [Public Groups Details](http://apidocs.mendeley.com/home/public-resources/public-groups-details)
- _added_ `fetchPeopleSuccess:failure:` [Public Groups People](http://apidocs.mendeley.com/home/public-resources/public-groups-people)
  
### MDLMendeleyAPIClient

- _added_ `automaticAuthenticationEnabled`
- _added_ `rateLimitRemainingForLatestRequest` [Rate Limiting](http://apidocs.mendeley.com/home/rate-limiting)
- _added_ `sharedClient`
- _added_ `getPublicPath:parameters:success:failure:`
- _added_ `getPrivatePath:success:failure:`
- _added_ `postPrivatePath:bodyKey:bodyContent:success:failure:`
- _added_ `putPrivatePath:fileAtURL:success:failure:`
  
### MDLPublication

- _added_ `publicationWithName:`
- _added_ `topPublicationsInPublicLibraryForCategory:upAndComing:success:failure:` [Stats Publication Outlets](http://apidocs.mendeley.com/home/public-resources/stats-publication-outlets)

### MDLSubcategory

- _added_ `subcategoryWithIdentifier:name:slug:`

### MDLTag

- _added_ `tagWithName:count:`
- _added_ `lastTagsInPublicLibraryForCategory:success:failure:` [Stats Tags](http://apidocs.mendeley.com/home/public-resources/stats-tags)
  
### MDLUser

- _added_ `userWithIdentifier:name:`
- _added_ `fetchMyUserProfileSuccess:failure:` [Profile Information](http://apidocs.mendeley.com/home/user-specific-methods/profile-information)
- _added_ `fetchProfileSuccess:failure:` [Profile Information](http://apidocs.mendeley.com/home/user-specific-methods/profile-information)
