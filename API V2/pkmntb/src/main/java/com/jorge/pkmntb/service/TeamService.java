package com.jorge.pkmntb.service;

import com.jorge.pkmntb.exceptions.UserNotFoundException;
import com.jorge.pkmntb.model.Team;
import com.jorge.pkmntb.model.User;
import com.jorge.pkmntb.repository.TeamRepository;
import com.jorge.pkmntb.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@AllArgsConstructor
public class TeamService {

    private final TeamRepository teamRepository;
    private final UserRepository userRepository;

    public List<Team> getTeams() {
        return teamRepository.findAll();
    }

    public Optional<Team> findTeamByUser(String username) {
        User user = userRepository.findByUsername(username).orElseThrow(
                () -> new UserNotFoundException("user with email " + username + " does not exists.")
        );
        return teamRepository.findTeamsByUser(user);
    }
}
