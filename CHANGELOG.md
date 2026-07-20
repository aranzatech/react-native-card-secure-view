# Changelog

## 0.1.2

- Soporta `use_frameworks!` (requerido por dependencias como `@react-native-firebase`) además del linkage estático por defecto: el adaptador ahora importa el header Swift generado con `__has_include`, ya que su ruta cambia según el modo de linkage de CocoaPods.

## 0.1.1

- Corrige el build iOS al consumir el pod: los headers ObjC++ ahora son privados (`private_header_files`), evitando que el spec C++ de Codegen entre al module map y rompa la compilación del módulo Swift (`'utility' file not found`).

## 0.1.0

- Extracción inicial de la librería desde la app del reto Card Secure View.
- TurboModule `NativeCardSecureView` con `createSecureToken`, `openSecureView` y los eventos `opened`, `cardDataShown`, `validationError` y `closed`.
- API JS tipada: `openSecureCardView`, `isSecureViewAvailable` y helpers de suscripción a eventos.
- Paquete Swift `CardSecureViewKit` incluido con validación HMAC-SHA256, timeout de sesión, escudo de privacidad en background, detección de captura y limpieza de contenido.
- Podspec para autolinking (CocoaPods) y `Package.swift` para consumo SPM independiente.
- CI (lint, typecheck, Jest, audit, build y tests nativos en simulador) y publicación a npm por tag.
