# 📩 Loadability

**LetMeIn** is a mini Swift Package that performs client certificate authentication on network requests. Client certificate authentication (CCA) allows servers to authenticate that the client is legitimate and authorized to access the server, or API.

## Requirements

**Loadability** supports **iOS 14+**, **macOS 11+**, and **watchOS 7+**. It does not have any dependencies.

## Installation

You can use **LetMeIn** as a Swift Package, or add it manually to your project. 

### Swift Package Manager (SPM)

Swift Package Manager is a way to add dependencies to your app, and is natively integrated with Xcode.

To add **LetMeIn** with SPM, click `File` ► `Swift Packages` ► `Add Package Dependency...`, then type in the URL to this Github repo. Xcode will then add the package to your project and perform all the necessary work to build it.

```
https://github.com/julianschiavo/LetMeIn
```

Alternatively, add the package to your `Package.swift` file.

```swift
let package = Package(
// ...
dependencies: [
.package(url: "https://github.com/julianschiavo/LetMeIn.git", from: "1.0.0")
],
// ...
)
```

*See [SPM documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation) to learn more.*

### Manually

If you prefer not to use SPM, you can also add **LetMeIn** as a normal framework by building the Xcode project from this repository. (See other sources for instructions on doing this.)

<br>

## Usage

Create an instance of an authenticator, then use it as the delegate when performing `URLSession` requests.

```swift
// Create a certificate file representation
let certificate = CertificateFile(fileName: "certificate", password: "12345678")
// Create an authenticator
let authenticator = ClientCertificateAuthenticator(certificateFile: certificate)

// Make a custom URLSession using the authenticator as the delegate
let urlSession = URLSession(configuration: .default, delegate: authenticator, delegateQueue: nil)

// Perform a URL request
let request = URLRequest(url: ...)
urlSession.downloadTask(with: request) { (_, response, error) in
...
}
```

If you already have a custom `URLSessionDelegate`, or want to use this package in some other way (for example, with [Alamofire](https://github.com/Alamofire/Alamofire)), you can use the authenticator object directly. This is a more advanced technique, and used internally by **LetMeIn** to provide `AVAsset` support.

```swift
// Create a certificate file representation
let certificate = ...
// Create an authenticator
let authenticator = ...

// A `URLAuthenticationChallenge` that was received by your client
let challenge = ...

authenticator.handleChallenge(authenticationChallenge) { result, credential in
switch result {
case .cancelAuthenticationChallenge, .rejectProtectionSpace:
challenge.sender?.cancel(challenge)
case .useCredential:
guard let credential = credential else { return }
challenge.sender?.use(credential, for: challenge)
case .performDefaultHandling:
challenge.sender?.performDefaultHandling?(for: challenge)
}
}
```

<br>

## Examples

### [SDWebImage](https://github.com/SDWebImage/SDWebImage)

For example, to prevent other clients or browsers from accessing your content and resources, you can use **LetMeIn** together with `SDWebImage` to load images with a client certificate.

```swift
// Create a certificate file representation
let certificate = CertificateFile(fileName: "certificate", password: "12345678")
// Create an authenticator
let authenticator = ClientCertificateAuthenticator(certificateFile: certificate)

// Create a custom downloader operation (see SDWebImage documentation for more info)
class MyDownloaderOperation: SDWebImageDownloaderOperation {
override func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
authenticator.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
}

override func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
authenticator.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
}
}

// Make SDWebImage use our custom downloader operation when downloading images
SDWebImageDownloader.shared.config.operationClass = MyDownloaderOperation.self

// Load an image using SDWebImage
imageView.sd_setImage(with: URL(string: "http://www.domain.com/path/to/image.jpg"), placeholderImage: UIImage(named: "placeholder.png"))
```

<br>

## Contributing

Contributions and pull requests are welcomed by anyone! If you find an issue with **LetMeIn**, file a Github Issue, or, if you know how to fix it, submit a pull request. 

Please review our [Code of Conduct](CODE_OF_CONDUCT.md) and [Contribution Guidelines](CONTRIBUTING.md) before making a contribution.

<br>

## Credit

**LetMeIn** was created by [Julian Schiavo](https://twitter.com/julianschiavo), and available under the [MIT License](LICENSE). Some code adapted from [Jeroen's blog post on CCA in Swift](https://leenarts.net/2020/02/28/client-certificate-with-urlsession-in-swift/).

<br>

## License

Available under the MIT License. See the [License](LICENSE) for more info.
