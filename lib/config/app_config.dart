import 'dart:ui';

abstract class AppConfig {
  // Const and final configuration values (immutable)
  static const Color primaryColor = Color(0xFF1E2A56);
  static const Color primaryColorLight = Color(0xFFB3BAD1);
  static const Color secondaryColor = Color(0xFF3A7CA5);

  static const Color chatColor = primaryColor;
  static const double messageFontSize = 16.0;
  static const bool allowOtherHomeservers = false;
  static const bool enableRegistration = true;
  static const bool hideTypingUsernames = false;

  static const String inviteLinkPrefix = 'https://matrix.to/#/';
  static const String deepLinkPrefix = 'com.unikong.whim://chat/';
  static const String schemePrefix = 'matrix:';
  static const String pushNotificationsChannelId = 'whim_push';
  static const String pushNotificationsAppId = 'com.unikong.whim';
  static const double borderRadius = 18.0;
  static const double spaceBorderRadius = 11.0;
  static const double columnWidth = 360.0;

  static const String website = 'https://chat.slc-group.com';
  static const String enablePushTutorial =
      'https://chat.slc-group.com';
  static const String encryptionTutorial =
      'https://chat.slc-group.com';
  static const String startChatTutorial =
      'https://chat.slc-group.com';
  static const String howDoIGetStickersTutorial =
      'https://chat.slc-group.com';
  static const String appId = 'com.unikong.whim';
  static const String appOpenUrlScheme = 'com.unikong.whim';

  static const String sourceCodeUrl =
      'https://github.com/morguee/Whim';
  static const String supportUrl =
      'https://github.com/morguee/Whim/issues';
  static const String changelogUrl = 'https://github.com/morguee/Whim/releases';
  static const String donationUrl = 'https://chat.slc-group.com';

  static const Set<String> defaultReactions = {'👍', '❤️', '😂', '😮', '😢'};

  static final Uri newIssueUrl = Uri(
    scheme: 'https',
    host: 'github.com',
    path: '/morguee/Whim/issues/new',
  );

  static final Uri homeserverList = Uri(
    scheme: 'https',
    host: 'chat.slc-group.com',
    path: '',
  );

  static final Uri privacyUrl = Uri(
    scheme: 'https',
    host: 'chat.slc-group.com',
    path: '/privacy',
  );

  static const String mainIsolatePortName = 'main_isolate';
  static const String pushIsolatePortName = 'push_isolate';
}
