const bcrypt = require("bcrypt");
const db = require("../models");
const jwt = require("jsonwebtoken");

const Trainer = db.trainers;

//signing a user up
//hashing users password before its saved to the database with bcrypt
const signup = async (req, res) => {
    try {
        const { username, email, password } = req.body;
        console.log("Before hash")
        const data = {
            username,
            email,
            password: await bcrypt.hash(password, 10),
        };
        console.log("Before create")

        const trainer = await Trainer.create(data);

        //if trainer details is captured
        //generate token with the trainer's id and the secretKey in the env file
        //set cookie with the token generated
        if (trainer) {
        console.log("Before jwt auth")

            let token = jwt.sign({ id: trainer.id }, process.env.secretKey, {
                expiresIn: 1 * 24 * 60 * 60 * 1000,
            });

            res.cookie("jwt", token, { maxAge: 1 * 24 * 60 * 60, httpOnly: true });
            console.log("trainer", JSON.stringify(trainer, null, 2));
            console.log(token);
            
            return res.status(201).send(trainer);
        } else {
            return res.status(409).send("Details are not correct");
        }
    } catch (error) {
        console.log(error);
    }
};

//login authentication
const login = async (req, res) => {
    try {
        const { username, password } = req.body;

        //find a trainer by their username
        const trainer = await Trainer.findOne({
            where: {
                username: username
            }
        });

        //if trainer username is found, compare password with bcrypt
        if (trainer) {
            const isSame = await bcrypt.compare(password, trainer.password);

            //if password is the same
            //generate token with the trainer's id and the secretKey in the env file
            if (isSame) {
                let token = jwt.sign({ id: trainer.id }, process.env.secretKey, {
                    expiresIn: 1 * 24 * 60 * 60 * 1000,
                });

                //if password matches wit the one in the database
                //go ahead and generate a cookie for the trainer
                res.cookie("jwt", token, { maxAge: 1 * 24 * 60 * 60, httpOnly: true });
                console.log("trainer", JSON.stringify(trainer, null, 2));
                console.log(token);
                return res.status(201).send(trainer);
            } else {
                return res.status(401).send("Authentication failed");
            }
        } else {
            return res.status(401).send("Authentication failed");
        }
    } catch (error) {
        console.log(error);
    }
};

const loggingOut = (req, res) =>{
    res.cookie('jwt', 0, {maxAge: 0, httpOnly:true})
    //res.redirect('/')
    res.status(200).json({
        msg: "Logged out",
    })
}

module.exports = {
    signup,
    login,
    loggingOut,
};