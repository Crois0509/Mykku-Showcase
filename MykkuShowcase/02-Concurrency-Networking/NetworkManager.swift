//
//  NetworkManager.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 2026.
//

import Foundation

// MARK: - Network Request Target Abstraction
public protocol NetworkTargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    var task: NetworkTask { get }
}

public enum NetworkTask {
    case requestPlain
    case requestJSONEncodable(any Encodable)
    case requestParameters([String: Any])
}

// MARK: - Server Response Container
public struct BaseResponse<T: Decodable>: Decodable {
    public let status: Int?
    public let message: String?
    public let data: T
    
    public init(status: Int? = 200, message: String? = "성공", data: T) {
        self.status = status
        self.message = message
        self.data = data
    }
}

public struct EmptyResponse: Decodable {
    public init() {}
}

public struct ErrorState: Decodable, Sendable {
    public let message: String
    public let code: String?
    
    public init(message: String, code: String? = nil) {
        self.message = message
        self.code = code
    }
}

// MARK: - Network Error with Typed Throws
public enum NetworkError: Error, Sendable {
    case requestFail
    case decoding
    case unauthorized
    case server(ErrorState)
    
    public var message: String {
        switch self {
        case .requestFail:
            return "네트워크 요청에 실패했습니다. 잠시 후 다시 시도해 주세요."
        case .decoding:
            return "데이터 파싱 중 오류가 발생했습니다."
        case .unauthorized:
            return "인증이 만료되었습니다. 다시 로그인해 주세요."
        case .server(let state):
            return state.message
        }
    }
    
    public var code: String? {
        switch self {
        case .server(let state):
            return state.code
        default:
            return nil
        }
    }
    
    public var serverCode: ServerErrorCode? {
        guard let code else { return nil }
        return ServerErrorCode(rawValue: code)
    }
}

// MARK: - Network Manager Protocol
public protocol NetworkManager: AnyObject, Sendable {
    @discardableResult
    func request<Target: NetworkTargetType, DTO: Decodable>(
        _ target: Target,
        of type: DTO.Type
    ) async throws(NetworkError) -> DTO
}

// MARK: - Default Network Implementation
public final class DefaultNetworkManager: NetworkManager, @unchecked Sendable {
    
    private let interceptor: AuthInterceptor?
    private let session: URLSession
    
    public init(interceptor: AuthInterceptor? = nil, session: URLSession = .shared) {
        self.interceptor = interceptor
        self.session = session
    }
    
    public func request<Target: NetworkTargetType, DTO: Decodable>(
        _ target: Target,
        of type: DTO.Type
    ) async throws(NetworkError) -> DTO {
        
        let url = target.baseURL.appendingPathComponent(target.path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = target.method
        
        // 헤더 적용
        target.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // 인터셉터 토큰 주입 (Adapt)
        if let interceptor = interceptor {
            urlRequest = interceptor.adapt(urlRequest)
        }
        
        // Body 직렬화
        switch target.task {
        case .requestPlain:
            break
        case .requestJSONEncodable(let encodable):
            urlRequest.httpBody = try? JSONEncoder().encode(encodable)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case .requestParameters(let params):
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: params)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.requestFail
            }
            
            // 401 Unauthorized 처리 & Interceptor Retry
            if httpResponse.statusCode == 401, let interceptor = interceptor {
                let shouldRetry = await interceptor.retry(request: urlRequest, statusCode: 401)
                if shouldRetry {
                    // 갱신된 새 토큰으로 1회 재시도
                    let retriedRequest = interceptor.adapt(urlRequest)
                    let (retryData, retryResponse) = try await session.data(for: retriedRequest)
                    return try parseResponse(data: retryData, response: retryResponse, of: type)
                } else {
                    throw NetworkError.unauthorized
                }
            }
            
            return try parseResponse(data: data, response: httpResponse, of: type)
            
        } catch let netError as NetworkError {
            throw netError
        } catch {
            throw NetworkError.requestFail
        }
    }
    
    private func parseResponse<DTO: Decodable>(data: Data, response: URLResponse, of type: DTO.Type) throws(NetworkError) -> DTO {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.requestFail
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            if DTO.self is EmptyResponse.Type {
                return EmptyResponse() as! DTO
            }
            do {
                return try JSONDecoder().decode(type, from: data)
            } catch {
                throw NetworkError.decoding
            }
        } else {
            if let errorState = try? JSONDecoder().decode(ErrorState.self, from: data) {
                throw NetworkError.server(errorState)
            }
            throw NetworkError.server(ErrorState(message: "서버 오류 (HTTP \(httpResponse.statusCode))"))
        }
    }
}

// MARK: - Mock Network Implementation
public final class MockNetworkManager: NetworkManager, @unchecked Sendable {
    
    public var shouldThrowError: Bool = false
    public var errorToThrow: NetworkError = .requestFail
    public var mockResponse: (any Decodable)?
    public private(set) var requestCallCount: Int = 0
    
    public init() {}
    
    public func request<Target: NetworkTargetType, DTO: Decodable>(
        _ target: Target,
        of type: DTO.Type
    ) async throws(NetworkError) -> DTO {
        requestCallCount += 1
        
        try? await Task.sleep(for: .milliseconds(300))
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        if DTO.self is EmptyResponse.Type {
            return EmptyResponse() as! DTO
        }
        
        guard let response = mockResponse as? DTO else {
            throw .decoding
        }
        
        return response
    }
}
