package com.jorge.pkmntb.config;

import com.jorge.pkmntb.model.*;
import com.jorge.pkmntb.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class Populate {

    @Bean
    CommandLineRunner commandLineRunner(
        AbilityRepository abilityRepository,
        FormatRepository formatRepository,
        ItemRepository itemRepository,
        MatchRepository matchRepository,
        NatureRepository natureRepository,
        PokemonRepository pokemonRepository,
        SelectedPokemonRepository selectedPokemonRepository,
        TeamRepository teamRepository,
        TournamentRepository tournamentRepository,
        TypeRepository typeRepository,
        UserRepository userRepository
    ) {
        return args -> {
            Ability ability = new Ability(
                    1,
                    "ability1",
                    7
            );

            Format format = new Format(
                    1,
                    "format1",
                    7,
                    2020,
                    "San Diego format"
            );

            Item item = new Item(
                    1,
                    "item1",
                    "desc",
                    5,
                    8
            );

            Nature nature = new Nature(
                    1,
                    "nature1",
                    "Atk",
                    "Def"
            );

            Type type1 = new Type(
                    1L,
                    "Type1",
                    3
            );

            User user1 = new User(
                    1L,
                    "test",
                    "test1@mail1.com",
                    "123",
                    Role.USER
            );

            Pokemon pokemon1 = new Pokemon(
                    1,
                    "Marill",
                    "{'atk': 3}",
                    type1,
                    type1,
                    ability,
                    ability,
                    ability,
                    4
            );
        };
    }

}
