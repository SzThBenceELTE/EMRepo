const Team = require('../models/TeamModel');
const Person = require('../models/PersonModel');
const sequelize = require('sequelize');


exports.getTeams = async (req, res) => {
    try{
        const teams = await Team.getAll();
        console.log(teams);
        res.status(200).json(teams);
    }
    catch(error){
        console.error(error);
        res.status(500).json({ message: 'Error retrieving teams' });
    }
};

exports.getMembers = async (req, res) => {
    const { teamId } = req.params;
    try{
        const team = await Team.findByPk(teamId, {
            include: {
                model: Person,
            }
        });
        console.log(team);
        if (team) {
            res.status(200).json(team.People);
        } else {
            res.status(404).json({ message: 'Team not found' });
        }
    }
    catch(error){
        console.error(error);
        res.status(500).json({ message: 'Error retrieving team members' });
    }
}

exports.createTeam = async (req, res)  => {
    try{
        const { name } = req.body;
        const newTeam = await Team.createTeam(name);

        const io = socketService.getIo();
        io.emit('refresh', { message: 'Team created' });

        res.status(201).json(newTeam);
    }
    catch(error){
        console.error(error);
        res.status(500).json({ message: 'Error creating team' });
    }
};

exports.editTeam = async (req, res) => {
    const { id } = req.params;
    const { name } = req.body;
    try{
        const updatedTeam = await Team.editTeam(id, name);
        if (updatedTeam) {
            res.status(200).json(updatedTeam);
        } else {
            res.status(404).json({ message: 'Team not found' });
        }
    }
    catch
    {
        console.error(error);
        res.status(500).json({ message: 'Error updating team' });
    }
};

exports.deleteTeam = async (req,res) => {
    const { id } = req.params;
    try{
      const team = await Team.findByPk(id);
        if (!team) {
          return res.status(404).json({ message: 'Team not found' });
        }
        const deletedTeam = await Team.deleteTeam(id);
        if (deletedTeam) {
            const io = socketService.getIo();
            io.emit('refresh', { message: 'Team deleted', teamId: deletedTeam.id });
            res.status(200).json(deletedTeam);
        } else {
            res.status(404).json({ message: 'Team not found' });
        }
    }
    catch(error){
        console.error(error);
        res.status(500).json({ message: 'Error deleting team' });
    }
};

exports.addPersonToTeam = async (req, res) => {
    const { teamId, personId } = req.params; // Ensure your request includes these values
    console.log(teamId, personId);
    try {
      // Find the team by primary key
      const team = await Team.findByPk(teamId);
      console.log(team);
      if (!team) {
        return res.status(404).json({ message: 'Team not found' });
      }
  
      // Find the person by primary key
      const person = await Person.findByPk(personId);
      console.log(person);
      if (!person) {
        return res.status(404).json({ message: 'Person not found' });
      }
  
      // Add the person to the team using the association method
      await team.addPerson(person);

      const io = socketService.getIo();
      io.emit('refresh', { message: 'Person added', personId: person.id, teamId: team.id });
  
      res.status(200).json({ message: 'Person added to team successfully.' });
    } catch (error) {
      console.error('Error adding person to team:', error);
      res.status(500).json({ message: 'Error adding person to team.' });
    }
};

  exports.removePersonFromTeam = async (req, res) => {
    const { teamId, personId } = req.params; // Ensure your request includes these values
    console.log(teamId, personId);
    try {
      // Find the team by primary key
      const team = await Team.findByPk(teamId);
      console.log(team);
      if (!team) {
        return res.status(404).json({ message: 'Team not found' });
      }
  
      // Find the person by primary key
      const person = await Person.findByPk(personId);
      console.log(person);
      if (!person) {
        return res.status(404).json({ message: 'Person not found' });
      }
  
      // Remove the person from the team using the association method
      await team.removePerson(person);

      const io = socketService.getIo();
      io.emit('refresh', { message: 'Person removed', personId: person.id, teamId: team.id });
  
  
      res.status(200).json({ message: 'Person removed from team successfully.' });
    } catch (error) {
      console.error('Error removing person from team:', error);
      res.status(500).json({ message: 'Error removing person from team.' });
    }
};

exports.addUsersToTeam = async (req, res) => {
    const { teamId } = req.params; // Expecting a URL like /teams/:teamId/users
    const { user_ids } = req.body; // Expecting { user_ids: [1, 2, 3, ...] }
  
    // Validate that user_ids is a non-empty array
    if (!Array.isArray(user_ids) || user_ids.length === 0) {
      return res.status(400).json({ message: 'user_ids must be a non-empty array.' });
    }
  
    try {
      // Find the team by its primary key
      const team = await Team.findByPk(teamId);
      if (!team) {
        return res.status(404).json({ message: 'Team not found.' });
      }
  
      // Retrieve all persons whose id is in the user_ids array
      const persons = await Person.findAll({
        where: { id: user_ids }
      });
  
      if (persons.length === 0) {
        return res.status(404).json({ message: 'No persons found for the provided user_ids.' });
      }
  
      // Add all found persons to the team. Note:
      // When using a many-to-many association, Sequelize creates helper methods like:
      // team.addPerson(singlePerson) and team.addPeople(arrayOfPersons).
      // Here we use addPeople to add multiple persons at once.
      await team.addPeople(persons);
  
      const io = socketService.getIo();
      io.emit('refresh', { message: 'Team joined', personId: persons, teamId: team.id });


      return res.status(200).json({ message: 'Users added to team successfully.' });
    } catch (error) {
      console.error('Error adding users to team:', error);
      return res.status(500).json({ message: 'Error adding users to team.' });
    }
  };

  exports.removeUsersFromTeam = async (req, res) => {
    const { teamId } = req.params; // Expecting a URL like /teams/:teamId/users
    const { user_ids } = req.body;  // Expecting { user_ids: [1, 2, 3, ...] }
  
    // Validate that user_ids is a non-empty array
    if (!Array.isArray(user_ids) || user_ids.length === 0) {
      return res.status(400).json({ message: 'user_ids must be a non-empty array.' });
    }
  
    try {
      // Find the team by its primary key
      const team = await Team.findByPk(teamId);
      if (!team) {
        return res.status(404).json({ message: 'Team not found.' });
      }
  
      // Retrieve all persons whose id is in the user_ids array
      const persons = await Person.findAll({
        where: { id: user_ids }
      });
  
      if (persons.length === 0) {
        return res.status(404).json({ message: 'No persons found for the provided user_ids.' });
      }
  
      // Remove all found persons from the team using the association removal method.
      // Sequelize automatically creates a helper method "removePeople" on the team instance.
      await team.removePeople(persons);

      const io = socketService.getIo();
      io.emit('refresh', { message: 'Team left', personId: persons, teamId: team.id });
  
      return res.status(200).json({ message: 'Users removed from team successfully.' });
    } catch (error) {
      console.error('Error removing users from team:', error);
      return res.status(500).json({ message: 'Error removing users from team.' });
    }
  };

  