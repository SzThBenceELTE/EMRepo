const Team = require('../models/TeamModel').Team;
const Sequelize = require('sequelize');


exports.getTeams = async (req, res) => {
    try{
        const teams = await Team.getAll();
        res.status(200).json(teams);
    }
    catch(error){
        console.error(error);
        res.status(500).json({ message: 'Error retrieving teams' });
    }
};

exports.createTeam = async (req, res)  => {
    try{
        const { name } = req.body;
        const newTeam = await Team.createTeam(name);
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
        const deletedTeam = await Team.deleteTeam(id);
        if (deletedTeam) {
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
