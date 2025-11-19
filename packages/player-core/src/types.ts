export type Track = {
  id: string;
  url: string;
  title: string;
  artistName?: string;
  artworkUrl?: string | null;
  durationMs?: number;
  metadata?: Record<string, unknown>;
};

export type PlayerStatus =
  | 'idle'
  | 'loading'
  | 'buffering'
  | 'playing'
  | 'paused'
  | 'ended'
  | 'error';

export type NativePlaybackStatus = {
  status: PlayerStatus;
  positionMs: number;
  durationMs: number;
};

export type NativePlayer = {
  load(track: Track): Promise<void>;
  play(): Promise<void>;
  pause(): Promise<void>;
  stop(): Promise<void>;
  seekTo(positionMs: number): Promise<void>;
  onStatus(listener: (payload: NativePlaybackStatus) => void): () => void;
  onEnded(listener: () => void): () => void;
  onError(listener: (error: Error) => void): () => void;
};

export type PlayerStoreState = {
  queue: Track[];
  currentIndex: number;
  status: PlayerStatus;
  positionMs: number;
  durationMs: number;
  bufferedMs: number;
  error: string | null;
};

export type PlayerStoreActions = {
  setQueue: (tracks: Track[], startIndex?: number, autoplay?: boolean) => Promise<void>;
  appendToQueue: (tracks: Track[]) => void;
  play: () => Promise<void>;
  pause: () => Promise<void>;
  next: () => Promise<void>;
  previous: () => Promise<void>;
  seekTo: (positionMs: number) => Promise<void>;
  clear: () => Promise<void>;
  clearError: () => void;
};

export type PlayerStore = PlayerStoreState & { actions: PlayerStoreActions };
