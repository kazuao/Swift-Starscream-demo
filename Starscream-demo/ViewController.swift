//
//  ViewController.swift
//  Starscream-demo
//
//  Created by kazunori.aoki on 2021/11/05.
//

import UIKit
import Starscream

class ViewController: UIViewController {

    // MARK: Property
    var socket: WebSocket!
    var isConnected = false
    let server = WebSocketServer()


    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSocket()
    }


    // MARK: IBAction
    @IBAction func stopWebsocket(_ sender: UIButton) {
        if isConnected {
            sender.setTitle("Connected", for: .normal)
            socket.disconnect()
        } else {
            sender.setTitle("Disconnected", for: .normal)
            socket.connect()
        }
    }

    @IBAction func writeMessage(_ sender: Any) {
        socket.write(string: "hello world")
    }
}


private extension ViewController {
    
    func setupSocket() {
        var request = URLRequest(url: URL(string: "http://192.168.10.2:8080")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
}


// MARK: - WebSocketDelegate
extension ViewController: WebSocketDelegate {

    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")

        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")

        case .text(let string):
            print("received text: \(string)")

        case .binary(let data):
            print("received data: \(data.count)")

        case .pong(_):
            break
        case .ping(_):
            break

        case .error(let e):
            isConnected = false
            handleError(e)

        case .viabilityChanged(_):
            break

        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        }
    }

    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }


}
