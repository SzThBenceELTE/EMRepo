const request = require('supertest');
const http = require('http');
const app = require('../server.js'); // assuming you export your Express app from app.js or similar
const { type } = require('os');
const { GroupTypeEnum } = require('../enums/GroupEnum.js');

let server;

beforeAll(done => {
  server = http.createServer(app);
  server.listen(4000, done); // use a different port for testing
});

afterAll(done => {
  server.close(done);
});

/*
    Event Tests
*/

describe('Get All Events', () => {
    it('should return a list of events', async () => {
        const res = await request(server)
        .get('/api/events')
        .expect(200);
    
        expect(res.body).toBeInstanceOf(Array);
    });
});

describe('Get Specific Event Check', () => {
    it('should return a single event', async () => {
        const eventId = 1; // adjust to an event you know exists in your test DB
    
        const res = await request(server)
        .get(`/api/events/${eventId}`)
        .expect(200);
    
        expect(res.body).toHaveProperty('id', eventId);
    });
});



// describe('POST /api/events', () => {
//     it('should create a new event', async () => {
//         const newEvent = {
//             name: 'Test Event',
//             type: 
//             date: '2022-12-31',
//             location: 'Test Location',
//             description: 'Test Description',
//         };
    
//         const res = await request(server)
//         .post('/api/events')
//         .send(newEvent)
//         .expect(201);
    
//         expect(res.body).toMatchObject(newEvent);
//     });
// });

// describe('DELETE /api/events/:id', () => {
//   it('should delete an event and emit a refresh event', async () => {
//     // First, create an event (or use a known event ID)
//     const eventId = 1; // adjust to an event you know exists in your test DB

//     const res = await request(server)
//       .delete(`/api/events/${eventId}`)
//       .expect(204);

//     // Optionally, verify that subsequent GET calls do not return this event.
//     const getRes = await request(server)
//       .get(`/api/events/${eventId}`)
//       .expect(404);
//   });
// });});
