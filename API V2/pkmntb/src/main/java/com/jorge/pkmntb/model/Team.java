package com.jorge.pkmntb.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import org.hibernate.annotations.ColumnDefault;

@Entity
@Getter
@Table(
        name = "teams"
)
public class Team {

    @Id
    @SequenceGenerator(
            name = "teams_sequence",
            sequenceName = "teams_sequence",
            allocationSize = 1
    )
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "teams_sequence"
    )
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    @NotNull
    private User user;

    @ManyToOne
    @JoinColumn(name = "format_id")
    @NotNull
    private Format format;

    @NotNull
    @Size(max=10)
    private String name;

    @Column(name = "private")
    @ColumnDefault("false")
    private Boolean isPrivate;
}
