package com.jorge.pkmntb.controllers;

import com.jorge.pkmntb.models.Trainer;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TrainerController {



    @GetMapping("/trainers")
    public void getTrainers() {

    }

    @PostMapping("/trainers")
    public void addTrainer(@RequestBody Trainer trainer) {

    }
}
