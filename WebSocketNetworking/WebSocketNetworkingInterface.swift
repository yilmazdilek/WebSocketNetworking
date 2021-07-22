//
//  WebSocketNetworkingInterface.swift
//  WebSocketNetworking
//
//  Created by Yilmaz Dilek on 22.07.21.
//

import Foundation

protocol WebSocketNetworkingInterface: AnyObject {
	func connectToSocket(withUrl url: URL) -> URLSessionWebSocketTask
	
	func send<T: Encodable>(messageData: T, to socketTask: URLSessionWebSocketTask,
							onError: @escaping (Error) -> Void)
	
	func receiveMessageData<T: Decodable>(from socketTask: URLSessionWebSocketTask,
										  onReceive: @escaping (Result<T, Error>) -> Void)
	
	func pingSocket(_ socketTask: URLSessionWebSocketTask,
					onError: @escaping (Error) -> Void)
	
	func disconnect(from socketTask: URLSessionWebSocketTask, code: URLSessionWebSocketTask.CloseCode)
}
