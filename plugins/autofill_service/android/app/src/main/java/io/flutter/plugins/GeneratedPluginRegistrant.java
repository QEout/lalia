package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import design.codeux.autofill_service.AutofillServicePlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
    public static void registerWith(PluginRegistry registry) {
        if (alreadyRegisteredWith(registry)) {
            return;
        }
        AutofillServicePlugin.registerWith(registry.registrarFor("design.codeux.autofill_service.AutofillServicePlugin"));
    }

    private static boolean alreadyRegisteredWith(PluginRegistry registry) {
        final String key = GeneratedPluginRegistrant.class.getCanonicalName();
        if (registry.hasPlugin(key)) {
            return true;
        }
        registry.registrarFor(key);
        return false;
    }
}
