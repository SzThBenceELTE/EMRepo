require('dotenv').config(); // Load environment variables early
process.env.NODE_ENV = 'test'; // Ensure NODE_ENV is set to 'test' for tests

require ('../db.js');
const request = require('supertest');
const http = require('http');
const app = require('../app.js'); // assuming you export your Express app from app.js or similar
const { type } = require('os');
const GroupTypeEnum = require('../enums/GroupEnum.js');
const EventTypeEnum = require('../enums/EventEnum.js');

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

describe('Get All Events and Subevents', () => {
    it('should return a list of events', async () => {
        const res = await request(server)
        .get('/api/events/all')
        .expect(200);
    
        expect(res.body).toBeInstanceOf(Array);
    });
});

describe('Get All Events and Subevents from any time', () => {
    it('should return a list of events', async () => {
        const res = await request(server)
        .get('/api/events/allandpast')
        .expect(200);
    
        expect(res.body).toBeInstanceOf(Array);
    });
});

describe('Get All Events from any time', () => {
    it('should return a list of events', async () => {
        const res = await request(server)
        .get('/api/events/allandpastmain')
        .expect(200);
    
        expect(res.body).toBeInstanceOf(Array);
    });
});

describe('Get Specific Event', () => {
    it('should return a single event', async () => {
        const eventId = 1; // adjust to an event you know exists in your test DB
    
        const res = await request(server)
        .get(`/api/events/${eventId}`)
        .expect(200);
    
        expect(res.body).toHaveProperty('id', eventId);
    });
});

describe('Is Person Subscribed to the event test', () => {
    it('should return a boolean value', async () => {
        const eventId = 1; 
        const personId = 1;
    
        const res = await request(server)
        .get(`/api/events/${eventId}/isSubscribed/${personId}`)
        .expect(200);
    
        expect(res.body).toHaveProperty('subscribed');
    });
});

describe('Get Non Existents Event', () => {
    it('should return noone', async () => {
        const eventId = -2; 
    
        const res = await request(server)
        .get(`/api/events/${eventId}`)
        .expect(404);
    
        expect(res.body).toHaveProperty('message', "Event not found");
    });
});

describe('Get Subscribed People Event Check', () => {
    it('should return a single event', async () => {
        const eventId = 1; 
    
        const res = await request(server)
        .get(`/api/${eventId}/subscribedUsers`)
        .expect(404);
    
        expect(res.body).toBeInstanceOf(Object);
    });
});

describe('Get Subscribed Events for a Person', () => {
    it('should return a list of events', async () => {
        const personId = 1; 
    
        const res = await request(server)
        .get(`/api/${personId}/subscribedEvents`)
        .expect(404);
    
        expect(res.body).toBeInstanceOf(Object);
    });
});


describe('Create an Event', () => {
    it('should create a new event', async () => {
        const newEvent = {
            name: 'Test Event',
            type: "MEETUP",
            startDate: '2025-12-31',
            endDate: '2025-12-31',
            maxParticipants: 10,
            groups: [],
            teams: [],
            location: 'Test Location',
            description: 'Test Description',
        };
    
        const res = await request(server)
        .post('/api/events')
        .send(newEvent)
        .set('Accept', 'application/json')
        .expect(201);

        console.log("Res body in the creation test");
        console.log(res.body);
    
        expect(res.body).toBeDefined();

        // // Optionally, verify that the event was created in your test DB
        // const events = await request(server)
        // .get('/api/events')
        // .expect(200);

        // expect(events.body).toContainEqual(expect.objectContaining(newEvent));

    });
});

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
