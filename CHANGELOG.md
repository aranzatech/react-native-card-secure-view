# Changelog

## 0.1.0

- Extracción inicial de la librería desde la app del reto Card Secure View.
- TurboModule `NativeCardSecureView` con `createSecureToken`, `openSecureView` y los eventos `opened`, `cardDataShown`, `validationError` y `closed`.
- API JS tipada: `openSecureCardView`, `isSecureViewAvailable` y helpers de suscripción a eventos.
- Paquete Swift `CardSecureViewKit` incluido con validación HMAC-SHA256, timeout de sesión, escudo de privacidad en background, detección de captura y limpieza de contenido.
- Podspec para autolinking (CocoaPods) y `Package.swift` para consumo SPM independiente.
- CI (lint, typecheck, Jest, audit, build y tests nativos en simulador) y publicación a npm por tag.
