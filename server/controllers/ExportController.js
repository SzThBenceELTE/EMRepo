const  User  = require('../models/UserModel');
const  Person  = require('../models/PersonModel');
const  Event  = require('../models/EventModel');
const  Team = require('../models/TeamModel');
const {EventParticipants} = require('../models/EventParticipants');

const UserController = require('./UserController');
const PersonController = require('./PersonController');
const EventController = require('./EventController');
const TeamController = require('./TeamController');

const sequelize = require('sequelize');

const ExcelJS = require('exceljs');




exports.exportUsers = async (req, res) => {
    const workbook = new ExcelJS.Workbook();
    console.log('exportUsers');
    const worksheet = workbook.addWorksheet('Users');
    console.log('Worksheet added');
    worksheet.columns = [
        { header: 'Username', key: 'name', width: 32 },
        { header: 'Email', key: 'email', width: 32 },
        { header: 'First Name', key: 'firstName', width: 32 },
        { header: 'Last Name', key: 'lastName', width: 32 },
        { header: 'Role', key: 'role', width: 32 },
        { header: 'Group', key: 'group', width: 32 },
    ];
    console.log('Columns added');

    try {
        const users = await User.findAll();
        console.log('Users fetched');
        users.forEach(user => {
            worksheet.addRow({
                name: user.name,
                email: user.email,
                // firstName: user.Person.firstName,
                // lastName: user.Person.lastName,
                // role: user.Person.role,
                // group: user.Person.group
            });
            console.log('User added' + user.name);
        });
        const filename = 'users.xlsx';
        res.status(200); // explicitly set HTTP status code
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
        await workbook.xlsx.write(res);
        res.end();
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error exporting users' });
    }
}

exports.exportPeople = async (req, res) => {
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('People');

    worksheet.columns = [
        { header: 'Id', key: 'id', width: 32 },
        { header: 'First Name', key: 'firstName', width: 32 },
        { header: 'Last Name', key: 'lastName', width: 32 },
        { header: 'Role', key: 'role', width: 32 },
        { header: 'Group', key: 'group', width: 32 },
    ];

    try{
        const people = await Person.findAll();
        people.forEach(person => {
            worksheet.addRow({
                id: person.id,
                firstName: person.firstName,
                lastName: person.lastName,
                role: person.role,
                group: person.group
            });
        });
        const filename = 'people.xlsx';
        res.status(200); // explicitly set HTTP status code
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
        await workbook.xlsx.write(res);
        res.end();
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error exporting people' });
    }
}

exports.exportEvents = async (req, res) => {
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Events');

    worksheet.columns = [
        { header: 'Id', key: 'id', width: 32 },
        { header: 'Name', key: 'name', width: 32 },
        { header: 'Type', key: 'type', width: 32 },
        { header: 'Start Date', key: 'startDate', width: 32 },
        { header: 'End Date', key: 'endDate', width: 32 },
        { header: 'Maximum Participants', key: 'maxParticipants', width: 32 },
        { header: 'Parent Id', key: 'parentId', width: 32 },
        { header: 'Invited Groups', key: 'groups', width: 64 },
        { header: 'Invited Teams', key: 'teams', width: 64 },
        { header: 'Description', key: 'description', width: 64 },
        { header: 'Location', key: 'location', width: 32 },
    ];

    try {
        const events = await Event.findAll();
        events.forEach(event => {
            worksheet.addRow({
                id: event.id,
                name: event.name,
                type: event.type,
                startDate: event.startDate,
                endDate: event.endDate,
                maxParticipants: event.maxParticipants,
                parentId: event.parentId,
                groups: event.groups,
                teams: event.teams,
                description: event.description,
                location: event.location
            });
        });
        res.status(200); // explicitly set HTTP status code
        const filename = 'events.xlsx';
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
        await workbook.xlsx.write(res);
        res.end();
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error exporting events' });
    }

}

exports.exportTeams = async (req, res) => {
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Teams');

    worksheet.columns = [
        { header: 'Id', key: 'id', width: 32 },
        { header: 'Name', key: 'name', width: 32 },
    ];

    try {
        const teams = await Team.getAll();
        teams.forEach(team => {
            worksheet.addRow({
                id: team.id,
                name: team.name
            });
        });
        const filename = 'teams.xlsx';
        res.status(200); // explicitly set HTTP status code
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
        await workbook.xlsx.write(res);
        res.end();
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error exporting teams' });
    }

}



exports.exportAll = async (req, res) => {
    const workbook = new ExcelJS.Workbook();
    const worksheetPeople = workbook.addWorksheet('People');
    const worksheetEvents = workbook.addWorksheet('Events');
    const worksheetTeams = workbook.addWorksheet('Teams');

    worksheetPeople.columns = [
        { header: 'Id', key: 'id', width: 32 },
        { header: 'First Name', key: 'firstName', width: 32 },
        { header: 'Last Name', key: 'lastName', width: 32 },
        { header: 'Role', key: 'role', width: 32 },
        { header: 'Group', key: 'group', width: 32 },
    ];


    worksheetEvents.columns = [
        { header: 'Id', key: 'id', width: 32 },
        { header: 'Name', key: 'name', width: 32 },
        { header: 'Type', key: 'type', width: 32 },
        { header: 'Start Date', key: 'startDate', width: 32 },
        { header: 'End Date', key: 'endDate', width: 32 },
        { header: 'Maximum Participants', key: 'maxParticipants', width: 32 },
        { header: 'Parent Id', key: 'parentId', width: 32 },
        { header: 'Invited Groups', key: 'groups', width: 64 },
        { header: 'Invited Teams', key: 'teams', width: 64 },
        { header: 'Description', key: 'description', width: 64 },
        { header: 'Location', key: 'location', width: 32 },
    ];

    worksheetTeams.columns = [
        { header: 'Id', key: 'id', width: 32 },
        { header: 'Name', key: 'name', width: 32 },
    ];
}
