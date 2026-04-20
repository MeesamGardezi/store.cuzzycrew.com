import 'dart:convert';
import 'dart:typed_data';

import 'package:cuzzycrewstore/api/ApiConstants.dart';
import 'package:cuzzycrewstore/utils/design_utils.dart';
import 'package:flutter/material.dart';

class AdaptiveImage extends StatefulWidget {
  const AdaptiveImage({
    super.key,
    required this.source,
    this.sources,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  final String source;
  final List<String>? sources;
  final BoxFit fit;
  final Widget? fallback;

  @override
  State<AdaptiveImage> createState() => _AdaptiveImageState();
}

class _AdaptiveImageState extends State<AdaptiveImage> {
  int _activeIndex = 0;

  @override
  void didUpdateWidget(covariant AdaptiveImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSignature = _signature(oldWidget.source, oldWidget.sources);
    final newSignature = _signature(widget.source, widget.sources);

    if (oldSignature != newSignature || _activeIndex >= _candidates.length) {
      _activeIndex = 0;
    }
  }

  List<String> get _candidates {
    final raw = <String>[...?widget.sources, widget.source];

    final unique = <String>[];
    final seen = <String>{};
    for (final entry in raw) {
      final value = entry.trim();
      if (value.isEmpty || seen.contains(value)) continue;
      seen.add(value);
      unique.add(value);
    }
    return unique;
  }

  @override
  Widget build(BuildContext context) {
    final candidates = _candidates;
    if (candidates.isEmpty) return _fallback(context);
    if (_activeIndex >= candidates.length) return _fallback(context);

    final value = candidates[_activeIndex];
    final image = _buildForSource(context, value);

    return image ?? _tryNextOrFallback(context, candidates.length);
  }

  Widget _tryNextOrFallback(BuildContext context, int totalCandidates) {
    if (_activeIndex < totalCandidates - 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _activeIndex += 1);
      });
      return const SizedBox.shrink();
    }
    return _fallback(context);
  }

  Widget? _buildForSource(BuildContext context, String value) {
    final dataBytes = _decodeDataImageUri(value);
    if (dataBytes != null) {
      return Image.memory(
        dataBytes,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) {
          final candidates = _candidates;
          return _tryNextOrFallback(context, candidates.length);
        },
      );
    }

    final remoteUrl = _resolveRemoteUrl(value);
    if (remoteUrl != null) {
      return Image.network(
        remoteUrl,
        fit: widget.fit,
        errorBuilder: (_, __, ___) {
          final candidates = _candidates;
          return _tryNextOrFallback(context, candidates.length);
        },
      );
    }

    if (DesignUtils.canRenderAssetImage(value)) {
      return Image.asset(
        value,
        fit: widget.fit,
        errorBuilder: (_, __, ___) {
          final candidates = _candidates;
          return _tryNextOrFallback(context, candidates.length);
        },
      );
    }

    return null;
  }

  Widget _fallback(BuildContext context) {
    if (widget.fallback != null) return widget.fallback!;

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Uint8List? _decodeDataImageUri(String value) {
    final match = RegExp(
      r'^data:image\/[a-zA-Z0-9.+-]+;base64,(.+)$',
    ).firstMatch(value);
    if (match == null) return null;
    try {
      return base64Decode(match.group(1)!);
    } catch (_) {
      return null;
    }
  }

  String? _resolveRemoteUrl(String value) {
    if (value.startsWith('https://') || value.startsWith('http://')) {
      return _normalizeStorageUrl(value);
    }

    if (value.startsWith('//')) {
      return 'https:$value';
    }

    if (value.startsWith('gs://')) {
      final withoutScheme = value.substring(5);
      final slashIndex = withoutScheme.indexOf('/');
      if (slashIndex <= 0 || slashIndex == withoutScheme.length - 1) {
        return null;
      }
      final bucket = withoutScheme.substring(0, slashIndex);
      final objectPath = withoutScheme
          .substring(slashIndex + 1)
          .split('/')
          .map(Uri.encodeComponent)
          .join('/');
      return 'https://storage.googleapis.com/$bucket/$objectPath';
    }

    if (value.startsWith('/')) {
      final base =
          ApiConstants.baseUrl.endsWith('/')
              ? ApiConstants.baseUrl.substring(
                0,
                ApiConstants.baseUrl.length - 1,
              )
              : ApiConstants.baseUrl;
      return '$base$value';
    }

    return null;
  }

  String _normalizeStorageUrl(String value) {
    try {
      final uri = Uri.parse(value);
      if (uri.host != 'storage.googleapis.com') return value;

      final normalizedPath = uri.path
          .replaceAll('%2F', '/')
          .replaceAll('%2f', '/');
      if (normalizedPath == uri.path) return value;

      return uri.replace(path: normalizedPath).toString();
    } catch (_) {
      return value;
    }
  }

  String _signature(String source, List<String>? sources) {
    final raw = <String>[...?sources, source];
    return raw
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .join('||');
  }
}
