# Deepgram

A Swift package for the Deepgram API, generated from Deepgram's OpenAPI
specification with `swift-openapi-generator`.

## Requirements

- Swift 6.2 or later (verified with Swift 6.4; resolved dependencies require 6.2)
- macOS 13, iOS 16, tvOS 16, or watchOS 9

## Installation

Add the package to `Package.swift`:

```swift
.package(url: "https://github.com/atacan/deepgram.git", branch: "main")
```

Add the core product and your chosen transport product to your target:

```swift
.product(name: "Deepgram", package: "deepgram"),
.product(name: "DeepgramURLSession", package: "deepgram"),
// Or: .product(name: "DeepgramAsyncHTTPClient", package: "deepgram")
```

The four products are `DeepgramTypes` (models and operation inputs/outputs),
`Deepgram` (shared client and authentication), `DeepgramURLSession`, and
`DeepgramAsyncHTTPClient`. Add `DeepgramTypes` directly when importing it.
The shared client and types have no transport dependencies.

## Usage

Use URLSession:

```swift
import Foundation
import Deepgram
import DeepgramURLSession

let client = Client.urlSession(
    serverURL: URL(string: "https://api.deepgram.com")!,
    authentication: .apiKey("<deepgram-api-key>")
)
```

Or use AsyncHTTPClient:

```swift
import Foundation
import Deepgram
import DeepgramAsyncHTTPClient

let client = Client.asyncHTTPClient(
    serverURL: URL(string: "https://api.deepgram.com")!,
    authentication: .apiKey("<deepgram-api-key>")
)
```

Both factories return `Deepgram.Client` and accept ISO-8601 response dates with or
without fractional seconds by default. Supply a raw API key: shared authentication
adds Deepgram's
`Authorization: Token <key>` header. For JWT credentials, use `.bearer("<jwt>")`.
Dynamic keys use `.apiKey { try await keyStore.currentKey() }` and are evaluated
per request; provider failures propagate. Named credentials use
`.credentials(["ApiKeyAuth": .init("<key>")])` or `JwtAuth` for JWTs.

The upstream specification declares authentication schemes without security
requirements. The overlay supplies default API-key/JWT alternatives so generated
operation security metadata requires authentication. With both credentials, the
API-key alternative is selected first. Factory authentication defaults to `.none`;
protected operations then fail before sending a request.

Factories accept `configuration:`, `transportConfiguration:`, and `middlewares:`.
Explicit runtime configuration overrides the date default. Additional middleware
runs before shared authentication. Inject sessions/clients through the upstream
transport configuration; import that transport and declare its product directly
when using its configuration types. The caller owns injected sessions/clients and
must manage their lifecycle; never shut down a shared client.

For another transport, use
`Client(serverURL:configuration:transport:authentication:middlewares:)` from the
core product. This authenticating initializer has the same lenient date default
as the factories. An explicit `configuration:` is always respected. Standalone
`JSONDecoder` instances need their own date strategy; use
`DeepgramDateTranscoder().decode(_:)` in a custom strategy.

### Migration compatibility

`AuthenticationMiddleware(apiKey:)` in `DeepgramTypes` has been removed. Import
`Deepgram` and use factory `authentication: .apiKey(key)`, or
`AuthenticationMiddleware(authentication: .apiKey(key))` with a custom transport.
Transport factories require importing their corresponding convenience module.
Swift OpenAPI Generator 1.14.2 splits Types into multiple files; this migration
preserves existing public property and typealias declarations.
The resolved dependency graph requires Swift 6.2; the package now declares that
minimum instead of the previous Swift 5.9 requirement. Package resolution may still
fetch both transport dependencies even when an application uses only one product.

Transcription failures now use `ErrorResponse` for HTTP 400, 401, 402, and 429
(the generated HTTP 402 case is `.code402`). Legacy errors require `err_msg` and
modern errors require `message`, so decoding preserves the correct error shape.
Multi-value redaction accepts strings instead of a closed three-value enum.
These changes alter public types and require a major version when released.

Do not commit API keys or local environment files. For local development, keep
credentials in your shell environment.

## Development

Generated Swift sources are checked in. To regenerate them from the original
OpenAPI specification and overlay, run:

```bash
make regenerate
```

This preserves the original specification, overlay, custom helpers, tests, manifest,
and documentation. Edit `original_openapi.yml` or `openapi-overlay.yaml`, then
regenerate; do not hand-edit the sanitized spec or generated Swift files.

Build the package with:

```bash
swift build
```

Run offline tests without using local credentials or sending requests:

```bash
make test-offline
```

`swift test` also skips the live transcription test by default. To run that test
intentionally, export `DEEPGRAM_API_KEY` and provide a root `sample.m4a`, then use
`DEEPGRAM_RUN_LIVE_TESTS=1 swift test --filter DeepgramTests`.

## Security

This repository uses Gitleaks and TruffleHog for local and CI secret scanning.
Run the configured hooks locally with:

```bash
pre-commit run --all-files
```

## License

MIT. See [LICENSE](LICENSE).
