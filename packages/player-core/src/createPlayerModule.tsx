import type { PropsWithChildren } from 'react';
import { createContext, useContext } from 'react';
import { useStore } from 'zustand';
import type { StoreApi, UseBoundStore } from 'zustand';

import { createPlayerStore } from './playerStore';
import type { NativePlayer, PlayerStore } from './types';

const createContextError = () =>
  new Error('PlayerProvider is not mounted. Ensure AppProviders wraps PlayerProvider.');

export const createPlayerModule = (nativePlayer: NativePlayer) => {
  const usePlayerStore = createPlayerStore(nativePlayer);
  const PlayerStoreContext = createContext<
    UseBoundStore<StoreApi<PlayerStore>> | null
  >(null);

  const PlayerProvider = ({ children }: PropsWithChildren) => (
    <PlayerStoreContext.Provider value={usePlayerStore}>
      {children}
    </PlayerStoreContext.Provider>
  );

  const usePlayerStoreContext = () => {
    const store = useContext(PlayerStoreContext);
    if (!store) {
      throw createContextError();
    }
    return store;
  };

  const usePlayerState = <T,>(selector: (state: PlayerStore) => T): T => {
    const store = usePlayerStoreContext();
    return useStore(store, selector);
  };

  const usePlayerControls = () =>
    usePlayerState((state) => state.actions);

  return {
    PlayerProvider,
    usePlayerState,
    usePlayerControls,
    nativePlayer,
  };
};
