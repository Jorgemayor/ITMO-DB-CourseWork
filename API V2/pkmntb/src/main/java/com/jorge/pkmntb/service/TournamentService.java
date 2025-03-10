package com.jorge.pkmntb.service;

import com.jorge.pkmntb.exceptions.UserNotFoundException;
import com.jorge.pkmntb.model.Team;
import com.jorge.pkmntb.model.Tournament;
import com.jorge.pkmntb.model.User;
import com.jorge.pkmntb.repository.TournamentRepository;
import com.jorge.pkmntb.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@AllArgsConstructor
public class TournamentService {

    private final TournamentRepository tournamentRepository;
    private final UserRepository userRepository;

    public List<Tournament> getTournaments() {
        return tournamentRepository.findAll();
    }

    public Optional<Tournament> findTournamentByUser(String username) {
        User user = userRepository.findByUsername(username).orElseThrow(
                () -> new UserNotFoundException("user with email " + username + " does not exists.")
        );
        return tournamentRepository.findTournamentByUser(user);
    }
}
