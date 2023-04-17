class AppConfig {
  AppConfig._();

  static const int databaseVersion = 1;
  static const String databaseVersionKey = "isarVersionKey";

  static const Duration maxCacheAge = Duration(minutes: 5); //30
  static const String dioCacheForceRefreshKey = 'dio_cache_force_refresh_key';
  static const String dioNeedToCacheKey = 'dio_need_to_cache_key';

  static const String baseUrl = 'https://shikimori.me/api/';
  static const String staticUrl = 'https://shikimori.me';
}
