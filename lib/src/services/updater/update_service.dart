import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';

import '../../presentation/providers/environment_provider.dart';
import '../../utils/target_platform.dart';
import '../../constants/config.dart';
import '../../../secret.dart';

final appReleaseProvider =
    AsyncNotifierProvider<AppReleaseNotifier, AppRelease?>(() {
  return AppReleaseNotifier();
}, name: 'appReleaseProvider');

class AppReleaseNotifier extends AsyncNotifier<AppRelease?> {
  @override
  Future<AppRelease?> build() async {
    ref.onDispose(() {
      state = const AsyncValue.loading();
    });
    return await _fetchUpdate();
  }

  Future<List<GithubRelease>> _getReleases() async {
    final response = await http.get(Uri.parse(
        'https://api.github.com/repos/wheremyfiji/ShikiWatch/releases?page=1&per_page=5'));

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        debugPrint('[UpdateService] Response body is empty');
        throw Exception('Response body is empty');
      }

      final jsonArray = jsonDecode(utf8.decode(response.bodyBytes));

      return [for (final json in jsonArray) GithubRelease.fromJson(json)]
          .toList();
    } else {
      throw Exception('Failed to get releases');
    }
  }

  Future<AppRelease?> _fetchUpdate() async {
    if (kDebugMode) {
      return null;
    }

    debugPrint('[UpdateService] kAppArch: $kAppArch');

    final env = ref.read(environmentProvider);

    if (!_checkAppSig(env.packageInfo.buildSignature)) {
      return null;
    }

    if (TargetP.instance.isDesktop) {
      return null;
    }

    final latest = await _getReleases()
        .then((release) => release.first)
        .onError((error, stackTrace) => throw Exception(error));

    //TODO Если последняя версия - prerelease, а также до нее есть еще версии, то ничего не произойдет
    if (latest.prerelease) {
      return null;
    }

    final currentVersion = Version.parse(env.appVersion);
    final latestVersion = Version.parse(latest.tagName.replaceAll('v', ''));

    if (latestVersion <= currentVersion) {
      return null;
    }

    final GithubAsset? asset = latest.assets
        .firstWhereOrNull((element) => element.name.contains(kAppArch));

    if (asset == null) {
      debugPrint('[UpdateService] asset == null');
      return null;
    }

    if (asset.state != 'uploaded') {
      return null;
    }

    final appRelease = AppRelease(
      name: latest.name,
      tag: latest.tagName,
      description: latest.body,
      asset: asset,
    );

    return appRelease;
  }

  bool _checkAppSig(String sig) {
    if (TargetP.instance.isDesktop) {
      return false;
    }

    return (sig.isEmpty || sig != kAppSignatureSHA1);
  }
}

class AppRelease {
  final String name;
  final String tag;
  final String description;
  final GithubAsset asset;

  AppRelease(
      {required this.name,
      required this.tag,
      required this.description,
      required this.asset});
}

class GithubRelease {
  final String htmlUrl;
  final int id;
  final String tagName;
  final String targetCommitish;
  final String name;
  final bool draft;
  final bool prerelease;
  final List<GithubAsset> assets;
  final String body;

  GithubRelease({
    required this.htmlUrl,
    required this.id,
    required this.tagName,
    required this.targetCommitish,
    required this.name,
    required this.draft,
    required this.prerelease,
    required this.assets,
    required this.body,
  });

  factory GithubRelease.fromJson(Map<String, dynamic> json) => GithubRelease(
        htmlUrl: json["html_url"],
        id: json["id"],
        tagName: json["tag_name"],
        targetCommitish: json["target_commitish"],
        name: json["name"],
        draft: json["draft"],
        prerelease: json["prerelease"],
        assets: List<GithubAsset>.from(
            json["assets"].map((x) => GithubAsset.fromJson(x))),
        body: json["body"],
      );

  Map<String, dynamic> toJson() => {
        "html_url": htmlUrl,
        "id": id,
        "tag_name": tagName,
        "target_commitish": targetCommitish,
        "name": name,
        "draft": draft,
        "prerelease": prerelease,
        "assets": List<dynamic>.from(assets.map((x) => x.toJson())),
        "body": body,
      };
}

class GithubAsset {
  final String url;
  final int id;
  final String name;
  final String contentType;
  final String state;
  final int size;
  final int downloadCount;
  final String browserDownloadUrl;

  GithubAsset({
    required this.url,
    required this.id,
    required this.name,
    required this.contentType,
    required this.state,
    required this.size,
    required this.downloadCount,
    required this.browserDownloadUrl,
  });

  factory GithubAsset.fromJson(Map<String, dynamic> json) => GithubAsset(
        url: json["url"],
        id: json["id"],
        name: json["name"],
        contentType: json["content_type"],
        state: json["state"],
        size: json["size"],
        downloadCount: json["download_count"],
        browserDownloadUrl: json["browser_download_url"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "id": id,
        "name": name,
        "content_type": contentType,
        "state": state,
        "size": size,
        "download_count": downloadCount,
        "browser_download_url": browserDownloadUrl,
      };
}
