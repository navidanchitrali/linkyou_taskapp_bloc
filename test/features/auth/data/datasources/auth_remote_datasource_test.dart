// =============================================================================
// TEST COVERAGE SUMMARY: AuthRemoteDataSourceImpl
// =============================================================================
// ✅ COVERS: API integration layer with JSONPlaceholder
// ✅ COVERS: Dio HTTP client configuration and error handling
// ✅ COVERS: Authentication token management (accessToken vs token fields)
// ✅ COVERS: Request/response formatting for login and user validation
// 
// ✅ TEST SCENARIOS COVERED (9 total):
//   Login (4 tests):
//     - Successful login with token extraction
//     - AccessToken field preference over token field  
//     - Missing token error handling
//     - HTTP 400 invalid credentials handling
//   
//   GetCurrentUser (5 tests):
//     - Authorization header formatting with Bearer token
//     - User data parsing with provided token
//     - HTTP 401 session expired handling
//     - Empty response graceful handling
//     - Partial response data handling
//
// ❌ NOT COVERED (optional future enhancements):
//   - Network timeout scenarios (connection, receive, send)
//   - Other HTTP error codes (404, 500, 502, 503)
//   - Concurrent request handling
//   - Real API integration tests
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:linkyou_tasks_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:linkyou_tasks_app/features/auth/domain/entities/user.dart';

// =============================================================================
// TEST DIO MOCK IMPLEMENTATION
// =============================================================================
// Purpose: Simulates Dio HTTP client behavior without actual network calls
// Design: Manual mock (no mocking libraries) for reliability and simplicity
// Features: Configurable responses, error injection, call tracking
class TestDio implements Dio {
  // Response configuration
  Map<String, dynamic>? _responseData;
  DioException? _errorToThrow;
  int _statusCode = 200;
  
  // Call tracking for assertions
  String? _lastPath;
  Options? _lastOptions;
  dynamic _lastData;

  // ---------------------------------------------------------------------------
  // TEST CONFIGURATION METHODS
  // ---------------------------------------------------------------------------
  void setResponse(Map<String, dynamic>? data) => _responseData = data;
  void setError(DioException error) => _errorToThrow = error;
  void setStatusCode(int code) => _statusCode = code;

  // ===========================================================================
  // HTTP METHOD IMPLEMENTATIONS (Only POST and GET needed for our tests)
  // ===========================================================================
  
  // ---------------------------------------------------------------------------
  // POST METHOD: Simulates login API call
  // ---------------------------------------------------------------------------
  // Tests: /auth/login endpoint, request body formatting, headers
  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Track call details for verification
    _lastPath = path;
    _lastOptions = options;
    _lastData = data;
    
    // Simulate error if configured
    if (_errorToThrow != null) {
      throw _errorToThrow!;
    }
    
