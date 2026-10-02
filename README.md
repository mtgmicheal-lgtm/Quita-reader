# MikroTik User Manager App

Android/Flutter app for managing more than one MikroTik RouterOS v7 User Manager.

## Current v0.1 features

- Multiple MikroTik routers.
- One tab per router.
- `All Routers` tab.
- Search by username.
- Username / profile / state.
- Download / upload / total usage.
- Active session indicator.
- Profile expiry.
- Demo mode for UI testing.
- Router settings saved locally on the device.
- Initial RouterOS REST API integration.

## Planned next step

1. Read quota automatically from:
   - `/user-manager limitation`
   - `/user-manager profile-limitation`
2. Calculate remaining GB and percentage.
3. Secure credential storage.
4. Test self-signed HTTPS / Tailscale access.
5. Add router edit/delete.
6. Build release APK.

## MikroTik REST requirements

RouterOS v7 REST is exposed under `/rest`.

For production, HTTPS (`www-ssl`) is recommended.

Create a dedicated RouterOS account/group instead of using admin. It needs at least:
- `read`
- `rest-api`

Example concept:

```routeros
/user group add name=app-read policy=read,rest-api
/user add name=usage-app group=app-read password=CHANGE_THIS
```

Restrict the account address if possible.

## Running

If Flutter is installed:

```bash
flutter create .
flutter pub get
flutter run
```

The repository already contains the main Dart source. Running `flutter create .`
fills any platform boilerplate not included in this starter package.

## Real data

Add your MikroTik, switch off `Demo data`, then refresh.

The REST service currently reads:

- `/rest/user-manager/user`
- `/rest/user-manager/user-profile`
- POST `/rest/user-manager/user/monitor`

The User Manager monitor command provides total download/upload, active sessions,
and actual profile.

## Security note

v0.1 stores router credentials in local app preferences for rapid prototyping.
Before production use, move the password to Android Keystore / flutter_secure_storage.
