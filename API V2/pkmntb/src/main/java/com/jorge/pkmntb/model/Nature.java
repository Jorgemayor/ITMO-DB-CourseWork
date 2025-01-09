package com.jorge.pkmntb.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Entity
@Getter
@Table(
        name = "natures"
)
public class Nature {

    @Id
    @SequenceGenerator(
            name = "natures_sequence",
            sequenceName = "natures_sequence",
            allocationSize = 1
    )
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "formats_sequence"
    )
    private Integer id;

    @NotNull
    @Size(max=10)
    private String name;

    @NotNull
    @Size(min = 3, max = 3)
    private String statUp;

    @NotNull
    @Size(min = 3, max = 3)
    private String statDown;
}
