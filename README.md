# Deepgram

A Swift package for the Deepgram API, generated from Deepgram's OpenAPI
specification with `swift-openapi-generator`.

## Requirements

- Swift 5.9 or later
- macOS 13, iOS 16, tvOS 16, or watchOS 9

## Installation

Add the package to `Package.swift`:

```swift
.package(url: "https://github.com/atacan/SwiftDeepgram.git", branch: "main")
```

Then add the product you need to your target:

```swift
.product(name: "Deepgram", package: "SwiftDeepgram")
```

The package also exposes `DeepgramTypes` separately for projects that only need
the generated OpenAPI types.

## Usage

Create a generated client with the provided authentication middleware:

```swift
import Deepgram
import DeepgramTypes
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime

let client = Client(
    serverURL: try Servers.Server1.url(),
    configuration: Configuration(dateTranscoder: .iso8601WithFractionalSeconds),
    transport: AsyncHTTPClientTransport(),
    middlewares: [
        AuthenticationMiddleware(apiKey: "<deepgram-api-key>")
    ]
)
```

Do not commit API keys or local environment files. For local development, keep
credentials in an ignored `.env` file or your shell environment.

## Development

Generated Swift sources are checked in. To regenerate them from the transformed
OpenAPI specification, run:

```bash
make regenerate
```

Build the package with:

```bash
swift build
```

## Security

This repository uses Gitleaks and TruffleHog for local and CI secret scanning.
Run the configured hooks locally with:

```bash
pre-commit run --all-files
```

## License

MIT. See [LICENSE](LICENSE).
