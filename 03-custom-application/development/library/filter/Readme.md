# Common functions - filter

This module contains functions for filtering and adding cross concerns
to any http handler function

## Basic Usage

Any filter can be placed before the http call.
Depending on the implementation, the filter can stop the processing returning an HTTP Status or continue to the next filter.


## Example

The ```filter.RequestLogging(...)``` is placed around the original handler function
and measures the time elapsed and logs it to zerolog.

```Go
router.
    Methods("POST").
    Path("/v1/token").
    Handler(filter.FilterChain(
        filter.FilterGroup(
            filter.RequestLogger(),
        ),
        handler{},
))
```

## Filters


### Request Logging

The request logger measures the duration of the call and writes a json log entry with
the following values.

* HTTP Method
* Request Path
* Duration in Milliseconds
* TODO Tenant (Header Field)
* TODO HTTP Return code


### Tenant Check
The tenant for each ReST-Call needs to be set as Header-Value, so the filter can access 
the value without any code-magic.

The Tenant-Check needs to be set on each ReST-Call that requires the tenant-information.

**Behavior**

If no tenant is provided (or empty), an HTTP 400 is returned.

For unknown values of the tenant, an HTTP 400 is returned.

Any known tenant will pass the filter and the next filter or the handler function is executed.

The usage of this filter requires the configuration of the mongodb adapter.

### Authentication

The authentication filter will check the HTTP Header 'Security-Token".

Actually, no real implementation is provided. Instead, a simple check is implemented.



### Authorization

Not yet implemented

### Rate Limiting

The rate limiting filter enables an in memory rate limiting of the ReST Call.
Using the Horizontal Autoscaler will affect the behavior of this filter!
If you need a global rate limiting, use the Redis based rate limiter.

### Redis Rate Limiting

Not yet implemented