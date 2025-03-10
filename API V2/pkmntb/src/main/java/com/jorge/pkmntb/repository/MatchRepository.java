package com.jorge.pkmntb.repository;

import com.jorge.pkmntb.model.Match;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MatchRepository  extends JpaRepository<Match, Integer> {
}
