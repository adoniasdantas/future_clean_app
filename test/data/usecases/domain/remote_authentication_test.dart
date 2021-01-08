import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({
    @required this.httpClient,
    @required this.url,
  });
  Future<void> auth() async {
    await httpClient.request(url: url, method: 'POST');
  }
}

abstract class HttpClient {
  Future<void> request({
    @required String url,
    @required String method,
  }) async {}
}

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  test('Should call HttpClient with correct values', () async {
    // arrange
    final httpClient = HttpClientSpy();
    final url = faker.internet.httpUrl();
    final sut = RemoteAuthentication(httpClient: httpClient, url: url);
    // act
    await sut.auth();
    // asset
    verify(httpClient.request(
      url: url,
      method: 'POST',
    ));
  });
}