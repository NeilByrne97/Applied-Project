var express = require('express');
var mongoose = require('mongoose');
var bodyparser = require('body-parser');
var cors = require('cors');
var path = require('path');

var app = express();

const route = require('./routes/route');

// Connect to mongoDB
mongoose.connect('mongodb://localhost:27017/contactlist');

// On Connection
mongoose.connection.on('connected', ()=>{
    console.log('Connected to database mongodb @ 27017');
});

mongoose.connection.on('error', (err)=>{
    if(err){
        console.log('Error in database connection: ' + err);
    }
});

// Port number
const port = 3000;

// Middleware
app.use(cors());

// Body - parser
app.use(bodyparser.json());

// Static files
app.use(express.static(path.join(__dirname, 'public')));

// routes
app.use('/api', route);

// Test server
app.get('/', (req, res)=>{
    res.send('hello world')
});


app.listen(port,()=>{
    console.log('Server started at port: ' + port);
});