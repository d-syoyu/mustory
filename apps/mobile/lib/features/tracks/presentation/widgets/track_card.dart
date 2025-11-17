import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';
import 'package:mustory_mobile/core/audio/audio_player_controller.dart';
import 'package:mustory_mobile/core/ui/app_palettes.dart';

class TrackCard extends ConsumerWidget {
  final Track track;
  final VoidCallback? onTap;
  final VoidCallback? onLike;

  const TrackCard({
    super.key,
    required this.track,
    this.onTap,
    this.onLike,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerControllerProvider);
    final isCurrentTrack = audioState.currentTrack?.id == track.id;
    final isPlaying = isCurrentTrack && audioState.isPlaying;
    final isLoading = isCurrentTrack && audioState.isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap ??
            () async {
              final controller = ref.read(audioPlayerControllerProvider.notifier);
              await controller.playTrack(track);
            },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isCurrentTrack
                ? const LinearGradient(
                    colors: [Color(0xFF2C2158), Color(0xFF401C44)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppGradients.card,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: isCurrentTrack ? 0.35 : 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: track.artworkUrl,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 84,
                    height: 84,
                    color: Colors.white10,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 84,
                    height: 84,
                    color: Colors.white12,
                    child: const Icon(Icons.music_note),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            track.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (track.hasStory)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.book, size: 14, color: AppColors.accentTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  '����',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppColors.accentTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      track.artistName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.favorite,
                          value: track.likeCount.toString(),
                        ),
                        const SizedBox(width: 12),
                        _StatChip(
                          icon: Icons.headphones,
                          value: '—', // placeholder for streaming count
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: onLike,
                          icon: Icon(
                            track.isLiked ? Icons.favorite : Icons.favorite_border,
                          ),
                          color: track.isLiked ? AppColors.accentSecondary : Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _PlayButton(
                isCurrent: isCurrentTrack,
                isPlaying: isPlaying,
                isLoading: isLoading,
                onPressed: () async {
                  final controller = ref.read(audioPlayerControllerProvider.notifier);
                  if (isCurrentTrack) {
                    await controller.togglePlayPause();
                  } else {
                    await controller.playTrack(track);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.isCurrent,
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isCurrent;
  final bool isPlaying;
  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A96), Color(0xFFFB588B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: IconButton(
        icon: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                isCurrent && isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
        onPressed: () async {
          await onPressed();
        },
      ),
    );
  }
}
