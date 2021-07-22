//
//  WebSocketNetworking.swift
//  WebSocketNetworking
//
//  Created by Yilmaz Dilek on 22.07.21.
//

import Foundation

final class WebSocketNetworking: NSObject, WebSocketNetworkingInterface {
	
	func connectToSocket(withUrl url: URL) -> URLSessionWebSocketTask {
		let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
		let webSocketTask = urlSession.webSocketTask(with: url)
		webSocketTask.resume()
		return webSocketTask
	}
	
	func send<T: Encodable>(messageData: T, to socketTask: URLSessionWebSocketTask,
							onError: @escaping (Error) -> Void) {
		
		guard let jsonData = try? JSONEncoder().encode(messageData),
			let jsonString = String(data: jsonData, encoding: .utf8) else {
				return onError(WebSocketNetworkingError.socketMessageSendingFailure(urlString: socketTask.originalRequest?.url?.absoluteString,
																					description: "Malformed message data."))
		}
		
		socketTask.send(URLSessionWebSocketTask.Message.string(jsonString)) { error in
			if let error = error {
				onError(WebSocketNetworkingError.socketMessageSendingFailure(urlString: socketTask.originalRequest?.url?.absoluteString,
																			 description: error.localizedDescription))
			}
		}
	}
	
	
	func receiveMessageData<T: Decodable>(from socketTask: URLSessionWebSocketTask,
										  onReceive: @escaping (Result<T, Error>) -> Void) {
		socketTask.receive { result in
			switch result {
			case .success(let message):
				switch message {
				case .string(let text):
					do {
						let parsedData = try JSONDecoder().decode(T.self, from: Data(text.utf8))
						onReceive(.success(parsedData))
					} catch {
						let e = WebSocketNetworkingError.socketMessageReceivingFailure(urlString: socketTask.originalRequest?.url?.absoluteString,
																					   description: error.localizedDescription)
						onReceive(.failure(e))
					}
					
				case .data(let data):
					do {
						let parsedData = try JSONDecoder().decode(T.self, from: data)
						onReceive(.success(parsedData))
					} catch {
						let e = WebSocketNetworkingError.socketMessageReceivingFailure(urlString: socketTask.originalRequest?.url?.absoluteString,
																					   description: error.localizedDescription)
						onReceive(.failure(e))
					}
					
				@unknown default:
					let e = WebSocketNetworkingError.socketMessageReceivingFailure(urlString: socketTask.originalRequest?.url?.absoluteString,
																				   description: "New web socket message type.")
					onReceive(.failure(e))
				}
				
			case .failure(let error):
				let e = WebSocketNetworkingError.socketMessageReceivingFailure(urlString: socketTask.originalRequest?.url?.absoluteString,
																			   description: error.localizedDescription)
				onReceive(.failure(e))
			}
		}
	}
	
	func pingSocket(_ socketTask: URLSessionWebSocketTask,
					onError: @escaping (Error) -> Void) {
		socketTask.sendPing { (error) in
			if let error = error {
				onError(WebSocketNetworkingError.socketPingFailure(urlString: socketTask.originalRequest?.url?.absoluteString,
																   description: error.localizedDescription))
			}
		}
	}
	
	func disconnect(from socketTask: URLSessionWebSocketTask, code: URLSessionWebSocketTask.CloseCode) {
		socketTask.cancel(with: code, reason: nil)
	}
}

extension WebSocketNetworking: URLSessionWebSocketDelegate {
	func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
		// TODO: publish a notification in NotificationCenter so that listeners may react/log
	}
	
	func urlSession(_ session: URLSession,
					webSocketTask: URLSessionWebSocketTask,
					didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
		// TODO: publish a notification in NotificationCenter so that listeners may react/log
	}
}
