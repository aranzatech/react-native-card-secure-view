import type {CodegenTypes, TurboModule} from 'react-native';
import {TurboModuleRegistry} from 'react-native';

export type SecureViewOpenedEvent = Readonly<{
  cardId: string;
}>;

export type ValidationErrorEvent = Readonly<{
  cardId: string;
  code: string;
  message: string;
}>;

export type CardDataShownEvent = Readonly<{
  cardId: string;
}>;

export type SecureViewClosedEvent = Readonly<{
  cardId: string;
  reason: string;
}>;

export interface Spec extends TurboModule {
  createSecureToken(cardId: string): Promise<string>;
  openSecureView(cardId: string, secureToken: string): Promise<void>;

  readonly onSecureViewOpened: CodegenTypes.EventEmitter<SecureViewOpenedEvent>;
  readonly onValidationError: CodegenTypes.EventEmitter<ValidationErrorEvent>;
  readonly onCardDataShown: CodegenTypes.EventEmitter<CardDataShownEvent>;
  readonly onSecureViewClosed: CodegenTypes.EventEmitter<SecureViewClosedEvent>;
}

export default TurboModuleRegistry.get<Spec>('NativeCardSecureView');
