// server/models/GroupModel.js

const { DataTypes } = require('sequelize');
const sequelize = require('../sequelize');
const GroupEnum = require('../enums/GroupEnum');

const Group = sequelize.define(
  'Group',
   {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  name: {
    type: DataTypes.ENUM(GroupEnum),
    allowNull: false,
    unique: true,
  },
});

module.exports = Group;