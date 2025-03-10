package com.jorge.pkmntb.repository;

import com.jorge.pkmntb.model.Nature;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NatureRepository  extends JpaRepository<Nature, Integer> {
}
