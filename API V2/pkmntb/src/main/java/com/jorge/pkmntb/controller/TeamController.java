package com.jorge.pkmntb.controller;

import com.jorge.pkmntb.model.Team;
import com.jorge.pkmntb.model.User;
import com.jorge.pkmntb.service.TeamService;
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
@RequestMapping(path = "api/v2/team")
public class TeamController {

    private final TeamService teamService;

    @GetMapping
    public ResponseEntity<List<Team>> getTeams() {
        return ResponseEntity.ok(teamService.getTeams());
    }

    @GetMapping(path = "/{username}")
    public ResponseEntity<Optional<Team>> findTeamByUser(@PathVariable("username") String username) {
        return ResponseEntity.ok(teamService.findTeamByUser(username));
    }
}
