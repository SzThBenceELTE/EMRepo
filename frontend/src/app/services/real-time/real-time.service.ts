// src/app/services/real-time.service.ts
import { Injectable } from '@angular/core';
import { io, Socket } from 'socket.io-client';

@Injectable({
  providedIn: 'root'
})
export class RealTimeService {
  private socket: Socket;

  constructor() {
    // Connect to your Socket.IO server; adjust the URL/port as needed.
    this.socket = io('http://localhost:3000', {
      path: '/io',
      // Optional configuration
      reconnectionAttempts: 5,
      timeout: 100,
    });

    // Log connection status
    this.socket.on('connect', () => {
      console.log(`Socket connected: ${this.socket.id}`);
    });

    this.socket.on('connect_error', (error) => {
      console.error('Socket connection error:', error);
    });

    this.socket.on('disconnect', () => {
      console.log('Socket disconnected');
    });
  }

  /**
   * Listen for a refresh event from the server.
   * @param callback - Function to call when a refresh event is received.
   */
  onRefresh(callback: (data: any) => void): void {
    this.socket.on('refresh', callback);
  }

  /**
   * Emit a refresh event to the server.
   * @param data - Data to send along with the refresh event.
   */
  emitRefresh(data: any): void {
    this.socket.emit('refresh', data);
  }

  /**
   * Get the underlying Socket instance (if needed).
   */
  getSocket(): Socket {
    return this.socket;
  }

  /**
   * Disconnect the socket (if needed).
   */
  disconnect(): void {
    this.socket.disconnect();
  }
}
