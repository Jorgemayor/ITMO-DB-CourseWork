package com.jorge.pkmntb.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Entity
@Getter
@Table(
        name = "pokemon"
)
public class Pokemon {
    @Id
    @SequenceGenerator(
            name = "pokemon_sequence",
            sequenceName = "pokemon_sequence",
            allocationSize = 1
    )
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "pokemon_sequence"
    )
    private Integer id;

    @NotNull
    private String name;

    @NotNull
    @Column(name = "base_stats", columnDefinition = "JSON")
    private String baseStats;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "type_1_id")
    private Type type1;

    @ManyToOne
    @JoinColumn(name = "type_2_id")
    private Type type2;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "ability_1_id")
    private Ability ability1;

    @ManyToOne
    @JoinColumn(name = "ability_2_id")
    private Ability ability2;

    @ManyToOne
    @JoinColumn(name = "hidden_ability_id")
    private Ability hiddenAbility;

    @NotNull
    private Integer generation;

}
