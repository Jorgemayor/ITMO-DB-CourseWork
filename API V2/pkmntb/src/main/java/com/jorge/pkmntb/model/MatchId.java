package com.jorge.pkmntb.model;

import jakarta.persistence.Embeddable;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.io.Serializable;

@Embeddable
@Getter
public class MatchId implements Serializable {
    @NotNull
    @ManyToOne
    @JoinColumn(name = "tournament_id")
    private Tournament tournament;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "team_1_id")
    private Team team1;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "team_2_id")
    private Team team2;

}
