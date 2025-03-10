package com.jorge.pkmntb.repository;

import com.jorge.pkmntb.model.Team;
import com.jorge.pkmntb.model.User;
import jakarta.validation.constraints.NotNull;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TeamRepository  extends JpaRepository<Team, Integer> {
    Optional<Team> findTeamByName(@NotNull String name);
    Optional<Team> findTeamsByUser(@NotNull User user);
}
