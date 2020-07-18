import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _logger = Logger('autofill_service');

enum AutofillServiceStatus {
  unsupported,
  disabled,
  enabled,
}

class AutofillPreferences {
  AutofillPreferences({this.enableDebug});

  factory AutofillPreferences.fromJson(Map<dynamic, dynamic> json) =>
      AutofillPreferences(enableDebug: json['enableDebug'] as bool);

  final bool enableDebug;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{
        'enableDebug': enableDebug,
      };
}

class AutofillService {
  factory AutofillService() => _instance;

  AutofillService._();

  static const MethodChannel _channel =
  MethodChannel('codeux.design/autofill_service');

  static final _instance = AutofillService._();

  Future<bool> get hasAutofillServicesSupport async {
    if (!Platform.isAndroid) {
      return false;
    }
    return await _channel.invokeMethod('hasAutofillServicesSupport');
  }

  Future<bool> get hasEnabledAutofillServices async {
    return (await _channel.invokeMethod<bool>('hasEnabledAutofillServices')) ==
        true;
  }

  Future<AutofillServiceStatus> status() async {
    if (!Platform.isAndroid) {
      return AutofillServiceStatus.unsupported;
    }
    final enabled =
    await _channel.invokeMethod<bool>('hasEnabledAutofillServices');
    if (enabled == null) {
      return AutofillServiceStatus.unsupported;
    } else if (enabled) {
      return AutofillServiceStatus.enabled;
    } else {
      return AutofillServiceStatus.disabled;
    }
  }

  Future<bool> requestSetAutofillService() async {
    return await _channel.invokeMethod('requestSetAutofillService');
  }

  Future<bool> resultWithDataset(
      {String label, String username, String password}) async {
    return await _channel.invokeMethod('resultWithDataset', <String, dynamic>{
      'label': label,
      'username': username,
      'password': password
    });
  }

  Future<void> disableAutofillServices() async {
    return await _channel.invokeMethod('disableAutofillServices');
  }

  Future<AutofillPreferences> getPreferences() async {
    final json =
    await _channel.invokeMapMethod<String, dynamic>('getPreferences');
    _logger.fine('Got preferences $json');
    return AutofillPreferences.fromJson(json);
  }

  Future<void> setPreferences(AutofillPreferences preferences) async {
    _logger.fine('set prefs to ${preferences.toJson()}');
    await _channel.invokeMethod<void>(
        'setPreferences', {'preferences': preferences.toJson()});
  }
}
