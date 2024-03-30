const bcrypt = require("bcrypt");
const db = require("../models");
const jwt = require("jsonwebtoken");

const Trainer = db.trainers;

const signup = async (req, res) => {
    try {
        const { username, email, password } = req.body;
        const data = {
            username,
            email,
            password: await bcrypt.hash(password, 10),
        };

        const trainer = await Trainer.create(data);

        if (trainer) {
            //generate token with the trainer's id and the secretKey in the env file
            let token = jwt.sign({ id: trainer.id }, process.env.secretKey, {
                expiresIn: 1 * 24 * 60 * 60 * 1000,
            });

            //set cookie with the token generated
            res.cookie("jwt", token, { maxAge: 1 * 24 * 60 * 60, httpOnly: true });
            console.log("trainer", JSON.stringify(trainer, null, 2));
            console.log(token);
            
            return res.status(201).send(trainer);
        } else {
            return res.status(409).send("Details are not correct");
        }
    } catch (error) {
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
};

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

            if (isSame) {
                //generate token with the trainer's id and the secretKey in the env file
                let token = jwt.sign({ id: trainer.id }, process.env.secretKey, {
                    expiresIn: 1 * 24 * 60 * 60 * 1000,
                });

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
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
};

const loggingOut = (req, res) =>{
    res.cookie('jwt', 0, {maxAge: 0, httpOnly:true})
    res.status(200).json({
        msg: "Logged out",
    })
}

module.exports = {
    signup,
    login,
    loggingOut,
};