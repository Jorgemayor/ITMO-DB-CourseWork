package com.jorge.pkmntb.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Entity
@Getter
@Table(
        name = "items"
)
public class Item {
    @Id
    @SequenceGenerator(
            name = "items_sequence",
            sequenceName = "items_sequence",
            allocationSize = 1
    )
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "items_sequence"
    )
    private Integer id;

    @NotNull
    @Size(max=20)
    private String name;

    @NotNull
    private String description;

    @NotNull
    private Integer generation;

    private Integer unavailableFrom;
}
