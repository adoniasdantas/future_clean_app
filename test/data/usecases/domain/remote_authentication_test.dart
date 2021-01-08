import 'package:faker/faker.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_clean_app/domain/usecases/usecases.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({@required this.httpClient, @required this.url});

  Future<void> auth(AuthenticationParams params) async {
    final body = {
      'email': params.email,
      'password': params.password,
    };
    await httpClient.request(url: url, method: 'POST', body: body);
  }
}

abstract class HttpClient {
  Future<void> request({
    @required String url,
    @required String method,
    Map body,
  }) async {}
}

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication sut;
  HttpClientSpy httpClient;
  String url;
  setUp(() {
    // arrange
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
  });
  test('Should call HttpClient with correct values', () async {
    // act
    final params = AuthenticationParams(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
    await sut.auth(params);
    // asset
    verify(
      httpClient.request(
        url: url,
        method: 'POST',
        body: {
          'email': params.email,
          'password': params.password,
        },
      ),
    );
  });
}
