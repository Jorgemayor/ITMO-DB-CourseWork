package com.jorge.pkmntb.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@Table(
        name = "types"
)
@NoArgsConstructor
@AllArgsConstructor
public class Type {
    @Id
    @SequenceGenerator(
            name = "types_sequence",
            sequenceName = "types_sequence",
            allocationSize = 1
    )
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "types_sequence"
    )
    private Long id;

    @NotNull
    @Size(max=10)
    private String name;

    @NotNull
    private Integer generation;

}
