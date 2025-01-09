package com.jorge.pkmntb.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;

@Entity
@Getter
@Setter
@Table(
        name = "selected_pokemon"
)
public class SelectedPokemon {
    @Id
    @SequenceGenerator(
            name = "selected_pokemon_sequence",
            sequenceName = "selected_pokemon_sequence",
            allocationSize = 1
    )
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "selected_pokemon_sequence"
    )
    private Integer id;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "pokemon_id")
    private Pokemon pokemon;

    @Size(max=20)
    private String nickname;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "team_id")
    private Team team;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "ability_id")
    private Ability ability;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "nature_id")
    private Nature nature;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "item_id")
    private Item item;

    @NotNull
    @Column(columnDefinition = "JSON")
    private String moveset;

    @NotNull
    @Column(columnDefinition = "JSON")
    private String ivs;

    @NotNull
    @Column(columnDefinition = "JSON")
    private String evs;

    @NotNull
    @ColumnDefault("false")
    private Boolean isShiny;
}
