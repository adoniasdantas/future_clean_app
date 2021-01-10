import 'package:faker/faker.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_clean_app/domain/helpers/helpers.dart';
import 'package:flutter_clean_app/domain/usecases/usecases.dart';

import 'package:flutter_clean_app/data/http/http.dart';
import 'package:flutter_clean_app/data/usecases/usecases.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication sut;
  HttpClientSpy httpClient;
  String url;
  AuthenticationParams params;
  setUp(() {
    // arrange
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  });
  test('Should call HttpClient with correct values', () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenAnswer((_) async =>
        {'accessToken': faker.guid.guid(), 'name': faker.person.name()});
    // act
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

  test('Should throw UnexpectedError if HttpClient returns 400', () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.badRequest);
    // act
    final future = sut.auth(params);
    // asset
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.notFound);
    // act
    final future = sut.auth(params);
    // asset
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw ServerError if HttpClient returns 500', () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.serverError);
    // act
    final future = sut.auth(params);
    // asset
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCredentialsError if HttpClient returns 401',
      () async {
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.unauthorized);
    // act
    final future = sut.auth(params);
    // asset
    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('Should return an Account if HttpClient returns 200', () async {
    final accessToken = faker.guid.guid();
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenAnswer((_) async =>
        {'accessToken': accessToken, 'name': faker.person.name()});
    // act
    final account = await sut.auth(params);
    // asset
    expect(account.token, accessToken);
  });
  
  test('Should throw UnexpectedError if HttpClient returns 200 with invalid data', () async {
    final accessToken = faker.guid.guid();
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenAnswer((_) async =>
        {'invalid_key': 'invalid_value'});
    // act
    final future = sut.auth(params);
    // asset
    expect(future, throwsA(DomainError.unexpected));
  });
}
