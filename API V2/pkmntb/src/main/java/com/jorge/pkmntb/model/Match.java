package com.jorge.pkmntb.model;

import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.PrePersist;
import lombok.Getter;

@Entity
@Getter
public class Match {

    @EmbeddedId
    private MatchId id;

    private Long winner;

    @PrePersist
    public void validate() {
        Long idTeam1 = id.getTeam1().getId();
        Long idTeam2 = id.getTeam2().getId();
        if (idTeam1.equals(idTeam2)) {
            throw new IllegalArgumentException("Both teams cannot be the same.");
        }
        if (!(winner.equals(idTeam1) || winner.equals(idTeam2))) {
            winner = 0L;
        }
    }

}
