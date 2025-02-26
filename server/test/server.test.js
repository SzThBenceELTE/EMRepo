require('dotenv').config(); // Load environment variables early
process.env.NODE_ENV = 'test'; // Ensure NODE_ENV is set to 'test' for tests

require ('../db.js');
const request = require('supertest');
const http = require('http');
const app = require('../app.js'); // assuming you export your Express app from app.js or similar
const { type } = require('os');
const GroupTypeEnum = require('../enums/GroupEnum.js');
const EventTypeEnum = require('../enums/EventEnum.js');

const sequelize = require('../sequelize');
// Remove Group import
// const Group = require('./models/GroupModel');
const Person = require('../models/PersonModel');
const User = require('../models/UserModel');
const Event = require('../models/EventModel');
const Team = require('../models/TeamModel');
const EventParticipants = require('../models/EventParticipants');
const Group = require('../models/GroupModel');
const JoiningInfo = require('../models/JoiningInfoModel'); 


let server;



beforeAll(done => {
  server = http.createServer(app);
  server.listen(4000, done); // use a different port for testing
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
    request(server)
    .post('/api/events')
    .send(newEvent);

    
});

afterAll(done => {
  server.close(done);
});

// beforeEach(async () => {
//   // Clear the database before each test
//   await sequelize.sync({ force: true });

//   const newEvent = {
//         name: 'Test Event',
//         type: "MEETUP",
//         startDate: '2025-12-31',
//         endDate: '2025-12-31',
//         maxParticipants: 10,
//         groups: [],
//         teams: [],
//         location: 'Test Location',
//         description: 'Test Description',
//     };
//     const res = await request(server)
//             .post('/api/events')
//             .send(newEvent)
//             .set('Accept', 'application/json')
//             .expect(201);

// });

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
        console.log("Create")
        console.log(res.body);
    
        expect(res.body).toBeDefined();

        // // Optionally, verify that the event was created in your test DB
        // const events = await request(server)
        // .get('/api/events')
        // .expect(200);

        // expect(events.body).toContainEqual(expect.objectContaining(newEvent));

    });
});

