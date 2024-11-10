import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {

  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.messaging'
    ];
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(
         //[private keys - get the keys from -> Firebase Project Setting -> Service Account -> Firebase Admin Sdk -> Node.js -> Generate new private key -> Paste All the content here ]
        //will look like this
        //"type": "service_account",
        //  "project_id": "",
        //  "private_key_id": "",
        //  "private_key": "",
        //  "client_email": "",
        //  "client_id": ,
        //  "auth_uri": ,
        //  "token_uri": ,
        //  "auth_provider_x509_cert_url":
        //      "",
        //  "client_x509_cert_url":
        //      "private",
        //  "universe_domain": "googleapis.com"
      ),
      scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
  static String myApi = "";
}