    // Return configured response
    return Response<T>(
      data: _responseData as T?,
      statusCode: _statusCode,
      requestOptions: RequestOptions(path: path),
    );
  }

  // ---------------------------------------------------------------------------
  // GET METHOD: Simulates getCurrentUser API call
  // ---------------------------------------------------------------------------
  // Tests: /auth/me endpoint, Authorization header, Bearer token
  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Track call details for verification
    _lastPath = path;
    _lastOptions = options;
    _lastData = data;
    
    // Simulate error if configured
    if (_errorToThrow != null) {
      throw _errorToThrow!;
    }
    
    // Return configured response
    return Response<T>(
      data: _responseData as T?,
      statusCode: _statusCode,
      requestOptions: RequestOptions(path: path),
    );
  }

  // ===========================================================================
  // REQUIRED DIO PROPERTIES (Minimal implementations for compilation)
  // ===========================================================================
  @override
  BaseOptions get options => BaseOptions();
  
  @override
  set options(BaseOptions _options) {}
  
  @override
  Interceptors get interceptors => Interceptors();
  
  @override
  void close({bool force = false}) {}
  
  @override
  Dio get instance => this;

  // ===========================================================================
  // TEST HELPER METHODS (For assertions and verification)
  // ===========================================================================
  String? get lastPath => _lastPath;
  Options? get lastOptions => _lastOptions;
  dynamic get lastData => _lastData;
  
  @override
  late HttpClientAdapter httpClientAdapter;
  
  @override
  late Transformer transformer;
  
  @override
  Dio clone({BaseOptions? options, Interceptors? interceptors, HttpClientAdapter? httpClientAdapter, Transformer? transformer}) {
    // TODO: implement clone
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> delete<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) {
    // TODO: implement delete
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> deleteUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken}) {
    // TODO: implement deleteUri
    throw UnimplementedError();
  }
  
  @override
  Future<Response<dynamic>> download(String urlPath, savePath, {ProgressCallback? onReceiveProgress, Map<String, dynamic>? queryParameters, CancelToken? cancelToken, bool deleteOnError = true, FileAccessMode fileAccessMode = FileAccessMode.write, String lengthHeader = Headers.contentLengthHeader, Object? data, Options? options}) {
    // TODO: implement download
    throw UnimplementedError();
  }
  
  @override
  Future<Response<dynamic>> downloadUri(Uri uri, savePath, {ProgressCallback? onReceiveProgress, CancelToken? cancelToken, bool deleteOnError = true, FileAccessMode fileAccessMode = FileAccessMode.write, String lengthHeader = Headers.contentLengthHeader, Object? data, Options? options}) {
    // TODO: implement downloadUri
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) {
    // TODO: implement fetch
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> getUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onReceiveProgress}) {
    // TODO: implement getUri
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> head<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) {
    // TODO: implement head
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> headUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken}) {
    // TODO: implement headUri
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> patch<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    // TODO: implement patch
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> patchUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    // TODO: implement patchUri
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> postUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    // TODO: implement postUri
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> put<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    // TODO: implement put
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> putUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    // TODO: implement putUri
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> request<T>(String url, {Object? data, Map<String, dynamic>? queryParameters, CancelToken? cancelToken, Options? options, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    // TODO: implement request
    throw UnimplementedError();
  }
  
  @override
  Future<Response<T>> requestUri<T>(Uri uri, {Object? data, CancelToken? cancelToken, Options? options, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    // TODO: implement requestUri
    throw UnimplementedError();
  }
}

// =============================================================================
// MAIN TEST SUITE
// =============================================================================
void main() {
  // Test grouping for organization and clarity
  group('AuthRemoteDataSourceImpl', () {
    // Test fixtures
    late TestDio mockDio;
    late AuthRemoteDataSourceImpl dataSource;

    // -------------------------------------------------------------------------
    // SETUP: Runs before each test
    // -------------------------------------------------------------------------
    // Purpose: Fresh mock and data source for each test (test isolation)
    setUp(() {
      mockDio = TestDio();
      dataSource = AuthRemoteDataSourceImpl(dio: mockDio);
    });

    // =========================================================================
    // TEST GROUP: Login Operation
    // =========================================================================
    // Purpose: Tests authentication API (/auth/login) with JSONPlaceholder
    // Coverage: Request formatting, response parsing, error handling
    group('login', () {
      // -----------------------------------------------------------------------
      // TEST 1: SUCCESSFUL LOGIN
      // -----------------------------------------------------------------------
      // ✅ Verifies: Correct API endpoint, request body, headers
      // ✅ Verifies: User object creation with extracted token
      // ✅ Edge Cases: Complete user data parsing
      test('makes correct API call with credentials', () async {
        // Arrange: Setup mock response
        mockDio.setResponse({
          'id': 15,
          'username': 'test',
          'email': 'test@test.com',
          'firstName': 'Test',
          'lastName': 'User',
          'gender': 'male',
          'image': '',
          'token': 'test_token',
        });

        // Act: Execute the login method
        final user = await dataSource.login('test', 'password');

        // Assert: Verify API call details
        expect(mockDio.lastPath, '/auth/login');
        expect(mockDio.lastData, {'username': 'test', 'password': 'password'});
        expect(mockDio.lastOptions?.headers?['Content-Type'], 'application/json');
        
        // Assert: Verify User object creation
        expect(user.id, '15');
        expect(user.username, 'test');
        expect(user.token, 'test_token');
      });

      // -----------------------------------------------------------------------
      // TEST 2: ACCESS TOKEN FIELD PREFERENCE
      // -----------------------------------------------------------------------
      // ✅ Verifies: accessToken field takes precedence over token field
      // ✅ Business Logic: API compatibility with different token field names
      test('prefers accessToken field over token field', () async {
        // Arrange: Response with both token field names
        mockDio.setResponse({
          'id': 15,
          'username': 'test',
          'accessToken': 'access_token_123',
          'token': 'regular_token_456',
        });

        // Act & Assert: accessToken should be used
        final user = await dataSource.login('test', 'password');
        expect(user.token, 'access_token_123');
      });

      // -----------------------------------------------------------------------
      // TEST 3: MISSING TOKEN ERROR HANDLING
      // -----------------------------------------------------------------------
      // ✅ Verifies: Graceful error when API response lacks token
      // ✅ Error Message: Clear exception for debugging
      // ✅ Security: Prevents authentication with invalid responses
      test('throws exception when no token in response', () async {
        // Arrange: Response without token fields
        mockDio.setResponse({
          'id': 15,
          'username': 'test',
          'email': 'test@test.com',
        });

        // Act & Assert: Should throw specific exception
        expect(
          () async => await dataSource.login('test', 'password'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'exception message',
            contains('No authentication token received'),
          )),
        );
      });

      // -----------------------------------------------------------------------
      // TEST 4: HTTP 400 INVALID CREDENTIALS
      // -----------------------------------------------------------------------
      // ✅ Verifies: Proper error mapping for invalid credentials
      // ✅ User Experience: Clear error message for wrong username/password
      // ✅ API Contract: Correct HTTP status code handling
      test('handles 400 invalid credentials error', () async {
        // Arrange: Simulate 400 Bad Request response
        mockDio.setError(DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response<dynamic>(
            statusCode: 400,
            requestOptions: RequestOptions(path: '/auth/login'),
          ),
        ));

        // Act & Assert: Should throw formatted exception
        expect(
          () async => await dataSource.login('test', 'password'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'exception message',
            contains('Invalid username or password'),
          )),
        );
      });
    });

    // =========================================================================
    // TEST GROUP: GetCurrentUser Operation
    // =========================================================================
    // Purpose: Tests user validation API (/auth/me) with existing token
    // Coverage: Authorization headers, session validation, error handling
    group('getCurrentUser', () {
      // -----------------------------------------------------------------------
      // TEST 5: AUTHORIZATION HEADER FORMATTING
      // -----------------------------------------------------------------------
      // ✅ Verifies: Bearer token format in Authorization header
      // ✅ Verifies: Correct API endpoint and content type
      // ✅ Security: Proper token transmission
      test('adds authorization header with Bearer token', () async {
        // Arrange: Setup user data response
        mockDio.setResponse({
          'id': 15,
          'username': 'test',
          'email': 'test@test.com',
        });

        // Act: Call getCurrentUser with token
        await dataSource.getCurrentUser('test_token');

        // Assert: Verify headers and endpoint
        expect(mockDio.lastPath, '/auth/me');
        expect(mockDio.lastOptions?.headers?['Authorization'], 'Bearer test_token');
        expect(mockDio.lastOptions?.headers?['Content-Type'], 'application/json');
      });

      // -----------------------------------------------------------------------
      // TEST 6: USER DATA PARSING WITH PROVIDED TOKEN
      // -----------------------------------------------------------------------
      // ✅ Verifies: User object creation with external token
      // ✅ Verifies: Response data merging with provided token
      // ✅ Data Flow: Token passed from client through to User object
      test('returns user with provided token', () async {
        // Arrange: Setup user data response
        mockDio.setResponse({
          'id': 15,
          'username': 'test',
          'email': 'test@test.com',
        });

        // Act: Call with specific token
        final user = await dataSource.getCurrentUser('provided_token_123');

        // Assert: Verify user data and token
        expect(user.id, '15');
        expect(user.username, 'test');
        expect(user.token, 'provided_token_123');
      });

      // -----------------------------------------------------------------------
      // TEST 7: HTTP 401 SESSION EXPIRED HANDLING
      // -----------------------------------------------------------------------
      // ✅ Verifies: Proper error handling for expired/invalid tokens
      // ✅ User Experience: Clear message prompting re-login
      // ✅ Security: Session management error cases
      test('handles 401 session expired error', () async {
        // Arrange: Simulate 401 Unauthorized response
        mockDio.setError(DioException(
          requestOptions: RequestOptions(path: '/auth/me'),
          response: Response<dynamic>(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/auth/me'),
          ),
        ));

        // Act & Assert: Should throw session expired exception
        expect(
          () async => await dataSource.getCurrentUser('expired_token'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'exception message',
            contains('Session expired. Please login again.'),
          )),
        );
      });

      // -----------------------------------------------------------------------
      // TEST 8: EMPTY RESPONSE GRACEFUL HANDLING
      // -----------------------------------------------------------------------
      // ✅ Verifies: Null/empty response doesn't crash application
      // ✅ Verifies: Default values used for missing fields
      // ✅ Robustness: API returns minimal or empty data
      test('handles empty response', () async {
        // Arrange: Empty response data
        mockDio.setResponse(<String, dynamic>{});

        // Act: Call with token
        final user = await dataSource.getCurrentUser('test_token');

        // Assert: User created with defaults and provided token
        expect(user.token, 'test_token');
        expect(user.username, '');
        expect(user.email, '');
      });

      // -----------------------------------------------------------------------
      // TEST 9: PARTIAL RESPONSE DATA HANDLING
      // -----------------------------------------------------------------------
      // ✅ Verifies: Missing fields in API response handled gracefully
      // ✅ Verifies: Default values for optional fields
      // ✅ API Evolution: Backward compatibility with new/removed fields
      test('handles partial response data', () async {
        // Arrange: Response with only required fields
        mockDio.setResponse({
          'id': 15,
          'username': 'test',
        });

        // Act: Call with token
        final user = await dataSource.getCurrentUser('test_token');

        // Assert: Partial data parsed, defaults for missing fields
        expect(user.id, '15');
        expect(user.username, 'test');
        expect(user.email, ''); // Default empty string
        expect(user.token, 'test_token');
      });
    });
  });
}

// =============================================================================
// TEST IMPLEMENTATION NOTES:
// =============================================================================
// 1. MANUAL MOCKING STRATEGY:
//    - No external mocking libraries (mockito/mocktail)
//    - Full control over mock behavior
//    - Avoids null-safety issues common with generated mocks
//    - Clear, predictable test setup
//
// 2. TEST ISOLATION:
//    - Each test gets fresh mock instance (setUp)
//    - No shared state between tests
//    - Tests can run in any order
//
// 3. COVERAGE FOCUS:
//    - API contract validation (endpoints, headers, methods)
//    - Error handling and edge cases
//    - Business logic (token extraction, field preferences)
//    - Response parsing and data transformation
//
// 4. REAL-WORLD SCENARIOS:
//    - Complete success flows
//    - Common error responses (400, 401)
//    - Edge cases (empty/partial responses)
//    - Field naming variations (accessToken vs token)
// =============================================================================