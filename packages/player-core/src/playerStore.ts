import { create } from 'zustand';

import {
  NativePlayer,
  NativePlaybackStatus,
  PlayerStatus,
  PlayerStore,
  Track,
} from './types';

const clampIndex = (queue: Track[], index: number) => {
  if (!queue.length) return -1;
  if (index < 0) return 0;
  if (index >= queue.length) return queue.length - 1;
  return index;
};

const statusFromNative = (status: PlayerStatus): PlayerStatus => status;

export const createPlayerStore = (nativePlayer: NativePlayer) => {
  const usePlayerStore = create<PlayerStore>((set, get) => ({
    queue: [],
    currentIndex: -1,
    status: 'idle',
    positionMs: 0,
    durationMs: 0,
    bufferedMs: 0,
    error: null,
    actions: {
      setQueue: async (tracks, startIndex = 0, autoplay = true) => {
        set({
          queue: tracks,
          currentIndex: clampIndex(tracks, startIndex),
          status: 'loading',
          positionMs: 0,
          durationMs: 0,
          bufferedMs: 0,
          error: null,
        });
        const nextTrack = tracks[clampIndex(tracks, startIndex)];
        if (!nextTrack) return;
        await nativePlayer.load(nextTrack);
        if (autoplay) {
          await nativePlayer.play();
        }
      },
      appendToQueue: (tracks) => {
        const queue = get().queue.concat(tracks);
        set({ queue });
      },
      play: async () => {
        const state = get();
        if (state.currentIndex < 0 && state.queue.length > 0) {
          await get().actions.setQueue(state.queue, 0, true);
          return;
        }
        await nativePlayer.play();
      },
      pause: async () => {
        await nativePlayer.pause();
      },
      next: async () => {
        const state = get();
        const nextIndex = clampIndex(state.queue, state.currentIndex + 1);
        if (nextIndex === state.currentIndex) {
          await nativePlayer.stop();
          set({ status: 'ended' });
          return;
        }
        await get().actions.setQueue(state.queue, nextIndex, true);
      },
      previous: async () => {
        const state = get();
        const nextIndex = clampIndex(state.queue, state.currentIndex - 1);
        await get().actions.setQueue(state.queue, nextIndex, true);
      },
      seekTo: async (positionMs) => {
        await nativePlayer.seekTo(positionMs);
        set({ positionMs });
      },
      clear: async () => {
        await nativePlayer.stop();
        set({
          queue: [],
          currentIndex: -1,
          status: 'idle',
          positionMs: 0,
          durationMs: 0,
          bufferedMs: 0,
          error: null,
        });
      },
      clearError: () => set({ error: null }),
    },
  }));

  const handleStatus = (payload: NativePlaybackStatus) => {
    usePlayerStore.setState({
      status: statusFromNative(payload.status),
      positionMs: payload.positionMs,
      durationMs: payload.durationMs,
    });
  };

  const handleEnded = () => {
    void usePlayerStore.getState().actions.next();
  };

  const handleError = (error: Error) => {
    usePlayerStore.setState({ status: 'error', error: error.message });
  };

  const unsubStatus = nativePlayer.onStatus(handleStatus);
  const unsubEnded = nativePlayer.onEnded(handleEnded);
  const unsubError = nativePlayer.onError(handleError);

  return usePlayerStore;
};
