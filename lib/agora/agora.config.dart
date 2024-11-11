String get appId {
  // Allow pass an `appId` as an environment variable with name `TEST_APP_ID` by using --dart-define
  return const String.fromEnvironment('10f40214c03f40a5a3172bf86e90f8dc',
      defaultValue: '10f40214c03f40a5a3172bf86e90f8dc');
}

/// Please refer to https://docs.agora.io/en/Agora%20Platform/token
String get token {
  // Allow pass a `token` as an environment variable with name `TEST_TOKEN` by using --dart-define
  return const String.fromEnvironment('007eJxTYLg/ISllj0nh78aLLpL7a+wcrmib2bDZRL9kC188N4MjcKoCg6FBmomBkaFJsoExkJFommhsaG6UlGZhlmppkGaRkhz20jj5ppVpsprYcgZGKATx2RhK8ouTEhMZGAALNh81',
      defaultValue: '007eJxTYLg/ISllj0nh78aLLpL7a+wcrmib2bDZRL9kC188N4MjcKoCg6FBmomBkaFJsoExkJFommhsaG6UlGZhlmppkGaRkhz20jj5ppVpsprYcgZGKATx2RhK8ouTEhMZGAALNh81');
}

/// Your channel ID
String get channelId {
  // Allow pass a `channelId` as an environment variable with name `TEST_CHANNEL_ID` by using --dart-define
  return const String.fromEnvironment(
    'tosbaa',
    defaultValue: 'tosbaa',
  );
}

/// Your int user ID
const int uid = 0;

/// Your user ID for the screen sharing
const int screenSharingUid = 10;

/// Your string user ID
const String stringUid = '0';