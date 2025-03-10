package com.jorge.pkmntb.repository;

import com.jorge.pkmntb.model.Pokemon;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PokemonRepository  extends JpaRepository<Pokemon, Integer> {
}
