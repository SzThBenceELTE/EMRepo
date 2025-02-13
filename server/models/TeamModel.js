const {Op, Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../sequelize'); // Import from sequelize.js
const now = new Date();
const Person = require('./PersonModel');

/*
What we need:
    Teams with name and id
    People associated with the team - based on Person Id
    Also need an event association, altough I'd put that in EventModel
*/

const Team = sequelize.define(
    'Team',
    {
        id : {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },
        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
    },
);

Team.getAll = async () => {
    return await Team.findAll({
        include: [{
            model: Person,
            through: { attributes: [] },
        }],
    });
};

Team.createTeam = async (name) => {
    sequelize.transaction(async (t) => {
    return await Team.create({ name }, { transaction: t });
});
};

Team.editTeam = async (id, name) => {
    sequelize.transaction(async (t) => {
    const team = await Team.findByPk(id);
    if (team) {
        team.name = name;
        return await team.save({transaction: t});
    }
    return null;
});
};

Team.deleteTeam = async (id) => {
    sequelize.transaction(async (t) => {
    const team = await Team.findByPk(id);
    if (team) {
        await team.setPeople([], {transaction: t}); // Deletes all the member associations first
        return await team.destroy({transaction: t}); //Then the actual team
    }
    return null;
});
};

module.exports = Team;