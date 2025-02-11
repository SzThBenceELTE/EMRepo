const { DataTypes } = require('sequelize');
const sequelize = require("../sequelize");
const StatusEnum = require("../enums/StatusEnum");

const JoiningInfo = sequelize.define(
    'JoiningInfo',{

    status: {
      type: DataTypes.ENUM(StatusEnum),
      allowNull: true, // Change to true if the status can be omitted
    },
    application_time: {
      type: DataTypes.DATE,
      allowNull: true, // This can be null until an application is made
      defaultValue: DataTypes.NOW,
    }},);

module.exports = JoiningInfo;