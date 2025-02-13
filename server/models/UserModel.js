const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../sequelize'); // Import from sequelize.js

// Define the User model
const User = sequelize.define(
  'User', 
  {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false, // Add validation if needed
    },
    email: {
        type: DataTypes.STRING,
        unique: true,
        allowNull: false, // Add validation if needed
    },
    password: {
        type: DataTypes.STRING,
        allowNull: false, // Add validation if needed
    }, 
},
);



// CRUD operations
User.getAll = async () => {
    return await User.findAll();
};

User.createUser = async (name, email, password) => {
    sequelize.transaction(async (t) => {
        return await User.create({ name, email, password },
                                    {transaction: t});
    });
};

User.findById = async (id) => {
    console.log('finbyid - id:', id);
    return await User.findByPk(id);
};

User.findByEmail = async (email) => {
    console.log('finbyemail - email:', email);
    return await User.findOne({ where: { email } });
}

User.findByName = async (name) => {
    console.log('finbyname - name:', name);
    return await User.findOne({ where: { name } });
}


User.updateUser = async (id, name, email) => {
    sequelize.transaction(async (t) => {
        const user = await User.findByPk(id);
        if (user) {
            user.name = name;
            user.email = email;
            return await user.save({ transaction: t });
        }
    return null; // User not found
    });
};

User.deleteUser = async (id) => {
    sequelize.transaction(async (t) => {
    const user = await User.findByPk(id);
    if (user) {
        return await user.destroy();
    }
    return null; // User not found
});
};

module.exports = User;
