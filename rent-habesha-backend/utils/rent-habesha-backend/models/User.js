import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: {
        type: String,
        required: true,
        unique: true,
        match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Invalid email format']
    },
    hash: {
        type: String,
        required: true
    },
    role: {
        type: String,
        enum: ['renter', 'owner', 'admin'],
        default: 'renter'
    },
    phone: {
        type: String,
        validate: {
            validator: function(v) {
            return /^\+?[\d\s-]{10,}$/.test(v);
        },
        message: props => `${props.value} is not a valid phone number!`
        }
    },
    address: { type: String },
    profilePhoto: {
         type: String,
         default: null
    },
    gender: { type: String },
    createdAt: { type: Date, default: Date.now }
});

userSchema.methods.toJSON = function() {
    const user = this.toObject();
    delete user.hash;
    return user;
};

export default mongoose.model('User', userSchema);