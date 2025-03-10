package com.jorge.pkmntb.repository;

import com.jorge.pkmntb.model.Type;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TypeRepository  extends JpaRepository<Type, Integer> {
}
