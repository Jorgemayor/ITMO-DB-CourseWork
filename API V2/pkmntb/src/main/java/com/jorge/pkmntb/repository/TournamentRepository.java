package com.jorge.pkmntb.repository;

import com.jorge.pkmntb.model.Tournament;
import com.jorge.pkmntb.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TournamentRepository extends JpaRepository<Tournament, Integer> {
    Optional<Tournament> findTournamentByUser(User user);
}
