import 'package:googleapis_auth/auth_io.dart';

Future<String> getAccessToken() async {
  final String accountCredentialsJson = "{\n"
      "  \"type\": \"service_account\",\n"
      "  \"project_id\": \"flutterapp-dde40\",\n"
      "  \"private_key_id\": \"b4be40c0cbc7705191dc6ea48108c4371ee4285a\",\n"
      "  \"private_key\": \"-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCexVGGa4rlZgFO\\nS31i+fufiEhhpuXfqLUZSnNpocQaq1ou5fNKiQpoaTYRhRjEV/GCJRhvNUje75Ug\\nwOIFY6aEf9RkBRWXt0lU4vg8B/NhFBpd/LHVAFHyIt8RipVeV9GGA8Binb+NBBQ9\\nGVa+wQeHDmh9oVCFouEj9JSJmHlJXDYow9TS4xGf49IpzFlcAkKU91S4IxOd9XEn\\n96+Rwe1pZgNlgsVs/2csOW5/rx5wy6kpIyIK3404sk9R+nY+aQs1StdXV6CwzpWL\\nviO6ACpquNhHEma+4Gi9du4/7RcGF24gDTY3Zx/srxT/2qcRRMVAVbJMymLyN7Gn\\ngMbdDqTvAgMBAAECggEAPTEKbzbClRA/35errzpulrlVQEGtZgqlJaaynZsptCen\\nfdzFbEwt9TjbjFwSRBYq8ABxDudn+vg2ryV31yDlfDqyNoxZGpybCDrj9msQC7HO\\nSbwLI+9YJez3sVCKqg5JpA+NFdT7jxNr43KBIsrNpmlQr169ZIv2nr90giWAVVu3\\nyUR0EkdpEqCRXZC+MlsfyzgHQK4BKgT2QlRLg/kgWHWmf2x69ATsm1YW86dPIdUh\\nY19+b3k7R/0NtrmPyeg9XbY5pNfdy6VQ3MZy5uv0Ki50VVC5asEZgXYvUfK28tGP\\nBq/bLGKGfVnr6HUxpEwOFRMbHA92e7uba1eCcbYM+QKBgQDQ6XaQSkQdJkZR9GhQ\\nZPSGbOfazGRsQV9nN/2q468GX7Qqsxl/vWVB497o61UvG/6H4bTxFIi3s+f51YaL\\nH2LD2Z3gDwuewH0PktphZCQ5fZgNpB5XGbL0yIiE3Kxem8Y/3475wkWooLvwsRCf\\nM6uSKA+2mMoBiOFV9GMhqxPzyQKBgQDCjqH4Hz2G236ZQaC/TnTVdJ5WWB4rYzvG\\n5nWJnZpKVOH76n6c9c4KqjotbRW7cp3L3qDqMYwfU3qt6GuaNQXPTAfyMFO5YCoS\\nbMhWJ09DfcgT9kTq2srn31ixDWhE28PyvZfVgwjB9XolKQy6vzijPpzpNbNwTZyQ\\nLiXSTgX+9wKBgBLa72uIeGtVGAWvlHalFfjH/Yke53Vp1Q2A3TE+SX6+xokQDx4b\\nXvc6dNT64H5W/XsQIP+dRdWmtCo1XmZSF9zrWDdvxDG419C/BVzC6A4UStP4WxCr\\nbh5vtvqe3CPR1WvQZpweL6FPmIbZxFFKHZMccIafdaP70bKrUwMn6K4ZAoGATCYt\\niQMZPtZcV7nTI+2eVwm9C4iTzmGZvQDo0kMoZ52Pkd03T1H6Ijx8ZtlCX0q+LlRl\\n4SQhdwVih/znWMUWEAvvNEDsFCtqbCm9w9LA+Gab0Axc7xtRva2ydiIMRJ9Ls4+3\\nhO8zl07wTukhPVqo3WQdYD4PjI4kEF6vmP/G4wMCgYEAqqxVFd+9aXmD1cD1WQ2H\\nc4n3pOgnxKUPq1bqhA/A/O+jZ9vs+VnLdiYutNRUslp3f5XyrCyHN3AX6SFfm7hY\\nePBdIqqNeNNzLNyB7Y5sLcQg5Ffozcp+o+nSB3yhArKUGGHe3uNL9pg+P3UmP2WP\\nn4llrTg6EafdDltYGpjtMVM=\\n-----END PRIVATE KEY-----\\n\",\n"
      "  \"client_email\": \"firebase-adminsdk-t2d4e@flutterapp-dde40.iam.gserviceaccount.com\",\n"
      "  \"client_id\": \"111556264132715390187\",\n"
      "  \"auth_uri\": \"https://accounts.google.com/o/oauth2/auth\",\n"
      "  \"token_uri\": \"https://oauth2.googleapis.com/token\",\n"
      "  \"auth_provider_x509_cert_url\": \"https://www.googleapis.com/oauth2/v1/certs\",\n"
      "  \"client_x509_cert_url\": \"https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-t2d4e%40flutterapp-dde40.iam.gserviceaccount.com\",\n"
      "  \"universe_domain\": \"googleapis.com\"\n"
      "}\n";

  final accountCredentials =
      ServiceAccountCredentials.fromJson(accountCredentialsJson);

  // Các scope cần thiết
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // Nhận client với Access Token
  final client = await clientViaServiceAccount(accountCredentials, scopes);

  // Trả về Access Token
  return client.credentials.accessToken.data;
}