describe('Join Event', () => {
    it('should allow a person to join an event', async () => {
      // Adjust these IDs if needed to match your test DB setup
        const newEvent = {
            name: 'Test Join Event',
            type: "MEETUP",
            startDate: '2025-12-31',
            endDate: '2025-12-31',
            maxParticipants: 10,
            groups: [],
            teams: [],
            location: 'Test Location',
            description: 'Test Description',
        };
        const createRes = await request(server)
        .post('/api/events')
        .send(newEvent)
        .set('Accept', 'application/json')
        .expect(201);
        const evId = createRes.body.id;
        console.log("Event ID: " + evId);
      const joinData = { eventId: evId, personId: 1 };
      const res = await request(server)
        .post('/api/events/join')
        .send(joinData)
        .set('Accept', 'application/json')
        .expect(200);
      
      expect(res.body).toHaveProperty('message', 'Successfully joined the event.');
    });
  
    it('should not allow a person to join an event twice', async () => {

        const newEvent = {
            name: 'Test Join Event2',
            type: "MEETUP",
            startDate: '2025-12-31',
            endDate: '2025-12-31',
            maxParticipants: 10,
            groups: [],
            teams: [],
            location: 'Test Location',
            description: 'Test Description',
        };
        const createRes = await request(server)
        .post('/api/events')
        .send(newEvent)
        .set('Accept', 'application/json')
        .expect(201);
        const evId = createRes.body.id;
        console.log("Create Res: " + createRes.body);
      const joinData = { eventId: evId, personId: 1 };
      // First join
      await request(server)
        .post('/api/events/join')
        .send(joinData)
        .set('Accept', 'application/json')
        .expect(200);
      // Second join should fail
      const res = await request(server)
        .post('/api/events/join')
        .send(joinData)
        .set('Accept', 'application/json')
        .expect(400);
      
      expect(res.body).toHaveProperty('message', 'Person already joined.');
    });
  });
  
  describe('Leave Event', () => {
    it('should allow a person to leave an event they joined', async () => {
      const joinData = { eventId: 1, personId: 1 };
      // Ensure the person is joined before leaving.
      await request(server)
        .post('/api/events/join')
        .send(joinData)
        .set('Accept', 'application/json')
        .expect(200);
      
      const res = await request(server)
        .post('/api/events/leave')
        .send(joinData)
        .set('Accept', 'application/json')
        .expect(200);
      
      expect(res.body).toHaveProperty('message', 'Successfully left the event.');
    });
  
    it('should return an error when a person who is not a participant tries to leave', async () => {
      const leaveData = { eventId: 1, personId: 9999 }; // use a non-existing or non-joined personId
      const res = await request(server)
        .post('/api/events/leave')
        .send(leaveData)
        .set('Accept', 'application/json')
        .expect(400);
      
      expect(res.body).toHaveProperty('message', 'Person is not a participant.');
    });
  });
  
  describe('Update an Event', () => {
    it('should update an existing event', async () => {
      // First, create an event to update
      const newEvent = {
        name: 'Event To Update',
        type: 'MEETUP',
        startDate: '2025-12-31',
        endDate: '2025-12-31',
        maxParticipants: 20,
        groups: [],
        teams: [],
        location: 'Old Location',
        description: 'Old Description',
      };
  
      const createRes = await request(server)
        .post('/api/events')
        .send(newEvent)
        .set('Accept', 'application/json')
        .expect(201);
      
      const eventId = createRes.body.id;
  
      // Now update some fields
      const updatedData = {
        name: 'Updated Event Name',
        type: 'WORKSHOP',
        startDate: '2025-12-31',
        endDate: '2025-12-31',
        maxParticipants: 15,
        groups: [],
        teams: [],
        location: 'New Location',
        description: 'Updated Description',
      };
  
      const updateRes = await request(server)
        .put(`/api/events/${eventId}`)
        .send(updatedData)
        .set('Accept', 'application/json')
        .expect(200);
      
      expect(updateRes.body).toHaveProperty('name', 'Updated Event Name');
      expect(updateRes.body).toHaveProperty('location', 'New Location');
    });
  });
  
  describe('Delete an Event', () => {
    it('should delete an event and its subevents', async () => {
      // First, create an event to delete
      const newEvent = {
        name: 'Event To Delete',
        type: 'MEETUP',
        startDate: '2025-12-31',
        endDate: '2025-12-31',
        maxParticipants: 10,
        groups: [],
        teams: [],
        location: 'Test Location',
        description: 'Test Description',
      };
  
      const createRes = await request(server)
        .post('/api/events')
        .send(newEvent)
        .set('Accept', 'application/json')
        .expect(201);
      
      const eventId = createRes.body.id;
  
      // Now delete the event
      await request(server)
        .delete(`/api/events/${eventId}`)
        .expect(204);
  
      // Verify that the event no longer exists
      await request(server)
        .get(`/api/events/${eventId}`)
        .expect(404);
    });
  });
  
  describe('Get Subscribed Users for an Event', () => {
    it('should return a list of subscribed users for an event', async () => {
      // Adjust eventId if necessary
      const eventId = 1;
      const res = await request(server)
        .get(`/api/events/${eventId}/subscribedUsers`)
        .expect(200);
      
      expect(res.body).toHaveProperty('subscribedUsers');
      expect(Array.isArray(res.body.subscribedUsers)).toBe(true);
    });
  });
  
  describe('Get Subscribed Events for a Person', () => {
    it('should return a list of events that the person is subscribed to', async () => {
      // Adjust personId if necessary
      const personId = 1;
      const res = await request(server)
        .get(`/api/events/${personId}/subscribedEvents`)
        .expect(200);
      
      expect(res.body).toHaveProperty('subscribedEvents');
      expect(Array.isArray(res.body.subscribedEvents)).toBe(true);
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
