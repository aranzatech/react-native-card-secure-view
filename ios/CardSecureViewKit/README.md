# CardSecureViewKit

Native iOS package that validates a short-lived signed token and presents sensitive mock card data without returning PAN or CVV to React Native.

## Public API

- `DemoSecureTokenIssuer`: creates a demo HMAC-SHA256 token with a maximum TTL of 60 seconds.
- `CardSecureViewCoordinator`: validates the request and presents the native full-screen flow.
- `SecureViewRequest`: contains only `cardId` and `secureToken`.
- `SecureViewEvent`: reports `opened`, `cardDataShown`, `validationError`, and `closed`.
- `CardSecureViewConfiguration`: configures a session timeout between 30 and 60 seconds.

## Security boundaries

- Full PAN and CVV exist only in the native mock repository and UIKit view lifecycle.
- Sensitive labels are cleared before dismissal and card data references are released.
- The view conceals its content when the application resigns active or screen capture is detected.
- Screenshot detection closes the session by default.
- No sensitive values are logged.
- The bundled HMAC secret and token issuer are for this challenge demo only. Production applications must obtain short-lived tokens from a backend and inject protected key material.

## Example

```swift
let issuer = DemoSecureTokenIssuer()
let token = issuer.issueToken(for: "card_001")!

let coordinator = CardSecureViewCoordinator()
coordinator.open(
    request: SecureViewRequest(cardId: "card_001", secureToken: token),
    from: presentingViewController
) { event in
    // Forward metadata-only events. Never forward PAN or CVV.
}
```

## Host integration

Add `CardSecureViewKit` as a local Swift Package dependency and keep the platform adapter intentionally thin. The host must pass only a `SecureViewRequest`, a presenting view controller and an event callback. It must never copy native card values into bridge payloads, analytics or logs.

The package has no React Native dependency, so it can also be embedded in a native iOS application.

## Tests

From this directory, select an installed simulator and run:

```sh
xcodebuild \
  -scheme CardSecureViewKit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test
```

The suite covers valid and invalid tokens, TTL boundaries, card binding, lifecycle transitions, screen capture, screenshots, timeouts, duplicate presentation, cleanup and performance.
