// lib/services/real_time_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RealTimeService {
  late IO.Socket socket;

  RealTimeService() {
    // Connect to the server with the custom path '/io'
    socket = IO.io(
      'http://localhost:3000', 
      IO.OptionBuilder()
        .setTransports(['websocket']) // for Flutter, using WebSocket is preferable
        .setPath('/io')
        .setReconnectionAttempts(5)
        .setTimeout(10000)
        .build()
    );

    // Connect the socket
    socket.connect();

    // Listen for connection events
    socket.onConnect((_) {
      print('Connected to socket server: ${socket.id}');
    });

    socket.onConnectError((error) {
      print('Socket connection error: $error');
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });

    // Listen for refresh events
    socket.on('refresh', (data) {
      print('Refresh event received: $data');
      // Here, trigger your UI update, e.g., notify listeners in a provider or call setState
    });
  }
  
  IO.Socket getSocket() {
    return socket;
  }

   /// Subscribes to the 'refresh' event.
  void onRefresh(void Function(dynamic data) callback) {
    socket.on('refresh', callback);
  }

  /// Optionally, emit a 'refresh' event.
  void emitRefresh(dynamic data) {
    socket.emit('refresh', data);
  }

  void disconnect() {
    socket.disconnect();
  }
}