We generate the Swift code using swift-openapi-generator. As we apply complex transformations to the original OpenAPI specification, we use a Python tool to do this. Run the generation with 

```bash
make regenerate
```

As this is a Swift package, you can find the code of the Swift package dependencies in the ".build/checkouts/" directory. Look at that folder when you need to understand how to use the code from the Swift package dependencies.


The package exposes DeepgramTypes, Deepgram, DeepgramURLSession, and
DeepgramAsyncHTTPClient. Keep transport imports and dependencies out of Types and
core. Swift 6.2 or newer is required by the resolved dependency graph; migration
was verified with Swift 6.4.

Use either factory, importing Deepgram plus the corresponding transport module:

```swift
let urlSessionClient = Client.urlSession(
    serverURL: URL(string: "https://api.deepgram.com")!,
    authentication: .apiKey(apiKey)
)
let asyncHTTPClient = Client.asyncHTTPClient(
    serverURL: URL(string: "https://api.deepgram.com")!,
    authentication: .apiKey(apiKey)
)
```

The shared authentication middleware prefixes ApiKeyAuth values with `Token `.
Keep this Deepgram customization when changing authentication. JWTs use `.bearer`.
The upstream spec omits security requirements; keep the root authentication
alternatives in the overlay. Regenerate operation security metadata rather than
editing Authentication/GeneratedSecurity/OperationSecurity.swift directly.
The old DeepgramTypes.AuthenticationMiddleware(apiKey:) was removed; callers use
Deepgram.AuthenticationMiddleware(authentication:) or factory authentication.

Both factories default to Configuration(dateTranscoder:
.iso8601WithFractionalSeconds). Preserve this default and explicit configuration
forwarding on reruns. If a custom client reports `Expected date string to be
ISO8601-formatted`, pass the fractional-second transcoder explicitly. Direct
Client initialization bypasses factory defaults; standalone JSONDecoder needs its
own dateDecodingStrategy.

After regeneration, run `swift build` and `make test-offline`. These checks cover
Token/JWT authentication, missing credentials, dynamic credential providers,
fractional-second response decoding through both factories, and caller overrides.
Factory date tests use a middleware response fixture; authentication tests use a
terminal mock transport. No live service is contacted.
The preserved transcription test is opt-in through DEEPGRAM_RUN_LIVE_TESTS=1;
never run it without explicit intent or print local credentials. Keep UsefulThings
and existing local sample files. Do not read `.env` during offline verification.

Generated sources are split into Types+*.swift by the resolved generator. Keep
manual changes outside GeneratedSources. `make regenerate` preserves existing
factory helpers, overlay, tests, documentation, and manifest.
