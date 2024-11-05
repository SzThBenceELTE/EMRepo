const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../db');
const RoleEnum = require('../enums/RoleEnum');
const GroupEnum = require('../enums/GroupEnum');



const Person = sequelize.define(
    'Person',
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      firstName: {
        type: DataTypes.STRING,
      },
      surnameName: {
        type: DataTypes.STRING,
      },
      role: {
        type: DataTypes.ENUM(RoleEnum),
        allowNull: false,
      },
      group: {
        type: DataTypes.ENUM(GroupEnum),
        allowNull: true,
      },
      
    },
    {
      validate: {
        groupRoleValidation() {
          if (this.role === 'DEVELOPER' && !this.group) {
            throw new Error('Group must be specified if the role is Developer.');
          }
          if (this.role !== 'DEVELOPER' && this.group) {
            throw new Error('Group can only be specified if the role is Developer.');
          }
        }
      }
    }
  );

Person.getAll = async () => {
return await Person.findAll();
};

Person.createPerson = async (firstName, surnameName, role, group) => {
    return await Person.create({ firstName, surnameName, role, group });
};

Person.findById = async (id) => {
    return await Person.findByPk(id);
}

Person.updatePerson = async (id, firstName, surnameName, role, group) => {
    const person = await Person.findByPk(id);
    if (person) {
        person.firstName = firstName;
        person.surnameName = surnameName;
        person.role = role;
        person.group = group;
        return await person.save();
    }
    return null; // Person not found
};

Person.deletePerson = async (id) => {
    const person = await Person.findByPk(id);
    if (person) {
        return await person.destroy();
    }
    return null; // Person not found
};

module.exports = Person;