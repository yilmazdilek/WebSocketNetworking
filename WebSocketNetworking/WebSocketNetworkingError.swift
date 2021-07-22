//
//  WebSocketNetworkingError.swift
//  WebSocketNetworking
//
//  Created by Yilmaz Dilek on 22.07.21.
//

import Foundation

enum WebSocketNetworkingError: Error {
	case socketMessageSendingFailure(urlString: String?, description: String)
	case socketMessageReceivingFailure(urlString: String?, description: String)
	case socketPingFailure(urlString: String?, description: String)
	
	var domain: String { "Networking" }
	
	var code: Int {
		switch self {
		case .socketMessageSendingFailure(_, _): return -9001
		case .socketMessageReceivingFailure(_, _): return -9002
		case .socketPingFailure(_, _): return -9003
		}
	}
	
	var localizedDescription: String {
		switch self {
		case .socketMessageSendingFailure(let urlString, let description):
			return "Message sending failed: \(urlString ?? "no_url"), \(description)"
			
		case .socketMessageReceivingFailure(let urlString, let description):
			return "Message receiving failed: \(urlString ?? "no_url"), \(description)"
			
		case .socketPingFailure(let urlString, let description):
			return "Ping failed: \(urlString ?? "no_url"), \(description)"
		}
	}
}
