# Resolvers

Resolvers are rooted in the `/v1/resolvers/{org_label}/{project_label}` collection and are used in the following scenarios

- Bring the content of the value on the `owl:imports` predicate for schema resources. The value is the `@id` of the resource. E.g.: You can define owl imports on a schema, as follows `"owl:imports": "http://example.com/myid"`. The resolver will try to find a resource with `"@id": "http://example.com/myid"` and if found, will bring the payload into the original resource. 
- Bring the content of the `@context` links. The value is the `@id` of the resource. E.g.: A resource might define the context as follows: `"@context": "http://example.com/id"`. The resolver will try to find a resource with `"@id": "http://example.com/id"` and if found, will bring the payload into the original resource. 

Each resolver... 

- belongs to a `project` identifier by the label `{project_label}` 
- inside an `organization` identifier by the label `{org_label}` 
- it is validated against the [resolver schema](https://bluebrain.github.io/nexus/schemas/resolver).

Access to resources in the system depends on the access control list set for them. Depending on the access control list, a caller may need to prove its identity by means of an **access token** passed to the `Authorization` header (`Authorization: Bearer {token}`). Please visit @ref:[Authentication](../iam/authentication.md) to learn more about how to retrieve an access token.

@@@ note { .tip title="Running examples with Postman" }

The simplest way to explore our API is using [Postman](https://www.getpostman.com/apps). Once downloaded, import the [resolvers collection](../assets/resolver-postman.json).

If your deployment is protected by an access token: 

Edit the imported collection -> Click on the `Authorization` tab -> Fill the token field.

@@@

## Resolver types

There are several types of resolvers, which perform resolution in different scopes.

### InProject resolver

The scope of the resolution is the current project where the resource resides. In other words:

- Schema `A` can import schema `B` using the `owl:import` as long as schema `B` is located on the same project as schema `A`. 
- Resource `A` can reference resource's context `B` (inside `@context`) as long as resource `B` is located on the same project as resource `A`. 

This resolver gets automatically created when the project is created and it cannot be modified.

**InProject resolver payload**
```
{
    "@id": "nxv:InProject",
    "@type": [ "InProject", "Resolver" ],
    "priority": {priority},
}
```

where `{priority}` is a numeric value (from 1 - 100) which defines the resolution priority when attempting to find the resource with a particular @id.

### InAccount resolver

The scope of the resolution is the current organization where the resource resides. Account resolution defines a collection of identities `I` to enforce ACLs. In other words:

- Schema `A` can import schema `B` using the `owl:import` as long as schema `B` is located on the same organization as schema `A` and as long `I` have `schemas/read` permissions on the schema `B` project.
- Resource `A` can reference resource's context `B` (inside `@context`) as long as resource `B` is located on the same organization as resource `A` and as long as `I` have `schemas/read` permissions on the schema `B` project.


**InAccount resolver payload**
```
{
  "@id": "{someid}",
  "@type": ["Resolver", "InAccount"],
  "resourceTypes": ["{resourceType}", ...],
  "identities": [ {_identity_}, {...} ],
  "priority": {priority}
}
```

where...
 
- `{resourceType}`: Iri - resolves only the resources with `@type` containing `{resourceType}`. This field is optional.
- `{priority}`: Number - value (from 1 - 100) which defines the resolution priority when attempting to find the resource with a particular @id.
- `_identity_`: Json object - the identity against which to enforce ACLs during resolution process.
- `{someid}`: Iri - the @id value for this resolver.

**Example**

Request
:   @@snip [resolver-in-account.sh](../assets/resolver-in-account-put.sh)

Payload
:   @@snip [resolver-in-account.json](../assets/resolver-in-account.json)

Response
:   @@snip [resolver-in-account-ref-new.json](../assets/resolver-in-account-ref-new.json)


### CrossProject resolver

The scope of the resolution is the collections of projects `P` defined on the resolver. CrossProject resolution also defines a collection of identities `I` to enforce ACLs. In other words:

- Schema `A` can import schema `B` using the `owl:import` as long as schema `B` is located on some of the projects from the collection `P` and as long `I` have `schemas/read` permissions on the schema `B` project.
- Resource `A` can reference resource's context `B` (inside `@context`) as long as resource `B` is located on some of the projects from the collection `P` and as long as `I` have `schemas/read` permissions on the schema `B` project.


**CrossProject resolver payload**
```
{
  "@id": "{someid}",
  "@type": ["Resolver", "CrossProject"],
  "resourceTypes": ["{resourceType}", ...],
  "projects": ["{project}", ... ],
  "identities": [ {_identity_}, {...} ],
  "priority": 50
}
```

where...

- `{resourceType}`: Iri - resolves only the resources with `@type` containing `{resourceType}`. This field is optional.
- `{priority}`: Number - value (from 1 - 100) which defines the resolution priority when attempting to find the resource with a particular @id.
- `{project}`: String - the user friendly reference to the project from where the resolution process will attempt to find the @id's. It follows the format `{organization}/{project}`.
- `_identity_`: Json object - the identity against which to enforce ACLs during resolution process.
- `{someid}`: Iri - the @id value for this resolver.

**Example**

Request
:   @@snip [resolver-cross-project.sh](../assets/resolver-cross-project-put.sh)

Payload
:   @@snip [resolver-cross-project.json](../assets/resolver-cross-project.json)

Response
:   @@snip [resolver-cross-project-ref-new.json](../assets/resolver-cross-project-ref-new.json)

## Create a resolver using POST

```
POST /v1/resolver/{org_label}/{project_label}
  {...}
```

The json payload: 

- If the `@id` value is found on the payload, this @id will be used.
- If the `@id` value is not found on the payload, an @id will be generated as follows: `base:{UUID}`. The `base` is the `prefix` defined on the resolver's project (`{project_label}`).

**Example**

Request
:   @@snip [resolver-cross-project.sh](../assets/resolver-cross-project.sh)

Payload
:   @@snip [resolver-cross-project.json](../assets/resolver-cross-project.json)

Response
:   @@snip [resolver-cross-project-ref-new.json](../assets/resolver-cross-project-ref-new.json)


## Create a resolver using PUT
This alternative endpoint to create a resolver is useful in case the json payload does not contain an `@id` but you want to specify one. The @id will be specified in the last segment of the endpoint URI.
```
PUT /v1/resolvers/{org_label}/{project_label}/{resolver_id}
  {...}
```
 
Note that if the payload contains an @id different from the `{resolver_id}`, the request will fail.

**Example**

Request
:   @@snip [resolver-cross-project.sh](../assets/resolver-cross-project-put.sh)

Payload
:   @@snip [resolver-cross-project-put.json](../assets/resolver-cross-project-put.json)

Response
:   @@snip [resolver-cross-project-ref-new.json](../assets/resolver-cross-project-ref-new.json)


## Update a resolver

This operation overrides the payload.

In order to ensure a client does not perform any changes to a resolver without having had seen the previous revision of
the resolver, the last revision needs to be passed as a query parameter.

```
PUT /v1/resolvers/{org_label}/{project_label}/{resolver_id}?rev={previous_rev}
  {...}
```
... where `{previous_rev}` is the last known revision number for the resolver.


**Example**

Request
:   @@snip [resolver-cross-project-update.sh](../assets/resolver-cross-project-update.sh)

Payload
:   @@snip [resolver-cross-project.json](../assets/resolver-cross-project.json)

Response
:   @@snip [resolver-cross-project-ref-updated.json](../assets/resolver-cross-project-ref-updated.json)


## Tag a resolver

Links a resolver revision to a specific name. 

Tagging a resolver is considered to be an update as well.

```
PUT /v1/resolvers/{org_label}/{project_label}/{resolver_id}/tags?rev={previous_rev}
  {
    "tag": "{name}",
    "rev": {rev}
  }
```
... where 

- `{previous_rev}`: Number - the last known revision for the resolver.
- `{name}`: String - label given to the resolver at specific revision.
- `{rev}`: Number - the revision to link the provided `{name}`.

**Example**

Request
:   @@snip [resolver-tag.sh](../assets/resolver-tag.sh)

Payload
:   @@snip [tag.json](../assets/tag.json)

Response
:   @@snip [resolver-cross-project-ref-tagged.json](../assets/resolver-cross-project-ref-tagged.json)

## Add attachment to a resolver

Adds a binary to an already existing resolver

```
PUT /v1/resolvers/{org_label}/{project_label}/{resolver_id}/atachments/{name}?rev={previous_rev}
```
...where

- `{previous_rev}`: is the last known revision number for the resolver.
- `{name}`: String - the attachment identifier. This value is uniquely identifying the attachment per project.

**Example**

Request
:   @@snip [resolver-attach.sh](../assets/resolver-attach.sh)

Response
:   @@snip [resolver-cross-project-ref-attached.json](../assets/resolver-cross-project-ref-attached.json)

## Delete attachment from a resolver

Deletes the attachment metadata from the latest revision of the resolver. The attachment will still be accessible accessing the previous revision.

```
DELETE /v1/resolvers/{org_label}/{project_label}/{resolver_id}/atachments/{name}?rev={previous_rev}
```
...where

- `{previous_rev}`: is the last known revision number for the resolver.
- `{name}`: String - the attachment identifier. This value is uniquely identifying the attachment per project.

**Example**

Request
:   @@snip [resolver-unattach.sh](../assets/resolver-unattach.sh)

Response
:   @@snip [resolver-cross-project-ref-unattached.json](../assets/resolver-cross-project-ref-unattached.json)

## Fetch attachment from a resolver (current revision)

```
GET /v1/resolvers/{org_label}/{project_label}/{resolver_id}/atachments/{name}
```
...where `{name}` is the attachment identifier.

**Example**

Request
:   @@snip [resolver-attach-fetch.sh](../assets/resolver-attach-fetch.sh)

## Fetch attachment from a resolver (specific revision)

```
GET /v1/resolvers/{org_label}/{project_label}/{resolver_id}/atachments/{name}?rev={rev}
```
... where 
- `{name}` - String:  is the attachment identifier.
- `{rev}` - Long: is the revision number of the resolver to be retrieved.

**Example**

Request
:   @@snip [resolver-attach-fetch-rev.sh](../assets/resolver-attach-fetch-rev.sh)

## Fetch attachment from a resolver (specific tag)

```
GET /v1/resolvers/{org_label}/{project_label}/{resolver_id}/atachments/{name}?tag={tag}
```
... where 
- `{name}` - String:  is the attachment identifier.
- `{tag}` - String: is the tag of the resolver to be retrieved.

**Example**

Request
:   @@snip [resolver-attach-fetch-tag.sh](../assets/resolver-attach-fetch-tag.sh)


## Deprecate a resolver

Locks the resolver, so no further operations can be performed. It will also not be taken into account in the resolution process.

Deprecating a resolver is considered to be an update as well. 

```
DELETE /v1/resolvers/{org_label}/{project_label}/{resolver_id}?rev={previous_rev}
```

... where `{previous_rev}` is the last known revision number for the resolver.

**Example**

Request
:   @@snip [resolver-deprecate.sh](../assets/resolver-deprecate.sh)

Response
:   @@snip [resolver-ref-deprecated.json](../assets/resolver-cross-project-ref-deprecated.json)


## Fetch a resolver (current version)

```
GET /v1/resolvers/{org_label}/{project_label}/{resolver_id}
```

**Example**

Request
:   @@snip [resolver-fetch.sh](../assets/resolver-fetch.sh)

Response
:   @@snip [resolver-fetched.json](../assets/resolver-fetched.json)


## Fetch a resolver (specific version)

```
GET /v1/resolvers/{org_label}/{project_label}/{resolver_id}?rev={rev}
```
... where `{rev}` is the revision number of the resolver to be retrieved.

**Example**

Request
:   @@snip [resolver-fetch-revision.sh](../assets/resolver-fetch-revision.sh)

Response
:   @@snip [resolver-fetched.json](../assets/resolver-fetched.json)


## Fetch a resolver (specific tag)

```
GET /v1/resolvers/{org_label}/{project_label}/{resolver_id}?tag={tag}
```

... where `{tag}` is the tag of the resolver to be retrieved.


**Example**

Request
:   @@snip [resolver-fetch-tag.sh](../assets/resolver-fetch-tag.sh)

Response
:   @@snip [resolver-fetched-tag.json](../assets/resolver-fetched-tag.json)

## List resolvers

```
GET /v1/resolvers/{org_label}/{project_label}?from={from}&size={size}&deprecated={deprecated}&q={full_text_search_query}
```

where...

- `{full_text_search_query}`: String - can be provided to select only the resolvers in the collection that have attribute values matching (containing) the provided token; when this field is provided the results will also include score values for each result
- `{from}`: Number - is the parameter that describes the offset for the current query; defaults to `0`
- `{size}`: Number - is the parameter that limits the number of results; defaults to `20`
- `{deprecated}`: Boolean - can be used to filter the resulting resolvers based on their deprecation status


**Example**

Request
:   @@snip [resolver-list.sh](../assets/resolver-list.sh)

Response
:   @@snip [resolver-list.json](../assets/resolver-list.json)