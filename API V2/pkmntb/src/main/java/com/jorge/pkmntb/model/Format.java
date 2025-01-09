package com.jorge.pkmntb.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Entity
@Getter
@Table(
        name = "formats"
)
public class Format {
    @Id
    @SequenceGenerator(
            name = "formats_sequence",
            sequenceName = "formats_sequence",
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
    private Integer generation;

    @NotNull
    private Integer year;

    @NotNull
    @Column(columnDefinition = "JSON")
    private String rules;
}
