import 'dart:typed_data';

import 'package:daily_spark/design_system/widgets/user_avatar.dart';
import 'package:daily_spark/state/avatar_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> flush() => Future<void>.delayed(const Duration(milliseconds: 25));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('avatar persists across reload, rejects invalid files, and can be removed', () async {
    SharedPreferences.setMockInitialValues({});
    final first = ProviderContainer();
    addTearDown(first.dispose);
    expect(first.read(avatarProvider), isNull);
    final data = await rootBundle.load('assets/brand/spark_logo.png');
    final photo = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    expect(await first.read(avatarProvider.notifier).save(photo), isTrue);
    expect(first.read(avatarProvider), orderedEquals(photo));
    expect(await first.read(avatarProvider.notifier).save(Uint8List.fromList([1, 2, 3])), isFalse);
    expect(first.read(avatarProvider), orderedEquals(photo));
    expect(await first.read(avatarProvider.notifier).save(Uint8List(AvatarController.maxBytes + 1)), isFalse);
    expect(first.read(avatarProvider), orderedEquals(photo));

    final second = ProviderContainer();
    addTearDown(second.dispose);
    second.read(avatarProvider);
    await flush();
    expect(second.read(avatarProvider), orderedEquals(photo));
    expect(await second.read(avatarProvider.notifier).remove(), isTrue);
    expect(second.read(avatarProvider), isNull);
    final third = ProviderContainer();
    addTearDown(third.dispose);
    third.read(avatarProvider);
    await flush();
    expect(third.read(avatarProvider), isNull);
  });

  test('corrupt stored data falls back without throwing', () async {
    SharedPreferences.setMockInitialValues({AvatarController.storageKey: 'not-base64!'});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(avatarProvider);
    await flush();
    expect(c.read(avatarProvider), isNull);
  });

  testWidgets('avatar without a photo displays the spark logo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: UserAvatar(bytes: null, size: 72)));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, 'assets/brand/spark_logo.png');
  });
}
