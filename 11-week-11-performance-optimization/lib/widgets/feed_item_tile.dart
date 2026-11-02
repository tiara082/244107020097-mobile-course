import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/feed_item.dart';

class FeedItemTile extends StatelessWidget {
  const FeedItemTile({
    required this.item,
    required this.onLike,
    super.key,
  });

  final FeedItem item;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optimized Image loading with memCacheWidth & memCacheHeight limits
          SizedBox(
            height: 160,
            width: double.infinity,
            child: item.imageUrl.isEmpty
                ? Container(
                    color: Colors.indigo.shade50,
                    child: Center(
                      child: Icon(
                        Icons.newspaper_rounded,
                        size: 48,
                        color: Colors.indigo.shade300,
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    memCacheWidth: 480, // Decode at mobile device target size, not 4K raw res
                    memCacheHeight: 320,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.indigo.shade50,
                      child: Center(
                        child: Icon(
                          Icons.newspaper_rounded,
                          size: 48,
                          color: Colors.indigo.shade300,
                        ),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade800,
                        ),
                      ),
                    ),
                    Text(
                      '${item.publishedAt.day}/${item.publishedAt.month}/${item.publishedAt.year}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  item.summary,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        item.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: item.isLiked ? Colors.red : Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: onLike,
                      tooltip: item.isLiked ? 'Unlike' : 'Like',
                    ),
                    Text(
                      '${item.likeCount} suka',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
