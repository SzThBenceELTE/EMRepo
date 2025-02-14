// Example UserController.js
const { authenticateToken } = require('./auth/AuthenticationChecker');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/UserModel'); 
const Person = require('../models/PersonModel');
const sequelize = require('sequelize');
const socketService = require('../socketService');
require('dotenv').config();

const jwtSecret = process.env.JWT_SECRET || 'your_jwt_secret_here';

exports.getUsers = async (req, res) => {
    try {
        const users = await User.getAll();
        //console.log(users);
        res.status(200).json(users);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error retrieving users' });
    }
};

// exports.createUser = async (req, res) => {
//     const { name, email, password } = req.body;
//     try {
//         const newUser = await User.createUser(name, email, password);
//         res.status(201).json(newUser);
//     } catch (error) {
//         console.error(error);
//         res.status(500).json({ message: 'Error creating user' });
//     }
// };

exports.createUser = async (req, res) => {
    const { name, email, password, firstName, surname, role, group } = req.body;
    console.log('req.body:', req.body);
    try {
      // Check if user already exists
      let existingUser = await User.findByEmail(email);
      if (existingUser) {

        return res.status(400).json({ message: 'Email already exists' });
      }
  
      // Hash the password
       const hashedPassword = await bcrypt.hash(password, 10);
  
      // Create the user
      
      const newUser = await User.create({
        name,
        email,
        password: hashedPassword,
      });
      //console.log('newUser:', newUser);
  
      // Create the person and link to the user
      
      const newPerson = await Person.create({
        firstName,
        surname,
        role,
        group,
        userId: newUser.id,
      });
      await newUser.setPerson(newPerson); // Associate the person with the user
      console.log('newUser:', newPerson);

      const io = socketService.getIO();
      console.log('io:', io);
      io.emit('refresh', { message: 'User created' });
      console.log("message emmited");

      res.status(201).json({ user: newUser, person: newPerson });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Error creating user' });
    }
};

exports.getUserById = async (req, res) => {
    const { id } = req.params;
    try {
        const user = await User.findById(id);
        if (user) {
            res.status(200).json(user);
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error retrieving user' });
    }
};

exports.getUserByName = async (req, res) => {
    const { name } = req.params;
    try {
        const user = await User.findByName(name);
        if (user) {
            res.status(200).json(user);
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error retrieving user' });
    }
};

exports.getUserByEmail = async (req, res) => {
    const { email } = req.params;
    try {
        const user = await User.findByEmail(email);
        if (user) {
            res.status(200).json(user);
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error retrieving user' });
    }
};


exports.updateUser = async (req, res) => {
    const { id } = req.params;
    const { name, email } = req.body;
    try {
        const updatedUser = await User.updateUser(id, name, email);
        if (updatedUser) {
          const io = socketService.getIO();
          io.emit('refresh', { message: 'User updated', userId: updatedUser.id });
            res.status(200).json(updatedUser);
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error updating user' });
    }
};

exports.deleteUser = async (req, res) => {
    const { id } = req.params;
    try {
        const deletedUser = await User.deleteUser(id);
        if (deletedUser) {
          const io = socketService.getIO();
          io.emit('refresh', { message: 'User deleted', userId: deletedUser.id });
            res.status(204).send(); // No content to send back
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error deleting user' });
    }
};

// Login User
exports.loginUser = async (req, res) => {
  const { username, password } = req.body;

  try {
    // Find user by email and include associated Person
    const user = await User.findOne({
      where: { name: username }, // Use 'username' for lookup
      include: [{ model: Person }], // Include the associated Person
    });

    //console.log('user:', user);

    if (!user || !user.Person) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Compare password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Authentication failed. Wrong password.' });
    }

    // Generate JWT including userId
    const token = jwt.sign(
      { userId: user.id },
      jwtSecret,
      { expiresIn: '1h' }
    );

    res.cookie('loginToken', token, {
      httpOnly: true, // Cannot be accessed by client-side JavaScript
      secure: false, // Set to true if using HTTPS
      maxAge: 3600000, // 1 hour
    });

    res.status(200).json({
      user,
      token
    });
  } catch (error) {
    console.error('Login Error:', error.message);
    res.status(500).json({ message: 'Internal server error.' });
  }
};

  exports.getCurrentUser = async (req, res) => {
    try {
        const userId = req.user.id; 
        //console.log('userId:', userId);
    
        // Await the asynchronous call to fetch the user
        const user = await User.findByPk(userId, {
          include: [{ model: Person }],  // Ensures Person is fetched along with User
        });
        //console.log('user:', user);
        if (!user) {
          return res.status(404).json({ message: 'User not found' });
        }
    
        // Access the associated Person using Sequelize associations
        const person = user.Person; // Using the generated accessor method
        //console.log('person:', person);
        if (!person) {
          return res.status(404).json({ message: 'Person not found' });
        }
        
      res.status(200).json({
        id: user.id,
        username: user.username,
        email: user.email,
        personId: person.id,
        person: {
            id: person.id,
            firstName: person.firstName,
            surname: person.surname,
            role: person.role,
            group: person.group,
            userId: person.userId, // Ensure this is included
          },
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Internal server error, get current user.' });
    }
  };

  exports.getSubscribedEvents = async (req, res) => {
    const { personId } = req.params;
  
    try {
      const person = await Person.findByPk(personId);
      if (!person) {
        return res.status(404).json({ message: 'Person not found.' });
      }
  
      const events = await person.getEvents({ attributes: ['id'] });
      const eventIds = events.map(event => event.id);
  
      res.status(200).json({ subscribedEventIds: eventIds });
    } catch (error) {
      console.error('Get Subscribed Events Error:', error);
      res.status(500).json({ message: 'Internal server error.' });
    }
  };

  exports.getPersonByUser = async (req, res) => {
    const { userId } = req.params;
    //console.log('userId:', userId);
    try {
        const user = await User.findByPk(userId, {
            include: [Person],
        });
        //console.log('user:', user);
        if (user && user.Person) {
            res.status(200).json(user.Person);
        } else {
            res.status(404).json({ message: 'Person not found for the user' });
        }
    } catch (error) {
        console.error('Get Person By User Error:', error);
        res.status(500).json({ message: 'Internal server error.' });
    }
  };