package com.jorge.pkmntb.repository;

import com.jorge.pkmntb.model.SelectedPokemon;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SelectedPokemonRepository  extends JpaRepository<SelectedPokemon, Integer> {
}
