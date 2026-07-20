import type {EventSubscription} from 'react-native';

import NativeCardSecureView from './NativeCardSecureView';
import type {
  CardDataShownEvent,
  SecureViewClosedEvent,
  SecureViewOpenedEvent,
  ValidationErrorEvent,
} from './NativeCardSecureView';

export type {
  CardDataShownEvent,
  SecureViewClosedEvent,
  SecureViewOpenedEvent,
  ValidationErrorEvent,
} from './NativeCardSecureView';

function getNativeModule() {
  if (!NativeCardSecureView) {
    throw new Error(
      'NativeCardSecureView no está disponible en esta plataforma.',
    );
  }

  return NativeCardSecureView;
}

export function isSecureViewAvailable(): boolean {
  return NativeCardSecureView != null;
}

export function createSecureToken(cardId: string): Promise<string> {
  return getNativeModule().createSecureToken(cardId);
}

export function openSecureView(
  cardId: string,
  secureToken: string,
): Promise<void> {
  return getNativeModule().openSecureView(cardId, secureToken);
}

export async function openSecureCardView(cardId: string): Promise<void> {
  const secureToken = await createSecureToken(cardId);
  await openSecureView(cardId, secureToken);
}

export function onSecureViewOpened(
  listener: (event: SecureViewOpenedEvent) => void,
): EventSubscription {
  return getNativeModule().onSecureViewOpened(listener);
}

export function onValidationError(
  listener: (event: ValidationErrorEvent) => void,
): EventSubscription {
  return getNativeModule().onValidationError(listener);
}

export function onCardDataShown(
  listener: (event: CardDataShownEvent) => void,
): EventSubscription {
  return getNativeModule().onCardDataShown(listener);
}

export function onSecureViewClosed(
  listener: (event: SecureViewClosedEvent) => void,
): EventSubscription {
  return getNativeModule().onSecureViewClosed(listener);
}
