let io;

module.exports = {
  init: (serverIo) => {
    io = serverIo;
    return io;
  },
  getIO: () => {
    if (!io) {
      throw new Error('Socket.io not initialized!');
    }
    return io;
  }
};