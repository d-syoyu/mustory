import type {
  NativePlaybackStatus,
  NativePlayer,
  PlayerStatus,
  Track,
} from '@mustory/player-core';

type AudioApiEventSubscription = { remove: () => void } | (() => void);

type AudioApiPlayer = {
  load: (payload: {
    url: string;
    title?: string;
    artist?: string;
    artwork?: string | null;
    metadata?: Record<string, unknown>;
  }) => Promise<void>;
  play: () => Promise<void>;
  pause: () => Promise<void>;
  stop: () => Promise<void>;
  seekTo: (positionMs: number) => Promise<void>;
  addListener?: (
    event: string,
    handler: (...args: any[]) => void
  ) => AudioApiEventSubscription | void;
};

const { AudioPlayer } = require('react-native-audio-api') as {
  AudioPlayer: new () => AudioApiPlayer;
};

const statusMap: Record<string, PlayerStatus> = {
  ready: 'idle',
  loading: 'loading',
  buffering: 'buffering',
  playing: 'playing',
  paused: 'paused',
  ended: 'ended',
};

type PlaybackPayload = {
  state?: string;
  position?: number;
  duration?: number;
};

export class AudioApiNativePlayer implements NativePlayer {
  private player: AudioApiPlayer;
  private statusListeners = new Set<(payload: NativePlaybackStatus) => void>();
  private endedListeners = new Set<() => void>();
  private errorListeners = new Set<(error: Error) => void>();

  constructor() {
    this.player = new AudioPlayer();
    this.bindNativeEvents();
  }

  private bindNativeEvents() {
    this.player.addListener?.('playback', (payload: PlaybackPayload) => {
      const mapped: NativePlaybackStatus = {
        status: statusMap[payload.state ?? 'playing'] ?? 'playing',
        positionMs: Math.floor((payload.position ?? 0) * 1000),
        durationMs: Math.floor((payload.duration ?? 0) * 1000),
      };
      this.statusListeners.forEach((listener) => listener(mapped));
      if (mapped.status === 'ended') {
        this.endedListeners.forEach((listener) => listener());
      }
    });

    this.player.addListener?.('ended', () => {
      this.endedListeners.forEach((listener) => listener());
    });

    this.player.addListener?.('error', (message: string | Error) => {
      const error =
        message instanceof Error ? message : new Error(String(message));
      this.errorListeners.forEach((listener) => listener(error));
    });
  }

  async load(track: Track) {
    await this.player.load({
      url: track.url,
      title: track.title,
      artist: track.artistName,
      artwork: track.artworkUrl ?? undefined,
      metadata: track.metadata,
    });
  }

  play() {
    return this.player.play();
  }

  pause() {
    return this.player.pause();
  }

  stop() {
    return this.player.stop();
  }

  seekTo(positionMs: number) {
    return this.player.seekTo(positionMs);
  }

  onStatus(listener: (payload: NativePlaybackStatus) => void) {
    this.statusListeners.add(listener);
    return () => this.statusListeners.delete(listener);
  }

  onEnded(listener: () => void) {
    this.endedListeners.add(listener);
    return () => this.endedListeners.delete(listener);
  }

  onError(listener: (error: Error) => void) {
    this.errorListeners.add(listener);
    return () => this.errorListeners.delete(listener);
  }
}
