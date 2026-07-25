import Foundation

/// Typed networking failures surfaced to ViewModels.
enum APIError: LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
    case transport(Error)
    case mockUnavailable
    case unauthorized
    case serverMessage(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The request URL was invalid."
        case .invalidResponse:
            "The server returned an unexpected response."
        case .httpStatus(let code):
            "Request failed with status \(code)."
        case .decoding(let error):
            "Unable to decode response: \(error.localizedDescription)"
        case .transport(let error):
            error.localizedDescription
        case .mockUnavailable:
            "Mock data is unavailable for this endpoint."
        case .unauthorized:
            "Please sign in to continue."
        case .serverMessage(let message):
            message
        }
    }
}
