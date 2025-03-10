package com.jorge.pkmntb.controller;

import com.jorge.pkmntb.model.Tournament;
import com.jorge.pkmntb.service.TournamentService;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Optional;

@RestController
@AllArgsConstructor
@RequestMapping(path = "api/v2/tournament")
public class TournamentController {

    private final TournamentService tournamentService;

    @GetMapping
    public ResponseEntity<List<Tournament>> getUsers() {
        return ResponseEntity.ok(tournamentService.getTournaments());
    }

    @GetMapping(path = "/{username}")
    public ResponseEntity<Optional<Tournament>> findTournamentByUser(@PathVariable("username") String username) {
        return ResponseEntity.ok(tournamentService.findTournamentByUser(username));
    }
}
