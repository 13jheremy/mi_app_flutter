// lib/services/image_cache_service.dart
// Servicio de cache para imágenes usando flutter_cache_manager

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;

  late final DefaultCacheManager _cacheManager;

  ImageCacheService._internal() {
    _cacheManager = DefaultCacheManager();
  }

  // Obtener imagen con cache
  Widget getCachedNetworkImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? const CircularProgressIndicator(),
      errorWidget: (context, url, error) => errorWidget ?? const Icon(Icons.error),
      cacheManager: _cacheManager,
    );
  }

  // Precargar imagen
  Future<void> preloadImage(String imageUrl) async {
    await _cacheManager.getSingleFile(imageUrl);
  }

  // Limpiar cache de imágenes
  Future<void> clearImageCache() async {
    await _cacheManager.emptyCache();
  }

  // Obtener tamaño del cache de imágenes
  Future<int> getImageCacheSize() async {
    final cacheInfo = await _cacheManager.getFileFromCache('');
    return cacheInfo?.file.length() ?? 0;
  }
}