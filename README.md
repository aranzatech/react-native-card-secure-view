# @aranzatech/react-native-card-secure-view

Vista segura nativa iOS para mostrar datos sensibles de una tarjeta (PAN, CVV, vencimiento, titular) desde React Native. El PAN y el CVV se crean, conservan y renderizan exclusivamente en Swift: nunca cruzan el bridge hacia JavaScript.

La librería expone un TurboModule (New Architecture) que valida un token HMAC de vida corta antes de presentar la vista, y emite eventos de solo metadatos hacia JS.

## Características

- **Frontera de datos sensibles**: PAN y CVV viven únicamente en el paquete Swift `CardSecureViewKit`; el contrato JS no tiene ningún método que los devuelva.
- **Validación de token**: HMAC-SHA256 (CryptoKit) con verificación de firma en tiempo constante, match de `cardId`, TTL máximo de 60 s, clock skew y expiración, distinguiendo `TOKEN_INVALID` de `TOKEN_EXPIRED`.
- **Protecciones de sesión**: timeout configurable (30–60 s), escudo de privacidad en background, ocultamiento durante grabación o duplicación de pantalla, cierre al detectar screenshot, limpieza de contenido antes del dismissal y bloqueo de aperturas simultáneas.
- **Sin logs sensibles**: el código no contiene sentencias de logging.
- **Eventos tipados**: `opened`, `cardDataShown`, `validationError`, `closed` — solo `cardId`, códigos y motivos.

## Requisitos

- React Native >= 0.80 con New Architecture habilitada (usa Codegen y `CodegenTypes.EventEmitter`).
- iOS 15+.
- Android no está implementado todavía; `isSecureViewAvailable()` devuelve `false` fuera de iOS.

## Instalación

```sh
npm install @aranzatech/react-native-card-secure-view
cd ios && bundle exec pod install
```

El módulo se registra por autolinking; no se requiere configuración manual.

## Uso

```tsx
import {
  isSecureViewAvailable,
  openSecureCardView,
  onSecureViewClosed,
  onValidationError,
} from '@aranzatech/react-native-card-secure-view';

// Suscripción a eventos (por ejemplo, en un useEffect)
const closedSubscription = onSecureViewClosed(({cardId, reason}) => {
  // reason: USER_DISMISS | TIMEOUT | CAPTURE_DETECTED | BACKGROUND_TIMEOUT | VALIDATION_ERROR
});
const errorSubscription = onValidationError(({code, message}) => {
  // code: TOKEN_INVALID | TOKEN_EXPIRED | CARD_NOT_FOUND | VIEW_ALREADY_PRESENTED
});

// Abrir la vista segura (emite el token demo y presenta la UI nativa)
await openSecureCardView('card_001');

// Limpieza
closedSubscription.remove();
errorSubscription.remove();
```

Si prefieres controlar el token por separado:

```ts
import {
  createSecureToken,
  openSecureView,
} from '@aranzatech/react-native-card-secure-view';

const token = await createSecureToken('card_001');
await openSecureView('card_001', token);
```

## API

| Función | Descripción |
| --- | --- |
| `isSecureViewAvailable()` | `true` si el módulo nativo existe en la plataforma actual. |
| `createSecureToken(cardId)` | Emite un token demo HMAC de vida corta para la tarjeta. |
| `openSecureView(cardId, secureToken)` | Valida el token en Swift y presenta la vista segura. |
| `openSecureCardView(cardId)` | Conveniencia: emite el token y abre la vista en un paso. |
| `onSecureViewOpened(listener)` | La sesión nativa fue presentada. |
| `onCardDataShown(listener)` | El contenido fue revelado dentro de UIKit. |
| `onValidationError(listener)` | El token o la solicitud no superó la validación. |
| `onSecureViewClosed(listener)` | La sesión terminó; incluye el motivo. |

Todas las suscripciones devuelven un `EventSubscription` con `.remove()`.

## Arquitectura

```text
src/
├── NativeCardSecureView.ts   # contrato TurboModule (Codegen)
└── index.ts                  # API pública tipada
ios/
├── RCTNativeCardSecureView.{h,mm}      # TurboModule ObjC++ (adaptador delgado)
├── NativeCardSecureViewAdapter.swift   # traducción de llamadas y eventos
└── CardSecureViewKit/                  # Swift Package independiente
    └── Sources/CardSecureViewKit/
        ├── Domain/          # SensitiveCardData, SecureTokenClaims
        ├── Application/     # puertos de validación y datos
        ├── Infrastructure/  # HMAC, codec, repositorio mock
        ├── Presentation/    # vista segura UIKit y protecciones
        └── Public/          # coordinador, configuración, eventos
```

`CardSecureViewKit` es también un Swift Package autónomo (sin dependencia de React Native): puede consumirse por SPM desde una app iOS nativa. El podspec compila las mismas fuentes para el flujo CocoaPods/autolinking de React Native.

## Seguridad — alcance demo

El emisor de tokens (`DemoSecureTokenIssuer`) y el repositorio de tarjetas mock existen para demostración. En producción el token debe emitirlo un backend, los secretos no deben distribuirse en la app y los datos deben provenir de un servicio seguro. iOS informa una captura de pantalla después de realizada; con APIs públicas no es posible impedirla de forma garantizada, por lo que la librería responde ocultando el contenido y cerrando la sesión.

## Desarrollo

```sh
npm install
npm run ci          # lint + typecheck + jest + build

cd ios/CardSecureViewKit
xcodebuild -scheme CardSecureViewKit \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Publicación

El workflow `publish.yml` publica en npm y crea el GitHub Release al pushear un tag `vX.Y.Z` que coincida con la versión del `package.json`. Requiere el secret `NPM_TOKEN` en el repositorio.

## Licencia

MIT
