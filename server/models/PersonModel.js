const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../sequelize'); // Import from sequelize.js
const RoleEnum = require('../enums/RoleEnum');
const GroupEnum = require('../enums/GroupEnum');
// const User = require('./UserModel');


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
      surname: {
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
      UserId: {
        type: DataTypes.INTEGER,
        allowNull: true, // Ensure this matches your requirement
        references: {
          model: 'Users', // Ensure this matches your User model name
          key: 'id',
        },
        onDelete: 'CASCADE',
        onUpdate: 'CASCADE',
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
    },
  );

// Person.belongsTo(User, { foreignKey: 'userId', allowNull: false });
// User.hasOne(Person, { foreignKey: 'userId' });

Person.getAll = async () => {
return await Person.findAll();
};

Person.createPerson = async (firstName, surname, role, group) => {
    console.log("Model");
    console.log(firstName, surname, role, group);
    return await Person.create({ firstName, surname, role, group });
};

Person.findById = async (id) => {
    return await Person.findByPk(id);
}

Person.updatePerson = async (id, firstName, surname, role, group) => {
    const person = await Person.findByPk(id);
    console.log("Model");
    console.log(firstName, surname, role, group);
    if (person) {
        person.firstName = firstName;
        person.surname = surname;
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
Person.findBySurname = async (surname) => {
    return await Person.findOne({ where: { surname } });
};

module.exports = Person;