import type {EventSubscription} from 'react-native';

import {
  createSecureToken,
  isSecureViewAvailable,
  onSecureViewClosed,
  openSecureCardView,
} from '../src';
import NativeCardSecureView from '../src/NativeCardSecureView';

jest.mock('../src/NativeCardSecureView', () => ({
  __esModule: true,
  default: {
    createSecureToken: jest.fn(),
    openSecureView: jest.fn(),
    onSecureViewOpened: jest.fn(),
    onValidationError: jest.fn(),
    onCardDataShown: jest.fn(),
    onSecureViewClosed: jest.fn(),
  },
}));

const nativeModule = jest.mocked(NativeCardSecureView!);

beforeEach(() => {
  jest.clearAllMocks();
});

test('reports the native module as available when it exists', () => {
  expect(isSecureViewAvailable()).toBe(true);
});

test('creates a short-lived token before opening the native secure view', async () => {
  const calls: string[] = [];
  nativeModule.createSecureToken.mockImplementation(async cardId => {
    calls.push(`token:${cardId}`);
    return 'signed-demo-token';
  });
  nativeModule.openSecureView.mockImplementation(async (cardId, token) => {
    calls.push(`open:${cardId}:${token}`);
  });

  await openSecureCardView('card_001');

  expect(calls).toEqual(['token:card_001', 'open:card_001:signed-demo-token']);
});

test('delegates token creation to the native module', async () => {
  nativeModule.createSecureToken.mockResolvedValue('signed-demo-token');

  await expect(createSecureToken('card_002')).resolves.toBe(
    'signed-demo-token',
  );
  expect(nativeModule.createSecureToken).toHaveBeenCalledWith('card_002');
});

test('subscribes listeners to native events and returns the subscription', () => {
  const subscription = {remove: jest.fn()} as unknown as EventSubscription;
  nativeModule.onSecureViewClosed.mockReturnValue(subscription);
  const listener = jest.fn();

  expect(onSecureViewClosed(listener)).toBe(subscription);
  expect(nativeModule.onSecureViewClosed).toHaveBeenCalledWith(listener);
});
