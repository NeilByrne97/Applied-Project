const mongoose = require('mongoose');


const ContactSchema = mongoose.Schema({
    first_name:{
        type: String,
        required: true
    },
    last_name:{
        type: String,
        required: true
    },
    phone:{
        type: String,
        required: true
    },
    email:{
        type: String,
        required: true
    },
    timestamp : {
        type: Date, default: Date.now

    }

});

const Contact = module.exports = mongoose.model('Contact', ContactSchema);