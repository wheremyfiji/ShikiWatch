///For mobile
const String kShikiClientId = String.fromEnvironment('SHIKI_CLIENT_ID');
const String kShikiClientSecret = String.fromEnvironment('SHIKI_CLIENT_SECRET');

///For desktop
const String kShikiClientIdDesktop =
    String.fromEnvironment('SHIKI_CLIENT_ID_DESKTOP');
const String kShikiClientSecretDesktop =
    String.fromEnvironment('SHIKI_CLIENT_SECRET_DESKTOP');

const String kKodikToken = String.fromEnvironment('KODIK_TOKEN');
const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
const String kDiscordAppId = String.fromEnvironment('DISCORD_APP_ID');

//оч секретно братан
const String kAppSignatureSHA1 = String.fromEnvironment('APP_SIGNATURE');
