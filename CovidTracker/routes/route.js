const express = require('express');
const router = express.Router();

// Retrievign contacts
router.get('/contacts', (req, res, next)=>{
    res.send('Retrieving the contact list')
});

// Add contact
router.post('/contact', (req, res, next)=>{

});

router.delete('/contact/:id', (req, res, next)=>{

});



module.exports = router;