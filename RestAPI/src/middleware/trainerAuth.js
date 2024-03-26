const express = require("express");
const db = require("../models");

const Trainer = db.trainers;

//Function to check if username or email already exist in the database
//this is to avoid having two trainers with the same username and email
const saveTrainer = async (req, res, next) => {

    try {
        const username = await Trainer.findOne({
            where: {
                username: req.body.username,
            },
        });

        if (username) return res.json(409).send("Username already taken");

        const emailcheck = await Trainer.findOne({
            where: {
                email: req.body.email,
            },
        });
        
        if (emailcheck) {
            return res.json(409).send("Authentication failed");
        }

        next();
    } catch (error) {
        console.log(error);
    }
};
    
module.exports = {
    saveTrainer,
};