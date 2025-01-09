package com.jorge.pkmntb.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Entity
@Getter
@Table(
        name = "abilities"
)
public class Ability {

    @Id
    @SequenceGenerator(
            name = "abilities_sequence",
            sequenceName = "abilities_sequence",
            allocationSize = 1
    )
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "abilities_sequence"
    )
    private Integer id;

    @NotNull
    @Size(max=10)
    private String name;

    @NotNull
    private Integer generation;
}
