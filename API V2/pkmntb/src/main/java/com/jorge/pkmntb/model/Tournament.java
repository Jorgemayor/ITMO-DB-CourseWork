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
        name = "tournaments"
)
@NoArgsConstructor
@AllArgsConstructor
public class Tournament {
    @Id
    @SequenceGenerator(
            name = "tournaments_sequence",
            sequenceName = "tournaments_sequence",
            allocationSize = 1
    )
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "tournaments_sequence"
    )
    private Long id;

    @NotNull
    @Size(max=25)
    private String name;

    @ManyToOne
    @JoinColumn(name = "format_id")
    @NotNull
    private Format format;
}
