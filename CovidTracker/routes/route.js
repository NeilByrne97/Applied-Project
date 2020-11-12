const express = require('express');
const router = express.Router();

const Contact = require('../moduls/contacts');

// Retrieving contacts
router.get('/contacts', (req, res, next)=>{
    res.send('Retrieving the contact list');
    res.json(contacts);
});

// Add contact
router.post('/contact', (req, res, next)=>{
    let newContact = new Contact({
        first_name: req.body.first_name,
        last_name: req.body.last_name,
        phone: req.body.phone

    })

    newContact.save((err, contact)=>{
        if(err){
            res.json({msg: 'Failed to add contact'});
        }
        else{
            res.json({msg: 'Contact added successfully'});
        }
    });
});

router.delete('/contact/:id', (req, res, next)=>{

});



module.exports = router;