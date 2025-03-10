package com.jorge.pkmntb.repository;

import com.jorge.pkmntb.model.Item;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ItemRepository extends JpaRepository<Item, Integer> {
}
