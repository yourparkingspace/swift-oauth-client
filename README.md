# OAuthClient

An opinionated OAuthClient for authenticating to a Laravel Passport protected API.

## Requirements

* iOS 13+
* Swift 5

## Contributing
Please make a PR and once merged, a release will be tagged with the correct version number

## Default Supported Grants
* Client Credentials
* Password
* Refresh

### Custom Grant Types
Its entirely possible to use custom grant types with this package. Simply use the custom grant type and pass in the desired paramteres

## Using OAuthClient

```swift
let connectionBuilder = {
    OAuthServerConnection(url: URL(string: "https://test.com")!,
                          clientID: "1",
                          clientSecret: "abcdef")
}
                                       
let client = OAuthClient(connectionBuilder: connectionBuilder)

client.requestToken(for: .clientCredentials) { (result) in
    switch result {
    case.success(let token):
        // Do something
    case .failure(let error):
        // Handle error
    }
}
```

```swift
let connectionBuilder = {
    OAuthServerConnection(url: URL(string: "https://test.com")!,
                          clientID: "1",
                          clientSecret: "abcdef")
}
                                       
let client = OAuthClient(connectionBuilder: connectionBuilder)

client.fetchStoredToken(type: .clientCredentials) { (result) in
    switch result {
    case .success(let token):
        // Do something with the token
    case .failure(let error):
        // Handle failure
    }
}
```
