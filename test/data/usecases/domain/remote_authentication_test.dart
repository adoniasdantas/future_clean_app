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
  Map mockValidData() => {'accessToken': faker.guid.guid(), 'name': faker.person.name()};
  
  PostExpectation mockRequest() => when(httpClient.request(
        url: anyNamed('url'),
        method: anyNamed('method'),
        body: anyNamed('body'),
      ));

  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError httpError) {
    mockRequest().thenThrow(httpError);
  }

  setUp(() {
    // arrange
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
    mockHttpData(mockValidData());
  });
  test('Should call HttpClient with correct values', () async {
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
    mockHttpError(HttpError.badRequest);
    // act
    final future = sut.auth(params);
    // asset
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    mockHttpError(HttpError.notFound);
    // act
    final future = sut.auth(params);
    // asset
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw ServerError if HttpClient returns 500', () async {
    mockHttpError(HttpError.serverError);
    // act
    final future = sut.auth(params);
    // asset
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCredentialsError if HttpClient returns 401',
      () async {
    mockHttpError(HttpError.unauthorized);
    // act
    final future = sut.auth(params);
    // asset
    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('Should return an Account if HttpClient returns 200', () async {
    final validData = mockValidData();
    mockHttpData(validData);    
    // act
    final account = await sut.auth(params);
    // asset
    expect(account.token, validData['accessToken']);
  });

  test('Should throw UnexpectedError if HttpClient returns 200 with invalid data', () async {
    mockHttpData({'invalid_key': 'invalid_value'});
    // act
    final future = sut.auth(params);
    // asset
    expect(future, throwsA(DomainError.unexpected));
  });
}
